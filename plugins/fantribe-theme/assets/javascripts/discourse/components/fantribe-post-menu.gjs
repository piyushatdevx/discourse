import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import FlagModal from "discourse/components/modal/flag";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import PostFlag from "discourse/lib/flag-targets/post-flag";
import { clipboardCopy } from "discourse/lib/utilities";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import ftIcon from "../helpers/ft-icon";

export default class FantribePostMenu extends Component {
  @service currentUser;
  @service fantribeCreate;
  @service modal;
  @service store;
  @service toasts;

  @tracked isBookmarkLoading = false;
  @tracked showDeleteConfirm = false;
  @tracked _isBookmarked = null;
  @tracked _bookmarkId = null;

  get isBookmarked() {
    if (this._isBookmarked !== null) {
      return this._isBookmarked;
    }
    return this.args.topic?.bookmarked || false;
  }

  get isClosed() {
    return this.args.topicClosed || this.args.topic?.closed || false;
  }

  @action
  async handleEdit(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const postId = this.args.firstPostId;
    if (!postId) {
      return;
    }
    try {
      const post = await ajax(`/posts/${postId}.json`);
      const tags = this.args.topic?.tags || [];
      this.fantribeCreate.openEditPostModal(post, this.args.topic?.title, tags);
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  handleCopyLink(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const topic = this.args.topic;
    if (!topic) {
      return;
    }
    const url = `${window.location.origin}/t/${topic.slug}/${topic.id}`;
    clipboardCopy(url);
    this.toasts.success({ data: { message: "Link copied to clipboard" } });
  }

  @action
  handleClose() {
    this.showDeleteConfirm = false;
    this.args.onClose?.();
  }

  @action
  confirmDelete(event) {
    event.stopPropagation();
    this.showDeleteConfirm = true;
  }

  @action
  cancelDelete(event) {
    event.stopPropagation();
    this.showDeleteConfirm = false;
  }

  @action
  async handleDelete(event) {
    event.stopPropagation();
    const topic = this.args.topic;
    if (!topic?.id) {
      return;
    }
    try {
      await ajax(`/t/${topic.id}`, { type: "DELETE" });
      this.toasts.success({ data: { message: "Post deleted" } });
      this.args.onClose?.();
      this.args.onDismiss?.();
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async handleReport(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const postId = this.args.firstPostId;
    if (!postId) {
      return;
    }
    try {
      const post = await this.store.find("post", postId);
      this.modal.show(FlagModal, {
        model: {
          flagTarget: new PostFlag(),
          flagModel: post,
          setHidden: () => {},
        },
      });
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async handleNotInterested(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const topicId = this.args.topic?.id;
    if (!topicId) {
      return;
    }
    try {
      await ajax(`/t/${topicId}/notifications`, {
        type: "POST",
        data: { notification_level: 0 },
      });
      this.toasts.success({ data: { message: "Post hidden from your feed" } });
      this.args.onDismiss?.();
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async handleMute(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const username = this.args.userName;
    if (!username) {
      return;
    }
    try {
      await ajax(`/u/${username}/notification_level.json`, {
        type: "PUT",
        data: { notification_level: "mute" },
      });
      this.toasts.success({
        data: { message: `${username} muted — their posts are hidden` },
      });
      this.args.onDismiss?.();
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async handleBlock(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const username = this.args.userName;
    if (!username) {
      return;
    }
    try {
      const farFuture = new Date();
      farFuture.setFullYear(farFuture.getFullYear() + 100);
      await ajax(`/u/${username}/notification_level.json`, {
        type: "PUT",
        data: {
          notification_level: "ignore",
          expiring_at: farFuture.toISOString(),
        },
      });
      this.toasts.success({ data: { message: `${username} blocked` } });
      this.args.onDismiss?.();
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async handleTurnOffComments(event) {
    event.stopPropagation();
    const topicId = this.args.topic?.id;
    if (!topicId) {
      return;
    }
    const willClose = !this.isClosed;
    try {
      await ajax(`/t/${topicId}/status`, {
        type: "PUT",
        data: {
          status: "closed",
          enabled: willClose ? "true" : "false",
        },
      });
      this.toasts.success({
        data: {
          message: willClose ? "Comments turned off" : "Comments turned on",
        },
      });
      this.args.onClosedChange?.(willClose);
      this.args.onClose?.();
    } catch (error) {
      popupAjaxError(error);
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
        const bookmarkId = this._bookmarkId || this.args.topic?.bookmark_id;
        if (bookmarkId) {
          await ajax(`/bookmarks/${bookmarkId}`, { type: "DELETE" });
        }
        this._bookmarkId = null;
        this.toasts.success({ data: { message: "Bookmark removed" } });
      } else {
        const result = await ajax("/bookmarks", {
          type: "POST",
          data: {
            bookmarkable_id: this.args.firstPostId,
            bookmarkable_type: "Post",
          },
        });
        this._bookmarkId = result?.id ?? null;
        this.toasts.success({ data: { message: "Post saved to bookmarks" } });
      }
    } catch (error) {
      this._isBookmarked = wasBookmarked;
      popupAjaxError(error);
    } finally {
      this.isBookmarkLoading = false;
    }

    this.args.onClose?.();
  }

  <template>
    {{#if @isOpen}}
      {{! Backdrop }}
      <button
        type="button"
        class="fantribe-post-menu__backdrop"
        {{on "click" this.handleClose}}
      ></button>

      {{! Menu Dropdown }}
      <div
        class="fantribe-post-menu"
        {{closeOnClickOutside
          this.handleClose
          (hash ignoreSelector=".fantribe-post-menu")
        }}
      >
        {{#if this.showDeleteConfirm}}
          {{! Delete confirmation view }}
          <div class="fantribe-post-menu__confirm">
            <p class="fantribe-post-menu__confirm-text">Delete this post?</p>
            <p class="fantribe-post-menu__confirm-sub">This action cannot be
              undone.</p>
            <div class="fantribe-post-menu__confirm-actions">
              <button
                type="button"
                class="fantribe-post-menu__confirm-cancel"
                {{on "click" this.cancelDelete}}
              >Cancel</button>
              <button
                type="button"
                class="fantribe-post-menu__confirm-delete"
                {{on "click" this.handleDelete}}
              >Delete</button>
            </div>
          </div>
        {{else if @isOwnPost}}
          {{! Menu for own posts }}
          <div class="fantribe-post-menu__items">
            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleEdit}}
            >
              {{ftIcon "edit3"}}
              <span>Edit Post</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleCopyLink}}
            >
              {{ftIcon "link2"}}
              <span>Copy Link</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleTurnOffComments}}
            >
              {{ftIcon "message-square-off"}}
              <span>{{if
                  this.isClosed
                  "Turn On Comments"
                  "Turn Off Comments"
                }}</span>
            </button>

            <div class="fantribe-post-menu__divider"></div>

            <button
              type="button"
              class="fantribe-post-menu__item fantribe-post-menu__item--destructive"
              {{on "click" this.confirmDelete}}
            >
              {{ftIcon "trash2"}}
              <span>Delete Post</span>
            </button>
          </div>
        {{else}}
          {{! Menu for other people's posts }}
          <div class="fantribe-post-menu__items">
            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleCopyLink}}
            >
              {{ftIcon "link2"}}
              <span>Copy Link</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleNotInterested}}
            >
              {{ftIcon "eye-off"}}
              <div class="fantribe-post-menu__item-text">
                <span>Not interested in this</span>
                <span class="fantribe-post-menu__item-subtext">Hide this post</span>
              </div>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleMute}}
            >
              {{ftIcon "eye"}}
              <div class="fantribe-post-menu__item-text">
                <span>Mute {{@userName}}</span>
                <span class="fantribe-post-menu__item-subtext">Stop seeing their
                  posts</span>
              </div>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleReport}}
            >
              {{ftIcon "flag"}}
              <span>Report this post</span>
            </button>

            <div class="fantribe-post-menu__divider"></div>

            <button
              type="button"
              class="fantribe-post-menu__item fantribe-post-menu__item--destructive"
              {{on "click" this.handleBlock}}
            >
              {{ftIcon "ban"}}
              <span>Block {{@userName}}</span>
            </button>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
