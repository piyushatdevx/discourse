import Component from "@glimmer/component";
import { service } from "@ember/service";
import FtUserProfileHeader from "../../components/ft-user-profile-header";

export default class FantribeUserProfile extends Component {
  @service siteSettings;
  @service router;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get showProfileHeader() {
    const route = this.router.currentRouteName || "";
    return (
      !route.startsWith("userNotifications") &&
      !route.startsWith("userPrivateMessages")
    );
  }

  get shouldShowProfile() {
    return this.isEnabled && this.showProfileHeader;
  }

  <template>
    {{#if this.shouldShowProfile}}
      <FtUserProfileHeader @user={{@outletArgs.model}} />
    {{/if}}
  </template>
}
