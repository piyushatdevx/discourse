import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn, concat } from "@ember/helper";
import { not } from "discourse/truth-helpers";
import icon from "discourse/helpers/d-icon";

export default class FantribeMobileTribeChips extends Component {
  @service fantribeFilter;
  @service site;

  get categories() {
    return (this.site.categories || [])
      .filter((c) => !c.isUncategorized && c.permission !== null)
      .sort((a, b) => (a.position || 0) - (b.position || 0));
  }

  get hasFilters() {
    return this.fantribeFilter.hasFilters;
  }

  isCategorySelected = (category) => {
    return this.fantribeFilter.isCategorySelected(category);
  };

  getTopicCount(category) {
    return category?.topic_count || 0;
  }

  @action
  selectAll() {
    this.fantribeFilter.clearFilters();
  }

  @action
  toggleCategory(category) {
    this.fantribeFilter.toggleCategory(category);
  }

  <template>
    <div class="fantribe-mobile-chips">
      <button
        type="button"
        class="fantribe-chip fantribe-chip--all
          {{if (not this.hasFilters) 'fantribe-chip--active'}}"
        {{on "click" this.selectAll}}
      >
        {{icon "globe"}}
        <span>All</span>
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
            style={{concat "background-color: #" category.color}}
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
  </template>
}
