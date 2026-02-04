import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { filterTypeForMode } from "discourse/lib/filter-mode";
import PeriodChooser from "discourse/select-kit/components/period-chooser";
import FantribeComposeBox from "./fantribe-compose-box";
import FantribeFeedCard from "./fantribe-feed-card";
import FantribeMobileTribeChips from "./fantribe-mobile-tribe-chips";
import FantribeTrendingPanel from "./fantribe-trending-panel";
import FantribeTribesPanel from "./fantribe-tribes-panel";

export default class FantribeFeedLayout extends Component {
  @service fantribeFilter;
  @service currentUser;
  @service site;
  @service router;

  get categories() {
    return (this.site.categories || [])
      .filter((c) => !c.isUncategorized && c.permission !== null)
      .sort((a, b) => (a.position || 0) - (b.position || 0));
  }

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

  get showPeriodChooser() {
    const list = this.args.model?.list ?? this.args.model;
    const filter = list?.filter ?? list?.get?.("filter");
    return filterTypeForMode(filter) === "top";
  }

  get period() {
    const list = this.args.model?.list ?? this.args.model;
    return list?.for_period ?? list?.get?.("for_period");
  }

  @action
  changePeriod(newPeriod) {
    this.router.transitionTo({ queryParams: { period: newPeriod } });
  }

  @action
  initializeFilters() {
    this.fantribeFilter.initializeWithAllIfEmpty(this.categories);
  }

  <template>
    <div class="fantribe-feed-layout" {{didInsert this.initializeFilters}}>
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

        {{#if this.showPeriodChooser}}
          <div class="fantribe-feed-layout__period-chooser top-lists">
            <PeriodChooser
              @period={{this.period}}
              @action={{this.changePeriod}}
              @fullDay={{false}}
            />
          </div>
        {{/if}}

        {{! Conversation Feed - single card containing all posts }}
        <div class="fantribe-conversation-feed">
          <header class="fantribe-conversation-feed__header">
            <h3 class="fantribe-conversation-feed__title">
              <span class="fantribe-conversation-feed__icon" aria-hidden="true">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path
                    d="M22 17a2 2 0 0 1-2 2H6.828a2 2 0 0 0-1.414.586l-2.202 2.202A.71.71 0 0 1 2 21.286V5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2z"
                  />
                </svg>
              </span>
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
                <p class="fantribe-conversation-feed__empty-title">No
                  conversations found</p>
                <p class="fantribe-conversation-feed__empty-text">Try adjusting
                  your search terms</p>
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
