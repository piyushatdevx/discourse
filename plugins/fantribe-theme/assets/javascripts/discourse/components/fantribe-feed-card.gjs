import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { concat, fn } from "@ember/helper";
import icon from "discourse/helpers/d-icon";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import FantribeEngagementBar from "./fantribe-engagement-bar";
import FantribeMediaSingleImage from "./fantribe-media-single-image";
import FantribeMediaVideo from "./fantribe-media-video";
import FantribeMediaPhotoGrid from "./fantribe-media-photo-grid";

export default class FantribeFeedCard extends Component {
  @service router;

  get topic() {
    return this.args.topic;
  }

  get poster() {
    return this.topic?.posters?.[0]?.user || this.topic?.creator;
  }

  get posterInitials() {
    if (!this.poster) return "?";
    const name = this.poster.name || this.poster.username || "";
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .substring(0, 2)
      .toUpperCase();
  }

  get category() {
    return this.topic?.category;
  }

  get categoryBadgeStyle() {
    if (!this.category?.color) return "";
    return `background-color: #${this.category.color}20; color: #${this.category.color};`;
  }

  get excerpt() {
    return this.topic?.excerpt || "";
  }

  get hasImages() {
    // Check if topic has image uploads
    return this.topic?.image_url || this.topic?.thumbnails?.length > 0;
  }

  get imageUrl() {
    return this.topic?.image_url || this.topic?.thumbnails?.[0]?.url;
  }

  get likeCount() {
    return this.topic?.like_count || 0;
  }

  get replyCount() {
    return this.topic?.posts_count ? this.topic.posts_count - 1 : 0;
  }

  get viewCount() {
    return this.topic?.views || 0;
  }

  @action
  navigateToTopic() {
    if (this.topic?.id) {
      this.router.transitionTo("topic", this.topic.slug, this.topic.id);
    }
  }

  @action
  navigateToUser(event) {
    event.stopPropagation();
    if (this.poster?.username) {
      this.router.transitionTo("user", this.poster.username);
    }
  }

  <template>
    <article class="fantribe-feed-card" {{on "click" this.navigateToTopic}}>
      <div class="fantribe-feed-card__content">
        {{! Post Header }}
        <header class="fantribe-feed-card__header">
          <div
            class="fantribe-feed-card__avatar"
            {{on "click" this.navigateToUser}}
          >
            {{#if this.poster}}
              {{avatar this.poster imageSize="medium"}}
            {{else}}
              <span class="fantribe-feed-card__avatar-initials">
                {{this.posterInitials}}
              </span>
            {{/if}}
          </div>

          <div class="fantribe-feed-card__meta">
            <a
              class="fantribe-feed-card__username"
              href="#"
              {{on "click" this.navigateToUser}}
            >
              {{#if this.poster}}
                {{this.poster.username}}
              {{else}}
                Unknown
              {{/if}}
            </a>
            <div class="fantribe-feed-card__timestamp-row">
              <span>{{formatDate @topic.created_at format="tiny"}}</span>
              {{#if this.category}}
                <span class="fantribe-feed-card__separator">&middot;</span>
                <span
                  class="fantribe-feed-card__category-badge"
                  style={{this.categoryBadgeStyle}}
                >
                  {{this.category.name}}
                </span>
              {{/if}}
            </div>
          </div>
        </header>

        {{! Post Title and Excerpt }}
        <div class="fantribe-feed-card__text">
          <p><strong>{{@topic.title}}</strong></p>
          {{#if this.excerpt}}
            <p>{{this.excerpt}}</p>
          {{/if}}
        </div>

        {{! Media Section }}
        {{#if this.hasImages}}
          <div class="fantribe-feed-card__media">
            <FantribeMediaSingleImage @imageUrl={{this.imageUrl}} />
          </div>
        {{/if}}

        {{! Engagement Bar }}
        <FantribeEngagementBar
          @likeCount={{this.likeCount}}
          @commentCount={{this.replyCount}}
          @shareCount={{this.viewCount}}
          @topicId={{@topic.id}}
        />
      </div>
    </article>
  </template>
}
