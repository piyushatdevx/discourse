import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import FantribeTribeCard from "./fantribe-tribe-card";

export default class FantribeExplorePage extends Component {
  @tracked activeFilter = "All";
  @tracked isFilterOpen = false;

  isActiveFilter = (filter) => filter === this.activeFilter;

  get parentCategories() {
    const cats = this.args.categories || [];
    return cats.filter(
      (c) => !c.parent_category_id && !c.isUncategorizedCategory
    );
  }

  get filterOptions() {
    const parents = this.parentCategories;
    const names = parents.map((c) => c.name);
    return ["All", ...new Set(names)];
  }

  get allDisplayCategories() {
    const cats = this.args.categories || [];
    return cats.filter((c) => !c.isUncategorizedCategory);
  }

  get filteredCategories() {
    if (this.activeFilter === "All") {
      return this.allDisplayCategories;
    }
    return this.allDisplayCategories.filter((c) => {
      if (c.name === this.activeFilter) {
        return true;
      }
      const parent = c.parentCategory;
      return parent && parent.name === this.activeFilter;
    });
  }

  get showCategoryLabel() {
    return this.activeFilter !== "All";
  }

  @action
  toggleFilter() {
    this.isFilterOpen = !this.isFilterOpen;
  }

  @action
  closeFilter() {
    this.isFilterOpen = false;
  }

  @action
  selectFilter(filter) {
    this.activeFilter = filter;
    this.isFilterOpen = false;
  }

  <template>
    <div class="ft-explore-page">
      <div class="ft-explore-container">
        {{! Page header }}
        <div class="ft-explore-header">
          <h1 class="ft-explore-title">Explore Tribes</h1>
          <p class="ft-explore-subtitle">Join communities of creators who share
            your passion</p>
        </div>

        {{! Filter dropdown }}
        <div class="ft-explore-filters">
          <div class="ft-filter-dropdown">
            <button
              class="ft-filter-dropdown__trigger"
              type="button"
              {{on "click" this.toggleFilter}}
            >
              {{icon "sliders"}}
              <span>Filter: {{this.activeFilter}}</span>
              <span
                class="ft-filter-dropdown__chevron
                  {{if this.isFilterOpen 'ft-filter-dropdown__chevron--open'}}"
              >
                {{icon "chevron-down"}}
              </span>
            </button>

            {{#if this.isFilterOpen}}
              {{! template-lint-disable no-invalid-interactive }}
              <div
                class="ft-filter-dropdown__backdrop"
                {{on "click" this.closeFilter}}
              ></div>

              <div class="ft-filter-dropdown__menu">
                {{#each this.filterOptions as |filter|}}
                  <button
                    class="ft-filter-dropdown__item
                      {{if
                        (this.isActiveFilter filter)
                        'ft-filter-dropdown__item--active'
                      }}"
                    type="button"
                    {{on "click" (fn this.selectFilter filter)}}
                  >
                    <span>{{filter}}</span>
                    {{#if (this.isActiveFilter filter)}}
                      {{icon "check"}}
                    {{/if}}
                  </button>
                {{/each}}
              </div>
            {{/if}}
          </div>
        </div>

        {{! Results count }}
        <div class="ft-explore-results-count">
          <p>
            Showing
            <span
              class="ft-count-number"
            >{{this.filteredCategories.length}}</span>
            tribes
            {{#if this.showCategoryLabel}}
              in
              <span class="ft-count-category">{{this.activeFilter}}</span>
            {{/if}}
          </p>
        </div>

        {{! Tribe grid or empty state }}
        {{#if this.filteredCategories.length}}
          <div class="ft-tribe-grid">
            {{#each this.filteredCategories as |category|}}
              <FantribeTribeCard @category={{category}} />
            {{/each}}
          </div>
        {{else}}
          <div class="ft-explore-empty">
            <div class="ft-explore-empty-icon">🔍</div>
            <h3 class="ft-explore-empty-title">No tribes found</h3>
            <p class="ft-explore-empty-text">Try adjusting your search or
              filters</p>
          </div>
        {{/if}}
      </div>
    </div>
  </template>
}
