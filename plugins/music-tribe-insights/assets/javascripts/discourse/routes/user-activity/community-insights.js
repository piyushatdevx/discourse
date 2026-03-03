import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";

export default class UserActivityCommunityInsightsRoute extends DiscourseRoute {
  @service router;

  beforeModel() {
    if (!this.currentUser?.admin) {
      return this.router.replaceWith("userActivity");
    }
  }

  titleToken() {
    return i18n("music_tribe_insights.dashboard.title");
  }
}
