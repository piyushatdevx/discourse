import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { filterTypeForMode } from "discourse/lib/filter-mode";
import PeriodChooser from "discourse/select-kit/components/period-chooser";
import FantribeComposeBox from "./fantribe-compose-box";
import FantribeFeedCard from "./fantribe-feed-card";
import FantribeMobileTribeChips from "./fantribe-mobile-tribe-chips";
import FantribeRightSidebar from "./fantribe-right-sidebar";
import FantribeTribePage from "./fantribe-tribe-page";
import FtFiltersModal from "./ft-filters-modal";

export default class FantribeFeedLayout extends Component {
  @service fantribeFilter;
  @service currentUser;
  @service router;

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

  <template>
    {{! When on a category route, show the dedicated tribe page (full-width, no sidebar) }}
    {{#if @category}}
      <FantribeTribePage
        @category={{@category}}
        @topics={{this.filteredTopics}}
      />
    {{else}}
      {{! Home feed — two-column layout with right sidebar }}
      <div class="fantribe-feed-layout">
        {{! Mobile tribe chips }}
        <div class="fantribe-feed-layout__mobile-chips">
          <FantribeMobileTribeChips />
        </div>

        {{! Main content - Feed }}
        <main class="fantribe-feed-layout__content">
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

          {{#if this.hasTopics}}
            {{#each this.filteredTopics as |topic|}}
              <FantribeFeedCard @topic={{topic}} />
            {{/each}}
          {{else}}
            <div class="fantribe-feed-layout__empty">
              <p class="fantribe-feed-layout__empty-title">No posts yet</p>
              <p class="fantribe-feed-layout__empty-text">Be the first to share
                something</p>
            </div>
          {{/if}}
        </main>

        {{! Right sidebar - Trending }}
        <aside class="fantribe-feed-layout__right-sidebar">
          <FantribeRightSidebar />
        </aside>
      </div>

      {{! Filters modal — rendered outside sticky sidebar so backdrop covers full page }}
      {{#if this.fantribeFilter.isFiltersModalOpen}}
        <FtFiltersModal @onClose={{this.fantribeFilter.closeFiltersModal}} />
      {{/if}}
    {{/if}}
  </template>
}
