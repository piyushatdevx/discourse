import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { ajax } from "discourse/lib/ajax";
import { extractError, popupAjaxError } from "discourse/lib/ajax-error";
import { not, or } from "discourse/truth-helpers";
import ftIcon from "../helpers/ft-icon";
import FantribePostMenu from "./fantribe-post-menu";
import FantribePostMoreTopics from "./fantribe-post-more-topics";

const REACTIONS = [
  { emoji: "🎵", key: "musical_note" },
  { emoji: "🔥", key: "fire" },
  { emoji: "❤️", key: "heart" },
];

export default class FantribePostFullPage extends Component {
  @service currentUser;
  @service site;
  @service toasts;

  @tracked currentImageIndex = 0;
  @tracked menuOpen = false;
  @tracked commentText = "";
  @tracked isSubmittingComment = false;
  @tracked reactionsLoaded = false;
  @tracked isBookmarkLoading = false;
  @tracked isReactionLoading = false;
  @tracked _localComments = null;
  @tracked _serverComments = null;
  @tracked _serverReactions = null;
  @tracked _localReactions = null;
  @tracked _isBookmarked = null;
  @tracked _bookmarkId = null;

  constructor(owner, args) {
    super(owner, args);
    document.body.classList.add("ft-full-post-active");
    this.loadReactions();
    this.loadComments();
  }

  willDestroy() {
    super.willDestroy();
    document.body.classList.remove("ft-full-post-active");
  }

  get topic() {
    return this.args.topic;
  }

  get firstPost() {
    return this.topic?.postStream?.posts?.[0];
  }

  get poster() {
    return this.firstPost?.user || this.topic?.posters?.[0]?.user;
  }

  get displayName() {
    return this.poster?.name || this.poster?.username || "Unknown";
  }

  get posterUsername() {
    return this.poster?.username || "unknown";
  }

  get posterRoleName() {
    return this.poster?.primary_group_name || null;
  }

  get tribeCategory() {
    const catId =
      this.topic?.category_id ||
      this.topic?.categoryId ||
      this.topic?.get?.("category_id");
    if (!catId) {
      return null;
    }
    return (this.site.categories || []).find((c) => c.id === catId) || null;
  }

  get images() {
    const cooked = this.firstPost?.cooked;
    if (cooked) {
      const parser = new DOMParser();
      const doc = parser.parseFromString(cooked, "text/html");

      // Prefer lightbox anchor hrefs (full-size images)
      const lightboxLinks = doc.querySelectorAll("a.lightbox");
      if (lightboxLinks.length > 0) {
        return Array.from(lightboxLinks)
          .map((a) => ({ url: a.getAttribute("href") }))
          .filter((img) => img.url && !img.url.includes("emoji"));
      }

      // Fallback: non-emoji, non-avatar img tags
      const imgs = doc.querySelectorAll(
        "img[src]:not(.emoji):not(.avatar):not(.site-icon)"
      );
      const urls = Array.from(imgs)
        .map((img) => ({ url: img.getAttribute("src") }))
        .filter((img) => img.url);
      if (urls.length > 0) {
        return urls;
      }
    }

    // Final fallback to topic image_url
    const url = this.topic?.image_url;
    return url ? [{ url }] : [];
  }

  get hasImages() {
    return this.images.length > 0;
  }

  get hasMultipleImages() {
    return this.images.length > 1;
  }

  get currentImage() {
    return this.images[this.currentImageIndex] || null;
  }

  get imageIndicator() {
    return `${this.currentImageIndex + 1}/${this.images.length}`;
  }

  get hasPrevImage() {
    return this.currentImageIndex > 0;
  }

  get hasNextImage() {
    return this.currentImageIndex < this.images.length - 1;
  }

  get reactions() {
    const serverReactions = this._serverReactions || [];
    return REACTIONS.map((r) => {
      const server = serverReactions.find((sr) => sr.id === r.key);
      const local = (this._localReactions || []).find((lr) => lr.id === r.key);
      const count = local?.count ?? server?.count ?? 0;
      const isActive =
        local?.current_user_used ?? server?.current_user_used ?? false;
      return { ...r, count, isActive };
    });
  }

  get hasReactions() {
    return this.reactions.some((r) => r.count > 0);
  }

  get tags() {
    return this.topic?.tags || [];
  }

  get hasTags() {
    return this.tags.length > 0;
  }

  get cookedBodyHtml() {
    const cooked = this.firstPost?.cooked;
    if (!cooked) {
      return null;
    }
    const parser = new DOMParser();
    const doc = parser.parseFromString(cooked, "text/html");
    // Remove lightbox wrappers (shown in carousel) and video embeds
    doc.querySelectorAll(".lightbox-wrapper").forEach((el) => el.remove());
    doc
      .querySelectorAll("img:not(.emoji)")
      .forEach((img) => img.parentElement?.remove?.() || img.remove());
    const html = doc.body.innerHTML.trim();
    return html ? htmlSafe(html) : null;
  }

  get comments() {
    const localComments = this._localComments || [];

    if (this._serverComments !== null) {
      // Server comments loaded — append any locally-posted ones not yet in the list
      const serverIds = new Set(this._serverComments.map((c) => c.id));
      const unsyncedLocal = localComments.filter((c) => !serverIds.has(c.id));
      return [
        ...this._serverComments,
        ...unsyncedLocal.map((c, i) => ({
          ...c,
          initials: this.getInitials(c.user?.name || c.user?.username),
          gradientClass: `ft-full-post__comment-avatar--gradient-${((this._serverComments.length + i) % 4) + 1}`,
        })),
      ];
    }

    // Fallback while server load is in-flight: use pre-loaded postStream posts
    const posts = this.topic?.postStream?.posts || [];
    const localIds = new Set(localComments.map((c) => c.id).filter(Boolean));
    const postComments = posts
      .slice(1)
      .filter((post) => !localIds.has(post.id))
      .map((post, index) => {
        const raw = post.raw || this._getPlainText(post.cooked) || "";
        return {
          id: post.id,
          user: post.user,
          raw,
          created_at: post.createdAt || post.created_at,
          initials: this.getInitials(post.user?.name || post.user?.username),
          gradientClass: `ft-full-post__comment-avatar--gradient-${(index % 4) + 1}`,
        };
      });

    return [
      ...postComments,
      ...localComments.map((c, i) => ({
        ...c,
        initials: this.getInitials(c.user?.name || c.user?.username),
        gradientClass: `ft-full-post__comment-avatar--gradient-${((postComments.length + i) % 4) + 1}`,
      })),
    ];
  }

  get replyCount() {
    const count =
      this.topic?.posts_count ??
      this.topic?.postsCount ??
      this.topic?.get?.("posts_count");
    return count ? count - 1 : 0;
  }

  get viewCount() {
    return this.topic?.views || 0;
  }

  get topicTitle() {
    return this.topic?.title || "";
  }

  get topicId() {
    return this.topic?.id;
  }

  get firstPostId() {
    return this.firstPost?.id || this.topic?.first_post_id;
  }

  get isOwnPost() {
    if (!this.currentUser || !this.poster) {
      return false;
    }
    return this.currentUser.username === this.poster.username;
  }

  get canComment() {
    return !!this.currentUser && !this.topic?.closed;
  }

  get topicClosed() {
    return this.topic?.closed || false;
  }

  get isBookmarked() {
    if (this._isBookmarked !== null) {
      return this._isBookmarked;
    }
    return this.topic?.bookmarked || false;
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

  _getPlainText(cooked) {
    if (!cooked) {
      return "";
    }
    const parser = new DOMParser();
    const doc = parser.parseFromString(cooked, "text/html");
    return doc.body.textContent?.trim() || "";
  }

  async loadReactions() {
    const postId = this.firstPostId;
    if (!postId) {
      return;
    }
    try {
      const result = await ajax(
        `/discourse-reactions/posts/${postId}/reactions_users.json`
      );
      this._serverReactions = (result || []).map((r) => ({
        id: r.id,
        count: r.count || 0,
        current_user_used:
          r.users?.some?.((u) => u.username === this.currentUser?.username) ||
          false,
      }));
    } catch {
      // Silently ignore — reactions plugin may not be installed
    } finally {
      this.reactionsLoaded = true;
    }
  }

  async loadComments() {
    const topicId = this.topicId;
    if (!topicId) {
      return;
    }
    try {
      const topicData = await ajax(`/t/${topicId}.json`);
      const streamIds = topicData?.post_stream?.stream || [];
      // Skip post_number 1 (the OP) — replies start from index 1
      const replyIds = streamIds.slice(1);
      if (replyIds.length === 0) {
        this._serverComments = [];
        return;
      }
      const BATCH_SIZE = 200;
      const allPosts = [];
      for (let i = 0; i < replyIds.length; i += BATCH_SIZE) {
        const batch = replyIds.slice(i, i + BATCH_SIZE);
        const params = batch.map((id) => `post_ids[]=${id}`).join("&");
        const result = await ajax(`/t/${topicId}/posts.json?${params}`);
        allPosts.push(...(result?.post_stream?.posts || []));
      }
      this._serverComments = allPosts.map((post, index) => ({
        id: post.id,
        user: {
          id: post.user_id,
          username: post.username,
          name: post.name || post.username,
          avatar_template: post.avatar_template,
        },
        raw: post.raw || this._getPlainText(post.cooked) || "",
        created_at: post.created_at,
        initials: this.getInitials(post.name || post.username),
        gradientClass: `ft-full-post__comment-avatar--gradient-${(index % 4) + 1}`,
      }));
    } catch {
      this._serverComments = [];
    }
  }

  @action
  goBack() {
    history.back();
  }

  @action
  prevImage() {
    if (this.currentImageIndex > 0) {
      this.currentImageIndex--;
    }
  }

  @action
  nextImage() {
    if (this.currentImageIndex < this.images.length - 1) {
      this.currentImageIndex++;
    }
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
  updateCommentText(event) {
    this.commentText = event.target.value;
  }

  @action
  handleCommentKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      this.submitComment(event);
    }
  }

  @action
  async submitComment(event) {
    event?.stopPropagation?.();
    if (
      !this.canComment ||
      this.isSubmittingComment ||
      !this.commentText.trim()
    ) {
      return;
    }
    const topicId = this.topicId;
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
      this.commentText = "";
      if (result) {
        const newComment = {
          id: result.id,
          raw: commentText,
          created_at: new Date().toISOString(),
          user: {
            id: this.currentUser.id,
            username: this.currentUser.username,
            name: this.currentUser.name || this.currentUser.username,
            avatar_template: this.currentUser.avatar_template,
          },
        };
        this._localComments = [...(this._localComments || []), newComment];
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmittingComment = false;
    }
  }

  @action
  async toggleReaction(key, event) {
    event?.stopPropagation?.();
    if (!this.currentUser || this.isReactionLoading || !this.firstPostId) {
      return;
    }

    const currentReactions = this.reactions;
    const clickedReaction = currentReactions.find((r) => r.key === key);
    const wasActive = clickedReaction?.isActive ?? false;
    const previouslyActive = currentReactions.find(
      (r) => r.isActive && r.key !== key
    );

    const baseReactions = this._localReactions || this._serverReactions || [];
    this._localReactions = REACTIONS.map((r) => {
      const base = baseReactions.find((br) => br.id === r.key);
      const baseCount = base?.count ?? 0;
      const baseActive = base?.current_user_used ?? false;

      if (r.key === key) {
        return {
          id: r.key,
          count: wasActive ? Math.max(0, baseCount - 1) : baseCount + 1,
          current_user_used: !wasActive,
        };
      }

      if (!wasActive && previouslyActive && r.key === previouslyActive.key) {
        return {
          id: r.key,
          count: Math.max(0, baseCount - 1),
          current_user_used: false,
        };
      }

      return { id: r.key, count: baseCount, current_user_used: baseActive };
    });

    this.isReactionLoading = true;
    try {
      await ajax(
        `/discourse-reactions/posts/${this.firstPostId}/custom-reactions/${key}/toggle`,
        { type: "PUT" }
      );
    } catch (error) {
      this._localReactions = null;
      const message = extractError(error) || "";
      const isRateLimit =
        error?.jqXHR?.status === 429 ||
        message.toLowerCase().includes("too many");
      if (!isRateLimit) {
        popupAjaxError(error);
      }
    } finally {
      this.isReactionLoading = false;
    }
  }

  @action
  async handleBookmark(event) {
    event.stopPropagation();
    if (!this.currentUser || this.isBookmarkLoading) {
      return;
    }
    const wasBookmarked = this.isBookmarked;
    this._isBookmarked = !wasBookmarked;
    this.isBookmarkLoading = true;
    try {
      if (wasBookmarked) {
        const bookmarkId = this._bookmarkId || this.topic?.bookmark_id;
        if (bookmarkId) {
          await ajax(`/bookmarks/${bookmarkId}`, { type: "DELETE" });
        }
        this._bookmarkId = null;
      } else {
        const result = await ajax("/bookmarks", {
          type: "POST",
          data: {
            bookmarkable_id: this.firstPostId,
            bookmarkable_type: "Post",
          },
        });
        this._bookmarkId = result?.id ?? null;
      }
    } catch (error) {
      this._isBookmarked = wasBookmarked;
      popupAjaxError(error);
    } finally {
      this.isBookmarkLoading = false;
    }
  }

  @action
  handleShare(event) {
    event.stopPropagation();
    const url = window.location.href;
    navigator.clipboard?.writeText?.(url).catch(() => {});
    this.toasts?.success?.({ data: { message: "Link copied!" } });
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="ft-full-post-layout">
      <div class="ft-full-post-layout__content">
        <div class="ft-full-post">
          <div class="ft-full-post__card">

            {{! ===== HEADER ===== }}
            <div class="ft-full-post__header">
              <div class="ft-full-post__header-left">
                <button
                  type="button"
                  class="ft-full-post__back-btn"
                  {{on "click" this.goBack}}
                >
                  {{ftIcon "chevron-left"}}
                </button>

                <div class="ft-full-post__author-block">
                  <div class="ft-full-post__avatar-wrapper">
                    {{#if this.poster}}
                      {{avatar this.poster imageSize="medium"}}
                    {{/if}}
                  </div>
                  <div class="ft-full-post__author-meta">
                    <span
                      class="ft-full-post__author-name"
                    >{{this.displayName}}</span>
                    <div class="ft-full-post__author-info">
                      <span
                        class="ft-full-post__author-handle"
                      >@{{this.posterUsername}}</span>
                      <span class="ft-full-post__separator">&middot;</span>
                      <span class="ft-full-post__timestamp">
                        {{#if this.firstPost.createdAt}}
                          {{formatDate this.firstPost.createdAt format="tiny"}}
                        {{else if this.topic.created_at}}
                          {{formatDate this.topic.created_at format="tiny"}}
                        {{/if}}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="ft-full-post__header-right">
                {{#if this.tribeCategory}}
                  <button
                    type="button"
                    class="ft-full-post__category-pill"
                  >{{this.tribeCategory.name}}</button>
                {{/if}}
                {{#if this.posterRoleName}}
                  <span
                    class="ft-full-post__role-badge"
                  >{{this.posterRoleName}}</span>
                {{/if}}
                <div class="ft-full-post__menu-wrapper">
                  <button
                    type="button"
                    class="ft-full-post__more-btn"
                    {{on "click" this.toggleMenu}}
                  >
                    {{ftIcon "more-horizontal"}}
                  </button>
                  <FantribePostMenu
                    @isOpen={{this.menuOpen}}
                    @onClose={{this.closeMenu}}
                    @onDismiss={{this.closeMenu}}
                    @isOwnPost={{this.isOwnPost}}
                    @userName={{this.posterUsername}}
                    @topic={{this.topic}}
                    @firstPostId={{this.firstPostId}}
                    @topicClosed={{this.topicClosed}}
                    @onClosedChange={{this.closeMenu}}
                  />
                </div>
              </div>
            </div>

            {{! ===== CONTENT ===== }}
            <div class="ft-full-post__content">

              {{! Title + Action Icons }}
              <div class="ft-full-post__title-section">
                <div class="ft-full-post__title-row">
                  <h1 class="ft-full-post__title">{{this.topicTitle}}</h1>
                  <div class="ft-full-post__title-actions">
                    <button
                      type="button"
                      class="ft-full-post__action-btn"
                      {{on "click" this.handleShare}}
                    >
                      {{ftIcon "share"}}
                    </button>
                    <button
                      type="button"
                      class="ft-full-post__action-btn
                        {{if
                          this.isBookmarked
                          'ft-full-post__action-btn--active'
                        }}"
                      disabled={{this.isBookmarkLoading}}
                      {{on "click" this.handleBookmark}}
                    >
                      {{#if this.isBookmarked}}
                        {{ftIcon "bookmark-fill"}}
                      {{else}}
                        {{ftIcon "bookmark"}}
                      {{/if}}
                    </button>
                    {{#if this.isOwnPost}}
                      <button type="button" class="ft-full-post__action-btn">
                        {{ftIcon "edit3"}}
                      </button>
                    {{/if}}
                  </div>
                </div>

                {{! Post Body Text }}
                {{#if this.cookedBodyHtml}}
                  <div class="ft-full-post__body">
                    {{this.cookedBodyHtml}}
                  </div>
                {{/if}}
              </div>

              {{! ===== TWO COLUMNS ===== }}
              <div class="ft-full-post__columns">

                {{! LEFT COLUMN: Image + Gear + Reactions + Stats }}
                <div class="ft-full-post__left-col">
                  {{! Top: image + gear tags (gap-12 between them, matching Figma node 539:36411) }}
                  <div class="ft-full-post__left-top">
                    {{! Image Carousel }}
                    {{#if this.hasImages}}
                      <div class="ft-full-post__carousel">
                        <img
                          src={{this.currentImage.url}}
                          alt="Post image"
                          class="ft-full-post__carousel-img"
                          loading="lazy"
                        />
                        {{#if this.hasMultipleImages}}
                          <div class="ft-full-post__img-indicator">
                            {{this.imageIndicator}}
                          </div>
                          {{#if this.hasPrevImage}}
                            <button
                              type="button"
                              class="ft-full-post__carousel-nav ft-full-post__carousel-nav--prev"
                              {{on "click" this.prevImage}}
                            >
                              {{ftIcon "chevron-left"}}
                            </button>
                          {{/if}}
                          {{#if this.hasNextImage}}
                            <button
                              type="button"
                              class="ft-full-post__carousel-nav ft-full-post__carousel-nav--next"
                              {{on "click" this.nextImage}}
                            >
                              {{ftIcon "chevron-right"}}
                            </button>
                          {{/if}}
                        {{/if}}
                      </div>
                    {{/if}}

                    {{! Gear Tags (rendered from topic tags) }}
                    {{#if this.hasTags}}
                      <div class="ft-full-post__gear-row">
                        <div class="ft-full-post__gear-pills">
                          {{#each this.tags as |tag|}}
                            <button
                              type="button"
                              class="ft-full-post__gear-pill"
                            >
                              <span>#{{tag}}</span>
                            </button>
                          {{/each}}
                        </div>
                      </div>
                    {{/if}}
                  </div>

                  <div class="ft-full-post__left-bottom">
                    <div class="ft-full-post__reactions-row">
                      <div class="ft-full-post__reactions">
                        {{#each this.reactions as |reaction|}}
                          {{#if reaction.count}}
                            <button
                              type="button"
                              class="ft-full-post__reaction-pill
                                {{if
                                  reaction.isActive
                                  'ft-full-post__reaction-pill--active'
                                }}"
                              disabled={{or
                                this.isReactionLoading
                                (not this.currentUser)
                              }}
                              {{on
                                "click"
                                (fn this.toggleReaction reaction.key)
                              }}
                            >
                              <span
                                class="ft-full-post__reaction-emoji"
                              >{{reaction.emoji}}</span>
                              <span
                                class="ft-full-post__reaction-count"
                              >{{reaction.count}}</span>
                            </button>
                          {{/if}}
                        {{/each}}
                      </div>

                      {{! Comment + View Counts }}
                      <div class="ft-full-post__stats">
                        <span class="ft-full-post__stat">
                          {{ftIcon "message-circle"}}
                          <span>{{this.replyCount}}</span>
                        </span>
                        <span class="ft-full-post__stat">
                          {{ftIcon "eye"}}
                          <span>{{this.viewCount}}</span>
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {{! RIGHT COLUMN: Comments }}
                <div class="ft-full-post__right-col">
                  <div class="ft-full-post__comments-inner">
                    <span class="ft-full-post__comments-label">Comments</span>
                    <div class="ft-full-post__comments-list">
                      {{#each this.comments as |comment|}}
                        <div class="ft-full-post__comment">
                          <div
                            class="ft-full-post__comment-avatar
                              {{comment.gradientClass}}"
                          >
                            <span
                              class="ft-full-post__comment-initials"
                            >{{comment.initials}}</span>
                          </div>
                          <div class="ft-full-post__comment-body">
                            <div class="ft-full-post__comment-header">
                              <span
                                class="ft-full-post__comment-author"
                              >{{comment.user.name}}</span>
                              <span class="ft-full-post__comment-time">
                                {{formatDate comment.created_at format="tiny"}}
                              </span>
                            </div>
                            <p
                              class="ft-full-post__comment-text"
                            >{{comment.raw}}</p>
                          </div>
                        </div>
                      {{/each}}
                    </div>
                  </div>

                  {{! Comment Input }}
                  <div class="ft-full-post__comment-input-row">
                    <div class="ft-full-post__comment-input-avatar">
                      {{#if this.currentUser}}
                        {{avatar this.currentUser imageSize="medium"}}
                      {{/if}}
                    </div>
                    <div class="ft-full-post__comment-input-wrap">
                      <input
                        type="text"
                        class="ft-full-post__comment-input"
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
                        {{on "input" this.updateCommentText}}
                        {{on "keydown" this.handleCommentKeydown}}
                      />
                      <button type="button" class="ft-full-post__emoji-btn">
                        {{ftIcon "smile"}}
                      </button>
                    </div>
                  </div>
                </div>

              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="ft-full-post-layout__sidebar">
        <FantribePostMoreTopics />
      </div>
    </div>
  </template>
}
