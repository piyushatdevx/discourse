import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq, not, or } from "discourse/truth-helpers";
import ftIcon from "../helpers/ft-icon";

const PAGE_SIZE = 20;

const GRADIENT_CLASSES = [
  "ft-comment-panel__avatar--gradient-1",
  "ft-comment-panel__avatar--gradient-2",
  "ft-comment-panel__avatar--gradient-3",
  "ft-comment-panel__avatar--gradient-4",
];

export default class FtCommentPanel extends Component {
  @service currentUser;

  @tracked isLoading = true;
  @tracked commentText = "";
  @tracked isSubmitting = false;
  @tracked replyingTo = null;
  setupPanel = modifier(() => {
    this.loadComments();

    return () => {
      this._serverComments = null;
      this._localComments = null;
      this._likeLoadingIds = [];
      this._expandedThreads = new Set();
      this._displayedCount = PAGE_SIZE;
      this.commentText = "";
      this.replyingTo = null;
    };
  });
  setupDrag = modifier((el) => {
    const handle = el.querySelector(".ft-comment-panel__drag-handle");
    if (!handle) {
      return;
    }

    let startY = 0;
    let currentY = 0;

    const onTouchStart = (e) => {
      startY = e.touches[0].clientY;
      currentY = 0;
      el.style.transition = "none";
    };

    const onTouchMove = (e) => {
      currentY = e.touches[0].clientY - startY;
      if (currentY > 0) {
        el.style.transform = `translateY(${currentY}px)`;
      }
    };

    const onTouchEnd = () => {
      el.style.transition = "transform 300ms cubic-bezier(0.4, 0, 0.2, 1)";
      if (currentY > 150) {
        this.closePanel();
      } else {
        el.style.transform = "translateY(0)";
      }
    };

    handle.addEventListener("touchstart", onTouchStart, { passive: true });
    handle.addEventListener("touchmove", onTouchMove, { passive: true });
    handle.addEventListener("touchend", onTouchEnd, { passive: true });

    return () => {
      handle.removeEventListener("touchstart", onTouchStart);
      handle.removeEventListener("touchmove", onTouchMove);
      handle.removeEventListener("touchend", onTouchEnd);
    };
  });
  setupScrollPagination = modifier((el) => {
    const scrollContainer = el.querySelector(
      ".ft-comment-panel__comments-list"
    );
    if (!scrollContainer) {
      return;
    }

    const onScroll = () => {
      const { scrollTop, scrollHeight, clientHeight } = scrollContainer;
      if (scrollHeight - scrollTop - clientHeight < 200) {
        this.loadMoreComments();
      }
    };

    scrollContainer.addEventListener("scroll", onScroll, { passive: true });

    return () => {
      scrollContainer.removeEventListener("scroll", onScroll);
    };
  });
  @tracked _serverComments = null;
  @tracked _localComments = null;
  @tracked _likeLoadingIds = [];
  @tracked _expandedThreads = new Set();
  @tracked _displayedCount = PAGE_SIZE;

  @tracked _dragY = null;
  @tracked _panelTranslateY = 0;
  @tracked _isClosing = false;

  get topicId() {
    return this.args.topicId;
  }

  get topic() {
    return this.args.topic;
  }

  get topicClosed() {
    return this.topic?.closed || false;
  }

  get canComment() {
    return !!this.currentUser && !this.topicClosed;
  }

  get posterName() {
    const poster = this.topic?.posters?.[0]?.user || this.topic?.creator;
    return poster?.name || poster?.username || "Unknown";
  }

  get poster() {
    return this.topic?.posters?.[0]?.user || this.topic?.creator;
  }

  get comments() {
    const serverComments = this._serverComments || [];
    const localComments = (this._localComments || []).map((c, i) => ({
      ...c,
      initials: this._getInitials(c.user?.name || c.user?.username),
      gradientClass: GRADIENT_CLASSES[(serverComments.length + i) % 4],
    }));
    return [...serverComments, ...localComments];
  }

  get threadedComments() {
    const all = this.comments;
    const byPostNumber = new Map();
    for (const c of all) {
      if (c.post_number) {
        byPostNumber.set(c.post_number, c);
      }
    }

    const topLevel = [];
    const repliesByParent = new Map();

    for (const c of all) {
      const parent = c.reply_to_post_number;
      if (!parent || parent === 1 || !byPostNumber.has(parent)) {
        topLevel.push(c);
      } else {
        if (!repliesByParent.has(parent)) {
          repliesByParent.set(parent, []);
        }
        repliesByParent.get(parent).push(c);
      }
    }

    const expandedThreads = this._expandedThreads;
    return topLevel.map((comment) => {
      const replies = this._collectReplies(
        comment.post_number,
        repliesByParent
      );
      return {
        comment,
        replies,
        replyCount: replies.length,
        isExpanded: expandedThreads.has(comment.post_number),
      };
    });
  }

  get visibleThreadedComments() {
    return this.threadedComments.slice(0, this._displayedCount);
  }

  get hasMoreComments() {
    return this._displayedCount < this.threadedComments.length;
  }

  get commentCount() {
    return this.comments.length;
  }

  _collectReplies(postNumber, repliesByParent) {
    const direct = repliesByParent.get(postNumber) || [];
    const result = [];
    for (const reply of direct) {
      result.push(reply);
      result.push(...this._collectReplies(reply.post_number, repliesByParent));
    }
    return result;
  }

  _getInitials(name) {
    if (!name) {
      return "?";
    }
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  async loadComments() {
    const topicId = this.topicId;
    if (!topicId) {
      return;
    }
    this.isLoading = true;
    try {
      const topicData = await ajax(`/t/${topicId}.json`);
      const streamIds = topicData?.post_stream?.stream || [];
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
      this._serverComments = allPosts.map((post, index) => {
        const likeAction = post.actions_summary?.find((a) => a.id === 2);
        return {
          id: post.id,
          user: {
            id: post.user_id,
            username: post.username,
            name: post.name || post.username,
            avatar_template: post.avatar_template,
          },
          raw: post.raw || this._getPlainText(post.cooked) || "",
          created_at: post.created_at,
          initials: this._getInitials(post.name || post.username),
          gradientClass: GRADIENT_CLASSES[index % 4],
          like_count: likeAction?.count || 0,
          liked: likeAction?.acted || false,
          post_number: post.post_number,
          reply_to_post_number: post.reply_to_post_number || null,
          reply_to_user: post.reply_to_user || null,
        };
      });
    } catch {
      this._serverComments = [];
    } finally {
      this.isLoading = false;
    }
  }

  _getPlainText(cooked) {
    if (!cooked) {
      return "";
    }
    const parser = new DOMParser();
    const doc = parser.parseFromString(cooked, "text/html");
    return doc.body.textContent?.trim() || "";
  }

  @action
  closePanel() {
    this._isClosing = true;
    this.args.onClose?.();
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.closePanel();
    }
  }

  @action
  loadMoreComments() {
    if (this.hasMoreComments) {
      this._displayedCount += PAGE_SIZE;
    }
  }

  @action
  updateCommentText(event) {
    this.commentText = event.target.value;
  }

  @action
  handleCommentKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      this.submitComment();
    }
  }

  @action
  async submitComment() {
    if (!this.canComment || this.isSubmitting || !this.commentText.trim()) {
      return;
    }
    const topicId = this.topicId;
    if (!topicId) {
      return;
    }
    this.isSubmitting = true;
    const commentText = this.commentText.trim();
    try {
      const replyTo = this.replyingTo;
      const postData = {
        raw: commentText,
        topic_id: topicId,
        draft_key: `topic_${topicId}`,
      };
      if (replyTo?.post_number) {
        postData.reply_to_post_number = replyTo.post_number;
      }
      const result = await ajax("/posts", {
        type: "POST",
        data: postData,
      });
      this.commentText = "";
      this.replyingTo = null;
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
          like_count: 0,
          liked: false,
          post_number: result.post_number,
          reply_to_post_number: replyTo?.post_number || null,
          reply_to_user: replyTo ? { username: replyTo.username } : null,
        };
        this._localComments = [...(this._localComments || []), newComment];
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmitting = false;
    }
  }

  @action
  startReply(comment) {
    this.replyingTo = {
      post_number: comment.post_number,
      username: comment.user?.username || comment.user?.name,
    };
  }

  @action
  cancelReply() {
    this.replyingTo = null;
  }

  @action
  toggleThread(postNumber) {
    const next = new Set(this._expandedThreads);
    if (next.has(postNumber)) {
      next.delete(postNumber);
    } else {
      next.add(postNumber);
    }
    this._expandedThreads = next;
  }

  @action
  async toggleCommentLike(comment) {
    if (!this.currentUser || this._likeLoadingIds.includes(comment.id)) {
      return;
    }

    const wasLiked = comment.liked;
    const prevCount = comment.like_count;

    const updatedComment = {
      ...comment,
      liked: !wasLiked,
      like_count: wasLiked ? Math.max(0, prevCount - 1) : prevCount + 1,
    };

    this._updateComment(comment.id, updatedComment);
    this._likeLoadingIds = [...this._likeLoadingIds, comment.id];

    try {
      if (wasLiked) {
        await ajax(`/post_actions/${comment.id}`, {
          type: "DELETE",
          data: { post_action_type_id: 2 },
        });
      } else {
        await ajax("/post_actions", {
          type: "POST",
          data: { id: comment.id, post_action_type_id: 2 },
        });
      }
    } catch {
      this._updateComment(comment.id, {
        ...comment,
        liked: wasLiked,
        like_count: prevCount,
      });
    } finally {
      this._likeLoadingIds = this._likeLoadingIds.filter(
        (id) => id !== comment.id
      );
    }
  }

  _updateComment(commentId, updatedComment) {
    if (this._serverComments) {
      this._serverComments = this._serverComments.map((c) =>
        c.id === commentId ? { ...c, ...updatedComment } : c
      );
    }
    if (this._localComments) {
      this._localComments = this._localComments.map((c) =>
        c.id === commentId ? { ...c, ...updatedComment } : c
      );
    }
  }

  @action
  stopPropagation(event) {
    event.stopPropagation();
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-comment-panel-backdrop"
      {{on "click" this.handleBackdropClick}}
      {{this.setupPanel}}
    >
      <div
        class="ft-comment-panel"
        {{this.setupDrag}}
        {{this.setupScrollPagination}}
        {{on "click" this.stopPropagation}}
      >
        {{! Drag handle }}
        <div class="ft-comment-panel__drag-handle">
          <div class="ft-comment-panel__drag-bar"></div>
        </div>

        {{! Header }}
        <div class="ft-comment-panel__header">
          <span class="ft-comment-panel__title">Comments</span>
        </div>

        {{! Comments list }}
        <div class="ft-comment-panel__comments-list">
          {{#if this.isLoading}}
            <div class="ft-comment-panel__loading">
              {{ftIcon "loader"}}
            </div>
          {{else if this.comments.length}}
            {{#each this.visibleThreadedComments as |thread|}}
              <div class="ft-comment-panel__thread">
                {{! Top-level comment }}
                <div class="ft-comment-panel__comment">
                  <div
                    class="ft-comment-panel__comment-avatar
                      {{unless
                        thread.comment.user
                        thread.comment.gradientClass
                      }}"
                  >
                    {{#if thread.comment.user}}
                      {{avatar thread.comment.user imageSize="small"}}
                    {{else}}
                      <span
                        class="ft-comment-panel__comment-initials"
                      >{{thread.comment.initials}}</span>
                    {{/if}}
                  </div>
                  <div class="ft-comment-panel__comment-body">
                    <div class="ft-comment-panel__comment-meta">
                      <span
                        class="ft-comment-panel__comment-author"
                      >{{thread.comment.user.name}}</span>
                      <span class="ft-comment-panel__comment-time">
                        {{formatDate thread.comment.created_at format="tiny"}}
                      </span>
                    </div>
                    <p
                      class="ft-comment-panel__comment-text"
                    >{{thread.comment.raw}}</p>
                    <div class="ft-comment-panel__comment-actions">
                      {{#if thread.comment.like_count}}
                        <span
                          class="ft-comment-panel__comment-likes"
                        >{{thread.comment.like_count}}
                          {{if
                            (eq thread.comment.like_count 1)
                            "like"
                            "likes"
                          }}</span>
                      {{/if}}
                      {{#if this.canComment}}
                        <button
                          type="button"
                          class="ft-comment-panel__reply-btn"
                          {{on "click" (fn this.startReply thread.comment)}}
                        >Reply</button>
                      {{/if}}
                    </div>
                  </div>
                  <button
                    type="button"
                    class="ft-comment-panel__like-btn
                      {{if
                        thread.comment.liked
                        'ft-comment-panel__like-btn--liked'
                      }}"
                    {{on "click" (fn this.toggleCommentLike thread.comment)}}
                  >
                    {{#if thread.comment.liked}}
                      {{ftIcon "heart" size=14 fill="currentColor"}}
                    {{else}}
                      {{ftIcon "heart" size=14}}
                    {{/if}}
                  </button>
                </div>

                {{! Thread replies }}
                {{#if thread.replyCount}}
                  {{#unless thread.isExpanded}}
                    <button
                      type="button"
                      class="ft-comment-panel__thread-toggle"
                      {{on
                        "click"
                        (fn this.toggleThread thread.comment.post_number)
                      }}
                    >
                      <span class="ft-comment-panel__thread-toggle-line"></span>
                      View
                      {{thread.replyCount}}
                      {{if (eq thread.replyCount 1) "reply" "replies"}}
                    </button>
                  {{/unless}}
                  {{#if thread.isExpanded}}
                    <button
                      type="button"
                      class="ft-comment-panel__thread-toggle"
                      {{on
                        "click"
                        (fn this.toggleThread thread.comment.post_number)
                      }}
                    >
                      <span class="ft-comment-panel__thread-toggle-line"></span>
                      Hide replies
                    </button>
                    <div class="ft-comment-panel__thread-replies">
                      {{#each thread.replies as |reply|}}
                        <div
                          class="ft-comment-panel__comment ft-comment-panel__comment--reply"
                        >
                          <div
                            class="ft-comment-panel__comment-avatar ft-comment-panel__comment-avatar--reply
                              {{unless reply.user reply.gradientClass}}"
                          >
                            {{#if reply.user}}
                              {{avatar reply.user imageSize="small"}}
                            {{else}}
                              <span
                                class="ft-comment-panel__comment-initials"
                              >{{reply.initials}}</span>
                            {{/if}}
                          </div>
                          <div class="ft-comment-panel__comment-body">
                            <div class="ft-comment-panel__comment-meta">
                              <span
                                class="ft-comment-panel__comment-author"
                              >{{reply.user.name}}</span>
                              <span class="ft-comment-panel__comment-time">
                                {{formatDate reply.created_at format="tiny"}}
                              </span>
                            </div>
                            <p
                              class="ft-comment-panel__comment-text"
                            >{{reply.raw}}</p>
                            <div class="ft-comment-panel__comment-actions">
                              {{#if reply.like_count}}
                                <span
                                  class="ft-comment-panel__comment-likes"
                                >{{reply.like_count}}
                                  {{if
                                    (eq reply.like_count 1)
                                    "like"
                                    "likes"
                                  }}</span>
                              {{/if}}
                              {{#if this.canComment}}
                                <button
                                  type="button"
                                  class="ft-comment-panel__reply-btn"
                                  {{on "click" (fn this.startReply reply)}}
                                >Reply</button>
                              {{/if}}
                            </div>
                          </div>
                          <button
                            type="button"
                            class="ft-comment-panel__like-btn
                              {{if
                                reply.liked
                                'ft-comment-panel__like-btn--liked'
                              }}"
                            {{on "click" (fn this.toggleCommentLike reply)}}
                          >
                            {{#if reply.liked}}
                              {{ftIcon "heart" size=14 fill="currentColor"}}
                            {{else}}
                              {{ftIcon "heart" size=14}}
                            {{/if}}
                          </button>
                        </div>
                      {{/each}}
                    </div>
                  {{/if}}
                {{/if}}
              </div>
            {{/each}}

            {{#if this.hasMoreComments}}
              <div class="ft-comment-panel__load-more">
                <button
                  type="button"
                  class="ft-comment-panel__load-more-btn"
                  {{on "click" this.loadMoreComments}}
                >Load more comments</button>
              </div>
            {{/if}}
          {{else}}
            <div class="ft-comment-panel__empty">
              <p>No comments yet. Be the first to comment!</p>
            </div>
          {{/if}}
        </div>

        {{! Input area }}
        <div class="ft-comment-panel__input-area">
          {{#if this.replyingTo}}
            <div class="ft-comment-panel__reply-indicator">
              <span>Replying to @{{this.replyingTo.username}}</span>
              <button
                type="button"
                class="ft-comment-panel__reply-cancel"
                {{on "click" this.cancelReply}}
              >
                {{ftIcon "x" size=14}}
              </button>
            </div>
          {{/if}}
          <div class="ft-comment-panel__input-row">
            <div class="ft-comment-panel__input-avatar">
              {{#if this.currentUser}}
                {{avatar this.currentUser imageSize="small"}}
              {{/if}}
            </div>
            <div class="ft-comment-panel__input-container">
              <input
                type="text"
                class="ft-comment-panel__input"
                placeholder={{if
                  this.topicClosed
                  "Comments are turned off"
                  "Join the conversation..."
                }}
                value={{this.commentText}}
                disabled={{or
                  this.isSubmitting
                  this.topicClosed
                  (not this.currentUser)
                }}
                {{on "input" this.updateCommentText}}
                {{on "keydown" this.handleCommentKeydown}}
              />
              <button
                type="button"
                class="ft-comment-panel__send-btn
                  {{if this.commentText 'ft-comment-panel__send-btn--active'}}"
                disabled={{or
                  this.isSubmitting
                  (not this.commentText)
                  this.topicClosed
                  (not this.currentUser)
                }}
                {{on "click" this.submitComment}}
              >
                {{#if this.isSubmitting}}
                  {{ftIcon "loader" size=16}}
                {{else}}
                  {{ftIcon "arrow-up" size=16}}
                {{/if}}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
}
