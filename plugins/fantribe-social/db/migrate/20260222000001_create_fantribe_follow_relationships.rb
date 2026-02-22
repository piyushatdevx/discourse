# frozen_string_literal: true

class CreateFantribeFollowRelationships < ActiveRecord::Migration[7.2]
  def change
    create_table :fantribe_follow_relationships do |t|
      # follower_id — the user who is doing the following
      # followee_id — the user being followed
      t.integer :follower_id, null: false
      t.integer :followee_id, null: false
      t.timestamps null: false
    end

    # Enforce uniqueness at DB level: one follow relationship per pair
    add_index :fantribe_follow_relationships,
              %i[follower_id followee_id],
              unique: true,
              name: "idx_ft_follows_unique"

    # Fast lookup of all followers of a given user
    add_index :fantribe_follow_relationships, :followee_id, name: "idx_ft_follows_followee"

    # Fast lookup of all users a given user is following
    add_index :fantribe_follow_relationships, :follower_id, name: "idx_ft_follows_follower"
  end
end
