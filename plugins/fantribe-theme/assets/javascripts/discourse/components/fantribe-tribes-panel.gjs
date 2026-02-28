import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import avatar from "discourse/helpers/avatar";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";
import FtCreateMenu from "./ft-create-menu";

const SIDEBAR_CREATE_MENU_GAP = 110;
// Gap between menu bottom and create button top — keeps spacing constant for 1 or more items
const SIDEBAR_CREATE_MENU_GAP_ABOVE_BUTTON = 20;
// Match expanded sidebar width (left-sidebar.scss) so menu starts at same horizontal position when expanded or collapsed
const EXPANDED_SIDEBAR_WIDTH = 200;

const positionSidebarCreateMenu = modifier((element) => {
  const trigger = element.parentElement?.querySelector(
    ".fantribe-sidebar-nav__create"
  );
  const sidebar = element.closest(".fantribe-left-sidebar");
  if (!trigger || !sidebar) {
    return;
  }

  const gap = SIDEBAR_CREATE_MENU_GAP_ABOVE_BUTTON;

  const applyPosition = () => {
    const triggerRect = trigger.getBoundingClientRect();
    const sidebarRect = sidebar.getBoundingClientRect();

    // We want the BOTTOM of `.ft-create-menu__items` to be a fixed GAP above the Create button.
    // This keeps the last menu item “fixed” even as the menu grows upward with more options.
    const items = element.querySelector(".ft-create-menu__items");
    const itemsBottomWithinMenu = items
      ? items.offsetTop + items.offsetHeight
      : element.offsetHeight;

    const menuHeight = element.offsetHeight;
    const desiredItemsBottomViewport = triggerRect.top - gap;
    const menuTopViewport = desiredItemsBottomViewport - itemsBottomWithinMenu;
    const menuBottomViewport = menuTopViewport + menuHeight;

    // If the sidebar is transformed (collapsed/mobile), it becomes the fixed-position containing block.
    const isFixedToSidebar = getComputedStyle(sidebar).transform !== "none";
    const bottomBase = isFixedToSidebar
      ? sidebarRect.bottom
      : window.innerHeight;
    const bottom = bottomBase - menuBottomViewport;

    element.style.position = "fixed";
    element.style.left = `${sidebarRect.left + EXPANDED_SIDEBAR_WIDTH + SIDEBAR_CREATE_MENU_GAP}px`;
    element.style.zIndex = "var(--ft-z-dropdown, 1100)";
    element.style.top = "auto";
    element.style.bottom = `${bottom + 10}px`;
  };

  applyPosition();
  requestAnimationFrame(() => {
    requestAnimationFrame(applyPosition);
  });
  const resizeObserver = new ResizeObserver(applyPosition);
  resizeObserver.observe(element);

  return () => resizeObserver.disconnect();
});

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

  positionSidebarCreateMenu = positionSidebarCreateMenu;

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
      return (
        route === "explore" ||
        route.startsWith("topic") ||
        route.startsWith("discovery.category")
      );
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

  _sidebarCreateMenuCloseTimeout = null;

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
  openSidebarCreateMenu() {
    if (this._sidebarCreateMenuCloseTimeout) {
      clearTimeout(this._sidebarCreateMenuCloseTimeout);
      this._sidebarCreateMenuCloseTimeout = null;
    }
    this.fantribeCreate.openSidebarCreateMenu();
  }

  @action
  closeSidebarCreateMenu() {
    this._sidebarCreateMenuCloseTimeout = setTimeout(() => {
      this.fantribeCreate.closeSidebarCreateMenu();
      this._sidebarCreateMenuCloseTimeout = null;
    }, 150);
  }

  @action
  cancelSidebarCreateMenuClose() {
    if (this._sidebarCreateMenuCloseTimeout) {
      clearTimeout(this._sidebarCreateMenuCloseTimeout);
      this._sidebarCreateMenuCloseTimeout = null;
    }
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
            aria-haspopup="true"
            aria-expanded={{this.fantribeCreate.isSidebarCreateMenuOpen}}
            {{on "mouseenter" this.openSidebarCreateMenu}}
            {{on "mouseleave" this.closeSidebarCreateMenu}}
          >
            <span class="fantribe-sidebar-nav__create-icon">{{ftIcon
                "plus"
                size=20
              }}</span>
            <span class="fantribe-sidebar-nav__create-label">{{i18n
                "sidebar.create"
              }}</span>
          </button>
          {{#if this.fantribeCreate.isSidebarCreateMenuOpen}}
            <div
              class="fantribe-sidebar-nav__create-menu-wrap"
              {{this.positionSidebarCreateMenu}}
              {{on "mouseenter" this.cancelSidebarCreateMenuClose}}
              {{on "mouseleave" this.closeSidebarCreateMenu}}
            >
              <FtCreateMenu
                @variant="sidebar"
                @useClickOutside={{false}}
                @clickOutsideTargetSelector=".fantribe-sidebar-nav__create-wrap"
              />
            </div>
          {{/if}}
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
            <span class="fantribe-sidebar-nav__user-menu">
              {{ftIcon "more-vertical" size=20}}
            </span>
          </span>
        </button>
      {{/if}}
    </nav>
  </template>
}
