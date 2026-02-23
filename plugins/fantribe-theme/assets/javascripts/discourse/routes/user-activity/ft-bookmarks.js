import { TrackedArray } from "@ember-compat/tracked-built-ins";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

// Renders the FanTribe-styled list of topics the user has bookmarked.
// Uses Discourse's /u/:username/bookmarks.json endpoint which returns a
// paginated list of bookmarks; we extract the associated topic for each.
export default class UserActivityFtBookmarksRoute extends DiscourseRoute {
  async model() {
    const username = this.modelFor("user").username;
    try {
      const response = await ajax(`/u/${username}/bookmarks.json`);
      const bookmarks =
        response.user_bookmark_list?.bookmarks || response.bookmarks || [];
      // Each bookmark has a `topic` object with standard topic-list fields.
      // Filter out any bookmarks that have been deleted/unavailable.
      return new TrackedArray(
        bookmarks.filter((b) => b.topic).map((b) => b.topic)
      );
    } catch {
      return new TrackedArray([]);
    }
  }
}
