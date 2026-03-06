import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import ftIcon from "../helpers/ft-icon";

export default class FantribeMobileNav extends Component {
  @service router;
  @service currentUser;

  get currentPath() {
    return this.router.currentRouteName;
  }

  get isFeedActive() {
    const route = this.currentPath;
    return (
      route === "discovery.latest" ||
      route === "discovery.categories" ||
      route === "index"
    );
  }

  get isSearchActive() {
    const route = this.currentPath;
    return route === "explore" || route?.startsWith("explore.");
  }

  get isChatActive() {
    const route = this.currentPath;
    return route?.startsWith("chat");
  }

  get isNotificationsActive() {
    return this.currentPath?.startsWith("userNotifications");
  }

  get isProfileActive() {
    return this.currentPath?.startsWith("user.");
  }

  get isLoggedIn() {
    return !!this.currentUser;
  }

  @action
  goToFeed() {
    this.router.transitionTo("discovery.latest");
  }

  @action
  goToSearch() {
    this.router.transitionTo("explore");
  }

  @action
  goToChat() {
    this.router.transitionTo("chat.index");
  }

  @action
  goToNotifications() {
    if (this.currentUser) {
      this.router.transitionTo("userNotifications", this.currentUser.username);
    } else {
      this.router.transitionTo("login");
    }
  }

  @action
  goToProfile() {
    if (this.currentUser) {
      this.router.transitionTo("user", this.currentUser.username);
    } else {
      this.router.transitionTo("login");
    }
  }

  <template>
    {{#if this.isLoggedIn}}
      <nav class="fantribe-mobile-nav">
        <button
          class="fantribe-mobile-nav__item {{if this.isFeedActive 'active'}}"
          type="button"
          {{on "click" this.goToFeed}}
        >
          <span class="fantribe-mobile-nav__icon">
            {{ftIcon "home" size=26}}
          </span>
        </button>

        <button
          class="fantribe-mobile-nav__item {{if this.isSearchActive 'active'}}"
          type="button"
          {{on "click" this.goToSearch}}
        >
          <span class="fantribe-mobile-nav__icon">
            {{ftIcon "compass" size=26}}
          </span>
        </button>

        <button
          class="fantribe-mobile-nav__item {{if this.isChatActive 'active'}}"
          type="button"
          {{on "click" this.goToChat}}
        >
          <span class="fantribe-mobile-nav__icon">
            {{ftIcon "message-circle" size=26}}
          </span>
        </button>

        <button
          class="fantribe-mobile-nav__item
            {{if this.isNotificationsActive 'active'}}"
          type="button"
          {{on "click" this.goToNotifications}}
        >
          <span class="fantribe-mobile-nav__icon">
            {{ftIcon "bell" size=26}}
          </span>
        </button>

        <button
          class="fantribe-mobile-nav__item {{if this.isProfileActive 'active'}}"
          type="button"
          {{on "click" this.goToProfile}}
        >
          <span class="fantribe-mobile-nav__avatar">
            {{#if this.currentUser}}
              {{avatar this.currentUser imageSize="small"}}
            {{else}}
              {{icon "user"}}
            {{/if}}
          </span>
        </button>
      </nav>
    {{/if}}
  </template>
}
