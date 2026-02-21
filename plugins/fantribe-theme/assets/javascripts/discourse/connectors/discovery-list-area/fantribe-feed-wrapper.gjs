import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";
import { service } from "@ember/service";
import FantribeFeedLayout from "../../components/fantribe-feed-layout";

export default class FantribeFeedWrapper extends Component {
  @service siteSettings;
  @service router;
  @service fantribeFeedState;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get isTopicListRoute() {
    // Only show feed layout on topic list routes (latest, top, new, hot, etc.)
    // NOT on categories page
    const routeName = this.router.currentRouteName || "";
    const topicListRoutes = [
      "discovery.latest",
      "discovery.top",
      "discovery.new",
      "discovery.unread",
      "discovery.hot",
      "discovery.posted",
      "discovery.bookmarks",
      "discovery.votes",
    ];

    return (
      topicListRoutes.some((route) => routeName.startsWith(route)) ||
      routeName.startsWith("tag.") ||
      routeName.startsWith("discovery.category") // Category-specific topic lists
    );
  }

  get shouldShowFeedLayout() {
    return this.isEnabled && this.isTopicListRoute;
  }

  @cached
  get topics() {
    const model = this.args.outletArgs?.model;
    let routeTopics = [];

    if (model) {
      // The route model structure is {list, filterType}
      // Topics are in model.list.topics for discovery routes
      const list = model.list || model;
      let topicsList = list.get?.("topics") ?? list.topics;

      if (topicsList) {
        if (typeof topicsList.toArray === "function") {
          routeTopics = topicsList.toArray();
        } else if (Array.isArray(topicsList)) {
          routeTopics = topicsList;
        }
      }
    }

    // Prepend any topics created in this session, deduplicating against the
    // route model so they don't double-show after a background refresh.
    const pending = this.fantribeFeedState.pendingTopics;
    if (pending.length === 0) {
      return routeTopics;
    }

    const existingIds = new Set(routeTopics.map((t) => t.id));
    const newPending = pending.filter((t) => !existingIds.has(t.id));
    return [...newPending, ...routeTopics];
  }

  get model() {
    return this.args.outletArgs?.model;
  }

  // For discovery.category routes, the model includes the current category object.
  get currentCategory() {
    const model = this.args.outletArgs?.model;
    return model?.category || null;
  }

  <template>
    {{#if this.shouldShowFeedLayout}}
      <FantribeFeedLayout
        @topics={{this.topics}}
        @model={{this.model}}
        @category={{this.currentCategory}}
      />
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
