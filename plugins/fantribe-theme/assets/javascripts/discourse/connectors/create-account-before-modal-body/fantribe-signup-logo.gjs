import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import getURL from "discourse/lib/get-url";
import FtLangDropdown from "../../components/ft-lang-dropdown";

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

  get helpUrl() {
    return "https://support.empowertribe.com";
  }

  <template>
    {{#if this.isEnabled}}
      <header class="fantribe-login-header">
        <a href={{this.homeUrl}} class="fantribe-login-header__logo">
          <img src={{this.logoUrl}} alt="FanTribe" />
        </a>
        <div class="fantribe-login-header__actions">
          <FtLangDropdown />
          <a
            href={{this.helpUrl}}
            class="fantribe-login-header__btn"
            target="_blank"
            rel="noopener noreferrer"
          >
            {{icon "headset"}}
            <span>Help</span>
          </a>
        </div>
      </header>
    {{/if}}
  </template>
}
