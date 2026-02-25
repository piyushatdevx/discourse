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
import Composer from "discourse/models/composer";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import ftIcon from "../helpers/ft-icon";

export default class FantribePostMenu extends Component {
  @service composer;
  @service currentUser;
  @service modal;
  @service router;
  @service store;

  @tracked isBookmarkLoading = false;
  @tracked _isBookmarked = null;
  @tracked _bookmarkId = null;

  get isBookmarked() {
    if (this._isBookmarked !== null) {
      return this._isBookmarked;
    }
    return this.args.topic?.bookmarked || false;
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
      this.composer.open({
        action: Composer.EDIT,
        post,
        draftKey: `topic_${this.args.topic?.id}`,
        draftSequence: 0,
      });
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
  }

  @action
  async handleDelete(event) {
    event.stopPropagation();
    this.args.onClose?.();
    const topic = this.args.topic;
    if (!topic?.id) {
      return;
    }
    try {
      await ajax(`/t/${topic.id}`, { type: "DELETE" });
      this.router.transitionTo("discovery.latest");
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
      // Use the Discourse store to get a proper Post model for FlagModal
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
      // Mute the topic so it's filtered from future feeds
      await ajax(`/t/${topicId}/notifications`, {
        type: "POST",
        data: { notification_level: 0 },
      });
      // Signal the card to remove itself from the current view
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
      // "ignore" requires an expiry date; use 100 years for a permanent block
      const farFuture = new Date();
      farFuture.setFullYear(farFuture.getFullYear() + 100);
      await ajax(`/u/${username}/notification_level.json`, {
        type: "PUT",
        data: {
          notification_level: "ignore",
          expiring_at: farFuture.toISOString(),
        },
      });
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
      } else {
        const result = await ajax("/bookmarks", {
          type: "POST",
          data: {
            bookmarkable_id: this.args.firstPostId,
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

    this.args.onClose?.();
  }

  @action
  noop(event) {
    event.stopPropagation();
    this.args.onClose?.();
  }

  <template>
    {{#if @isOpen}}
      {{! Backdrop }}
      <button
        type="button"
        class="fantribe-post-menu__backdrop"
        {{on "click" @onClose}}
      ></button>

      {{! Menu Dropdown }}
      <div
        class="fantribe-post-menu"
        {{closeOnClickOutside
          @onClose
          (hash ignoreSelector=".fantribe-post-menu")
        }}
      >
        {{#if @isOwnPost}}
          {{! Menu for own posts }}
          <div class="fantribe-post-menu__items">
            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.noop}}
            >
              {{ftIcon "pin"}}
              <span>Pin to Profile</span>
            </button>

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
              {{on "click" this.noop}}
            >
              {{ftIcon "message-square-off"}}
              <span>Turn Off Comments</span>
            </button>

            <div class="fantribe-post-menu__divider"></div>

            <button
              type="button"
              class="fantribe-post-menu__item fantribe-post-menu__item--destructive"
              {{on "click" this.handleDelete}}
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
              disabled={{this.isBookmarkLoading}}
              {{on "click" this.handleBookmark}}
            >
              {{#if this.isBookmarked}}
                {{ftIcon "bookmark-fill"}}
              {{else}}
                {{ftIcon "bookmark"}}
              {{/if}}
              <span>Save Post</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" this.handleCopyLink}}
            >
              {{ftIcon "link2"}}
              <span>Copy Link</span>
            </button>

            {{#unless @isFollowing}}
              <button
                type="button"
                class="fantribe-post-menu__item"
                {{on "click" this.noop}}
              >
                {{ftIcon "user-plus"}}
                <span>Follow {{@userName}}</span>
              </button>
            {{/unless}}

            <div class="fantribe-post-menu__divider"></div>

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
