import Component from "@glimmer/component";
import { service } from "@ember/service";
import FantribeHeader from "../../components/fantribe-header";
import FantribeMobileNav from "../../components/fantribe-mobile-nav";
import FantribeFab from "../../components/fantribe-fab";

export default class FantribeHeaderConnector extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  <template>
    {{#if this.isEnabled}}
      <FantribeHeader />
      <FantribeMobileNav />
      <FantribeFab />
    {{/if}}
  </template>
}
