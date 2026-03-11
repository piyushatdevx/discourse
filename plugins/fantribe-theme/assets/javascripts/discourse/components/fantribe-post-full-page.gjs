import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { modifier } from "ember-modifier";
import DecoratedHtml from "discourse/components/decorated-html";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { ajax } from "discourse/lib/ajax";
import { extractError, popupAjaxError } from "discourse/lib/ajax-error";
import { not, or } from "discourse/truth-helpers";
import ftIcon from "../helpers/ft-icon";
import FantribeMediaCarousel from "./fantribe-media-carousel";
import FantribePostMenu from "./fantribe-post-menu";
import FantribePostMoreTopics from "./fantribe-post-more-topics";

const ONEBOX_SELECTOR =
  "aside.onebox, div.youtube-onebox, div.onebox, div.lazy-video-container";

const MOBILE_BREAKPOINT = 768;
const MOBILE_PAGE_SIZE = 10;

const REACTIONS = [
  { emoji: "🎵", key: "musical_note" },
  { emoji: "🔥", key: "fire" },
  { emoji: "❤️", key: "heart" },
  { emoji: "👏", key: "clap" },
];

export default class FantribePostFullPage extends Component {
  @service currentUser;
  @service fantribeCreate;
  @service fantribeFeedState;
  @service site;
  @service toasts;

  @tracked menuOpen = false;
  @tracked commentText = "";
  @tracked isSubmittingComment = false;
  @tracked reactionsLoaded = false;
  @tracked isBookmarkLoading = false;
  @tracked isReactionLoading = false;

  watchTopic = modifier((el, [topicId]) => {
    if (!topicId) {
      return;
    }
    this._serverComments = null;
    this._localComments = null;
    this._serverReactions = null;
    this._localReactions = null;
    this._isBookmarked = null;
    this._bookmarkId = null;
    this._viewCount = null;
    this.reactionsLoaded = false;
    this.commentText = "";
    this._displayedCommentCount = MOBILE_PAGE_SIZE;
    this.loadReactions();
    this.loadComments();
    this.recordView();
  });

  setupMobileDetection = modifier(() => {
    const INLINE_STYLE_TARGETS = [
      "html",
      "body",
      "#main",
      "#main-outlet-wrapper",
      "#main-outlet",
      "#main-outlet .ember-view",
      "#main-outlet .row",
      "#main-outlet .container",
      "#main-outlet .container.posts",
      "#main-outlet .posts-wrapper",
      ".topic-area",
      "section#topic",
    ];

    const unlockAll = () => {
      document.documentElement.style.setProperty("height", "auto", "important");
      document.body.style.setProperty("overflow-y", "auto", "important");
      document.body.style.setProperty("height", "auto", "important");
      for (const sel of INLINE_STYLE_TARGETS.slice(2)) {
        for (const el of document.querySelectorAll(sel)) {
          el.style.setProperty("height", "auto", "important");
          el.style.setProperty("max-height", "none", "important");
          el.style.setProperty("overflow-y", "visible", "important");
        }
      }
    };

    const restoreAll = () => {
      document.documentElement.style.removeProperty("height");
      document.body.style.removeProperty("overflow-y");
      document.body.style.removeProperty("height");
      for (const sel of INLINE_STYLE_TARGETS.slice(2)) {
        for (const el of document.querySelectorAll(sel)) {
          el.style.removeProperty("height");
          el.style.removeProperty("max-height");
          el.style.removeProperty("overflow-y");
        }
      }
    };

    // Safe MutationObserver to prevent Discourse re-applying inline styles without looping
    let observer = null;
    const startObserver = () => {
      if (observer) {
        observer.disconnect();
      }

      observer = new MutationObserver(() => {
        // Pausing observer to avoid infinite loop when we change styles
        observer.disconnect();
        unlockAll();
        // Resume observing
        observeTargets();
      });
      observeTargets();
    };

    const observeTargets = () => {
      for (const sel of INLINE_STYLE_TARGETS) {
        for (const el of document.querySelectorAll(sel)) {
          observer.observe(el, {
            attributes: true,
            attributeFilter: ["style"],
          });
        }
      }
    };

    const update = () => {
      const isCurrentlyMobile = window.innerWidth <= MOBILE_BREAKPOINT;

      if (isCurrentlyMobile !== this._isMobile) {
        this._isMobile = isCurrentlyMobile;

        if (this._isMobile) {
          requestAnimationFrame(() => {
            unlockAll();
            startObserver();
          });
        } else {
          observer?.disconnect();
          observer = null;
          restoreAll();
        }
      }
    };

    // Initial setup
    this._isMobile = window.innerWidth <= MOBILE_BREAKPOINT;
    if (this._isMobile) {
      requestAnimationFrame(() => {
        unlockAll();
        startObserver();
      });
      // Discourse sometimes applies height late on mount, check again after 500ms
      setTimeout(() => {
        if (this._isMobile) {
          observer?.disconnect();
          unlockAll();
          observeTargets();
        }
      }, 500);
    }

    window.addEventListener("resize", update, { passive: true });

    return () => {
      window.removeEventListener("resize", update);
      observer?.disconnect();
      restoreAll();
    };
  });

  setupScrollSentinel = modifier((el) => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting) {
          this.loadMoreComments();
        }
      },
      { rootMargin: "200px" }
    );
    observer.observe(el);
    return () => observer.disconnect();
  });

  @tracked _localComments = null;
  @tracked _serverComments = null;
  @tracked _serverReactions = null;
  @tracked _localReactions = null;
  @tracked _isBookmarked = null;
  @tracked _bookmarkId = null;
  @tracked _viewCount = null;
  @tracked _displayedCommentCount = MOBILE_PAGE_SIZE;
  @tracked _isMobile = false;

  constructor(owner, args) {
    super(owner, args);
  }

  willDestroy() {
    super.willDestroy();
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

  get mediaItems() {
    const cooked = this.firstPost?.cooked;
    // eslint-disable-next-line no-console
    console.log("[Audio Debug] Cooked HTML:", cooked);
    if (!cooked) {
      return [];
    }

    const parser = new DOMParser();
    const doc = parser.parseFromString(cooked, "text/html");
    const items = [];

    // Videos
    doc
      .querySelectorAll("div.video-placeholder-container[data-video-src]")
      .forEach((container) => {
        items.push({
          type: "video",
          url: container.getAttribute("data-video-src"),
          thumbnail_url: container.getAttribute("data-thumbnail-src"),
        });
      });

    // Audio
    doc
      .querySelectorAll("div.audio-placeholder-container[data-audio-src]")
      .forEach((container) => {
        items.push({
          type: "audio",
          url: container.getAttribute("data-audio-src"),
        });
      });

    // Images (prefer lightbox anchors for full-size)
    const lightboxLinks = doc.querySelectorAll("a.lightbox");
    if (lightboxLinks.length > 0) {
      lightboxLinks.forEach((a) => {
        const url = a.getAttribute("href");
        if (url && !url.includes("emoji")) {
          items.push({ type: "image", url });
        }
      });
    } else {
      // Fallback: non-emoji, non-avatar img tags
      doc
        .querySelectorAll("img[src]:not(.emoji):not(.avatar):not(.site-icon)")
        .forEach((img) => {
          const url = img.getAttribute("src");
          if (url) {
            items.push({ type: "image", url });
          }
        });
    }

    // Final fallback to topic image_url if no media found
    if (items.length === 0 && this.topic?.image_url) {
      items.push({ type: "image", url: this.topic.image_url });
    }

    // eslint-disable-next-line no-console
    console.log("[Audio Debug] Extracted media items:", items);
    return items;
  }

  get hasMedia() {
    return this.mediaItems.length > 0;
  }

  get firstOneboxHtml() {
    const cooked = this.firstPost?.cooked;
    if (!cooked) {
      return null;
    }
    const parser = new DOMParser();
    const doc = parser.parseFromString(cooked, "text/html");
    const onebox = doc.querySelector(ONEBOX_SELECTOR);
    if (!onebox) {
      return null;
    }
    const html = onebox.outerHTML;
    return html ? htmlSafe(html) : null;
  }

  get hasOnebox() {
    return !!this.firstOneboxHtml;
  }

  get reactions() {
    // Prefer feedState so counts are immediately in sync when the full page
    // opens after reacting via a feed card (and vice versa).
    const feedStateReactions =
      this.fantribeFeedState?.topicUpdates?.[this.topicId]?.reactions;
    const serverReactions = feedStateReactions || this._serverReactions || [];
    return REACTIONS.map((r) => {
      const server = serverReactions.find((sr) => sr.id === r.key);
      const local = (this._localReactions || []).find((lr) => lr.id === r.key);
      const count = local?.count ?? server?.count ?? 0;
      const isActive =
        local?.current_user_used ?? server?.current_user_used ?? false;
      const cssKey = r.key.replace(/_/g, "-");
      return {
        ...r,
        count,
        isActive,
        activeClass: isActive
          ? `ft-full-post__reaction-pill--${cssKey}-active`
          : "",
      };
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
    doc.querySelectorAll(".lightbox-wrapper").forEach((el) => el.remove());
    doc.querySelectorAll(ONEBOX_SELECTOR).forEach((el) => el.remove());
    doc
      .querySelectorAll("div.video-placeholder-container")
      .forEach((el) => el.remove());
    doc
      .querySelectorAll("div.audio-placeholder-container")
      .forEach((el) => el.remove());
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

  // On mobile, show a paged slice; on desktop show all.
  get visibleComments() {
    if (this._isMobile) {
      return this.comments.slice(0, this._displayedCommentCount);
    }
    return this.comments;
  }

  get hasMoreComments() {
    return this._isMobile && this._displayedCommentCount < this.comments.length;
  }

  get replyCount() {
    const count =
      this.topic?.posts_count ??
      this.topic?.postsCount ??
      this.topic?.get?.("posts_count");
    return count ? count - 1 : 0;
  }

  get viewCount() {
    // _viewCount is set by recordView() after POST /fantribe/topics/:id/view,
    // which calls TopicViewItem.add synchronously and returns the fresh count.
    // Falls back to the route-model value (pre-visit count) until the POST
    // completes.
    return this._viewCount ?? this.topic?.views ?? 0;
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

  async recordView() {
    const topicId = this.topicId;
    if (!topicId || !this.currentUser) {
      return;
    }
    try {
      const result = await ajax(`/fantribe/topics/${topicId}/view`, {
        type: "POST",
      });
      if (typeof result?.views === "number") {
        this._viewCount = result.views;
      }
    } catch {
      // Silently ignore — view tracking is non-critical
    }
  }

  async loadReactions() {
    const postId = this.firstPostId;
    if (!postId) {
      return;
    }
    try {
      // Route: GET /discourse-reactions/posts/:id/reactions-users (dash, not underscore)
      // Response: { reaction_users: [{id, count, users: [{username, ...}]}] }
      const result = await ajax(
        `/discourse-reactions/posts/${postId}/reactions-users.json`
      );
      this._serverReactions = (result?.reaction_users || []).map((r) => ({
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
  loadMoreComments() {
    this._displayedCommentCount += MOBILE_PAGE_SIZE;
  }

  @action
  goBack() {
    history.back();
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

    // Mirror the same priority as the reactions getter: local → feedState → server.
    // Without the feedState fallback, switching reactions from the full page
    // while _serverReactions is still loading (or after a reverted error) would
    // use stale/empty counts as the base for the optimistic update.
    const feedStateReactions =
      this.fantribeFeedState?.topicUpdates?.[this.topicId]?.reactions;
    const baseReactions =
      this._localReactions || feedStateReactions || this._serverReactions || [];
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
      if (this.topicId) {
        this.fantribeFeedState?.updateTopic(this.topicId, {
          reactions: this._localReactions,
        });
      }
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

  @action
  async handleEditPost(event) {
    event.stopPropagation();
    const postId = this.firstPostId;
    if (!postId) {
      return;
    }
    try {
      const result = await ajax(`/posts/${postId}.json`);
      this.fantribeCreate.openEditPostModal(
        result,
        this.topic?.title,
        this.topic?.tags || []
      );
    } catch (error) {
      popupAjaxError(error);
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-full-post-layout
        {{unless this.hasMedia 'ft-full-post-layout--no-image'}}"
      {{this.watchTopic this.topicId}}
      {{this.setupMobileDetection}}
    >
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
            <div
              class="ft-full-post__content
                {{unless this.hasMedia 'ft-full-post__content--no-image'}}"
            >

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
                      <button
                        type="button"
                        class="ft-full-post__action-btn"
                        {{on "click" this.handleEditPost}}
                      >
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

              {{! ===== WITH IMAGE: two columns (left: image + gear + reactions | right: comments) ===== }}
              {{! ===== NO IMAGE: single column (gear + reactions then comments below) — Figma node 785-3194 ===== }}
              <div class="ft-full-post__columns">
                {{! LEFT COLUMN: Image + Gear + Reactions + Stats (or gear + reactions only when no image) }}
                <div class="ft-full-post__left-col">
                  <div class="ft-full-post__left-top">
                    {{#if this.hasMedia}}
                      <FantribeMediaCarousel @mediaItems={{this.mediaItems}} />
                    {{else if this.hasOnebox}}
                      <div class="ft-full-post__onebox">
                        <DecoratedHtml @html={{this.firstOneboxHtml}} />
                      </div>
                    {{/if}}

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
                          <button
                            type="button"
                            class="ft-full-post__reaction-pill
                              {{reaction.activeClass}}"
                            disabled={{or
                              this.isReactionLoading
                              (not this.currentUser)
                            }}
                            {{on "click" (fn this.toggleReaction reaction.key)}}
                          >
                            <span
                              class="ft-full-post__reaction-emoji"
                            >{{reaction.emoji}}</span>
                            <span
                              class="ft-full-post__reaction-count"
                            >{{reaction.count}}</span>
                          </button>
                        {{/each}}
                      </div>

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

                {{! RIGHT COLUMN: Comments (hidden when no media; comments move to no-image block below) }}
                {{#if (or this.hasMedia this.hasOnebox)}}
                  <div class="ft-full-post__right-col">
                    <div class="ft-full-post__comments-inner">
                      <span class="ft-full-post__comments-label">Comments</span>
                      <div class="ft-full-post__comments-list">
                        {{#each this.visibleComments as |comment|}}
                          <div class="ft-full-post__comment">
                            <div
                              class="ft-full-post__comment-avatar
                                {{unless comment.user comment.gradientClass}}"
                            >
                              {{#if comment.user}}
                                {{avatar comment.user imageSize="small"}}
                              {{else}}
                                <span
                                  class="ft-full-post__comment-initials"
                                >{{comment.initials}}</span>
                              {{/if}}
                            </div>
                            <div class="ft-full-post__comment-body">
                              <div class="ft-full-post__comment-header">
                                <span
                                  class="ft-full-post__comment-author"
                                >{{comment.user.name}}</span>
                                <span class="ft-full-post__comment-time">
                                  {{formatDate
                                    comment.created_at
                                    format="tiny"
                                  }}
                                </span>
                              </div>
                              <p
                                class="ft-full-post__comment-text"
                              >{{comment.raw}}</p>
                            </div>
                          </div>
                        {{/each}}
                        {{#if this.hasMoreComments}}
                          <div
                            class="ft-full-post__comments-sentinel"
                            {{this.setupScrollSentinel}}
                          ></div>
                        {{/if}}
                      </div>
                    </div>

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
                {{/if}}
              </div>

              {{! NO MEDIA: comments section full width below (Figma node 785-3194) }}
              {{#unless (or this.hasMedia this.hasOnebox)}}
                <div
                  class="ft-full-post__comments-block ft-full-post__comments-block--no-image"
                >
                  <span class="ft-full-post__comments-label">Comments</span>
                  <div class="ft-full-post__comments-list">
                    {{#each this.visibleComments as |comment|}}
                      <div class="ft-full-post__comment">
                        <div
                          class="ft-full-post__comment-avatar
                            {{unless comment.user comment.gradientClass}}"
                        >
                          {{#if comment.user}}
                            {{avatar comment.user imageSize="small"}}
                          {{else}}
                            <span
                              class="ft-full-post__comment-initials"
                            >{{comment.initials}}</span>
                          {{/if}}
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
                    {{#if this.hasMoreComments}}
                      <div
                        class="ft-full-post__comments-sentinel"
                        {{this.setupScrollSentinel}}
                      ></div>
                    {{/if}}
                  </div>

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
              {{/unless}}
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
