import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import ftIcon from "../helpers/ft-icon";

const NAV_ITEMS = [
  {
    id: "home-feed",
    label: "Home Feed",
    icon: "home",
    route: "discovery.latest",
  },
  {
    id: "explore-tribes",
    label: "Explore Tribes",
    icon: "compass",
    route: "explore",
  },
  { id: "chat", label: "Chat", icon: "message-circle", route: "chat.index" },
];

export default class FantribeTribesPanel extends Component {
  @service router;
  @service currentUser;
  @service chatTrackingStateManager;

  @tracked isCollapsed = document.body.classList.contains(
    "fantribe-sidebar-collapsed"
  );

  isActive = (item) => {
    const route = this.router.currentRouteName || "";
    if (!item.route) {
      return false;
    }
    if (item.route === "discovery.latest") {
      // discovery.category routes are tribe pages — don't highlight Home Feed there
      return (
        route === "discovery.latest" ||
        route === "discovery.top" ||
        route === "discovery.new" ||
        route === "discovery.unread" ||
        route === "discovery.hot" ||
        route === "index"
      );
    }
    if (item.route === "explore") {
      return route === "explore";
    }
    if (item.route === "chat.index") {
      return route.startsWith("chat");
    }
    return route === item.route;
  };

  hasNotification = (item) => {
    return item.id === "chat" && this.hasUnreadChat;
  };

  get navItems() {
    return NAV_ITEMS;
  }

  get hasUnreadChat() {
    const manager = this.chatTrackingStateManager;
    if (!manager) {
      return false;
    }
    return (
      manager.allChannelUrgentCount > 0 || manager.publicChannelUnreadCount > 0
    );
  }

  @action
  async navigateTo(item) {
    if (!item.route) {
      return;
    }

    try {
      const transition = this.router.transitionTo(item.route);
      await transition;
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("[FantribeNav] Navigation failed:", item.route, error);
    }
  }

  @action
  navigateToProfile() {
    if (this.currentUser) {
      this.router.transitionTo("user", this.currentUser.username);
    }
  }

  @action
  toggleCollapse() {
    document.body.classList.toggle("fantribe-sidebar-collapsed");
    this.isCollapsed = !this.isCollapsed;
  }

  <template>
    <nav class="fantribe-sidebar-nav">
      <div class="fantribe-sidebar-nav__items">
        {{#each this.navItems as |item|}}
          <button
            type="button"
            class="fantribe-sidebar-nav__item
              {{if (this.isActive item) 'fantribe-sidebar-nav__item--active'}}
              {{if
                (this.hasNotification item)
                'fantribe-sidebar-nav__item--has-notification'
              }}"
            {{on "click" (fn this.navigateTo item)}}
          >
            <span class="fantribe-sidebar-nav__item-icon">
              {{ftIcon item.icon}}
            </span>
            <span class="fantribe-sidebar-nav__item-label">{{item.label}}</span>
            {{#if (this.isActive item)}}
              <span class="fantribe-sidebar-nav__item-chevron">
                {{ftIcon "chevron-right"}}
              </span>
            {{/if}}
            <span class="fantribe-sidebar-nav__item-dot"></span>
          </button>
        {{/each}}
      </div>

      {{! Collapse toggle }}
      <button
        type="button"
        class="fantribe-sidebar-nav__collapse"
        {{on "click" this.toggleCollapse}}
      >
        {{ftIcon (if this.isCollapsed "chevron-right" "chevron-left")}}
      </button>

      {{! User profile at bottom }}
      {{#if this.currentUser}}
        <button
          type="button"
          class="fantribe-sidebar-nav__user"
          {{on "click" this.navigateToProfile}}
        >
          <span class="fantribe-sidebar-nav__user-avatar">
            {{avatar this.currentUser imageSize="medium"}}
          </span>
          <span class="fantribe-sidebar-nav__user-info">
            <span class="fantribe-sidebar-nav__user-name">
              {{this.currentUser.name}}
            </span>
            <span class="fantribe-sidebar-nav__user-username">
              @{{this.currentUser.username}}
            </span>
          </span>
          <span class="fantribe-sidebar-nav__user-chevron">
            {{ftIcon "chevron-right"}}
          </span>
        </button>
      {{/if}}
    </nav>
  </template>
}
