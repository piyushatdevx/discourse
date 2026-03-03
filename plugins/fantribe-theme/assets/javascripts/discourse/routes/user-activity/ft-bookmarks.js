import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
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
// Paginated via the more_bookmarks_url field returned by Discourse's bookmark API.

// Discourse's PrettyText.excerpt keeps <a class="lightbox" href="…"> wrappers
// around image alt-text. We parse those hrefs as image URLs before stripping
// HTML, giving the feed card real image URLs without a separate API call.
function extractLightboxUrls(excerptHtml) {
  if (!excerptHtml) {
    return [];
  }
  try {
    const doc = new DOMParser().parseFromString(excerptHtml, "text/html");
    return [...doc.querySelectorAll("a.lightbox[href]")]
      .map((a) => a.getAttribute("href"))
      .filter(Boolean);
  } catch {
    return [];
  }
}

// Strip all HTML tags, leaving only the visible text content.
function stripHtml(html) {
  if (!html) {
    return null;
  }
  const text = html.replace(/<[^>]*>/g, "").trim();
  return text || null;
}

function mapBookmark(b, currentUserId) {
  const lightboxUrls = extractLightboxUrls(b.excerpt);
  const imageUrls = b.image_urls?.length ? b.image_urls : lightboxUrls;
  return {
    // Core identifiers
    id: b.topic_id,
    slug: b.slug,
    title: b.title,
    fancy_title: b.fancy_title,
    // Strip HTML from the excerpt; image alt-text like [wallhaven-…]
    // would otherwise appear as literal text.
    excerpt: stripHtml(b.excerpt),
    excerpt_truncated: b.truncated,
    // Metadata
    category_id: b.category_id,
    created_at: b.bumped_at || b.created_at,
    posts_count: b.highest_post_number || 1,
    // Bookmark state for the engagement bar
    bookmarked: true,
    bookmark_id: b.id,
    first_post_id: b.bookmarkable_type === "Post" ? b.bookmarkable_id : null,
    // Prevent self-reactions: disable the reaction bar when the
    // bookmarked post was authored by the current user.
    op_can_like: !b.user?.id || !currentUserId || b.user.id !== currentUserId,
    // Images extracted from excerpt lightbox links (primary) or the
    // backend image_urls field (also populated for cooked HTML images).
    image_urls: imageUrls,
    first_onebox_html: b.first_onebox_html || null,
    tags: b.tags || [],
    // Synthesise a minimal posters array so the feed card can show
    // the author's avatar and name (bookmark serializer embeds user).
    posters: b.user ? [{ user_id: b.user.id, user: b.user }] : [],
  };
}

class FtBookmarkList {
  @tracked topics;
  @tracked canLoadMore;
  @tracked isLoadingMore = false;
  _page = 0;
  _username;
  _currentUserId;

  constructor({ bookmarks, canLoadMore, username, currentUserId }) {
    this.topics = new TrackedArray(bookmarks);
    this.canLoadMore = canLoadMore;
    this._username = username;
    this._currentUserId = currentUserId;
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
        `/u/${this._username}/bookmarks.json?page=${nextPage}`
      );
      const raw =
        response.user_bookmark_list?.bookmarks || response.bookmarks || [];
      const newBookmarks = raw
        .filter((b) => b.topic_id && !b.deleted)
        .map((b) => mapBookmark(b, this._currentUserId));
      this.topics.push(...newBookmarks);
      this._page = nextPage;
      this.canLoadMore = !!response.user_bookmark_list?.more_bookmarks_url;
    } catch {
      // silently fail — existing bookmarks remain visible
    } finally {
      this.isLoadingMore = false;
    }
  }
}

export default class UserActivityFtBookmarksRoute extends DiscourseRoute {
  async model() {
    const username = this.modelFor("user").username;
    const currentUserId = this.currentUser?.id;
    try {
      const response = await ajax(`/u/${username}/bookmarks.json`);
      const raw =
        response.user_bookmark_list?.bookmarks || response.bookmarks || [];
      return new FtBookmarkList({
        bookmarks: raw
          .filter((b) => b.topic_id && !b.deleted)
          .map((b) => mapBookmark(b, currentUserId)),
        canLoadMore: !!response.user_bookmark_list?.more_bookmarks_url,
        username,
        currentUserId,
      });
    } catch {
      return new FtBookmarkList({
        bookmarks: [],
        canLoadMore: false,
        username,
        currentUserId,
      });
    }
  }
}
