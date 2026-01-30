# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :check_xhr, :redirect_to_login_if_required, :redirect_to_profile_if_required

  def show
    render html: nil, layout: true
  end
end
