import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ShareTopicModal from "discourse/components/modal/share-topic";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
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

  get shareCount() {
    return this.args.shareCount || 0;
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

    this._isLiked = !wasLiked;
    this._likeCountOffset += wasLiked ? -1 : 1;

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
        {{#if this.likeCount}}
          <span class="fantribe-engagement-btn__count">{{this.likeCount}}</span>
        {{/if}}
      </button>

      <button
        type="button"
        class="fantribe-engagement-btn fantribe-engagement-btn--comment"
        {{on "click" this.handleComment}}
      >
        {{icon "comment"}}
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
        {{icon "share"}}
        {{#if this.shareCount}}
          <span
            class="fantribe-engagement-btn__count"
          >{{this.shareCount}}</span>
        {{/if}}
      </button>

      <button
        type="button"
        class="fantribe-engagement-btn fantribe-engagement-btn--bookmark
          {{if this.isBookmarked 'fantribe-engagement-btn--active'}}"
        {{on "click" this.handleBookmark}}
      >
        {{#if this.isBookmarked}}
          {{icon "bookmark"}}
        {{else}}
          {{icon "far-bookmark"}}
        {{/if}}
      </button>
    </div>
  </template>
}
