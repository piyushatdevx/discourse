import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import FantribeTribesPanel from "./fantribe-tribes-panel";
import FantribeMobileTribeChips from "./fantribe-mobile-tribe-chips";
import FantribeComposeBox from "./fantribe-compose-box";
import FantribeFeedCard from "./fantribe-feed-card";
import FantribeTrendingPanel from "./fantribe-trending-panel";

export default class FantribeFeedLayout extends Component {
  @service fantribeFilter;
  @service currentUser;
  @service site;

  get topics() {
    return this.args.topics || [];
  }

  get filteredTopics() {
    const selectedIds = this.fantribeFilter.selectedCategoryIds;

    if (!selectedIds || selectedIds.length === 0) {
      return this.topics;
    }

    return this.topics.filter((topic) => {
      const categoryId = topic.category?.id || topic.category_id;
      return selectedIds.includes(categoryId);
    });
  }

  get trendingTopics() {
    // Get topics sorted by engagement for trending panel
    return [...this.topics]
      .sort((a, b) => {
        const scoreA = (a.like_count || 0) + (a.views || 0) / 10;
        const scoreB = (b.like_count || 0) + (b.views || 0) / 10;
        return scoreB - scoreA;
      })
      .slice(0, 5);
  }

  get hasTopics() {
    return this.filteredTopics.length > 0;
  }

  <template>
    <div class="fantribe-feed-layout">
      {{! Mobile tribe chips }}
      <div class="fantribe-feed-layout__mobile-chips">
        <FantribeMobileTribeChips />
      </div>

      {{! Left sidebar - My Tribes }}
      <aside class="fantribe-feed-layout__left-sidebar">
        <FantribeTribesPanel />
      </aside>

      {{! Main content - Feed }}
      <main class="fantribe-feed-layout__content">
        {{! Compose box - separate card }}
        {{#if this.currentUser}}
          <FantribeComposeBox />
        {{/if}}

        {{! Conversation Feed - single card containing all posts }}
        <div class="fantribe-conversation-feed">
          <header class="fantribe-conversation-feed__header">
            <h3 class="fantribe-conversation-feed__title">
              <span class="fantribe-conversation-feed__icon">{{icon "comment"}}</span>
              Conversations Happening Now
            </h3>
            <p class="fantribe-conversation-feed__subtitle">
              Real people, real feelings, right now
            </p>
          </header>
          <div class="fantribe-conversation-feed__content">
            {{#if this.hasTopics}}
              {{#each this.filteredTopics as |topic|}}
                <FantribeFeedCard @topic={{topic}} />
              {{/each}}
            {{else}}
              <div class="fantribe-conversation-feed__empty">
                <p class="fantribe-conversation-feed__empty-title">No conversations found</p>
                <p class="fantribe-conversation-feed__empty-text">Try adjusting your search terms</p>
              </div>
            {{/if}}
          </div>
        </div>
      </main>

      {{! Right sidebar - Trending }}
      <aside class="fantribe-feed-layout__right-sidebar">
        <FantribeTrendingPanel @topics={{this.trendingTopics}} />
      </aside>
    </div>
  </template>
}
