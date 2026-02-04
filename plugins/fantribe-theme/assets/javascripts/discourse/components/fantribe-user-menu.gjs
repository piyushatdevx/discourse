import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import logout from "discourse/lib/logout";
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
    this.currentUser
      .destroySession()
      .then((response) => logout({ redirect: response["redirect_url"] }));
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
              <svg
                class="fantribe-user-menu__profile-icon"
                xmlns="http://www.w3.org/2000/svg"
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                <circle cx="12" cy="7" r="4"></circle>
              </svg>
              View Profile
            </button>
            <button type="button" {{on "click" this.goToMessages}}>
              {{icon "envelope"}}
              Messages
            </button>
            <button type="button" {{on "click" this.goToSettings}}>
              <svg
                class="fantribe-user-menu__settings-icon"
                xmlns="http://www.w3.org/2000/svg"
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path
                  d="M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915"
                ></path>
                <circle cx="12" cy="12" r="3"></circle>
              </svg>
              Settings
            </button>
            <hr class="fantribe-user-menu__divider" />
            <button
              type="button"
              class="fantribe-user-menu__logout"
              {{on "click" this.logout}}
            >
              <svg
                class="fantribe-user-menu__logout-icon"
                xmlns="http://www.w3.org/2000/svg"
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              >
                <path d="m16 17 5-5-5-5"></path>
                <path d="M21 12H9"></path>
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
              </svg>
              Sign Out
            </button>
          </nav>
        </div>
      {{/if}}
    </div>
  </template>
}
