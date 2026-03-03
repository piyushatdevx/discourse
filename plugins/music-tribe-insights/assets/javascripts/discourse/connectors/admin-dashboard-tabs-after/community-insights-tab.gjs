import Component from "@glimmer/component";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";

export default class CommunityInsightsTab extends Component {
  static shouldRender(args, context) {
    return context.currentUser?.admin;
  }

  get communityInsightsUrl() {
    return getURL("/admin/dashboard/community_insights");
  }

  <template>
    <li class="navigation-item community-insights">
      <a href={{this.communityInsightsUrl}} class="navigation-link">
        {{i18n "music_tribe_insights.dashboard.title"}}
      </a>
    </li>
  </template>
}
