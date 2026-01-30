import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";

export default class FantribeEngagementBar extends Component {
  @service currentUser;

  @tracked isLiked = false;

  get likeCount() {
    return this.args.likeCount || 0;
  }

  get commentCount() {
    return this.args.commentCount || 0;
  }

  get shareCount() {
    return this.args.shareCount || 0;
  }

  get displayLikeCount() {
    return this.isLiked ? this.likeCount + 1 : this.likeCount;
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
  handleLike(event) {
    event.stopPropagation();
    if (!this.currentUser) return;
    this.isLiked = !this.isLiked;
    // In production, this would call the Discourse API to like the topic
  }

  @action
  handleComment(event) {
    event.stopPropagation();
    // Navigate to topic and focus on reply
  }

  @action
  handleShare(event) {
    event.stopPropagation();
    // Open share dialog
    if (navigator.share && this.args.topicId) {
      navigator.share({
        title: "Check out this post",
        url: `/t/-/${this.args.topicId}`,
      });
    }
  }

  <template>
    <div class="fantribe-engagement-bar">
      <button
        type="button"
        class="fantribe-engagement-btn fantribe-engagement-btn--like
          {{if this.isLiked 'fantribe-engagement-btn--active'}}"
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
    </div>
  </template>
}
