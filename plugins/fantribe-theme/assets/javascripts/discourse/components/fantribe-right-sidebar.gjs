import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ftIcon from "../helpers/ft-icon";

export default class FantribeRightSidebar extends Component {
  @service router;
  @service site;
  @service fantribeFilter;

  get tribes() {
    return this.site.trending_tribes || [];
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
      return "0 members";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K members";
    }
    return `${count} members`;
  }

  formatPostCount(count) {
    if (!count) {
      return "0 posts";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K posts";
    }
    return `${count} posts`;
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
          aria-label="Open search"
          {{on "click" this.fantribeFilter.openSearchModal}}
        >
          {{ftIcon "search" size=18}}
          <span class="fantribe-right-sidebar__search-placeholder">Search
            people, gear, tribes...</span>
        </button>
        <button
          type="button"
          class="fantribe-right-sidebar__filter-btn
            {{if
              this.fantribeFilter.hasFilters
              'fantribe-right-sidebar__filter-btn--active'
            }}"
          aria-label="Open filters"
          {{on "click" this.fantribeFilter.openFiltersModal}}
        >
          {{ftIcon "filter-lines" size=24}}
        </button>
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
            Clear all
          </button>
        </div>
      {{/if}}

      {{! Trending Tribes Widget }}
      <div class="fantribe-right-sidebar__widget">
        <div class="fantribe-right-sidebar__widget-header">
          {{ftIcon "trending-up"}}
          <h3>Trending Tribes</h3>
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
              <p>No active tribes yet</p>
            </div>
          {{/if}}
        </div>

        <div class="fantribe-right-sidebar__widget-footer">
          <button
            type="button"
            class="fantribe-right-sidebar__footer-btn"
            {{on "click" this.viewAllTribes}}
          >
            View all
          </button>
        </div>
      </div>
    </div>
  </template>
}
