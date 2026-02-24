# frozen_string_literal: true

module FantribeSocial
  class FollowRelationship < ActiveRecord::Base
    self.table_name = "fantribe_follow_relationships"

    belongs_to :follower, class_name: "User"
    belongs_to :followee, class_name: "User"

    validates :follower_id, :followee_id, presence: true
    validate :cannot_follow_self

    # ------------------------------------------------------------------
    # Class-level query helpers — used by the serializer and controller.
    # Intentionally simple: one SQL call per stat, cached at the HTTP
    # layer by Discourse's standard page caching.
    # ------------------------------------------------------------------

    def self.follower_count_for(user_id)
      where(followee_id: user_id).count
    end

    def self.following_count_for(user_id)
      where(follower_id: user_id).count
    end

    def self.following?(follower_id, followee_id)
      exists?(follower_id: follower_id, followee_id: followee_id)
    end

    private

    def cannot_follow_self
      errors.add(:follower_id, :invalid) if follower_id == followee_id
    end
  end
end
