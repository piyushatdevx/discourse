import { TrackedArray } from "@ember-compat/tracked-built-ins";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

// Renders the FanTribe-styled feed of topics created by this user.
// Uses Discourse's /topics/created-by/:username endpoint which returns
// a standard topic list that our feed card component can render.
export default class UserActivityFtPostsRoute extends DiscourseRoute {
  async model() {
    const username = this.modelFor("user").username;
    try {
      const response = await ajax(`/topics/created-by/${username}.json`);
      return new TrackedArray(response.topic_list?.topics || []);
    } catch {
      return new TrackedArray([]);
    }
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.set("username", this.modelFor("user").username);
  }
}
