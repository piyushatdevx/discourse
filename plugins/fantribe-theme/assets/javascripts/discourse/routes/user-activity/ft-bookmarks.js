import { TrackedArray } from "@ember-compat/tracked-built-ins";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

// Renders the FanTribe-styled list of topics the user has bookmarked.
// Uses Discourse's /u/:username/bookmarks.json endpoint.
//
// The bookmarks API returns flat objects (UserPostBookmarkSerializer /
// UserTopicBookmarkSerializer) — NOT nested {topic:} objects. Fields like
// title, excerpt, slug, category_id and user are on the bookmark itself.
// We construct a topic-compatible shape so FantribeFeedCard can render them.
export default class UserActivityFtBookmarksRoute extends DiscourseRoute {
  async model() {
    const username = this.modelFor("user").username;
    try {
      const response = await ajax(`/u/${username}/bookmarks.json`);
      const bookmarks =
        response.user_bookmark_list?.bookmarks || response.bookmarks || [];

      return new TrackedArray(
        bookmarks
          .filter((b) => b.topic_id && !b.deleted)
          .map((b) => ({
            // Core identifiers
            id: b.topic_id,
            slug: b.slug,
            title: b.title,
            fancy_title: b.fancy_title,
            excerpt: b.excerpt,
            excerpt_truncated: b.truncated,
            // Metadata
            category_id: b.category_id,
            created_at: b.bumped_at || b.created_at,
            posts_count: b.highest_post_number || 1,
            // Bookmark state for the engagement bar
            bookmarked: true,
            bookmark_id: b.id,
            first_post_id:
              b.bookmarkable_type === "Post" ? b.bookmarkable_id : null,
            // Synthesise a minimal posters array so the feed card can show
            // the author's avatar and name (bookmark serializer embeds user).
            posters: b.user ? [{ user_id: b.user.id, user: b.user }] : [],
          }))
      );
    } catch {
      return new TrackedArray([]);
    }
  }
}
