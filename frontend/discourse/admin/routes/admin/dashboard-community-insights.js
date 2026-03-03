import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";

export default class AdminDashboardCommunityInsightsRoute extends DiscourseRoute {
  titleToken() {
    return i18n("music_tribe_insights.dashboard.title");
  }
}
