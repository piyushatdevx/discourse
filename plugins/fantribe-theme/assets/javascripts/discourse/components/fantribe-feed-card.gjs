import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { concat, fn } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import { gt, not, and } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import DecoratedHtml from "discourse/components/decorated-html";
import FantribeEngagementBar from "./fantribe-engagement-bar";
import FantribeMediaSingleImage from "./fantribe-media-single-image";
import FantribeMediaVideo from "./fantribe-media-video";
import FantribeMediaPhotoGrid from "./fantribe-media-photo-grid";

export default class FantribeFeedCard extends Component {
  @service router;

  @tracked expanded = false;
  @tracked expandedContent = null;
  @tracked loadingExpanded = false;

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

  get tags() {
    const tags = this.topic?.tags || [];
    return tags.map((tag) => (typeof tag === "string" ? tag : tag.name));
  }

  get categoryBadgeStyle() {
    if (!this.category?.color) return "";
    return `background-color: #${this.category.color}20; color: #${this.category.color};`;
  }

  get excerpt() {
    return this.topic?.excerpt || "";
  }

  get excerptTruncated() {
    return this.topic?.excerptTruncated ?? false;
  }

  get displayExcerpt() {
    const excerpt = this.excerpt;
    if (!excerpt) return "";
    if (this.excerptTruncated && excerpt.slice(-8) === "&hellip;") {
      return excerpt.slice(0, -8).trim();
    }
    return excerpt;
  }

  get expandedContentHtml() {
    return this.expandedContent ? htmlSafe(this.expandedContent) : null;
  }

  get firstOneboxHtml() {
    const html = this.topic?.first_onebox_html;
    return html ? htmlSafe(html) : null;
  }

  get hasOnebox() {
    return !!this.topic?.first_onebox_html;
  }

  get images() {
    const urls = this.topic?.image_urls || [];
    if (urls.length > 0) {
      return urls.map((url) => ({ url }));
    }
    if (this.imageUrl) {
      return [{ url: this.imageUrl }];
    }
    return [];
  }

  get hasImages() {
    return this.images.length > 0;
  }

  get hasMultipleImages() {
    return this.images.length > 1;
  }

  get imageUrl() {
    return this.topic?.image_url || this.topic?.thumbnails?.[0]?.url;
  }

  get likeCount() {
    return this.topic?.op_like_count || this.topic?.like_count || 0;
  }

  get firstPostId() {
    return this.topic?.first_post_id;
  }

  get opLiked() {
    return this.topic?.op_liked || false;
  }

  get opCanLike() {
    return this.topic?.op_can_like ?? true;
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

  @action
  async toggleExpandContent(event) {
    event?.stopPropagation?.();
    if (this.loadingExpanded) return;
    if (this.expanded) {
      this.expanded = false;
      this.expandedContent = null;
      return;
    }
    const postId = this.firstPostId;
    if (!postId) return;
    this.loadingExpanded = true;
    try {
      const result = await ajax(`/posts/${postId}/cooked.json`);
      this.expandedContent = result?.cooked ?? "";
      this.expanded = true;
    } finally {
      this.loadingExpanded = false;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <article
      class="fantribe-feed-card
        {{if this.expanded 'fantribe-feed-card--expanded'}}"
      {{on "click" this.navigateToTopic}}
    >
      <div class="fantribe-feed-card__content">
        {{! Post Header }}
        <header class="fantribe-feed-card__header">
          <button
            type="button"
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
          </button>

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
            <span class="fantribe-feed-card__separator">&middot;</span>
            <span class="fantribe-feed-card__timestamp">{{formatDate
                @topic.created_at
                format="tiny"
              }}</span>
            {{#if this.category}}
              <span class="fantribe-feed-card__separator">&middot;</span>
              <span
                class="fantribe-feed-card__category-badge"
                style={{this.categoryBadgeStyle}}
              >
                {{this.category.name}}
              </span>
            {{/if}}
            {{#if this.tags.length}}
              <span class="fantribe-feed-card__separator">&middot;</span>
              <span class="fantribe-feed-card__tags">
                {{#each this.tags as |tag index|}}
                  {{#if (gt index 0)}}
                    <span class="fantribe-feed-card__separator">&middot;</span>
                  {{/if}}
                  <span class="fantribe-feed-card__tag-badge">{{tag}}</span>
                {{/each}}
              </span>
            {{/if}}
          </div>
        </header>

        <div class="fantribe-feed-card__body">
          <div class="fantribe-feed-card__text">
            <p><strong>{{@topic.title}}</strong></p>
            {{#if this.hasOnebox}}
              <div class="fantribe-feed-card__onebox">
                <DecoratedHtml @html={{this.firstOneboxHtml}} />
              </div>
            {{else if this.excerpt}}
              {{#if this.expanded}}
                <div class="fantribe-feed-card__expanded-body">
                  <DecoratedHtml @html={{this.expandedContentHtml}} />
                  <button
                    type="button"
                    class="fantribe-feed-card__show-less"
                    {{on "click" this.toggleExpandContent}}
                  >
                    {{i18n "review.show_less"}}
                  </button>
                </div>
              {{else}}
                <p>
                  {{this.displayExcerpt}}
                  {{#if this.excerptTruncated}}
                    <button
                      type="button"
                      class="fantribe-feed-card__read-more"
                      {{on "click" this.toggleExpandContent}}
                      disabled={{this.loadingExpanded}}
                    >
                      {{#if this.loadingExpanded}}
                        {{i18n "loading"}}
                      {{else}}
                        {{i18n "read_more"}}
                        ..
                      {{/if}}
                    </button>
                  {{/if}}
                </p>
              {{/if}}
            {{/if}}
          </div>

          {{#if (and this.hasImages (not this.hasOnebox))}}
            <div class="fantribe-feed-card__media">
              {{#if this.hasMultipleImages}}
                <FantribeMediaPhotoGrid @images={{this.images}} />
              {{else}}
                <FantribeMediaSingleImage @imageUrl={{this.imageUrl}} />
              {{/if}}
            </div>
          {{/if}}

          <FantribeEngagementBar
            @topic={{@topic}}
            @likeCount={{this.likeCount}}
            @commentCount={{this.replyCount}}
            @shareCount={{this.viewCount}}
            @topicId={{@topic.id}}
            @firstPostId={{this.firstPostId}}
            @opLiked={{this.opLiked}}
            @opCanLike={{this.opCanLike}}
          />
        </div>
      </div>
    </article>
  </template>
}
