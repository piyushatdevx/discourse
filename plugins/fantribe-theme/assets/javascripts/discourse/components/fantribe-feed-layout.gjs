import Component from "@glimmer/component";
import { service } from "@ember/service";
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
        {{! Compose box }}
        {{#if this.currentUser}}
          <FantribeComposeBox />
        {{/if}}

        {{! Feed cards }}
        {{#if this.hasTopics}}
          {{#each this.filteredTopics as |topic|}}
            <FantribeFeedCard @topic={{topic}} />
          {{/each}}
        {{else}}
          <div class="fantribe-empty-state">
            <p>No posts to show. Try adjusting your filters or check back later.</p>
          </div>
        {{/if}}
      </main>

      {{! Right sidebar - Trending }}
      <aside class="fantribe-feed-layout__right-sidebar">
        <FantribeTrendingPanel @topics={{this.trendingTopics}} />
      </aside>
    </div>
  </template>
}
