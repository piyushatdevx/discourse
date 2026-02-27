import Component from "@glimmer/component";
import { service } from "@ember/service";
import getURL from "discourse/lib/get-url";

export default class FantribeSignupLogo extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get logoUrl() {
    return getURL("/plugins/fantribe-theme/images/logo.svg");
  }

  get homeUrl() {
    return getURL("/");
  }

  <template>
    {{#if this.isEnabled}}
      <header class="fantribe-login-header">
        <a href={{this.homeUrl}} class="fantribe-login-header__logo">
          <img src={{this.logoUrl}} alt="FanTribe" />
        </a>
      </header>
    {{/if}}
  </template>
}
