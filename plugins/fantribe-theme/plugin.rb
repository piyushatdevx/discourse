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

# Common styles (all viewports)
register_asset "stylesheets/common/design-tokens.scss"
register_asset "stylesheets/common/discourse-overrides.scss"
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

# Component styles (Phase 2.1 - Header)
register_asset "stylesheets/common/components/header.scss"
register_asset "stylesheets/common/components/mobile-nav.scss"

# Component styles (Phase 2.2 - Feed View)
register_asset "stylesheets/common/components/feed-layout.scss"
register_asset "stylesheets/common/components/tribes-panel.scss"
register_asset "stylesheets/common/components/trending-panel.scss"
register_asset "stylesheets/common/components/mobile-tribe-chips.scss"
register_asset "stylesheets/common/components/feed-card.scss"
register_asset "stylesheets/common/components/compose-box.scss"

# Desktop-specific styles
register_asset "stylesheets/desktop/desktop.scss", :desktop

# Mobile-specific styles
register_asset "stylesheets/mobile/mobile.scss", :mobile

# Enable serialization of first_post_id, op_liked, and op_can_like for feed card likes
register_modifier(:serialize_topic_op_likes_data) { true }

after_initialize do
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
