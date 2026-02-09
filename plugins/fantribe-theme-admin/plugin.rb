# frozen_string_literal: true

# name: fantribe-theme-admin
# about: FanTribe Admin Theme — modernizes the Discourse admin UI with FanTribe design language.
# version: 0.1.0
# authors: Fantribe
# url: https://github.com/fantribe/discourse
# required_version: 2.7.0

enabled_site_setting :fantribe_theme_admin_enabled

register_asset "stylesheets/common/admin-tokens.scss"
register_asset "stylesheets/common/admin-sidebar.scss"
register_asset "stylesheets/common/admin-components.scss"
