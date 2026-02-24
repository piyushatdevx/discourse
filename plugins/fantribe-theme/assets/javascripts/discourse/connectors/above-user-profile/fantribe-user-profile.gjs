import Component from "@glimmer/component";
import { service } from "@ember/service";
import FtUserProfileHeader from "../../components/ft-user-profile-header";

export default class FantribeUserProfile extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  <template>
    {{#if this.isEnabled}}
      <FtUserProfileHeader @user={{@outletArgs.model}} />
    {{/if}}
  </template>
}
