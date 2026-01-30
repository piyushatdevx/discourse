import Component from "@glimmer/component";
import { service } from "@ember/service";
import getURL from "discourse/lib/get-url";

export default class FantribeLoginLogo extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get logoUrl() {
    return getURL("/plugins/fantribe-theme/images/logo.svg");
  }

  <template>
    {{#if this.isEnabled}}
      <div class="fantribe-login-logo">
        <img src={{this.logoUrl}} alt="FanTribe" />
      </div>
    {{/if}}
  </template>
}
