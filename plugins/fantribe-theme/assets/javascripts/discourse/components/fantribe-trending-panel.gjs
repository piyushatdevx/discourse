import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { concat, fn } from "@ember/helper";
import icon from "discourse/helpers/d-icon";

export default class FantribeTrendingPanel extends Component {
  @service router;
  @service store;
  @service site;

  get trendingTopics() {
    // Get hot/top topics from the store
    // In production, this would fetch from a dedicated trending endpoint
    const topics = this.args.topics || [];
    return topics.slice(0, 5).map((topic) => ({
      id: topic.id,
      slug: topic.slug,
      title: this.formatTitle(topic.title),
      postCount: topic.posts_count || 0,
      category: topic.category,
      isHot: topic.like_count > 10 || topic.views > 100,
    }));
  }

  formatTitle(title) {
    // Remove common prefixes and clean up title for hashtag display
    if (!title) return "";
    return title
      .replace(/^(Discussion:|Question:|Help:|Announcement:)\s*/i, "")
      .substring(0, 30);
  }

  formatCount(count) {
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K posts";
    }
    return `${count} posts`;
  }

  @action
  navigateToTopic(topic) {
    this.router.transitionTo("topic", topic.slug, topic.id);
  }

  @action
  viewAll() {
    this.router.transitionTo("discovery.top");
  }

  <template>
    <div class="fantribe-trending-panel">
      <div class="fantribe-trending-panel__header">
        <h3 class="fantribe-trending-panel__title">
          {{icon "arrow-trend-up"}}
          Trending Topics
        </h3>
      </div>

      <div class="fantribe-trending-panel__content">
        {{#each this.trendingTopics as |topic|}}
          <button
            type="button"
            class="fantribe-trending-item"
            {{on "click" (fn this.navigateToTopic topic)}}
          >
            <div class="fantribe-trending-item__info">
              <span class="fantribe-trending-item__title">{{topic.title}}</span>
              <span class="fantribe-trending-item__count">
                {{this.formatCount topic.postCount}}
              </span>
            </div>

            <span class="fantribe-trending-item__indicator">
              {{icon "arrow-trend-up"}}
            </span>
          </button>
        {{else}}
          <div class="fantribe-trending-panel__empty">
            <p>No trending topics yet</p>
          </div>
        {{/each}}
      </div>

      <div class="fantribe-trending-panel__footer">
        <button
          type="button"
          class="fantribe-trending-panel__view-all"
          {{on "click" this.viewAll}}
        >
          View all
        </button>
      </div>
    </div>
  </template>
}
