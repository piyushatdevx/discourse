# frozen_string_literal: true

# name: fantribe-theme-admin
# about: FanTribe Admin Theme — modernizes the Discourse admin UI with FanTribe design language.
# version: 0.1.0
# authors: Fantribe
# url: https://github.com/fantribe/discourse
# required_version: 2.7.0

enabled_site_setting :fantribe_theme_admin_enabled

# Design tokens (load first — provides variables for all other sheets)
register_asset "stylesheets/common/admin-tokens.scss"

# Sidebar visual refinement
register_asset "stylesheets/common/admin-sidebar.scss"

# Custom components (stat card, attention panel, groups)
register_asset "stylesheets/common/admin-components.scss"

# Dashboard-specific card layout and section styling
register_asset "stylesheets/common/admin-dashboard.scss"

# Global admin overrides — surfaces, buttons, tables, inputs (load last)
register_asset "stylesheets/common/admin-overrides.scss"
