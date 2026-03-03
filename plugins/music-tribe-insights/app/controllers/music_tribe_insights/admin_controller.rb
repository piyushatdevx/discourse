# frozen_string_literal: true

module MusicTribeInsights
  class AdminController < ::Admin::StaffController
    requires_plugin MusicTribeInsights::PLUGIN_NAME

    def refresh
      load_insights_job
      Jobs.enqueue(Jobs::MusicTribeInsightsGenerateInsights)
      render json: { success: true, message: I18n.t("music_tribe_insights.job.enqueued") }
    rescue StandardError => e
      Rails.logger.warn(
        "MusicTribeInsights refresh failed: #{e.class} #{e.message}\n#{e.backtrace.first(5).join("\n")}",
      )
      render json: { success: false, error: e.message }, status: :internal_server_error
    end

    def index
      data = PluginStore.get(MusicTribeInsights::PLUGIN_NAME, MusicTribeInsights::STORE_KEY)
      base = data.presence || {}
      report_types = base["report_types"] || []
      report_types = enrich_report_types_with_titles(report_types)
      payload = {
        report_types: report_types,
        generated_at: base["generated_at"],
        posts_analyzed: base["posts_analyzed"],
        days_analyzed: base["days_analyzed"],
        max_posts: base["max_posts"],
      }
      render json: payload
    end

    private

    def load_insights_job
      job_path =
        File.expand_path("../../jobs/regular/music_tribe_insights_generate_insights.rb", __dir__)
      require job_path if File.exist?(job_path)
    end

    def build_topic_summaries(post_details)
      return [] if post_details.blank?

      by_topic = post_details.group_by { |d| d["topic_id"] }
      by_topic.filter_map do |topic_id, details|
        next if topic_id.blank?
        first = details.first
        {
          "topic_id" => topic_id,
          "topic_slug" => first["topic_slug"],
          "title" => first["title"].to_s.sub(/\s+\(post \d+\)\z/, "").strip,
          "post_count" => details.size,
        }
      end
    end

    def disambiguate_titles(post_details)
      return post_details if post_details.blank?

      titles = post_details.map { |d| d["title"] }
      title_counts = titles.tally
      post_details.map do |d|
        d = d.dup
        if title_counts[d["title"]] && title_counts[d["title"]] > 1
          d["title"] = "#{d["title"]} (post #{d["id"]})"
          d["short_label"] = "Post ##{d["id"]}"
        else
          d["short_label"] = d["title"]
        end
        d
      end
    end

    def enrich_report_types_with_titles(report_types)
      post_ids = report_types.flat_map { |r| r["post_ids"] || [] }.compact.uniq
      return report_types if post_ids.empty?

      posts_by_id = Post.where(id: post_ids).where(deleted_at: nil).includes(:topic).index_by(&:id)

      report_types.map do |r|
        r = r.dup
        seen = Set.new
        r["post_details"] = (r["post_ids"] || []).uniq.filter_map do |id|
          next if seen.include?(id)
          seen.add(id)
          post = posts_by_id[id.to_i]
          next unless post
          topic = post.topic
          next unless topic
          title = topic.title.presence || I18n.t("music_tribe_insights.post_fallback", id: id)
          {
            "id" => id,
            "title" => title.to_s.truncate(120),
            "topic_id" => topic.id,
            "topic_slug" => topic.slug,
          }
        end
        r["post_details"] = disambiguate_titles(r["post_details"])
        r["topic_summaries"] = build_topic_summaries(r["post_details"])
        r
      end
    end
  end
end
