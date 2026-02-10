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

# Common styles (all viewports)
register_asset "stylesheets/common/diagnostic.scss" # DIAGNOSTIC - REMOVE WHEN VERIFIED
# Design tokens, typography, and glassmorphism now come from theme
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

after_initialize do
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
