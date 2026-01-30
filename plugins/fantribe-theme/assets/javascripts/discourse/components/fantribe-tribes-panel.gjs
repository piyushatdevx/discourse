import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { not } from "discourse/truth-helpers";
import icon from "discourse/helpers/d-icon";
import FantribeTribeButton from "./fantribe-tribe-button";

export default class FantribeTribesPanel extends Component {
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

  @action
  clearFilters() {
    this.fantribeFilter.clearFilters();
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
            {{icon "filter"}}
            My Tribes
          </h3>
          <p class="fantribe-tribes-panel__subtitle">Filter your content</p>
        </div>
        <button
          type="button"
          class="fantribe-tribes-panel__clear-btn"
          disabled={{not this.hasFilters}}
          {{on "click" this.clearFilters}}
        >
          Clear
        </button>
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
