import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";

export default class FantribeFilterDropdown extends Component {
  <template>
    <div class="ft-filter-dropdown">
      <button
        class="ft-filter-dropdown__trigger"
        type="button"
        {{on "click" @onToggle}}
      >
        {{! SlidersHorizontal icon (Lucide, 24x24 viewBox, stroke-width 2) }}
        <svg
          class="ft-filter-dropdown__icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <line x1="21" x2="14" y1="4" y2="4" />
          <line x1="10" x2="3" y1="4" y2="4" />
          <line x1="21" x2="12" y1="12" y2="12" />
          <line x1="8" x2="3" y1="12" y2="12" />
          <line x1="21" x2="16" y1="20" y2="20" />
          <line x1="12" x2="3" y1="20" y2="20" />
          <line x1="14" x2="14" y1="2" y2="6" />
          <line x1="8" x2="8" y1="10" y2="14" />
          <line x1="16" x2="16" y1="18" y2="22" />
        </svg>
        <span>Filter: {{@activeFilter}}</span>
        {{! ChevronDown icon }}
        <svg
          class="ft-filter-dropdown__chevron
            {{if @isOpen 'ft-filter-dropdown__chevron--open'}}"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      </button>

      {{#if @isOpen}}
        {{! Backdrop to capture outside clicks }}
        <button
          class="ft-filter-dropdown__backdrop"
          type="button"
          aria-label="Close filter"
          {{on "click" @onClose}}
        ></button>

        {{! Dropdown menu }}
        <div class="ft-filter-dropdown__menu">
          {{#each @filters as |filter|}}
            <button
              class="ft-filter-dropdown__item
                {{if
                  (this.isActive filter)
                  'ft-filter-dropdown__item--active'
                }}"
              type="button"
              {{on "click" (fn @onSelect filter)}}
            >
              <span>{{filter}}</span>
              {{#if (this.isActive filter)}}
                {{! Check icon }}
                <svg
                  class="ft-filter-dropdown__check"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M20 6 9 17l-5-5" />
                </svg>
              {{/if}}
            </button>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>

  isActive = (filter) => filter === this.args.activeFilter;
}
