# frozen_string_literal: true

# name: fantribe-theme
# about: FanTribe social platform design system — glassmorphism UI, brand tokens, and component styles
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe/discourse

enabled_site_setting :fantribe_theme_enabled

# Load WaveSurfer.js from CDN for audio waveform visualization
register_html_builder("server:before-head-close") do |controller|
  "<script src='https://unpkg.com/wavesurfer.js@7/dist/wavesurfer.min.js' nonce='#{controller.helpers.csp_nonce_placeholder}'></script>"
end

# Allow unpkg CDN in Content Security Policy
extend_content_security_policy(script_src: %w[https://unpkg.com])

# Register SVG icons that remain as Discourse d-icons (no ft-icon equivalent)
register_svg_icon "user"
register_svg_icon "arrow-right-to-bracket"
register_svg_icon "location-dot"
# Icons for new features (trending panel, profile tabs, bookmark fill)
register_svg_icon "trending-up"
register_svg_icon "shopping-bag"
register_svg_icon "package"
register_svg_icon "microphone"
register_svg_icon "paperclip"
register_svg_icon "bolt"

# Common styles (all viewports)
register_asset "stylesheets/common/design-tokens.scss"
register_asset "stylesheets/common/typography.scss"
register_asset "stylesheets/common/glassmorphism.scss"
register_asset "stylesheets/common/buttons.scss"
register_asset "stylesheets/common/inputs.scss"
register_asset "stylesheets/common/cards.scss"
register_asset "stylesheets/common/avatars.scss"
register_asset "stylesheets/common/badges.scss"
register_asset "stylesheets/common/navigation.scss"
register_asset "stylesheets/common/overlays.scss"
register_asset "stylesheets/common/feedback.scss"
register_asset "stylesheets/common/layout.scss"
register_asset "stylesheets/common/login-signup.scss"
register_asset "stylesheets/common/auth.scss"

# Component styles (Phase 2.1 - Header)
register_asset "stylesheets/common/components/header.scss"
register_asset "stylesheets/common/components/mobile-nav.scss"

# App-level layout (persistent sidebar + main content grid)
register_asset "stylesheets/common/components/app-layout.scss"

# Component styles (Phase 2.2 - Feed View)
register_asset "stylesheets/common/components/feed-layout.scss"
register_asset "stylesheets/common/components/tribes-panel.scss"
register_asset "stylesheets/common/components/trending-panel.scss"
register_asset "stylesheets/common/components/mobile-tribe-chips.scss"
register_asset "stylesheets/common/components/feed-card.scss"
register_asset "stylesheets/common/components/compose-box.scss"

# Component styles (Phase 2.3 - Feed V1 Components)
register_asset "stylesheets/common/feed-animations.scss"
register_asset "stylesheets/common/components/avatar.scss"
register_asset "stylesheets/common/components/badge.scss"
register_asset "stylesheets/common/components/gear-pill.scss"
register_asset "stylesheets/common/components/support-bubble.scss"
register_asset "stylesheets/common/components/reaction-bar.scss"
register_asset "stylesheets/common/components/post-menu.scss"
register_asset "stylesheets/common/components/right-sidebar.scss"
register_asset "stylesheets/common/components/create-menu.scss"
register_asset "stylesheets/common/components/create-post-modal.scss"
register_asset "stylesheets/common/components/engagement-bar.scss"
register_asset "stylesheets/common/components/media.scss"

# Chat theme customization (Phase 3 - Chat UI)
register_asset "stylesheets/common/chat.scss"
register_asset "stylesheets/common/components/tribe-header.scss"
register_asset "stylesheets/common/components/tribe-page.scss"
register_asset "stylesheets/common/components/user-profile.scss"
register_asset "stylesheets/common/components/notifications.scss"
register_asset "stylesheets/common/components/profile-modals.scss"
register_asset "stylesheets/common/components/filters-modal.scss"
register_asset "stylesheets/common/components/search-modal.scss"
register_asset "stylesheets/common/components/flag-modal.scss"
register_asset "stylesheets/common/components/preferences.scss"
register_asset "stylesheets/common/components/composer.scss"
register_asset "stylesheets/common/components/full-post.scss"

# Discourse overrides - MUST load last
register_asset "stylesheets/common/fantribe-overrides.scss"

# Desktop-specific styles
register_asset "stylesheets/desktop/desktop.scss", :desktop

# Mobile-specific styles
register_asset "stylesheets/mobile/mobile.scss", :mobile

# Enable serialization of first_post_id, op_liked, and op_can_like for feed card likes
register_modifier(:serialize_topic_op_likes_data) { true }

# Preload first_post uploads to avoid N+1 queries when serializing image_urls
register_topic_preloader_associations({ first_post: :uploads }) do
  SiteSetting.fantribe_theme_enabled
end

# Preload first_post reactions + reaction_users for the engagement bar
# (only when discourse-reactions is active — guarded in the serializer too)
register_topic_preloader_associations({ first_post: { reactions: :reaction_users } }) do
  SiteSetting.fantribe_theme_enabled && SiteSetting.respond_to?(:discourse_reactions_enabled) &&
    SiteSetting.discourse_reactions_enabled
end

# Preload posts with users for inline comments preview in feed cards
register_topic_preloader_associations({ posts: :user }) { SiteSetting.fantribe_theme_enabled }

after_initialize do
  # POST /fantribe/topics/:id/view
  # Records a topic view synchronously and returns the updated view count.
  # Discourse's standard view tracking is deferred (background job), so the
  # route-model response always carries the pre-visit count. This endpoint
  # runs TopicViewItem.add inline and immediately returns the fresh `views`
  # value so the full-page component can display it without a race condition.
  Discourse::Application.routes.prepend do
    post "fantribe/topics/:topic_id/view" => "fantribe_theme/topic_views#record",
         :constraints => {
           topic_id: /\d+/,
         }
  end

  module ::FantribeTheme
    class TopicViewsController < ::ApplicationController
      requires_plugin "fantribe-theme"

      def record
        topic = Topic.find_by(id: params[:topic_id].to_i)
        raise Discourse::NotFound if topic.nil?
        raise Discourse::InvalidAccess unless guardian.can_see?(topic)

        TopicViewItem.add(topic.id, request.remote_ip, current_user&.id)
        render json: { views: Topic.where(id: topic.id).pick(:views) }
      end
    end
  end

  # GET /fantribe/trending_tribes.json
  # Returns top 5 tribes by post count. Previously embedded in the site
  # serializer (bootstrap JSON on every page). Now fetched on-demand by
  # sidebar components, reducing the initial payload on non-feed pages.
  # Uses the same ft_top_tribes_by_posts cache key and 10-minute TTL.
  Discourse::Application.routes.prepend do
    get "fantribe/trending_tribes" => "fantribe_theme/trending_tribes#index"
  end

  module ::FantribeTheme
    class TrendingTribesController < ::ApplicationController
      requires_plugin "fantribe-theme"

      def index
        return render json: { trending_tribes: [] } unless SiteSetting.fantribe_theme_enabled

        tribes =
          Rails
            .cache
            .fetch("ft_top_tribes_by_posts", expires_in: 10.minutes) do
              top_categories =
                Category
                  .where(read_restricted: false)
                  .where.not(id: SiteSetting.uncategorized_category_id)
                  .order(post_count: :desc)
                  .limit(5)

              next [] if top_categories.empty?

              member_counts =
                CategoryUser
                  .where(category_id: top_categories.map(&:id))
                  .where("notification_level >= ?", CategoryUser.notification_levels[:watching])
                  .group(:category_id)
                  .count

              top_categories.map do |cat|
                {
                  id: cat.id,
                  name: cat.name,
                  slug: cat.slug,
                  color: cat.color,
                  logo_url: cat.uploaded_logo&.url,
                  member_count: member_counts[cat.id].to_i,
                  post_count: cat.post_count,
                }
              end
            end

        render json: { trending_tribes: tribes }
      rescue StandardError
        render json: { trending_tribes: [] }
      end
    end
  end

  # Preload first_post.uploads for search results to avoid N+1 queries when
  # serializing image_urls in SearchTopicListItemSerializer
  Search.on_preload do |results, _search|
    next unless SiteSetting.fantribe_theme_enabled

    topics = results.posts&.map(&:topic)&.compact&.uniq
    next if topics.blank?

    # Preload first_post association on topics
    ActiveRecord::Associations::Preloader.new(records: topics, associations: :first_post).call

    # Then preload uploads on the first_posts
    first_posts = topics.filter_map(&:first_post)
    if first_posts.present?
      ActiveRecord::Associations::Preloader.new(records: first_posts, associations: :uploads).call
    end
  end

  # Auto-configure discourse-reactions for FanTribe's engagement bar.
  # Uses the same "unless already set" pattern as the OAuth settings below
  # so admin changes made through the UI are never overwritten on reboot.
  if SiteSetting.fantribe_theme_enabled && SiteSetting.respond_to?(:discourse_reactions_enabled)
    SiteSetting.discourse_reactions_enabled = true unless SiteSetting.discourse_reactions_enabled

    # Only replace the emoji set if it's still Discourse's factory default —
    # meaning nobody has customised it yet.
    discourse_default_reactions = "+1|laughing|open_mouth|clap|confetti_ball|hugs"
    if SiteSetting.discourse_reactions_enabled_reactions == discourse_default_reactions
      SiteSetting.discourse_reactions_enabled_reactions = "heart|fire|clap|musical_note"
    end

    # heart is already the default reaction_for_like but make it explicit
    if SiteSetting.discourse_reactions_reaction_for_like.blank?
      SiteSetting.discourse_reactions_reaction_for_like = "heart"
    end

    # Reactions use the like rate limiter. Raise the daily limit so users on
    # an engagement-heavy platform aren't blocked after a few posts.
    # Todo: Need to change this when going to prod
    SiteSetting.max_likes_per_day = 500 if SiteSetting.max_likes_per_day < 500
  end

  # Remove the daily bookmark cap — FanTribe encourages saving content and the
  # Discourse default of 20 bookmarks/day is too restrictive for a social platform.
  # 0 = unlimited. Only set if not already unlimited.
  if SiteSetting.fantribe_theme_enabled
    SiteSetting.max_bookmarks_per_day = 0 if SiteSetting.max_bookmarks_per_day.nonzero?
  end

  # Allow video uploads — FanTribe is a content platform; creators need to share
  # video. Discourse's default authorized_extensions excludes all video formats.
  # We append the common video types without touching formats already present.
  # Also raise the attachment size cap to 512 MB to accommodate video files.
  if SiteSetting.fantribe_theme_enabled
    video_extensions = %w[mp4 mov webm avi mkv m4v 3gp]
    current = SiteSetting.authorized_extensions.to_s.split("|")
    missing = video_extensions.reject { |ext| current.include?(ext) }
    SiteSetting.authorized_extensions = (current + missing).join("|") if missing.any?

    # 512 MB — generous for long-form video; admins can lower via the UI.
    SiteSetting.max_attachment_size_kb = 524_288 if SiteSetting.max_attachment_size_kb < 524_288
  end

  # Enable tagging so posts can have tags
  if SiteSetting.fantribe_theme_enabled
    SiteSetting.tagging_enabled = true unless SiteSetting.tagging_enabled
    SiteSetting.max_tags_per_topic = 3 if SiteSetting.max_tags_per_topic > 3 ||
      SiteSetting.max_tags_per_topic == 0
    # Allow all users to create and apply free-form tags.
    # Discourse moved from trust-level checks to group-list checks; the old
    # min_trust_to_create_tag setting is no longer used. Group 10 = trust_level_0
    # which includes every registered user.
    if SiteSetting.respond_to?(:create_tag_allowed_groups)
      groups = SiteSetting.create_tag_allowed_groups.to_s.split("|")
      SiteSetting.create_tag_allowed_groups = (groups | ["10"]).join("|") if groups.exclude?("10")
    end
    if SiteSetting.respond_to?(:tag_topic_allowed_groups)
      groups = SiteSetting.tag_topic_allowed_groups.to_s.split("|")
      SiteSetting.tag_topic_allowed_groups = (groups | ["10"]).join("|") if groups.exclude?("10")
    end
    # Allow posts to be edited at any time — FanTribe is a social platform
    # where authors should always be able to update their content.
    # 0 = unlimited (Discourse default is 43200 minutes = 30 days).
    SiteSetting.post_edit_time_limit = 0
  end

  # Default-enable auth settings when FanTribe is active
  if SiteSetting.fantribe_theme_enabled
    SiteSetting.login_required = true unless SiteSetting.login_required

    # Google OAuth
    SiteSetting.enable_google_oauth2_logins = true unless SiteSetting.enable_google_oauth2_logins
    if ENV["GOOGLE_OAUTH2_CLIENT_ID"].present?
      SiteSetting.google_oauth2_client_id = ENV["GOOGLE_OAUTH2_CLIENT_ID"]
    end
    if ENV["GOOGLE_OAUTH2_CLIENT_SECRET"].present?
      SiteSetting.google_oauth2_client_secret = ENV["GOOGLE_OAUTH2_CLIENT_SECRET"]
    end

    # Facebook OAuth
    SiteSetting.enable_facebook_logins = true unless SiteSetting.enable_facebook_logins
    SiteSetting.facebook_app_id = ENV["FACEBOOK_APP_ID"] if ENV["FACEBOOK_APP_ID"].present?
    if ENV["FACEBOOK_APP_SECRET"].present?
      SiteSetting.facebook_app_secret = ENV["FACEBOOK_APP_SECRET"]
    end
  end

  # Enable video uploads when fantribe theme is enabled
  if SiteSetting.fantribe_theme_enabled
    video_extensions = %w[mp4 mov webm ogv m4v 3gp avi mpeg]
    current_extensions = SiteSetting.authorized_extensions.to_s.split("|").map(&:strip)

    missing_extensions = video_extensions - current_extensions
    if missing_extensions.any?
      new_extensions = (current_extensions + missing_extensions).uniq.join("|")
      SiteSetting.authorized_extensions = new_extensions
    end

    # Enable video thumbnails if not already enabled
    SiteSetting.video_thumbnails_enabled = true unless SiteSetting.video_thumbnails_enabled
  end

  # Allow audio uploads — FanTribe creators need to share audio content.
  # Add common audio formats to authorized_extensions.
  if SiteSetting.fantribe_theme_enabled
    audio_extensions = %w[mp3 aac wav m4a ogg oga opus flac]
    current_extensions = SiteSetting.authorized_extensions.to_s.split("|").map(&:strip)

    missing_extensions = audio_extensions - current_extensions
    if missing_extensions.any?
      new_extensions = (current_extensions + missing_extensions).uniq.join("|")
      SiteSetting.authorized_extensions = new_extensions
    end
  end

  # Remove the reaction undo time window so users can change/remove reactions
  # at any time. Discourse core enforces post_undo_action_window_mins (default
  # 10 min) on both custom emoji reactions (via ReactionUser#can_undo?) and
  # the heart/like (via Guardian#can_delete_post_action?). We bypass both
  # checks when FanTribe is active while keeping all other guards intact
  # (own post, not a PM, not archived).
  if defined?(DiscourseReactions)
    module ::FantribeTheme
      module ReactionUserExtension
        def can_undo?
          return true if SiteSetting.fantribe_theme_enabled
          super
        end
      end

      module GuardianExtension
        # Allow custom emoji reactions on own posts when FanTribe is enabled (core
        # blocks liking own posts via post_can_act?(post, :like)).
        def can_use_reactions?(post)
          if SiteSetting.fantribe_theme_enabled && authenticated? && post && is_my_own?(post)
            return true
          end
          super
        end

        def can_delete_post_action?(post_action)
          return super unless SiteSetting.fantribe_theme_enabled
          # Same ownership / privacy / archive checks as core — just no time window.
          return false unless is_my_own?(post_action) && !post_action.is_private_message?
          !post_action.post&.topic&.archived?
        end
      end

      # Each reaction switch removes the old shadow like and creates a new one.
      # PostActionDestroyer and PostActionCreator share the same rate limit key
      # ("post_action-{post_id}_{type_id}", 4 ops/minute). Each switch consumes
      # 2 ops (1 remove + 1 create), so after 2 switches the 4-op limit is
      # exhausted and the 3rd switch raises LimitExceeded in remove_shadow_like —
      # before add_shadow_like is ever called. Admins bypass rate limiters.
      # We rescue in both places so the ReactionUser record changes always commit;
      # the shadow PostAction may become temporarily stale but emoji counts stay
      # correct.
      module ReactionManagerExtension
        private

        def remove_shadow_like
          return super unless SiteSetting.fantribe_theme_enabled
          begin
            super
          rescue RateLimiter::LimitExceeded
            # The destroy-side rate limit fired — leave the shadow like in place.
            # The ReactionUser change is still committed in the outer transaction.
          end
        end

        def add_shadow_like(notify: true)
          return super unless SiteSetting.fantribe_theme_enabled
          begin
            super
          rescue RateLimiter::LimitExceeded
            # The create-side rate limit fired — skip the shadow like silently.
            # Still send the reaction notification since the ReactionUser was saved.
            add_reaction_notification if notify
          end
        end
      end
    end

    reloadable_patch do
      DiscourseReactions::ReactionUser.prepend(FantribeTheme::ReactionUserExtension)
      Guardian.prepend(FantribeTheme::GuardianExtension)
      DiscourseReactions::ReactionManager.prepend(FantribeTheme::ReactionManagerExtension)
    end
  end

  # Allow topic authors to close/open their own topics (Turn Off Comments).
  # Core guardian requires staff or TL4 for this in some versions; we relax
  # the check to any authenticated topic owner when FanTribe is active.
  module ::FantribeTheme
    module GuardianTopicCloseExtension
      def can_close_topic?(topic)
        return super unless SiteSetting.fantribe_theme_enabled
        return false if !authenticated? || topic.archived?
        return true if is_staff? || is_category_group_moderator?(topic.category)
        is_my_own?(topic) && !@user.silenced?
      end
    end
  end

  reloadable_patch { Guardian.prepend(FantribeTheme::GuardianTopicCloseExtension) }

  # Enable topic excerpts for feed and discovery contexts.
  # Scoped away from admin routes — admin topic lists return to core behaviour
  # (include excerpt only when object.excerpt.present?), preventing unnecessary
  # payload on pages that never render feed cards.
  module ::FantribeTheme
    module ListableTopicSerializerExtension
      def include_excerpt?
        return super unless SiteSetting.fantribe_theme_enabled
        return super if scope.request&.path&.start_with?("/admin")
        true
      end
    end
  end

  reloadable_patch do
    ListableTopicSerializer.prepend(FantribeTheme::ListableTopicSerializerExtension)
  end

  # Add member_count to categories so tribe cards can show real membership numbers.
  # Uses Rails cache (15 min TTL) to avoid per-request DB hits since site.categories
  # is serialized once per session and cached on the frontend.
  add_to_serializer(:basic_category, :member_count) do
    Rails
      .cache
      .fetch("ft_member_count_#{object.id}", expires_in: 15.minutes) do
        CategoryUser
          .where(category_id: object.id)
          .where("notification_level >= ?", CategoryUser.notification_levels[:watching])
          .count
      end
  end

  # Expose the category (Tribe) logo URL on each topic so feed cards can
  # show the tribe badge with a logo image rather than just a colour dot.
  add_to_serializer(:topic_list_item, :category_logo_url) { object.category&.uploaded_logo&.url }

  # Expose first_post_id explicitly to ensure feed cards can always react
  add_to_serializer(:topic_list_item, :first_post_id) { object.first_post&.id }
  add_to_serializer(:topic_list_item, :include_first_post_id?) do
    SiteSetting.fantribe_theme_enabled && object.first_post.present?
  end

  add_to_serializer(:topic_list_item, :include_category_logo_url?) do
    SiteSetting.fantribe_theme_enabled
  end

  # Add image_urls to topic list serializer for multi-image support in feed cards
  add_to_serializer(:topic_list_item, :image_urls) do
    next [] unless object.first_post

    object
      .first_post
      .uploads
      .select { |u| FileHelper.is_supported_image?(u.original_filename) }
      .reject { |u| u.extension&.downcase == "svg" }
      .map(&:url)
  end

  # Add first onebox HTML to topic list serializer for link preview in feed cards
  add_to_serializer(:topic_list_item, :first_onebox_html) do
    next nil unless SiteSetting.fantribe_theme_enabled
    cooked = object.first_post&.cooked
    next nil if cooked.blank?
    # Fast-path: skip Nokogiri parse for posts with no onebox markup (~50% of posts)
    next nil if cooked.exclude?("onebox") && cooked.exclude?("lazy-video")

    doc = Nokogiri::HTML5.fragment(cooked)
    # Match standard oneboxes, YouTube embeds, and other video oneboxes
    onebox = doc.at_css("aside.onebox, div.youtube-onebox, div.onebox, div.lazy-video-container")

    next nil unless onebox

    onebox.to_html
  end

  # Add first video data to topic list serializer for video player in feed cards
  add_to_serializer(:topic_list_item, :first_video) do
    next nil unless SiteSetting.fantribe_theme_enabled
    cooked = object.first_post&.cooked
    next nil if cooked.blank?
    next nil if cooked.exclude?("video-placeholder-container")

    doc = Nokogiri::HTML5.fragment(cooked)
    container = doc.at_css("div.video-placeholder-container[data-video-src]")
    next nil unless container

    { video_url: container["data-video-src"], thumbnail_url: container["data-thumbnail-src"] }
  end

  add_to_serializer(:topic_list_item, :include_first_video?) { SiteSetting.fantribe_theme_enabled }

  # Add media_items array for unified carousel (videos, audio, images)
  add_to_serializer(:topic_list_item, :media_items) do
    next [] unless SiteSetting.fantribe_theme_enabled
    cooked = object.first_post&.cooked
    next [] if cooked.blank?

    items = []
    doc = Nokogiri::HTML5.fragment(cooked)

    # Videos
    doc
      .css("div.video-placeholder-container[data-video-src]")
      .each do |container|
        items << {
          type: "video",
          url: container["data-video-src"],
          thumbnail_url: container["data-thumbnail-src"],
        }
      end

    # Audio
    doc
      .css("div.audio-placeholder-container[data-audio-src]")
      .each { |container| items << { type: "audio", url: container["data-audio-src"] } }

    # Images (from lightbox anchors or uploads)
    if object.first_post
      object
        .first_post
        .uploads
        .select { |u| FileHelper.is_supported_image?(u.original_filename) }
        .reject { |u| u.extension&.downcase == "svg" }
        .each { |u| items << { type: "image", url: u.url } }
    end

    items
  end

  add_to_serializer(:topic_list_item, :include_media_items?) { SiteSetting.fantribe_theme_enabled }

  # Mirror image_urls onto search results so tribe page search shows images
  add_to_serializer(:search_topic_list_item, :image_urls) do
    next [] unless SiteSetting.fantribe_theme_enabled
    next [] unless object.first_post

    object
      .first_post
      .uploads
      .select { |u| FileHelper.is_supported_image?(u.original_filename) }
      .reject { |u| u.extension&.downcase == "svg" }
      .map(&:url)
  end

  add_to_serializer(:search_topic_list_item, :include_image_urls?) do
    SiteSetting.fantribe_theme_enabled
  end

  add_to_serializer(:search_topic_list_item, :first_onebox_html) do
    next nil unless SiteSetting.fantribe_theme_enabled
    cooked = object.first_post&.cooked
    next nil if cooked.blank?
    next nil if cooked.exclude?("onebox") && cooked.exclude?("lazy-video")

    doc = Nokogiri::HTML5.fragment(cooked)
    onebox = doc.at_css("aside.onebox, div.youtube-onebox, div.onebox, div.lazy-video-container")
    next nil unless onebox
    onebox.to_html
  end

  add_to_serializer(:search_topic_list_item, :include_first_onebox_html?) do
    SiteSetting.fantribe_theme_enabled
  end

  add_to_serializer(:search_topic_list_item, :first_video) do
    next nil unless SiteSetting.fantribe_theme_enabled
    cooked = object.first_post&.cooked
    next nil if cooked.blank?
    next nil if cooked.exclude?("video-placeholder-container")

    doc = Nokogiri::HTML5.fragment(cooked)
    container = doc.at_css("div.video-placeholder-container[data-video-src]")
    next nil unless container

    { video_url: container["data-video-src"], thumbnail_url: container["data-thumbnail-src"] }
  end

  add_to_serializer(:search_topic_list_item, :include_first_video?) do
    SiteSetting.fantribe_theme_enabled
  end

  # Add media_items array for unified carousel in search results
  add_to_serializer(:search_topic_list_item, :media_items) do
    next [] unless SiteSetting.fantribe_theme_enabled
    cooked = object.first_post&.cooked
    next [] if cooked.blank?

    items = []
    doc = Nokogiri::HTML5.fragment(cooked)

    # Videos
    doc
      .css("div.video-placeholder-container[data-video-src]")
      .each do |container|
        items << {
          type: "video",
          url: container["data-video-src"],
          thumbnail_url: container["data-thumbnail-src"],
        }
      end

    # Audio
    doc
      .css("div.audio-placeholder-container[data-audio-src]")
      .each { |container| items << { type: "audio", url: container["data-audio-src"] } }

    # Images (from uploads)
    if object.first_post
      object
        .first_post
        .uploads
        .select { |u| FileHelper.is_supported_image?(u.original_filename) }
        .reject { |u| u.extension&.downcase == "svg" }
        .each { |u| items << { type: "image", url: u.url } }
    end

    items
  end

  add_to_serializer(:search_topic_list_item, :include_media_items?) do
    SiteSetting.fantribe_theme_enabled
  end

  # Expose per-post emoji reactions on topic list items so the feed engagement
  # bar can show real counts and current-user state without a separate request.
  # Reactions are preloaded above — no N+1 here.
  add_to_serializer(:topic_list_item, :reactions) do
    return [] unless SiteSetting.respond_to?(:discourse_reactions_enabled)
    return [] unless SiteSetting.discourse_reactions_enabled
    return [] unless object.first_post

    object.first_post.reactions.filter_map do |reaction|
      count = reaction.reaction_users_count.to_i
      current_user_used =
        scope.current_user &&
          reaction.reaction_users.any? { |ru| ru.user_id == scope.current_user.id }
      { id: reaction.reaction_value, count:, current_user_used: }
    end
  rescue StandardError
    []
  end

  add_to_serializer(:topic_list_item, :include_reactions?) do
    SiteSetting.respond_to?(:discourse_reactions_enabled) &&
      SiteSetting.discourse_reactions_enabled && object.first_post.present?
  end

  # Expose first 3 comments (replies) on topic list items for inline preview
  # in feed cards. Returns user info + formatted timestamp + raw text.
  add_to_serializer(:topic_list_item, :first_comments) do
    return [] unless SiteSetting.fantribe_theme_enabled
    return [] if object.posts_count <= 1

    # Filter the preloaded in-memory collection — avoids one SQL query per topic.
    # posts + users are preloaded via register_topic_preloader_associations({ posts: :user })
    # above. Chaining .where() on a CollectionProxy bypasses the cache and re-queries;
    # Ruby-level filtering uses the loaded records directly.
    replies =
      object
        .posts
        .reject { |p| p.post_number <= 1 || p.deleted_at.present? }
        .sort_by(&:created_at)
        .first(3)

    replies.map do |post|
      user = post.user
      {
        id: post.id,
        raw: post.raw&.truncate(200),
        created_at: post.created_at,
        like_count: post.like_count || 0,
        user: {
          id: user&.id,
          username: user&.username || "unknown",
          name: user&.name || user&.username || "Unknown",
          avatar_template: user&.avatar_template,
        },
      }
    end
  rescue StandardError
    []
  end

  add_to_serializer(:topic_list_item, :include_first_comments?) do
    SiteSetting.fantribe_theme_enabled
  end

  # Expose the bookmark ID on topic list items so the engagement bar can call
  # DELETE /bookmarks/:id when un-bookmarking (Discourse requires the ID).
  # Discourse core already includes `bookmarked` (boolean) on TopicListItem;
  # we only need the ID for the DELETE call.
  #
  # Performance: first_post is preloaded via register_topic_preloader_associations,
  # so object.first_post&.id avoids a per-topic Post query. All Post-type bookmarks
  # for the current user are loaded in a single query on the first call per request
  # and cached in RequestStore, eliminating the N+1 Bookmark lookup.
  add_to_serializer(:topic_list_item, :bookmark_id) do
    return nil unless scope.current_user

    # Use the preloaded first_post (no extra DB query).
    post_id = object.first_post&.id
    return nil unless post_id

    # Cache the full bookmark map on the Guardian (scope) instance.
    # Guardian is constructed once per request, so this gives us a
    # per-request cache without any external gem dependency.
    unless scope.instance_variable_defined?(:@ft_post_bookmarks_cache)
      scope.instance_variable_set(
        :@ft_post_bookmarks_cache,
        Bookmark
          .where(user: scope.current_user, bookmarkable_type: "Post")
          .pluck(:bookmarkable_id, :id)
          .to_h,
      )
    end

    scope.instance_variable_get(:@ft_post_bookmarks_cache)[post_id]
  end

  add_to_serializer(:topic_list_item, :include_bookmark_id?) do
    SiteSetting.fantribe_theme_enabled && scope.current_user.present?
  end

  # Mirror image_urls and first_onebox_html onto the bookmark serializers so
  # FantribeFeedCard can render post images in the Bookmarks profile tab.
  # The bookmark API returns flat objects (not nested topic objects), so the
  # topic_list_item extensions above don't apply. We parse from `cooked` via
  # Nokogiri — already loaded for the excerpt — avoiding extra DB queries.
  # Both UserPostBookmarkSerializer and UserTopicBookmarkSerializer define a
  # `cooked` instance method, so calling `cooked` here resolves correctly.
  %i[user_post_bookmark user_topic_bookmark].each do |serializer_name|
    add_to_serializer(serializer_name, :image_urls) do
      next [] unless SiteSetting.fantribe_theme_enabled
      next [] if cooked.blank?

      doc = Nokogiri::HTML5.fragment(cooked)
      doc
        .css("img[src]")
        .filter_map do |img|
          src = img["src"]
          next if src.blank? || img["class"]&.include?("emoji")

          src
        end
    rescue StandardError
      []
    end

    add_to_serializer(serializer_name, :include_image_urls?) { SiteSetting.fantribe_theme_enabled }

    add_to_serializer(serializer_name, :first_onebox_html) do
      next nil unless SiteSetting.fantribe_theme_enabled
      next nil if cooked.blank?
      next nil if cooked.exclude?("onebox") && cooked.exclude?("lazy-video")

      doc = Nokogiri::HTML5.fragment(cooked)
      onebox = doc.at_css("aside.onebox, div.youtube-onebox, div.onebox, div.lazy-video-container")
      next nil unless onebox

      onebox.to_html
    rescue StandardError
      nil
    end

    add_to_serializer(serializer_name, :include_first_onebox_html?) do
      SiteSetting.fantribe_theme_enabled
    end

    # Expose topic tags on bookmark objects so the feed card can render them.
    add_to_serializer(serializer_name, :tags) do
      next [] unless SiteSetting.fantribe_theme_enabled && SiteSetting.tagging_enabled
      topic&.tags&.map(&:name) || []
    rescue StandardError
      []
    end

    add_to_serializer(serializer_name, :include_tags?) do
      SiteSetting.fantribe_theme_enabled && SiteSetting.tagging_enabled
    end
  end

  # Expose the number of categories (Tribes) a user is actively watching.
  # Using notification_level >= watching means only categories the user
  # deliberately joined — not ones they were auto-added to.
  # Cached per-user for 10 minutes to avoid a COUNT query on every user card render.
  add_to_serializer(:user_card, :ft_tribe_count) do
    return 0 unless SiteSetting.fantribe_theme_enabled
    Rails
      .cache
      .fetch("ft_tribe_count_#{object.id}", expires_in: 10.minutes) do
        CategoryUser
          .where(user_id: object.id)
          .where("notification_level >= ?", CategoryUser.notification_levels[:watching])
          .count
      end
  rescue StandardError
    0
  end

  add_to_serializer(:user_card, :include_ft_tribe_count?) { SiteSetting.fantribe_theme_enabled }

  # Expose user's post count directly on user_card (already in UserSerializer
  # via staff_attributes :post_count, but we need it publicly available).
  add_to_serializer(:user_card, :ft_post_count) { object.post_count }

  add_to_serializer(:user_card, :include_ft_post_count?) { SiteSetting.fantribe_theme_enabled }

  # Override SiteIconManager to use custom favicon and OG image
  module ::SiteIconManager
    class << self
      alias_method :original_favicon_url, :favicon_url
      alias_method :original_opengraph_image_url, :opengraph_image_url

      def favicon_url
        if SiteSetting.fantribe_theme_enabled
          "/plugins/fantribe-theme/images/favicon.png"
        else
          original_favicon_url
        end
      end

      def opengraph_image_url
        if SiteSetting.fantribe_theme_enabled
          "/plugins/fantribe-theme/images/favicon.png"
        else
          original_opengraph_image_url
        end
      end
    end
  end
end
