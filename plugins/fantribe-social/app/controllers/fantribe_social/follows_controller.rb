# frozen_string_literal: true

module FantribeSocial
  class FollowsController < ::ApplicationController
    requires_plugin FantribeSocial::PLUGIN_NAME

    before_action :ensure_logged_in
    before_action :find_followee

    # PUT /u/:username/follow
    # Toggle follow on: idempotent — safe to call even if already following.
    def create
      raise Discourse::InvalidAccess if @followee.id == current_user.id

      FollowRelationship.find_or_create_by!(follower_id: current_user.id, followee_id: @followee.id)

      render json:
               success_json.merge(
                 ft_follower_count: FollowRelationship.follower_count_for(@followee.id),
                 ft_is_following: true,
               )
    end

    # DELETE /u/:username/follow
    # Toggle follow off: idempotent — safe to call even if not following.
    def destroy
      FollowRelationship.where(follower_id: current_user.id, followee_id: @followee.id).delete_all

      render json:
               success_json.merge(
                 ft_follower_count: FollowRelationship.follower_count_for(@followee.id),
                 ft_is_following: false,
               )
    end

    # GET /u/:username/followers
    # Returns paginated list of users who follow @followee.
    def followers
      page = [params[:page].to_i, 0].max
      per_page = 24

      user_ids =
        FollowRelationship
          .where(followee_id: @followee.id)
          .order(created_at: :desc)
          .limit(per_page)
          .offset(page * per_page)
          .pluck(:follower_id)

      users = User.where(id: user_ids).index_by(&:id)
      ordered = user_ids.map { |id| users[id] }.compact

      render json: {
               users:
                 ordered.map do |u|
                   {
                     id: u.id,
                     username: u.username,
                     name: u.name,
                     avatar_template: u.avatar_template,
                   }
                 end,
               total_count: FollowRelationship.follower_count_for(@followee.id),
             }
    end

    # GET /u/:username/following
    # Returns paginated list of users that @followee is following.
    def following
      page = [params[:page].to_i, 0].max
      per_page = 24

      user_ids =
        FollowRelationship
          .where(follower_id: @followee.id)
          .order(created_at: :desc)
          .limit(per_page)
          .offset(page * per_page)
          .pluck(:followee_id)

      users = User.where(id: user_ids).index_by(&:id)
      ordered = user_ids.map { |id| users[id] }.compact

      render json: {
               users:
                 ordered.map do |u|
                   {
                     id: u.id,
                     username: u.username,
                     name: u.name,
                     avatar_template: u.avatar_template,
                   }
                 end,
               total_count: FollowRelationship.following_count_for(@followee.id),
             }
    end

    private

    def find_followee
      @followee = User.find_by_username(params[:username])
      raise Discourse::NotFound unless @followee
    end
  end
end
