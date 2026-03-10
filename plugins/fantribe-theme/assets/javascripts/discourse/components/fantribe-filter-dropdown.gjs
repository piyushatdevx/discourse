import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";

export default class FantribeFilterDropdown extends Component {
  <template>
    <div class="ft-filter-dropdown">
      <button
        class="ft-filter-dropdown__trigger"
        type="button"
        {{on "click" @onToggle}}
      >
        <svg
          class="ft-filter-dropdown__icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="M10 5H3" />
          <path d="M12 19H3" />
          <path d="M14 3v4" />
          <path d="M16 17v4" />
          <path d="M21 12h-9" />
          <path d="M21 19h-5" />
          <path d="M21 5h-7" />
          <path d="M8 10v4" />
          <path d="M8 12H3" />
        </svg>
        <span>{{i18n "fantribe.filter_dropdown.filter"}}:
          {{@activeFilter}}</span>
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
          aria-label={{i18n "fantribe.filter_dropdown.close_filter"}}
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
