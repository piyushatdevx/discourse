import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import FantribeTribesPanel from "../../components/fantribe-tribes-panel";
import ftIcon from "../../helpers/ft-icon";

export default class FantribeLeftSidebar extends Component {
  @service siteSettings;
  @service router;
  @service site;
  @service fantribeSidebarState;
  @service fantribeMembership;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get isAdminRoute() {
    const route = this.router.currentRouteName || "";
    return route.startsWith("admin") || route.startsWith("wizard");
  }

  get shouldRender() {
    return this.isEnabled && !this.isAdminRoute;
  }

  get categories() {
    return (this.site.categories || [])
      .filter((c) => !c.isUncategorized && c.permission !== null)
      .sort((a, b) => (a.position || 0) - (b.position || 0));
  }

  get sidebarClass() {
    const classes = ["fantribe-left-sidebar"];
    if (this.fantribeSidebarState.isCollapsed) {
      classes.push("fantribe-left-sidebar--collapsed");
    }
    if (this.fantribeSidebarState.isMobileOpen) {
      classes.push("fantribe-left-sidebar--mobile-open");
    }
    return classes.join(" ");
  }

  @action
  initializeFilters() {
    this.fantribeMembership.initialize();
  }

  @action
  closeMobileOverlay() {
    this.fantribeSidebarState.closeMobile();
  }

  <template>
    {{#if this.shouldRender}}
      {{! Mobile overlay backdrop }}
      {{#if this.fantribeSidebarState.isMobileOpen}}
        <div
          class="fantribe-sidebar-overlay"
          role="button"
          {{on "click" this.closeMobileOverlay}}
        ></div>
      {{/if}}

      <aside class={{this.sidebarClass}} {{didInsert this.initializeFilters}}>
        <div class="fantribe-left-sidebar__content">
          <FantribeTribesPanel />
        </div>

        <button
          class="fantribe-left-sidebar__toggle"
          type="button"
          aria-label="Toggle sidebar"
          {{on "click" this.fantribeSidebarState.toggle}}
        >
          {{ftIcon
            (if
              this.fantribeSidebarState.isCollapsed
              "chevron-right"
              "chevron-left"
            )
            size=14
          }}
        </button>
      </aside>
    {{/if}}
  </template>
}
