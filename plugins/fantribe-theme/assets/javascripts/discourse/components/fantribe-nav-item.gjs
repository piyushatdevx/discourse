import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

export default class FantribeNavItem extends Component {
  @service router;

  get isActive() {
    const currentRoute = this.router.currentRouteName;
    return currentRoute === this.args.route;
  }

  get isHouseIcon() {
    return this.args.icon === "house";
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
      {{#if this.isHouseIcon}}
        <svg
          class="fantribe-nav-item__icon fantribe-nav-item__icon--house"
          xmlns="http://www.w3.org/2000/svg"
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          aria-hidden="true"
        >
          <path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"></path>
          <path
            d="M3 10a2 2 0 0 1 .709-1.528l7-6a2 2 0 0 1 2.582 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
          ></path>
        </svg>
      {{else}}
        {{icon @icon}}
      {{/if}}
      <span class="fantribe-nav-item__label">{{@label}}</span>
    </button>
  </template>
}
