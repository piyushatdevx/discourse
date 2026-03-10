import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

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
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M10 8h4" />
          <path d="M12 21v-9" />
          <path d="M12 8V3" />
          <path d="M17 16h4" />
          <path d="M19 12V3" />
          <path d="M19 21v-5" />
          <path d="M3 14h4" />
          <path d="M5 10V3" />
          <path d="M5 21v-7" />
        </svg>
        <span>{{i18n "fantribe.mobile_chips.my_tribes"}}</span>
      </h3>
      <div class="fantribe-mobile-chips__row">
        <button
          type="button"
          class="fantribe-chip fantribe-chip--all
            {{if this.allCategoriesSelected 'fantribe-chip--active'}}"
          {{on "click" this.selectAll}}
        >
          <span>{{i18n
              "fantribe.mobile_chips.all_tribes"
              count=this.totalTopicCount
            }}</span>
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
                {{ftIcon "heart"}}
              </span>
            {{/if}}
          </button>
        {{/each}}
      </div>
    </div>
  </template>
}
