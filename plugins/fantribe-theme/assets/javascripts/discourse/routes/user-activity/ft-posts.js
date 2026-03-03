import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { TrackedArray } from "@ember-compat/tracked-built-ins";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

// Renders the FanTribe-styled feed of topics created by this user.
// Uses Discourse's /topics/created-by/:username endpoint which returns
// a standard topic list that our feed card component can render.
// Paginated via the more_topics_url field returned by Discourse's topic list API.

function attachUsers(topics, users) {
  const usersById = Object.fromEntries(users.map((u) => [u.id, u]));
  return topics.map((topic) => {
    if (topic.posters) {
      topic.posters = topic.posters.map((p) => ({
        ...p,
        user: usersById[p.user_id] || p.user,
      }));
    }
    return topic;
  });
}

class FtPostList {
  @tracked topics;
  @tracked canLoadMore;
  @tracked isLoadingMore = false;
  _page = 0;
  _username;

  constructor({ topics, canLoadMore, username }) {
    this.topics = new TrackedArray(topics);
    this.canLoadMore = canLoadMore;
    this._username = username;
  }

  @action
  async loadMore() {
    if (!this.canLoadMore || this.isLoadingMore) {
      return;
    }
    this.isLoadingMore = true;
    try {
      const nextPage = this._page + 1;
      const response = await ajax(
        `/topics/created-by/${this._username}.json?page=${nextPage}`
      );
      const newTopics = attachUsers(
        response.topic_list?.topics || [],
        response.users || []
      );
      this.topics.push(...newTopics);
      this._page = nextPage;
      this.canLoadMore = !!response.topic_list?.more_topics_url;
    } catch {
      // silently fail — existing topics remain visible
    } finally {
      this.isLoadingMore = false;
    }
  }
}

export default class UserActivityFtPostsRoute extends DiscourseRoute {
  async model() {
    const username = this.modelFor("user").username;
    try {
      const response = await ajax(`/topics/created-by/${username}.json`);
      return new FtPostList({
        topics: attachUsers(
          response.topic_list?.topics || [],
          response.users || []
        ),
        canLoadMore: !!response.topic_list?.more_topics_url,
        username,
      });
    } catch {
      return new FtPostList({ topics: [], canLoadMore: false, username });
    }
  }

  setupController(controller, model) {
    super.setupController(controller, model);
    controller.set("username", this.modelFor("user").username);
  }
}
