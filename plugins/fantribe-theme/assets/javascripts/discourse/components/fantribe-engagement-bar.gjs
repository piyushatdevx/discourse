import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ShareTopicModal from "discourse/components/modal/share-topic";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import Composer from "discourse/models/composer";

const LIKE_ACTION_TYPE_ID = 2;

const REACTIONS = [
  { emoji: "❤️", key: "heart" },
  { emoji: "🔥", key: "fire" },
  { emoji: "👏", key: "clap" },
  { emoji: "🎵", key: "music" },
];

export default class FantribeEngagementBar extends Component {
  @service currentUser;
  @service composer;
  @service modal;

  @tracked isLoading = false;
  @tracked activeReactions = new Set(["heart"]);
  @tracked _isLiked = null;
  @tracked _likeCountOffset = 0;
  @tracked _isBookmarked = false;

  get isLiked() {
    if (this._isLiked !== null) {
      return this._isLiked;
    }
    return this.args.opLiked || false;
  }

  get likeCount() {
    return (this.args.likeCount || 0) + this._likeCountOffset;
  }

  get commentCount() {
    return this.args.commentCount || 0;
  }

  get topicAuthor() {
    const topic = this.args.topic;
    return topic?.posters?.[0]?.user ?? topic?.creator ?? null;
  }

  get isOwnPost() {
    if (!this.currentUser || !this.topicAuthor) {
      return false;
    }
    const author = this.topicAuthor;
    return (
      this.currentUser.id === author.id ||
      this.currentUser.username === author.username
    );
  }

  get canLike() {
    return (
      this.currentUser &&
      this.args.firstPostId &&
      this.args.opCanLike &&
      !this.isOwnPost
    );
  }

  get isBookmarked() {
    return this._isBookmarked || this.args.topic?.bookmarked || false;
  }

  get reactions() {
    return REACTIONS.map((r) => ({
      ...r,
      count: this.getReactionCount(r.key),
      isActive: this.activeReactions.has(r.key),
    }));
  }

  getReactionCount(key) {
    if (key === "heart") {
      return this.likeCount;
    }
    // Simulated counts for other reactions
    const topic = this.args.topic;
    const seed = topic?.id || 0;
    switch (key) {
      case "fire":
        return Math.max(0, Math.floor((seed * 7) % 120));
      case "clap":
        return Math.max(0, Math.floor((seed * 3) % 80));
      case "music":
        return Math.max(0, Math.floor((seed * 11) % 100));
      default:
        return 0;
    }
  }

  @action
  async toggleReaction(key, event) {
    event?.stopPropagation();
    if (key === "heart") {
      await this.handleLike();
      return;
    }
    const newSet = new Set(this.activeReactions);
    if (newSet.has(key)) {
      newSet.delete(key);
    } else {
      newSet.add(key);
    }
    this.activeReactions = newSet;
  }

  @action
  async handleLike() {
    if (
      !this.canLike ||
      !this.currentUser ||
      !this.args.firstPostId ||
      this.isLoading
    ) {
      return;
    }

    this.isLoading = true;
    const wasLiked = this.isLiked;

    this._isLiked = !wasLiked;
    this._likeCountOffset += wasLiked ? -1 : 1;

    // Update activeReactions set
    const newSet = new Set(this.activeReactions);
    if (wasLiked) {
      newSet.delete("heart");
    } else {
      newSet.add("heart");
    }
    this.activeReactions = newSet;

    try {
      if (wasLiked) {
        await ajax(`/post_actions/${this.args.firstPostId}`, {
          type: "DELETE",
          data: { post_action_type_id: LIKE_ACTION_TYPE_ID },
        });
      } else {
        await ajax("/post_actions", {
          type: "POST",
          data: {
            id: this.args.firstPostId,
            post_action_type_id: LIKE_ACTION_TYPE_ID,
          },
        });
      }
    } catch {
      this._isLiked = wasLiked;
      this._likeCountOffset += wasLiked ? 1 : -1;
      const revertSet = new Set(this.activeReactions);
      if (wasLiked) {
        revertSet.add("heart");
      } else {
        revertSet.delete("heart");
      }
      this.activeReactions = revertSet;
    } finally {
      this.isLoading = false;
    }
  }

  @action
  handleComment(event) {
    event.stopPropagation();

    const topic = this.args.topic;
    if (!topic) {
      return;
    }

    this.composer.open({
      action: Composer.REPLY,
      draftKey: topic.draft_key || `topic_${topic.id}`,
      draftSequence: topic.draft_sequence ?? 0,
      topic,
    });
  }

  @action
  handleShare(event) {
    event.stopPropagation();

    const topic = this.args.topic;
    if (!topic) {
      return;
    }

    this.modal.show(ShareTopicModal, {
      model: {
        topic,
        category: topic.category,
      },
    });
  }

  @action
  handleBookmark(event) {
    event.stopPropagation();
    this._isBookmarked = !this.isBookmarked;
  }

  <template>
    <div class="fantribe-engagement">
      {{! Reaction Row — emoji pills with counts }}
      <div class="fantribe-engagement__reactions">
        {{#each this.reactions as |reaction|}}
          <button
            type="button"
            class="fantribe-engagement__reaction
              {{if reaction.isActive 'fantribe-engagement__reaction--active'}}"
            {{on "click" (fn this.toggleReaction reaction.key)}}
          >
            <span
              class="fantribe-engagement__reaction-emoji"
            >{{reaction.emoji}}</span>
            {{#if reaction.count}}
              <span
                class="fantribe-engagement__reaction-count"
              >{{reaction.count}}</span>
            {{/if}}
          </button>
        {{/each}}
      </div>

      {{! Action Bar — comment, share, save }}
      <div class="fantribe-engagement__actions">
        <button
          type="button"
          class="fantribe-engagement__action fantribe-engagement__action--comment"
          {{on "click" this.handleComment}}
        >
          {{icon "comment"}}
          {{#if this.commentCount}}
            <span>{{this.commentCount}}</span>
          {{/if}}
        </button>

        <button
          type="button"
          class="fantribe-engagement__action fantribe-engagement__action--share"
          {{on "click" this.handleShare}}
        >
          {{icon "share-nodes"}}
          <span>Share</span>
        </button>

        <button
          type="button"
          class="fantribe-engagement__action fantribe-engagement__action--bookmark
            {{if this.isBookmarked 'fantribe-engagement__action--active'}}"
          {{on "click" this.handleBookmark}}
        >
          {{#if this.isBookmarked}}
            {{icon "bookmark"}}
          {{else}}
            {{icon "far-bookmark"}}
          {{/if}}
          <span>Save</span>
        </button>
      </div>
    </div>
  </template>
}
