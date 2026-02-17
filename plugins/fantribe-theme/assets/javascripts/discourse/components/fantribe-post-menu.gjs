import Component from "@glimmer/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";

export default class FantribePostMenu extends Component {
  @action
  handleAction(actionName) {
    // eslint-disable-next-line no-console
    console.log(`Post action: ${actionName}`);
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
              {{on "click" (fn this.handleAction "pin")}}
            >
              {{icon "thumbtack"}}
              <span>Pin to Profile</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "edit")}}
            >
              {{icon "pencil-alt"}}
              <span>Edit Post</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "copy-link")}}
            >
              {{icon "link"}}
              <span>Copy Link</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "turn-off-comments")}}
            >
              {{icon "comment-slash"}}
              <span>Turn Off Comments</span>
            </button>

            <div class="fantribe-post-menu__divider"></div>

            <button
              type="button"
              class="fantribe-post-menu__item fantribe-post-menu__item--destructive"
              {{on "click" (fn this.handleAction "delete")}}
            >
              {{icon "trash-alt"}}
              <span>Delete Post</span>
            </button>
          </div>
        {{else}}
          {{! Menu for other people's posts }}
          <div class="fantribe-post-menu__items">
            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "save")}}
            >
              {{icon "bookmark"}}
              <span>Save Post</span>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "copy-link")}}
            >
              {{icon "link"}}
              <span>Copy Link</span>
            </button>

            {{#unless @isFollowing}}
              <button
                type="button"
                class="fantribe-post-menu__item"
                {{on "click" (fn this.handleAction "follow")}}
              >
                {{icon "user-plus"}}
                <span>Follow {{@userName}}</span>
              </button>
            {{/unless}}

            <div class="fantribe-post-menu__divider"></div>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "hide")}}
            >
              {{icon "eye-slash"}}
              <div class="fantribe-post-menu__item-text">
                <span>Not interested in this</span>
                <span class="fantribe-post-menu__item-subtext">Hide this post</span>
              </div>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "mute")}}
            >
              {{icon "eye"}}
              <div class="fantribe-post-menu__item-text">
                <span>Mute {{@userName}}</span>
                <span class="fantribe-post-menu__item-subtext">Stop seeing their
                  posts</span>
              </div>
            </button>

            <button
              type="button"
              class="fantribe-post-menu__item"
              {{on "click" (fn this.handleAction "report")}}
            >
              {{icon "flag"}}
              <span>Report this post</span>
            </button>

            <div class="fantribe-post-menu__divider"></div>

            <button
              type="button"
              class="fantribe-post-menu__item fantribe-post-menu__item--destructive"
              {{on "click" (fn this.handleAction "block")}}
            >
              {{icon "ban"}}
              <span>Block {{@userName}}</span>
            </button>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
