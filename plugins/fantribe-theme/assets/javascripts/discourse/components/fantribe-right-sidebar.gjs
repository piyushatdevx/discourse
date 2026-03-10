import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";
import FtLangDropdown from "./ft-lang-dropdown";

export default class FantribeRightSidebar extends Component {
  @service router;
  @service site;
  @service fantribeFilter;

  @tracked tribes = [];

  constructor(owner, args) {
    super(owner, args);
    this.loadTribes();
  }

  async loadTribes() {
    try {
      const data = await ajax("/fantribe/trending_tribes.json");
      this.tribes = data.trending_tribes || [];
    } catch {
      // fail silently — widget shows "No active tribes yet"
    }
  }

  get activeFilters() {
    const filters = [];
    const categories = this.site.categories || [];

    for (const id of this.fantribeFilter.selectedCategoryIds) {
      const cat = categories.find((c) => c.id === id);
      filters.push({
        type: "category",
        label: cat?.name ?? String(id),
        value: id,
      });
    }

    for (const tag of this.fantribeFilter.selectedTagNames) {
      filters.push({ type: "tag", label: `#${tag}`, value: tag });
    }

    for (const username of this.fantribeFilter.selectedUsernames) {
      filters.push({ type: "user", label: `@${username}`, value: username });
    }

    if (this.fantribeFilter.contentTypeFilter !== "all") {
      filters.push({
        type: "contentType",
        label: this.fantribeFilter.contentTypeFilter,
        value: this.fantribeFilter.contentTypeFilter,
      });
    }

    if (this.fantribeFilter.dateFrom || this.fantribeFilter.dateTo) {
      filters.push({
        type: "date",
        label: [this.fantribeFilter.dateFrom, this.fantribeFilter.dateTo]
          .filter(Boolean)
          .join(" – "),
        value: null,
      });
    }

    return filters;
  }

  @action
  removeFilter(filter) {
    if (filter.type === "category") {
      this.fantribeFilter.removeCategoryById(filter.value);
    } else if (filter.type === "tag") {
      this.fantribeFilter.removeTag(filter.value);
    } else if (filter.type === "user") {
      this.fantribeFilter.removeUser(filter.value);
    } else if (filter.type === "contentType") {
      this.fantribeFilter.setContentTypeFilter("all");
    } else if (filter.type === "date") {
      this.fantribeFilter.setDateRange(null, null);
    }
  }

  formatMemberCount(count) {
    if (!count) {
      return i18n("fantribe.right_sidebar.members_count", { count: 0 });
    }
    if (count >= 1000) {
      return i18n("fantribe.right_sidebar.members_count_k", {
        count: (count / 1000).toFixed(1),
      });
    }
    return i18n("fantribe.right_sidebar.members_count", { count });
  }

  formatPostCount(count) {
    if (!count) {
      return i18n("fantribe.right_sidebar.posts_count", { count: 0 });
    }
    if (count >= 1000) {
      return i18n("fantribe.right_sidebar.posts_count_k", {
        count: (count / 1000).toFixed(1),
      });
    }
    return i18n("fantribe.right_sidebar.posts_count", { count });
  }

  @action
  navigateToTribe(tribe) {
    this.router.transitionTo("discovery.category", tribe.slug);
  }

  @action
  viewAllTribes() {
    this.router.transitionTo("explore");
  }

  <template>
    <div class="fantribe-right-sidebar">

      {{! Search + Filter row }}
      <div class="fantribe-right-sidebar__search-row">
        <button
          type="button"
          class="fantribe-right-sidebar__search-bar"
          aria-label={{i18n "fantribe.right_sidebar.open_search"}}
          {{on "click" this.fantribeFilter.openSearchModal}}
        >
          {{ftIcon "search" size=18}}
          <span class="fantribe-right-sidebar__search-placeholder">{{i18n
              "fantribe.right_sidebar.search_placeholder"
            }}</span>
        </button>
        <button
          type="button"
          class="fantribe-right-sidebar__filter-btn
            {{if
              this.fantribeFilter.hasFilters
              'fantribe-right-sidebar__filter-btn--active'
            }}"
          aria-label={{i18n "fantribe.right_sidebar.open_filters"}}
          {{on "click" this.fantribeFilter.openFiltersModal}}
        >
          {{ftIcon "filter-lines" size=24}}
        </button>
        <div class="fantribe-right-sidebar__lang-dropdown">
          <FtLangDropdown />
        </div>
      </div>

      {{#if this.fantribeFilter.hasFilters}}
        <div class="fantribe-right-sidebar__clear-filters">
          {{#each this.activeFilters as |filter|}}
            <button
              type="button"
              class="fantribe-right-sidebar__filter-pill"
              {{on "click" (fn this.removeFilter filter)}}
            >
              <span
                class="fantribe-right-sidebar__filter-pill-label"
              >{{filter.label}}</span>
              <span class="fantribe-right-sidebar__filter-pill-x">×</span>
            </button>
          {{/each}}
          <button
            type="button"
            class="fantribe-right-sidebar__clear-all-btn"
            {{on "click" this.fantribeFilter.clearFilters}}
          >
            {{i18n "fantribe.right_sidebar.clear_all"}}
          </button>
        </div>
      {{/if}}

      {{! Trending Tribes Widget }}
      <div class="fantribe-right-sidebar__widget">
        <div class="fantribe-right-sidebar__widget-header">
          {{ftIcon "trending-up"}}
          <h3>{{i18n "fantribe.right_sidebar.trending_tribes"}}</h3>
        </div>

        <div class="fantribe-right-sidebar__widget-content">
          {{#if this.tribes.length}}
            {{#each this.tribes as |tribe|}}
              <button
                type="button"
                class="fantribe-right-sidebar__tribe-item"
                {{on "click" (fn this.navigateToTribe tribe)}}
              >
                <div class="fantribe-right-sidebar__tribe-info">
                  <span
                    class="fantribe-right-sidebar__tribe-name"
                  >{{tribe.name}}</span>
                  <div class="fantribe-right-sidebar__tribe-meta">
                    {{ftIcon "users" size=12}}
                    <span>{{this.formatMemberCount tribe.member_count}}</span>
                    <span
                      class="fantribe-right-sidebar__tribe-meta-sep"
                    >·</span>
                    {{ftIcon "message-circle" size=12}}
                    <span>{{this.formatPostCount tribe.post_count}}</span>
                  </div>
                </div>
                {{ftIcon "trend-arrow" size=16}}
              </button>
            {{/each}}
          {{else}}
            <div class="fantribe-right-sidebar__empty">
              <p>{{i18n "fantribe.right_sidebar.no_active_tribes"}}</p>
            </div>
          {{/if}}
        </div>

        <div class="fantribe-right-sidebar__widget-footer">
          <button
            type="button"
            class="fantribe-right-sidebar__footer-btn"
            {{on "click" this.viewAllTribes}}
          >
            {{i18n "fantribe.right_sidebar.view_all"}}
          </button>
        </div>
      </div>
    </div>
  </template>
}
