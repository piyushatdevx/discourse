# frozen_string_literal: true

# name: fantribe-theme
# about: FanTribe social platform design system — glassmorphism UI, brand tokens, and component styles
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe/discourse

enabled_site_setting :fantribe_theme_enabled

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
register_asset "stylesheets/common/components/profile-modals.scss"
register_asset "stylesheets/common/components/flag-modal.scss"
register_asset "stylesheets/common/components/preferences.scss"

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

after_initialize do
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
        def can_delete_post_action?(post_action)
          return super unless SiteSetting.fantribe_theme_enabled
          # Same ownership / privacy / archive checks as core — just no time window.
          return false unless is_my_own?(post_action) && !post_action.is_private_message?
          !post_action.post&.topic&.archived?
        end
      end
    end

    reloadable_patch do
      DiscourseReactions::ReactionUser.prepend(FantribeTheme::ReactionUserExtension)
      Guardian.prepend(FantribeTheme::GuardianExtension)
    end
  end

  # Enable topic excerpts for feed cards
  module ::FantribeTheme
    module ListableTopicSerializerExtension
      def include_excerpt?
        return true if SiteSetting.fantribe_theme_enabled
        super
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
    next nil if object.first_post&.cooked.blank?

    doc = Nokogiri::HTML5.fragment(object.first_post.cooked)
    # Match standard oneboxes, YouTube embeds, and other video oneboxes
    onebox = doc.at_css("aside.onebox, div.youtube-onebox, div.onebox, div.lazy-video-container")

    next nil unless onebox

    onebox.to_html
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
  end

  # Expose the number of categories (Tribes) a user is actively watching.
  # Using notification_level >= watching means only categories the user
  # deliberately joined — not ones they were auto-added to.
  # Cached at the HTTP layer; cheap single-table lookup with an index on
  # (user_id, category_id, notification_level).
  add_to_serializer(:user_card, :ft_tribe_count) do
    return 0 unless SiteSetting.fantribe_theme_enabled
    CategoryUser
      .where(user_id: object.id)
      .where("notification_level >= ?", CategoryUser.notification_levels[:watching])
      .count
  rescue StandardError
    0
  end

  add_to_serializer(:user_card, :include_ft_tribe_count?) { SiteSetting.fantribe_theme_enabled }

  # Top Tribes — ranked by all-time post count (highest posts first), top 5.
  # Uses the indexed post_count column on categories — no joins or aggregation
  # needed. Cached for 10 minutes to avoid per-request DB hits.
  add_to_serializer(:site, :trending_tribes) do
    return [] unless SiteSetting.fantribe_theme_enabled

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

        # Batch-load member counts (watchers) for the selected tribes in one query.
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
  rescue StandardError
    []
  end

  add_to_serializer(:site, :include_trending_tribes?) { SiteSetting.fantribe_theme_enabled }

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
