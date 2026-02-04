import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ShareTopicModal from "discourse/components/modal/share-topic";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";
import Composer from "discourse/models/composer";
import { not } from "discourse/truth-helpers";

const LIKE_ACTION_TYPE_ID = 2;

export default class FantribeEngagementBar extends Component {
  @service currentUser;
  @service composer;
  @service modal;

  @tracked isLoading = false;
  @tracked _isLiked = null;
  @tracked _likeCountOffset = 0;

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

  get shareCount() {
    return this.args.shareCount || 0;
  }

  get displayLikeCount() {
    return this.likeCount;
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

  get commentIconUrl() {
    return getURL("/plugins/fantribe-theme/images/comment.svg");
  }

  get shareIconUrl() {
    return getURL("/plugins/fantribe-theme/images/share.svg");
  }

  formatCount(count) {
    if (count >= 1000000) {
      return (count / 1000000).toFixed(1) + "M";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K";
    }
    return count.toString();
  }

  @action
  async handleLike(event) {
    event.stopPropagation();

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

    // Optimistic UI update
    this._isLiked = !wasLiked;
    this._likeCountOffset += wasLiked ? -1 : 1;

    try {
      if (wasLiked) {
        // Unlike: DELETE /post_actions/:post_id
        await ajax(`/post_actions/${this.args.firstPostId}`, {
          type: "DELETE",
          data: { post_action_type_id: LIKE_ACTION_TYPE_ID },
        });
      } else {
        // Like: POST /post_actions
        await ajax("/post_actions", {
          type: "POST",
          data: {
            id: this.args.firstPostId,
            post_action_type_id: LIKE_ACTION_TYPE_ID,
          },
        });
      }
    } catch {
      // Revert optimistic update on error
      this._isLiked = wasLiked;
      this._likeCountOffset += wasLiked ? 1 : -1;
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

  <template>
    <div class="fantribe-engagement-bar">
      <button
        type="button"
        class="fantribe-engagement-btn fantribe-engagement-btn--like
          {{if this.isLiked 'fantribe-engagement-btn--active'}}
          {{unless this.canLike 'fantribe-engagement-btn--disabled'}}"
        disabled={{not this.canLike}}
        {{on "click" this.handleLike}}
      >
        {{#if this.isLiked}}
          {{icon "heart"}}
        {{else}}
          {{icon "far-heart"}}
        {{/if}}
        {{#if this.displayLikeCount}}
          <span
            class="fantribe-engagement-btn__count"
          >{{this.displayLikeCount}}</span>
        {{/if}}
      </button>

      <button
        type="button"
        class="fantribe-engagement-btn fantribe-engagement-btn--comment"
        {{on "click" this.handleComment}}
      >
        <img
          src={{this.commentIconUrl}}
          alt="Comment"
          class="fantribe-engagement-btn__icon"
        />
        {{#if this.commentCount}}
          <span
            class="fantribe-engagement-btn__count"
          >{{this.commentCount}}</span>
        {{/if}}
      </button>

      <button
        type="button"
        class="fantribe-engagement-btn fantribe-engagement-btn--share"
        {{on "click" this.handleShare}}
      >
        <img
          src={{this.shareIconUrl}}
          alt="Share"
          class="fantribe-engagement-btn__icon"
        />
        {{#if this.shareCount}}
          <span
            class="fantribe-engagement-btn__count"
          >{{this.shareCount}}</span>
        {{/if}}
      </button>
    </div>
  </template>
}
