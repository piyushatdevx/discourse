import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class FantribeFab extends Component {
  @service fantribeCreate;
  @service currentUser;

  get isVisible() {
    return this.currentUser;
  }

  <template>
    {{#if this.isVisible}}
      <button
        class="fantribe-fab"
        style="display: none;"
        type="button"
        aria-label="Create new post"
        {{on "click" this.fantribeCreate.openCreatePostModal}}
      >
        {{icon "plus"}}
      </button>
    {{/if}}
  </template>
}
