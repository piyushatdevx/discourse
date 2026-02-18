import Component from "@glimmer/component";
import { service } from "@ember/service";
import FantribeFab from "../../components/fantribe-fab";
import FantribeHeader from "../../components/fantribe-header";
import FantribeMobileNav from "../../components/fantribe-mobile-nav";

export default class FantribeHeaderConnector extends Component {
  @service siteSettings;
  @service fantribeSidebarState;

  <template>
    {{#if this.isEnabled}}
      <FantribeHeader @onToggleSidebar={{this.fantribeSidebarState.toggle}} />
      <FantribeMobileNav />
      <FantribeFab />
    {{/if}}
  </template>

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }
}
