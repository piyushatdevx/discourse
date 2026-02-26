import Component from "@glimmer/component";
import { service } from "@ember/service";
import FantribeLoginForm from "../../components/fantribe-login-form";

export default class FantribeLoginWrapper extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  <template>
    {{#if this.isEnabled}}
      <FantribeLoginForm @outletArgs={{@outletArgs}} />
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
