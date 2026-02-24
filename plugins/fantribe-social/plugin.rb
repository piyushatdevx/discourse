# frozen_string_literal: true

# name: fantribe-social
# about: FanTribe social graph — follower/following relationships, social connections
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe/discourse

enabled_site_setting :fantribe_social_enabled

require_relative "lib/fantribe_social/engine"

after_initialize do
  require_relative "app/models/fantribe_social/follow_relationship"
  require_relative "app/controllers/fantribe_social/follows_controller"

  # ------------------------------------------------------------------
  # Routes
  # Register all /u/:username/follow* endpoints.
  # We use Discourse::Application.routes.prepend to keep routes before
  # Discourse's catch-all /u/:username rule.
  # ------------------------------------------------------------------
  Discourse::Application.routes.prepend do
    put "u/:username/follow" => "fantribe_social/follows#create",
        :constraints => {
          username: RouteFormat.username,
        }
    delete "u/:username/follow" => "fantribe_social/follows#destroy",
           :constraints => {
             username: RouteFormat.username,
           }
    get "u/:username/followers" => "fantribe_social/follows#followers",
        :constraints => {
          username: RouteFormat.username,
        }
    get "u/:username/following" => "fantribe_social/follows#following",
        :constraints => {
          username: RouteFormat.username,
        }
  end

  # ------------------------------------------------------------------
  # Serializer extensions
  # These three fields are added to UserCardSerializer so they are
  # available on BOTH the profile page (/u/:username.json) AND the
  # user card popup — the minimal trusted surface for follow state.
  #
  # ft_follower_count  — how many users follow this person
  # ft_following_count — how many users this person follows
  # ft_is_following    — whether the current request's user follows them
  #
  # All three gracefully degrade to 0/false when the DB table does not
  # exist yet (e.g. during pending migrations or local dev without setup).
  # ------------------------------------------------------------------

  add_to_serializer(:user_card, :ft_follower_count) do
    FantribeSocial::FollowRelationship.follower_count_for(object.id)
  rescue StandardError
    0
  end

  add_to_serializer(:user_card, :ft_following_count) do
    FantribeSocial::FollowRelationship.following_count_for(object.id)
  rescue StandardError
    0
  end

  add_to_serializer(:user_card, :ft_is_following) do
    next false unless scope.current_user
    FantribeSocial::FollowRelationship.following?(scope.current_user.id, object.id)
  rescue StandardError
    false
  end

  add_to_serializer(:user_card, :include_ft_follower_count?) { SiteSetting.fantribe_social_enabled }
  add_to_serializer(:user_card, :include_ft_following_count?) do
    SiteSetting.fantribe_social_enabled
  end
  add_to_serializer(:user_card, :include_ft_is_following?) { SiteSetting.fantribe_social_enabled }
end
