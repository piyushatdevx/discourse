import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";

export default class FantribeNavItem extends Component {
  @service router;

  get isActive() {
    const currentRoute = this.router.currentRouteName;
    return currentRoute === this.args.route;
  }

  @action
  navigate() {
    this.router.transitionTo(this.args.route);
  }

  <template>
    <button
      class="fantribe-nav-item {{if this.isActive 'fantribe-nav-item--active'}}"
      type="button"
      {{on "click" this.navigate}}
    >
      {{icon @icon}}
      <span class="fantribe-nav-item__label">{{@label}}</span>
    </button>
  </template>
}
