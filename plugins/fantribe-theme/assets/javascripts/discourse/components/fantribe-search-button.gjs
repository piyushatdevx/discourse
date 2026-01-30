import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";

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
      {{icon "magnifying-glass"}}
    </button>
  </template>
}
