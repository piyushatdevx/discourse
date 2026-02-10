import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";

const NAV_ITEMS = [
  {
    id: "home-feed",
    label: "Home Feed",
    icon: "house",
    route: "discovery.latest",
  },
  {
    id: "explore-tribes",
    label: "Explore Tribes",
    icon: "compass",
    route: "discovery.categories",
  },
  { id: "marketplace", label: "Marketplace", icon: "store" },
  { id: "co-create", label: "Co-Create", icon: "people-group" },
  { id: "live-events", label: "Live Events", icon: "tower-broadcast" },
  { id: "chat", label: "Chat", icon: "comments", route: "chat.index" },
  { id: "dashboard", label: "Dashboard", icon: "table-columns" },
  { id: "content-studio", label: "Content Studio", icon: "tv" },
  {
    id: "product-discovery",
    label: "Product Discovery",
    icon: "wand-magic-sparkles",
  },
  { id: "fan-crm", label: "Fan CRM", icon: "address-book" },
  { id: "rewards", label: "Rewards", icon: "gift" },
  { id: "revenue", label: "Revenue", icon: "dollar-sign" },
  { id: "partnerships", label: "Partnerships", icon: "handshake" },
];

export default class FantribeTribesPanel extends Component {
  @service router;
  @service currentUser;

  isActive = (item) => {
    const route = this.router.currentRouteName || "";
    if (!item.route) {
      return false;
    }
    if (item.route === "discovery.latest") {
      return (
        route === "discovery.latest" ||
        route === "discovery.top" ||
        route === "discovery.new" ||
        route === "discovery.unread" ||
        route === "discovery.hot" ||
        route === "index"
      );
    }
    if (item.route === "discovery.categories") {
      return route === "discovery.categories";
    }
    if (item.route === "chat.index") {
      return route.startsWith("chat");
    }
    return route === item.route;
  };

  get navItems() {
    return NAV_ITEMS;
  }

  @action
  navigateTo(item) {
    if (!item.route) {
      return;
    }
    try {
      this.router.transitionTo(item.route);
    } catch {
      // Route may not exist (e.g., chat not enabled)
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
  }

  <template>
    <nav class="fantribe-sidebar-nav">
      <div class="fantribe-sidebar-nav__items">
        {{#each this.navItems as |item|}}
          <button
            type="button"
            class="fantribe-sidebar-nav__item
              {{if (this.isActive item) 'fantribe-sidebar-nav__item--active'}}"
            {{on "click" (fn this.navigateTo item)}}
          >
            <span class="fantribe-sidebar-nav__item-icon">
              {{icon item.icon}}
            </span>
            <span class="fantribe-sidebar-nav__item-label">{{item.label}}</span>
            {{#if (this.isActive item)}}
              <span class="fantribe-sidebar-nav__item-chevron">
                {{icon "chevron-right"}}
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
        {{icon "chevron-left"}}
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
            {{icon "chevron-right"}}
          </span>
        </button>
      {{/if}}
    </nav>
  </template>
}
