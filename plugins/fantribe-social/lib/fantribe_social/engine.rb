# frozen_string_literal: true

module ::FantribeSocial
  PLUGIN_NAME = "fantribe-social"

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace FantribeSocial
    config.autoload_paths << File.join(config.root, "app")
  end
end
