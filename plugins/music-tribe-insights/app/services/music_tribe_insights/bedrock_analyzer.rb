# frozen_string_literal: true

module MusicTribeInsights
  class BedrockAnalyzer
    def self.call
      new.run
    end

    def run
      posts_data = fetch_posts_for_analysis
      return store_empty(0) if posts_data.empty?

      prompt = build_prompt(posts_data)
      response_json = invoke_bedrock(prompt)
      report_types = parse_response(response_json, posts_data)
      report_types = report_types.reject { |r| (r["count"] || 0).zero? }
      store_result(report_types, posts_data.size)
    rescue Aws::BedrockRuntime::Errors::ServiceError, Aws::Errors::ServiceError => e
      Rails.logger.warn("MusicTribeInsights::BedrockAnalyzer failed: #{e.message}")
      raise StandardError, I18n.t("music_tribe_insights.errors.bedrock_failed", message: e.message)
    end

    private

    def fetch_posts_for_analysis
      days = SiteSetting.music_tribe_insights_days_to_analyze
      limit = SiteSetting.music_tribe_insights_max_posts
      min_posts = SiteSetting.music_tribe_insights_min_posts_per_theme

      Post
        .joins(:topic)
        .where(post_type: Post.types[:regular])
        .where(hidden: false)
        .where(deleted_at: nil)
        .where("posts.post_number = 1")
        .where("posts.created_at > ?", days.days.ago)
        .where("topics.archetype = ?", Archetype.default)
        .where("topics.deleted_at IS NULL")
        .order("posts.created_at DESC")
        .limit(limit)
        .pluck(:id, :raw, "topics.title", "topics.id")
        .map do |post_id, raw, topic_title, topic_id|
          excerpt = raw.present? ? raw.to_s.truncate(400) : ""
          {
            post_id: post_id,
            topic_id: topic_id,
            topic_title: topic_title.to_s.truncate(120),
            excerpt: excerpt,
          }
        end
    end

    def build_prompt(posts_data)
      min_posts = SiteSetting.music_tribe_insights_min_posts_per_theme
      posts_text =
        posts_data
          .each_with_index
          .map do |p, i|
            "[#{i + 1}] (post_id=#{p[:post_id]} topic_id=#{p[:topic_id]}) " \
              "Topic: #{p[:topic_title]}\nContent: #{p[:excerpt]}"
          end
          .join("\n\n")

      <<~PROMPT
        You are analyzing TOPICS from a music community forum (Music Tribe). Each item below is ONE TOPIC (its opening post only). Identify recurring themes: when many TOPICS are about the same issue or subject (e.g. same guitar problem, same question), group them.

        Rules:
        - Only report a theme if at least #{min_posts} TOPICS clearly relate to it. Do not count replies/comments — each item is a different topic.
        - Focus on: product/gear issues, common questions, feature requests, bugs, or repeated subjects across topics.
        - For each report type provide: a short "type" label (e.g. "Guitar X buzzing issue"), "summary" (1-2 sentences), "count" (number of topics in this theme), and "post_ids" (array of the opening post IDs — one per topic — that belong to this theme).

        Return valid JSON only, no markdown. Format:
        {"report_types": [{"type": "...", "summary": "...", "count": N, "post_ids": [1,2,3]}, ...]}

        Topics to analyze (one opening post per topic):

        #{posts_text}
      PROMPT
    end

    def invoke_bedrock(prompt)
      region = SiteSetting.music_tribe_insights_aws_region.presence || "ap-south-1"
      model_id =
        SiteSetting.music_tribe_insights_model_id.presence ||
          "anthropic.claude-3-haiku-20240307-v1:0"

      Rails.logger.info("[MusicTribeInsights] Invoking Bedrock region=#{region} model=#{model_id}")
      Rails.logger.info(
        "[MusicTribeInsights] Request sent to AI (prompt length=#{prompt.length} chars). First 2500 chars: #{prompt.truncate(2500)}",
      )

      client = Aws::BedrockRuntime::Client.new(region: region)
      body = {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 2048,
        temperature: 0.3,
        messages: [{ role: "user", content: prompt }],
      }.to_json

      response =
        client.invoke_model(
          body: body,
          model_id: model_id,
          content_type: "application/json",
          accept: "application/json",
        )
      body_str = response.body.respond_to?(:read) ? response.body.read : response.body.to_s
      result = JSON.parse(body_str)
      text = result.dig("content", 0, "text")
      if text.blank?
        Rails.logger.info("[MusicTribeInsights] Response from AI: (empty)")
        return "{\"report_types\":[]}"
      end
      parsed = text.strip.sub(/\A```(?:json)?\s*/, "").sub(/\s*```\z/, "")
      Rails.logger.info("[MusicTribeInsights] Response from AI: #{parsed}")
      parsed
    end

    def parse_response(response_json, posts_data)
      data = JSON.parse(response_json)
      types = data["report_types"] || data[:report_types] || []
      types = types.first(20) if types.size > 20
      valid_post_ids = posts_data.map { |p| p[:post_id] }.to_set
      types.map do |t|
        raw_ids = Array(t["post_ids"]).first(50).map(&:to_i)
        post_ids = raw_ids.select { |id| valid_post_ids.include?(id) }
        {
          "type" => t["type"].to_s.presence || "Uncategorized",
          "summary" => t["summary"].to_s.presence || "",
          "count" => post_ids.size,
          "post_ids" => post_ids,
        }
      end
    rescue JSON::ParserError
      []
    end

    def store_empty(posts_analyzed = 0)
      days = SiteSetting.music_tribe_insights_days_to_analyze
      max_posts = SiteSetting.music_tribe_insights_max_posts
      PluginStore.set(
        MusicTribeInsights::PLUGIN_NAME,
        MusicTribeInsights::STORE_KEY,
        "report_types" => [],
        "generated_at" => Time.zone.now.iso8601,
        "posts_analyzed" => posts_analyzed,
        "days_analyzed" => days,
        "max_posts" => max_posts,
      )
    end

    def store_result(report_types, posts_analyzed)
      days = SiteSetting.music_tribe_insights_days_to_analyze
      max_posts = SiteSetting.music_tribe_insights_max_posts
      PluginStore.set(
        MusicTribeInsights::PLUGIN_NAME,
        MusicTribeInsights::STORE_KEY,
        "report_types" => report_types,
        "generated_at" => Time.zone.now.iso8601,
        "posts_analyzed" => posts_analyzed,
        "days_analyzed" => days,
        "max_posts" => max_posts,
      )
    end
  end
end
