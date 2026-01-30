import Component from "@glimmer/component";
import { cached } from "@glimmer/tracking";
import { service } from "@ember/service";
import FantribeFeedLayout from "../../components/fantribe-feed-layout";

export default class FantribeFeedWrapper extends Component {
  @service siteSettings;
  @service router;

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
    if (!model) {
      return [];
    }

    // The route model structure is {list, filterType}
    // Topics are in model.list.topics for discovery routes
    const list = model.list || model;
    let topicsList = list.get?.("topics") ?? list.topics;

    if (!topicsList) {
      return [];
    }

    // Convert to regular array if it's an Ember array
    if (typeof topicsList.toArray === "function") {
      return topicsList.toArray();
    }

    return Array.isArray(topicsList) ? topicsList : [];
  }

  <template>
    {{#if this.shouldShowFeedLayout}}
      <FantribeFeedLayout @topics={{this.topics}} />
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
