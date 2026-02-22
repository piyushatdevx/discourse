import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";

// Adds a "Posts" navigation tab to the user profile that renders
// the user's topics as FanTribe feed cards.
export default class FantribeProfileNav extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  <template>
    {{#if this.isEnabled}}
      <LinkTo @route="userActivity.ftPosts" class="ft-user-nav__tab">
        {{icon "bars-staggered"}}
        <span>Posts</span>
      </LinkTo>
    {{/if}}
  </template>
}
