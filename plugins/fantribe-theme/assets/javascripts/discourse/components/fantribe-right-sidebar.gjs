import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import ftIcon from "../helpers/ft-icon";

function dotStyle(color) {
  return htmlSafe(`background-color: #${color}`);
}

export default class FantribeRightSidebar extends Component {
  @service router;
  @service site;
  @service fantribeFilter;

  @tracked searchQuery = "";

  get tribes() {
    return this.site.trending_tribes || [];
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

  @action
  updateSearch(event) {
    this.searchQuery = event.target.value;
  }

  @action
  handleSearchKeydown(event) {
    if (event.key === "Enter") {
      const q = this.searchQuery.trim();
      if (q) {
        this.router.transitionTo("full-page-search", { queryParams: { q } });
      } else {
        this.router.transitionTo("full-page-search");
      }
    }
  }

  <template>
    <div class="fantribe-right-sidebar">

      {{! Search + Filter row }}
      <div class="fantribe-right-sidebar__search-row">
        <label class="fantribe-right-sidebar__search-bar">
          {{ftIcon "search" size=18}}
          <input
            type="text"
            class="fantribe-right-sidebar__search-input"
            placeholder="Search people, gear, tribes..."
            value={{this.searchQuery}}
            {{on "input" this.updateSearch}}
            {{on "keydown" this.handleSearchKeydown}}
          />
        </label>
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
          {{ftIcon "sliders-horizontal" size=24}}
        </button>
      </div>

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
                <div class="fantribe-right-sidebar__tribe-lead">
                  {{#if tribe.logo_url}}
                    <img
                      src={{tribe.logo_url}}
                      class="fantribe-right-sidebar__tribe-logo"
                      alt=""
                    />
                  {{else}}
                    <span
                      class="fantribe-right-sidebar__tribe-dot"
                      style={{dotStyle tribe.color}}
                    ></span>
                  {{/if}}
                </div>
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
                {{ftIcon "chevron-right" size=16}}
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
            See all tribes
          </button>
        </div>
      </div>
    </div>
  </template>
}
