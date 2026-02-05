# frozen_string_literal: true

# name: fantribe-theme-admin
# about: Fantribe Admin Theme
# version: 0.0.1
# authors: Fantribe
# url: https://github.com/fantribe/discourse
# required_version: 2.7.0

enabled_site_setting :plugin_name_enabled

module ::MyPluginModule
  PLUGIN_NAME = "discourse-plugin-name"
end

require_relative "lib/my_plugin_module/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
