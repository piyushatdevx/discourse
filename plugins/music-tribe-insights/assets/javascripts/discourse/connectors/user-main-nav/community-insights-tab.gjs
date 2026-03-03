import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class CommunityInsightsTab extends Component {
  @service currentUser;

  get showTab() {
    return this.currentUser?.admin;
  }

  <template>
    {{#if this.showTab}}
      <LinkTo @route="userActivity.communityInsights" class="ft-user-nav__tab">
        {{icon "chart-bar"}}
        <span>{{i18n "music_tribe_insights.user_nav.title"}}</span>
      </LinkTo>
    {{/if}}
  </template>
}
