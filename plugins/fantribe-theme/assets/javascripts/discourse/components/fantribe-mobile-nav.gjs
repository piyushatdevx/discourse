import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class FantribeMobileNav extends Component {
  @service router;
  @service currentUser;
  @service composer;

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
    return this.currentPath === "full-page-search";
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
    this.router.transitionTo("full-page-search");
  }

  @action
  createPost() {
    if (this.composer) {
      this.composer.open({
        action: "createTopic",
        draftKey: "new_topic",
      });
    }
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
          {{icon "house"}}
          <span>Feed</span>
        </button>

        <button
          class="fantribe-mobile-nav__item {{if this.isSearchActive 'active'}}"
          type="button"
          {{on "click" this.goToSearch}}
        >
          {{icon "magnifying-glass"}}
          <span>Search</span>
        </button>

        <button
          class="fantribe-mobile-nav__item fantribe-mobile-nav__item--create"
          type="button"
          {{on "click" this.createPost}}
        >
          {{icon "plus"}}
        </button>

        <button
          class="fantribe-mobile-nav__item
            {{if this.isNotificationsActive 'active'}}"
          type="button"
          {{on "click" this.goToNotifications}}
        >
          {{icon "bell"}}
          <span>Alerts</span>
        </button>

        <button
          class="fantribe-mobile-nav__item {{if this.isProfileActive 'active'}}"
          type="button"
          {{on "click" this.goToProfile}}
        >
          {{icon "user"}}
          <span>Profile</span>
        </button>
      </nav>
    {{/if}}
  </template>
}
