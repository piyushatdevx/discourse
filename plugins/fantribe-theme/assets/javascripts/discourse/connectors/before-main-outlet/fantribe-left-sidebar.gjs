import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import FantribeTribesPanel from "../../components/fantribe-tribes-panel";

export default class FantribeLeftSidebar extends Component {
  @service siteSettings;
  @service router;
  @service site;
  @service fantribeFilter;

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

  @action
  initializeFilters() {
    this.fantribeFilter.initializeWithAllIfEmpty(this.categories);
  }

  <template>
    {{#if this.shouldRender}}
      <aside class="fantribe-left-sidebar" {{didInsert this.initializeFilters}}>
        <FantribeTribesPanel />
      </aside>
    {{/if}}
  </template>
}
