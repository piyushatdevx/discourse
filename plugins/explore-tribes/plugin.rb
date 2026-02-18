# frozen_string_literal: true

# name: explore-tribes
# about: Explore Tribes page — browse and discover community tribes
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe/discourse

enabled_site_setting :explore_tribes_enabled

register_asset "stylesheets/common/explore-page.scss"
register_asset "stylesheets/common/tribe-grid.scss"
register_asset "stylesheets/common/tribe-card.scss"
register_asset "stylesheets/common/filter-dropdown.scss"

after_initialize do
  module ::ExploreTribes
    class ExploreController < ::ApplicationController
      requires_plugin "explore-tribes"
      skip_before_action :check_xhr

      def index
        render html: "".html_safe, layout: true
      end
    end
  end

  Discourse::Application.routes.prepend { get "/explore" => "explore_tribes/explore#index" }
end
