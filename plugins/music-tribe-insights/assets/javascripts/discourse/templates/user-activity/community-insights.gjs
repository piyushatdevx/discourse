import { concat, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { htmlSafe } from "@ember/template";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";

export default <template>
  <div class="fantribe-feed-card music-tribe-insights-card">
    <div class="fantribe-feed-card__content">
      <div class="music-tribe-insights-page__header">
        <h1 class="music-tribe-insights-page__title">
          {{i18n "music_tribe_insights.dashboard.title"}}
        </h1>
        <p class="music-tribe-insights-page__description">
          {{i18n "music_tribe_insights.dashboard.description"}}
        </p>
        <div class="music-tribe-insights-page__actions">
          <button
            type="button"
            class="btn btn-primary"
            disabled={{@controller.refreshButtonDisabled}}
            {{on "click" @controller.refresh}}
          >
            {{#if @controller.refreshing}}
              {{i18n "music_tribe_insights.refreshing"}}
            {{else}}
              {{i18n "music_tribe_insights.refresh"}}
            {{/if}}
          </button>
        </div>
      </div>

      {{#if @controller.error}}
        <div class="music-tribe-insights-page__error alert alert-error">
          {{i18n @controller.error}}
          {{#if @controller.errorDetail}}
            <span
              class="music-tribe-insights-page__error-detail"
            >{{@controller.errorDetail}}</span>
          {{/if}}
        </div>
      {{else if @controller.waitingForJob}}
        <div class="music-tribe-insights-page__loading">
          <span class="loading-spinner"></span>
          <span>{{i18n "music_tribe_insights.analysis_running"}}</span>
        </div>
      {{else if @controller.loading}}
        <div class="music-tribe-insights-page__loading">
          <span class="loading-spinner"></span>
          <span>{{i18n "music_tribe_insights.refreshing"}}</span>
        </div>
      {{else}}
        {{#if @controller.generatedAt}}
          <p class="music-tribe-insights-page__meta">
            {{i18n "music_tribe_insights.generated_at"}}:
            {{formatDate @controller.generatedAt format="medium"}}
          </p>
        {{/if}}

        {{#if @controller.postsAnalyzed}}
          <p class="music-tribe-insights-page__data-source">
            {{i18n
              "music_tribe_insights.data_source"
              count=@controller.postsAnalyzed
              days=@controller.daysAnalyzed
              max=@controller.maxPosts
            }}
          </p>
        {{/if}}

        {{#if @controller.reportTypesWithPercent.length}}
          <div class="music-tribe-insights-page__chart">
            <h2 class="music-tribe-insights-page__chart-title">
              {{i18n "music_tribe_insights.report_type"}}
            </h2>
            <div class="music-tribe-insights-page__charts-row">
              <div class="music-tribe-insights-page__pie-wrap">
                <div class="music-tribe-insights-page__pie-container">
                  <svg
                    class="music-tribe-insights-page__pie"
                    viewBox="0 0 180 180"
                    width="180"
                    height="180"
                    role="img"
                    aria-label="Pie chart of report types"
                  >
                    {{#each @controller.reportTypesWithPercent as |report|}}
                      <path
                        class="music-tribe-insights-page__pie-slice"
                        d={{report.piePath}}
                        fill={{report.pieColor}}
                        role="button"
                        tabindex="0"
                        {{on "mouseenter" (fn @controller.setPieHover report)}}
                        {{on "mousemove" @controller.setPieTooltipPosition}}
                        {{on "mouseleave" (fn @controller.setPieHover null)}}
                      >
                      </path>
                    {{/each}}
                  </svg>
                  {{#if @controller.hoveredPieReport}}
                    <div
                      class="music-tribe-insights-page__pie-tooltip"
                      style={{htmlSafe
                        (concat
                          "left: "
                          @controller.pieTooltipX
                          "px; top: "
                          @controller.pieTooltipY
                          "px;"
                        )
                      }}
                    >
                      <span
                        class="music-tribe-insights-page__pie-tooltip-label"
                      >{{@controller.hoveredPieReport.type}}</span>
                      <span
                        class="music-tribe-insights-page__pie-tooltip-percent"
                      >{{@controller.hoveredPieReport.piePercent}}%</span>
                    </div>
                  {{/if}}
                </div>
                <div class="music-tribe-insights-page__pie-legend">
                  {{#each @controller.reportTypesWithPercent as |report|}}
                    <span
                      class="music-tribe-insights-page__pie-legend-item"
                    >{{report.type}} ({{report.count}})</span>
                  {{/each}}
                </div>
              </div>
              <div class="music-tribe-insights-page__vertical-bars">
                {{#each @controller.reportTypesWithPercent as |report|}}
                  <div class="music-tribe-insights-page__vertical-bar-col">
                    <div class="music-tribe-insights-page__vertical-bar-wrap">
                      <div
                        class="music-tribe-insights-page__vertical-bar"
                        style={{report.barHeightStyle}}
                        title="{{report.type}}: {{report.count}}"
                      ></div>
                    </div>
                    <span
                      class="music-tribe-insights-page__vertical-bar-label"
                    >{{report.count}}</span>
                    <span
                      class="music-tribe-insights-page__vertical-bar-name"
                    >{{report.type}}</span>
                  </div>
                {{/each}}
              </div>
            </div>
            <div class="music-tribe-insights-page__report-list">
              {{#each @controller.reportTypesWithPercent as |report|}}
                <div class="music-tribe-insights-page__report-card">
                  <div class="music-tribe-insights-page__report-card-head">
                    <span
                      class="music-tribe-insights-page__bar-name"
                    >{{report.type}}</span>
                    <span
                      class="music-tribe-insights-page__bar-count"
                    >{{report.count}}
                      {{i18n "music_tribe_insights.count"}}</span>
                  </div>
                  {{#if report.summary}}
                    <p
                      class="music-tribe-insights-page__bar-summary"
                    >{{report.summary}}</p>
                  {{/if}}
                  {{#if report.postIds.length}}
                    <button
                      type="button"
                      class="btn btn-sm btn-primary music-tribe-insights-page__view-posts-btn"
                      {{on "click" (fn @controller.togglePosts report)}}
                    >
                      {{#if report.isExpanded}}
                        {{i18n "music_tribe_insights.hide_posts"}}
                      {{else}}
                        {{i18n
                          "music_tribe_insights.view_posts"
                          count=report.postIds.length
                        }}
                      {{/if}}
                    </button>
                  {{/if}}
                  {{#if report.isExpanded}}
                    <div class="music-tribe-insights-page__related-posts">
                      {{#if report.topicLinks.length}}
                        <span
                          class="music-tribe-insights-page__related-posts-label"
                        >{{i18n "music_tribe_insights.related_topics"}}:</span>
                        <ul class="music-tribe-insights-page__post-links">
                          {{#each report.topicLinks as |link|}}
                            <li>
                              <a
                                href={{link.url}}
                                target="_blank"
                                rel="noopener noreferrer"
                                class="music-tribe-insights-page__post-link"
                                title={{link.title}}
                              >
                                {{link.label}}
                              </a>
                            </li>
                          {{/each}}
                        </ul>
                      {{else}}
                        <span
                          class="music-tribe-insights-page__related-posts-label"
                        >{{i18n "music_tribe_insights.related_posts"}}:</span>
                        <ul class="music-tribe-insights-page__post-links">
                          {{#each report.postLinks as |link|}}
                            <li>
                              <a
                                href={{link.url}}
                                target="_blank"
                                rel="noopener noreferrer"
                                class="music-tribe-insights-page__post-link"
                                title={{link.title}}
                              >
                                {{link.label}}
                              </a>
                            </li>
                          {{/each}}
                        </ul>
                      {{/if}}
                    </div>
                  {{/if}}
                </div>
              {{/each}}
            </div>
          </div>
        {{else if @controller.generatedAt}}
          <div class="music-tribe-insights-page__empty">
            {{i18n "music_tribe_insights.no_recurring_themes"}}
          </div>
        {{else}}
          <div class="music-tribe-insights-page__empty">
            {{i18n "music_tribe_insights.no_insights"}}
          </div>
        {{/if}}
      {{/if}}
    </div>
  </div>
</template>
