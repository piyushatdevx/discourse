import DiscourseRoute from "discourse/routes/discourse";

export default class UserActivityFtSettingsRoute extends DiscourseRoute {
  model() {
    return this.modelFor("user");
  }
}
