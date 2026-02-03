import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";

export default class FantribeSearchButton extends Component {
  @service router;

  @action
  openSearch() {
    // Navigate to the full page search
    this.router.transitionTo("full-page-search");
  }

  <template>
    <button
      class="fantribe-search-btn"
      type="button"
      aria-label="Search"
      {{on "click" this.openSearch}}
    >
      <svg
        class="fantribe-search-btn__icon"
        xmlns="http://www.w3.org/2000/svg"
        width="20"
        height="20"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="m21 21-4.34-4.34"></path>
        <circle cx="11" cy="11" r="8"></circle>
      </svg>
    </button>
  </template>
}
