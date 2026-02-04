import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";

export default class FantribeMobileTribeChips extends Component {
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

  getTopicCount(category) {
    return category?.topic_count || 0;
  }

  getCategoryColorStyle(category) {
    return htmlSafe(`background-color: #${category.color}`);
  }

  get totalTopicCount() {
    return (this.categories || []).reduce(
      (sum, category) => sum + this.getTopicCount(category),
      0
    );
  }

  @action
  selectAll() {
    if (this.allCategoriesSelected) {
      this.fantribeFilter.clearFilters();
    } else {
      this.fantribeFilter.setFilters(this.categories.map((c) => c.id));
    }
  }

  @action
  toggleCategory(category) {
    this.fantribeFilter.toggleCategory(category);
  }

  <template>
    <div class="fantribe-mobile-chips">
      <h3 class="fantribe-mobile-chips__title">
        <svg
          class="fantribe-mobile-chips__filter-icon"
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
        <span>My Tribes</span>
      </h3>
      <div class="fantribe-mobile-chips__row">
        <button
          type="button"
          class="fantribe-chip fantribe-chip--all
            {{if this.allCategoriesSelected 'fantribe-chip--active'}}"
          {{on "click" this.selectAll}}
        >
          <span>All Tribes ({{this.totalTopicCount}})</span>
        </button>

        {{#each this.categories as |category|}}
          <button
            type="button"
            class="fantribe-chip
              {{if (this.isCategorySelected category) 'fantribe-chip--active'}}"
            {{on "click" (fn this.toggleCategory category)}}
          >
            <span
              class="fantribe-chip__color"
              style={{this.getCategoryColorStyle category}}
            ></span>
            <span>{{category.name}}</span>
            <span class="fantribe-chip__topic-count">
              ({{this.getTopicCount category}})
            </span>
            {{#if category.is_favorite}}
              <span class="fantribe-chip__favorite">
                {{icon "heart"}}
              </span>
            {{/if}}
          </button>
        {{/each}}
      </div>
    </div>
  </template>
}
