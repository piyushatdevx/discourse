import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import DecoratedHtml from "discourse/components/decorated-html";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { not, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";
import FantribeEngagementBar from "./fantribe-engagement-bar";
import FantribeMediaPhotoGrid from "./fantribe-media-photo-grid";
import FantribeMediaSingleImage from "./fantribe-media-single-image";
import FantribePostMenu from "./fantribe-post-menu";

export default class FantribeFeedCard extends Component {
  @service currentUser;
  @service router;
  @service site;
  @service fantribeFeedState;

  @tracked expanded = false;
  @tracked expandedContent = null;
  @tracked loadingExpanded = false;
  @tracked menuOpen = false;
  @tracked dismissed = false;
  @tracked commentText = "";
  @tracked isSubmittingComment = false;
  @tracked _topicClosed = null;
  // Local comments state for optimistic updates after submission
  @tracked _localComments = null;

  get topic() {
    return this.args.topic;
  }

  get poster() {
    return this.topic?.posters?.[0]?.user || this.topic?.creator;
  }

  get displayName() {
    if (!this.poster) {
      return "Unknown";
    }
    return this.poster.name || this.poster.username || "Unknown";
  }

  get posterUsername() {
    return this.poster?.username || "unknown";
  }

  get excerpt() {
    return this.topic?.excerpt || "";
  }

  get excerptTruncated() {
    return this.topic?.excerptTruncated ?? false;
  }

  get displayExcerpt() {
    const excerpt = this.excerpt;
    if (!excerpt) {
      return "";
    }
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

  // URL for the single-image case. Derives from the already-resolved `images`
  // array so it covers image_urls, topic.image_url, and thumbnails uniformly.
  get singleImageUrl() {
    return this.images[0]?.url || null;
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

  // Tribe (category) helpers — used for the tribe badge chip on feed cards
  get tribeCategory() {
    const catId = this.topic?.category_id;
    if (!catId) {
      return null;
    }
    return (this.site.categories || []).find((c) => c.id === catId) || null;
  }

  get tribeLogo() {
    // Prefer the serialized logo URL (avoids extra lookup), fall back to site data
    return (
      this.topic?.category_logo_url ||
      this.tribeCategory?.uploaded_logo_url ||
      null
    );
  }

  get tribeDotStyle() {
    const color = this.tribeCategory?.color || "9ca3af";
    return htmlSafe(`background-color: #${color}`);
  }

  get replyCount() {
    return this.topic?.posts_count ? this.topic.posts_count - 1 : 0;
  }

  get viewCount() {
    return this.topic?.views || 0;
  }

  get isOwnPost() {
    if (!this.currentUser || !this.poster) {
      return false;
    }
    return this.currentUser.username === this.poster.username;
  }

  get topicOverrides() {
    return this.fantribeFeedState.topicUpdates[this.topic?.id] || {};
  }

  get topicTitle() {
    return this.topicOverrides.title ?? this.topic?.title ?? "";
  }

  get tags() {
    return this.topicOverrides.tags ?? this.topic?.tags ?? [];
  }

  get hasTags() {
    return this.tags.length > 0;
  }

  get topicClosed() {
    return this._topicClosed !== null
      ? this._topicClosed
      : this.topic?.closed || false;
  }

  get showTribeBadge() {
    return !!this.tribeCategory && !this.args.hideTribeBadge;
  }

  // Inline comments preview — first 3 replies from serializer or local state
  get firstComments() {
    const comments = this._localComments || this.topic?.first_comments || [];
    return comments.map((comment, index) => ({
      ...comment,
      initials: this.getInitials(comment.user?.name || comment.user?.username),
      gradientClass: `fantribe-feed-card__comment-avatar--gradient-${(index % 4) + 1}`,
    }));
  }

  get hasComments() {
    return this.firstComments.length > 0;
  }

  get canComment() {
    return !!this.currentUser && !this.topicClosed;
  }

  getInitials(name) {
    if (!name) {
      return "?";
    }
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @action
  toggleMenu(event) {
    event.stopPropagation();
    this.menuOpen = !this.menuOpen;
  }

  @action
  closeMenu() {
    this.menuOpen = false;
  }

  @action
  dismissCard() {
    this.dismissed = true;
  }

  @action
  setTopicClosed(isClosed) {
    this._topicClosed = isClosed;
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
  navigateToTribe(event) {
    event.stopPropagation();
    const cat = this.tribeCategory;
    if (cat?.slug) {
      this.router.transitionTo("discovery.category", cat.slug);
    }
  }

  @action
  stopPropagation(event) {
    event.stopPropagation();
  }

  @action
  focusCommentInput(event) {
    event.stopPropagation();
  }

  @action
  updateCommentText(event) {
    event.stopPropagation();
    this.commentText = event.target.value;
  }

  @action
  handleCommentKeydown(event) {
    event.stopPropagation();
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      this.submitComment(event);
    }
  }

  @action
  async submitComment(event) {
    event?.stopPropagation();

    if (
      !this.canComment ||
      this.isSubmittingComment ||
      !this.commentText.trim()
    ) {
      return;
    }

    const topicId = this.topic?.id;
    if (!topicId) {
      return;
    }

    this.isSubmittingComment = true;
    const commentText = this.commentText.trim();

    try {
      const result = await ajax("/posts", {
        type: "POST",
        data: {
          raw: commentText,
          topic_id: topicId,
          draft_key: `topic_${topicId}`,
        },
      });

      // Clear input on success
      this.commentText = "";

      // Optimistic update: add new comment to local state
      if (result) {
        const newComment = {
          id: result.id,
          raw:
            commentText.length > 200
              ? commentText.substring(0, 200) + "..."
              : commentText,
          created_at: new Date().toISOString(),
          user: {
            id: this.currentUser.id,
            username: this.currentUser.username,
            name: this.currentUser.name || this.currentUser.username,
            avatar_template: this.currentUser.avatar_template,
          },
        };

        const existingComments =
          this._localComments || this.topic?.first_comments || [];
        // Keep only first 3 comments (new one at the end)
        this._localComments = [...existingComments, newComment].slice(-3);
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmittingComment = false;
    }
  }

  @action
  async toggleExpandContent(event) {
    event?.stopPropagation?.();
    if (this.loadingExpanded) {
      return;
    }
    if (this.expanded) {
      this.expanded = false;
      this.expandedContent = null;
      return;
    }
    const postId = this.firstPostId;
    if (!postId) {
      return;
    }
    this.loadingExpanded = true;
    try {
      const result = await ajax(`/posts/${postId}/cooked.json`);
      let cooked = result?.cooked ?? "";
      cooked = this.hideAllLightboxesInExpanded(cooked);
      this.expandedContent = cooked;
      this.expanded = true;
    } finally {
      this.loadingExpanded = false;
    }
  }

  hideAllLightboxesInExpanded(html) {
    if (!html || !html.includes("lightbox-wrapper")) {
      return html;
    }
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, "text/html");
    doc.querySelectorAll(".lightbox-wrapper").forEach((el) => el.remove());
    return doc.body.innerHTML.trim() || html;
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{#unless this.dismissed}}
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
              {{/if}}
            </button>

            <div class="fantribe-feed-card__meta">
              <div class="fantribe-feed-card__meta-name-row">
                <span
                  class="fantribe-feed-card__display-name"
                >{{this.displayName}}</span>
              </div>
              <div class="fantribe-feed-card__meta-info-row">
                <span
                  class="fantribe-feed-card__username-handle"
                >@{{this.posterUsername}}</span>
                <span class="fantribe-feed-card__separator">&middot;</span>
                <span class="fantribe-feed-card__timestamp">{{formatDate
                    @topic.created_at
                    format="tiny"
                  }}</span>
              </div>
            </div>

            <div class="fantribe-feed-card__header-right">
              {{#if this.showTribeBadge}}
                <button
                  type="button"
                  class="fantribe-feed-card__category-pill"
                  {{on "click" this.navigateToTribe}}
                >{{this.tribeCategory.name}}</button>
              {{/if}}
              <div class="fantribe-feed-card__more-wrapper">
                <button
                  type="button"
                  class="fantribe-feed-card__more-btn"
                  {{on "click" this.toggleMenu}}
                >
                  {{ftIcon "more-horizontal"}}
                </button>

                <FantribePostMenu
                  @isOpen={{this.menuOpen}}
                  @onClose={{this.closeMenu}}
                  @onDismiss={{this.dismissCard}}
                  @isOwnPost={{this.isOwnPost}}
                  @userName={{this.posterUsername}}
                  @topic={{@topic}}
                  @firstPostId={{this.firstPostId}}
                  @topicClosed={{this.topicClosed}}
                  @onClosedChange={{this.setTopicClosed}}
                />
              </div>
            </div>
          </header>

          <div class="fantribe-feed-card__body">
            <div class="fantribe-feed-card__text">
              {{#if this.hasTags}}
                <div
                  class="fantribe-feed-card__tags"
                  {{on "click" this.stopPropagation}}
                >
                  {{#each this.tags as |tag|}}
                    <span class="fantribe-feed-card__tag">#{{tag}}</span>
                  {{/each}}
                </div>
              {{/if}}
              <p><strong>{{this.topicTitle}}</strong></p>
              {{#if this.excerpt}}
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

            {{#if (or this.hasOnebox this.hasImages)}}
              <div
                class="fantribe-feed-card__media"
                {{on "click" this.stopPropagation}}
              >
                {{#if this.hasOnebox}}
                  <div
                    class="fantribe-feed-card__onebox fantribe-feed-card__onebox--in-media"
                  >
                    <DecoratedHtml @html={{this.firstOneboxHtml}} />
                  </div>
                {{else if this.hasMultipleImages}}
                  <FantribeMediaPhotoGrid @images={{this.images}} />
                {{else}}
                  <FantribeMediaSingleImage @imageUrl={{this.singleImageUrl}} />
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
              @topicClosed={{this.topicClosed}}
            />
          </div>
        </div>

        {{! Divider line }}
        <div class="fantribe-feed-card__divider"></div>

        {{! Comments Section - Always shown }}
        <div
          class="fantribe-feed-card__comments-section"
          {{on "click" this.stopPropagation}}
        >
          {{#if this.hasComments}}
            <div class="fantribe-feed-card__comments-inner">
              <span class="fantribe-feed-card__comments-label">Comments</span>

              <div class="fantribe-feed-card__comments-list">
                {{#each this.firstComments as |comment|}}
                  <div class="fantribe-feed-card__comment">
                    <div
                      class="fantribe-feed-card__comment-avatar
                        {{comment.gradientClass}}"
                    >
                      <span
                        class="fantribe-feed-card__comment-initials"
                      >{{comment.initials}}</span>
                    </div>
                    <div class="fantribe-feed-card__comment-content">
                      <div class="fantribe-feed-card__comment-meta">
                        <span
                          class="fantribe-feed-card__comment-author"
                        >{{comment.user.name}}</span>
                        <span
                          class="fantribe-feed-card__comment-timestamp"
                        >{{formatDate comment.created_at format="tiny"}}</span>
                      </div>
                      <p
                        class="fantribe-feed-card__comment-text"
                      >{{comment.raw}}</p>
                    </div>
                  </div>
                {{/each}}
              </div>
            </div>
          {{/if}}

          {{! Comment Input - Always shown }}
          <div class="fantribe-feed-card__comment-input-wrapper">
            <div class="fantribe-feed-card__comment-input-avatar">
              {{#if this.currentUser}}
                {{avatar this.currentUser imageSize="medium"}}
              {{/if}}
            </div>
            <div class="fantribe-feed-card__comment-input-container">
              <input
                type="text"
                class="fantribe-feed-card__comment-input
                  {{if
                    this.topicClosed
                    'fantribe-feed-card__comment-input--disabled'
                  }}"
                placeholder={{if
                  this.topicClosed
                  "Comments are turned off"
                  "Join the conversation..."
                }}
                value={{this.commentText}}
                disabled={{or
                  this.isSubmittingComment
                  this.topicClosed
                  (not this.currentUser)
                }}
                {{on "click" this.focusCommentInput}}
                {{on "input" this.updateCommentText}}
                {{on "keydown" this.handleCommentKeydown}}
              />
              <button
                type="button"
                class="fantribe-feed-card__comment-input-send
                  {{if
                    this.commentText
                    'fantribe-feed-card__comment-input-send--active'
                  }}"
                disabled={{or
                  this.isSubmittingComment
                  (not this.commentText)
                  this.topicClosed
                  (not this.currentUser)
                }}
                {{on "click" this.submitComment}}
              >
                {{#if this.isSubmittingComment}}
                  {{ftIcon "loader"}}
                {{else}}
                  {{ftIcon "arrow-up"}}
                {{/if}}
              </button>
            </div>
          </div>
        </div>
      </article>
    {{/unless}}
  </template>
}
