import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

const NAV_ITEMS = [
  {
    id: "home-feed",
    label: "sidebar.nav.home_feed",
    icon: "home",
    route: "discovery.latest",
  },
  {
    id: "explore-tribes",
    label: "sidebar.nav.explore_tribes",
    icon: "compass",
    route: "explore",
  },
  {
    id: "chat",
    label: "sidebar.nav.chat",
    icon: "message-circle",
    route: "chat.index",
  },
];

export default class FantribeTribesPanel extends Component {
  @service router;
  @service currentUser;
  @service chatTrackingStateManager;
  @service fantribeCreate;
  @service fantribeSidebarState;

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

  getBadgeCount = (item) => {
    if (item.id === "chat" && this.chatTrackingStateManager) {
      const n =
        (this.chatTrackingStateManager.allChannelUrgentCount || 0) +
        (this.chatTrackingStateManager.publicChannelUnreadCount || 0);
      return n > 0 ? Math.min(n, 99) : 0;
    }
    return 0;
  };

  get isCollapsed() {
    return this.fantribeSidebarState.isCollapsed;
  }

  get navItems() {
    return NAV_ITEMS;
  }

  get homeUrl() {
    return this.router.urlFor("discovery.latest");
  }

  get logoImageUrl() {
    return getURL("/plugins/fantribe-theme/images/logo.svg");
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
    this.fantribeSidebarState.toggle();
  }

  @action
  openCreate() {
    this.fantribeCreate.openCreatePostModal();
  }

  <template>
    <nav class="fantribe-sidebar-nav">
      <a
        href={{this.homeUrl}}
        class="fantribe-sidebar-nav__logo"
        aria-label={{i18n "sidebar.logo_aria"}}
      >
        <img
          src={{this.logoImageUrl}}
          alt="FanTribe"
          class="fantribe-sidebar-nav__logo-img"
        />
        <span class="fantribe-sidebar-nav__logo-ct" aria-hidden="true">
          <span class="fantribe-sidebar-nav__logo-ct-c">c</span><span
            class="fantribe-sidebar-nav__logo-ct-t"
          >t</span>
        </span>
      </a>

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
            <span class="fantribe-sidebar-nav__item-label">{{i18n
                item.label
              }}</span>
            {{#if (this.isActive item)}}
              <span class="fantribe-sidebar-nav__item-chevron">
                {{ftIcon "chevron-right"}}
              </span>
            {{/if}}
            {{#let (this.getBadgeCount item) as |count|}}
              {{#if count}}
                <span
                  class="fantribe-sidebar-nav__item-badge"
                  aria-label={{i18n "sidebar.notification_count" count=count}}
                >{{count}}</span>
              {{else if (this.hasNotification item)}}
                <span class="fantribe-sidebar-nav__item-dot"></span>
              {{/if}}
            {{/let}}
          </button>
        {{/each}}
      </div>

      <div class="fantribe-sidebar-nav__create-row">
        <div class="fantribe-sidebar-nav__create-wrap">
          <button
            type="button"
            class="fantribe-sidebar-nav__create"
            {{on "click" this.openCreate}}
          >
            <span class="fantribe-sidebar-nav__create-icon">{{ftIcon
                "plus"
                size=20
              }}</span>
            <span class="fantribe-sidebar-nav__create-label">{{i18n
                "sidebar.create"
              }}</span>
          </button>
        </div>

      </div>

      {{! User profile at bottom — Figma: column container with inner row for avatar | name | menu }}
      {{#if this.currentUser}}
        <button
          type="button"
          class="fantribe-sidebar-nav__user"
          {{on "click" this.navigateToProfile}}
        >
          <span class="fantribe-sidebar-nav__user-row">
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
          </span>
        </button>
      {{/if}}
    </nav>
  </template>
}
