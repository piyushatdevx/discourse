import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class FantribeFab extends Component {
  @service composer;
  @service currentUser;

  openComposer = () => {
    this.composer.openNewTopic();
  };

  get isVisible() {
    // Only show FAB when user is logged in
    // CSS handles desktop/mobile visibility
    return this.currentUser;
  }

  <template>
    {{#if this.isVisible}}
      <button
        class="fantribe-fab"
        type="button"
        aria-label="Create new post"
        {{on "click" this.openComposer}}
      >
        {{icon "plus"}}
      </button>
    {{/if}}
  </template>
}
