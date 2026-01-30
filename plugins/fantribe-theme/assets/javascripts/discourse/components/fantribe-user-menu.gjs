import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";

export default class FantribeUserMenu extends Component {
  @service router;
  @service currentUser;

  @tracked menuOpen = false;

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
  goToProfile() {
    this.router.transitionTo("user", this.currentUser.username);
    this.menuOpen = false;
  }

  @action
  goToSettings() {
    this.router.transitionTo("preferences.account", this.currentUser.username);
    this.menuOpen = false;
  }

  @action
  goToMessages() {
    this.router.transitionTo("userPrivateMessages", this.currentUser.username);
    this.menuOpen = false;
  }

  @action
  logout() {
    window.location.href = "/session/current?_method=DELETE";
  }

  <template>
    <div class="fantribe-user-menu">
      <button
        class="fantribe-user-menu__trigger"
        type="button"
        {{on "click" this.toggleMenu}}
      >
        {{avatar @user imageSize="small"}}
      </button>

      {{#if this.menuOpen}}
        <div
          class="fantribe-user-menu__dropdown"
          {{closeOnClickOutside
            this.closeMenu
            (hash targetSelector=".fantribe-user-menu__trigger")
          }}
        >
          <div class="fantribe-user-menu__header">
            {{avatar @user imageSize="medium"}}
            <div class="fantribe-user-menu__info">
              <span class="fantribe-user-menu__name">{{@user.name}}</span>
              <span
                class="fantribe-user-menu__username"
              >@{{@user.username}}</span>
            </div>
          </div>

          <nav class="fantribe-user-menu__nav">
            <button type="button" {{on "click" this.goToProfile}}>
              {{icon "user"}}
              Profile
            </button>
            <button type="button" {{on "click" this.goToMessages}}>
              {{icon "envelope"}}
              Messages
            </button>
            <button type="button" {{on "click" this.goToSettings}}>
              {{icon "gear"}}
              Settings
            </button>
            <hr class="fantribe-user-menu__divider" />
            <button
              type="button"
              class="fantribe-user-menu__logout"
              {{on "click" this.logout}}
            >
              {{icon "right-from-bracket"}}
              Log Out
            </button>
          </nav>
        </div>
      {{/if}}
    </div>
  </template>
}
