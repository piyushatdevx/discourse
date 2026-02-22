# frozen_string_literal: true

# name: fantribe-theme
# about: FanTribe social platform design system — glassmorphism UI, brand tokens, and component styles
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe/discourse

enabled_site_setting :fantribe_theme_enabled

# Register SVG icons used by FanTribe components
register_svg_icon "image"
register_svg_icon "video"
register_svg_icon "face-smile"
register_svg_icon "paper-plane"
register_svg_icon "globe"
register_svg_icon "heart"
register_svg_icon "far-heart"
register_svg_icon "magnifying-glass"
register_svg_icon "filter"
register_svg_icon "bell"
register_svg_icon "house"
register_svg_icon "plus"
register_svg_icon "user"
register_svg_icon "play"
register_svg_icon "arrow-trend-up"
register_svg_icon "fire"
register_svg_icon "arrow-up"
register_svg_icon "envelope"
register_svg_icon "gear"
register_svg_icon "right-from-bracket"
register_svg_icon "comment"
register_svg_icon "share"
register_svg_icon "share-nodes"
register_svg_icon "compass"
register_svg_icon "store"
register_svg_icon "people-group"
register_svg_icon "tower-broadcast"
register_svg_icon "comments"
register_svg_icon "table-columns"
register_svg_icon "tv"
register_svg_icon "wand-magic-sparkles"
register_svg_icon "address-book"
register_svg_icon "gift"
register_svg_icon "dollar-sign"
register_svg_icon "handshake"
register_svg_icon "chevron-right"
register_svg_icon "chevron-left"
register_svg_icon "ellipsis"
register_svg_icon "bookmark"
register_svg_icon "far-bookmark"
register_svg_icon "circle"
register_svg_icon "users"
register_svg_icon "sliders"
register_svg_icon "chevron-down"
register_svg_icon "check"
register_svg_icon "lock"
register_svg_icon "headphones"
register_svg_icon "thumbtack"
register_svg_icon "pencil"
register_svg_icon "link"
register_svg_icon "comment-slash"
register_svg_icon "trash-alt"
register_svg_icon "eye-slash"
register_svg_icon "eye"
register_svg_icon "flag"
register_svg_icon "ban"
register_svg_icon "user-plus"
register_svg_icon "xmark"
register_svg_icon "clock"
register_svg_icon "tag"
register_svg_icon "music"
register_svg_icon "calendar"
register_svg_icon "circle-xmark"
register_svg_icon "circle-check"
register_svg_icon "arrow-right-to-bracket"
register_svg_icon "location-dot"
register_svg_icon "zap"

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
register_asset "stylesheets/common/components/tribe-header.scss"
register_asset "stylesheets/common/components/tribe-page.scss"
register_asset "stylesheets/common/components/user-profile.scss"

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
