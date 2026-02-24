import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import ftIcon from "../../helpers/ft-icon";

// Injects FanTribe's profile tabs into the user-main-nav outlet.
// All native Discourse tabs (Activity, Notifications, etc.) are hidden
// via CSS in user-profile.scss using display:none !important, and the
// default userActivity route is redirected to ftPosts in the initializer.
export default class FantribeProfileNav extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  <template>
    {{#if this.isEnabled}}
      <LinkTo @route="userActivity.ftPosts" class="ft-user-nav__tab">
        {{ftIcon "music" size=16}}
        <span>Posts</span>
      </LinkTo>

      <LinkTo @route="userActivity.ftBookmarks" class="ft-user-nav__tab">
        {{ftIcon "bookmark" size=16}}
        <span>Bookmarks</span>
      </LinkTo>
    {{/if}}
  </template>
}
