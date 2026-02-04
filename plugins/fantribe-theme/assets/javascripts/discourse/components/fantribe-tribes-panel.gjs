import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import FantribeTribeButton from "./fantribe-tribe-button";

export default class FantribeTribesPanel extends Component {
  @service fantribeFilter;
  @service site;

  isCategorySelected = (category) => {
    return this.fantribeFilter.isCategorySelected(category);
  };

  get categories() {
    return (this.site.categories || [])
      .filter((c) => !c.isUncategorized && c.permission !== null)
      .sort((a, b) => (a.position || 0) - (b.position || 0));
  }

  get hasFilters() {
    return this.fantribeFilter.hasFilters;
  }

  get allCategoriesSelected() {
    const { categories } = this;
    return (
      categories.length > 0 &&
      categories.every((c) =>
        this.fantribeFilter.selectedCategoryIds.includes(c.id)
      )
    );
  }

  @action
  clearFilters() {
    this.fantribeFilter.clearFilters();
  }

  @action
  selectAllCategories() {
    this.fantribeFilter.setFilters(this.categories.map((c) => c.id));
  }

  @action
  toggleCategory(category) {
    this.fantribeFilter.toggleCategory(category);
  }

  <template>
    <div class="fantribe-tribes-panel">
      <div class="fantribe-tribes-panel__header">
        <div class="fantribe-tribes-panel__title-group">
          <h3 class="fantribe-tribes-panel__title">
            <svg
              class="fantribe-tribes-panel__filter-icon"
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="red"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            ><path
                d="M10 20a1 1 0 0 0 .553.895l2 1A1 1 0 0 0 14 21v-7a2 2 0 0 1 .517-1.341L21.74 4.67A1 1 0 0 0 21 3H3a1 1 0 0 0-.742 1.67l7.225 7.989A2 2 0 0 1 10 14z"
              ></path></svg>
            My Tribes
          </h3>
          <p class="fantribe-tribes-panel__subtitle">Filter your content</p>
        </div>
        {{#if this.allCategoriesSelected}}
          <button
            type="button"
            class="fantribe-tribes-panel__clear-btn"
            {{on "click" this.clearFilters}}
          >
            Clear
          </button>
        {{else}}
          <button
            type="button"
            class="fantribe-tribes-panel__all-btn"
            {{on "click" this.selectAllCategories}}
          >
            All Tribes
          </button>
        {{/if}}
      </div>

      <div class="fantribe-tribes-panel__content">
        {{#each this.categories as |category index|}}
          <FantribeTribeButton
            @category={{category}}
            @isSelected={{this.isCategorySelected category}}
            @onToggle={{fn this.toggleCategory category}}
            @gradientIndex={{index}}
          />
        {{/each}}
      </div>
    </div>
  </template>
}
