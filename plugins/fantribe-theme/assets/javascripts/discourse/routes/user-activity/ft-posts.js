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
      // The topic-list API returns users in a top-level array keyed by id.
      // Each topic's `posters` array only contains user_id references, not
      // embedded user objects. Build a lookup map and attach user objects so
      // the feed card can render the poster's name/avatar correctly.
      const users = response.users || [];
      const usersById = Object.fromEntries(users.map((u) => [u.id, u]));
      const topics = (response.topic_list?.topics || []).map((topic) => {
        if (topic.posters) {
          topic.posters = topic.posters.map((p) => ({
            ...p,
            user: usersById[p.user_id] || p.user,
          }));
        }
        return topic;
      });
      return new TrackedArray(topics);
    } catch {
      return new TrackedArray([]);
    }
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.set("username", this.modelFor("user").username);
  }
}
