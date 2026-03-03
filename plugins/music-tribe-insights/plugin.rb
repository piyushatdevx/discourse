# frozen_string_literal: true

# name: music-tribe-insights
# about: Community insights and report-type analysis for Music Tribe using AWS Bedrock (recurring themes, product issues, etc.).
# version: 0.1.0
# authors: Music Tribe
# url: https://github.com/fantribe/discourse
# required_version: 2.7.0

enabled_site_setting :music_tribe_insights_enabled

register_asset "stylesheets/common/community-insights.scss"

module ::MusicTribeInsights
  PLUGIN_NAME = "music-tribe-insights"
  STORE_KEY = "community_insights"
end

after_initialize do
  require_relative "app/controllers/music_tribe_insights/admin_controller"
  require_relative "app/services/music_tribe_insights/bedrock_analyzer"
  require_relative "app/jobs/regular/music_tribe_insights_generate_insights"
end

Discourse::Application.routes.append do
  get "admin/dashboard/community_insights" => "music_tribe_insights/admin#index",
      :constraints => StaffConstraint.new
  post "admin/community_insights/refresh" => "music_tribe_insights/admin#refresh",
       :constraints => AdminConstraint.new
end
