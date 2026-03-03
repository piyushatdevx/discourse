import { on } from "@ember/modifier";
import formatDate from "discourse/helpers/format-date";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";

export default <template>
  <div class="community-insights section">
    <div class="section-title">
      <h2 id="community-insights-heading">
        {{i18n "music_tribe_insights.dashboard.title"}}
      </h2>
      <p class="section-description">
        {{i18n "music_tribe_insights.dashboard.description"}}
      </p>
      {{#unless @controller.featureEnabled}}
        <div class="alert alert-info community-insights-setup">
          <p><strong>{{i18n "music_tribe_insights.setup.title"}}</strong></p>
          <ol>
            <li>{{i18n "music_tribe_insights.setup.step1"}}</li>
            <li>
              {{i18n "music_tribe_insights.setup.step2"}}
              <a
                href={{getURL
                  "/admin/site_settings/category/music_tribe_insights"
                }}
                class="setup-link"
              >
                {{i18n "music_tribe_insights.setup.step2_link"}}
              </a>
            </li>
            <li>{{i18n "music_tribe_insights.setup.step3"}}</li>
            <li>{{i18n "music_tribe_insights.setup.step4"}}</li>
          </ol>
          <p class="community-insights-url">
            {{i18n "music_tribe_insights.setup.url_label"}}
            <code>/admin/dashboard/community_insights</code>
          </p>
        </div>
      {{/unless}}
      <div class="section-actions">
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
      <div class="alert alert-error">
        <p>{{i18n @controller.error}}</p>
        {{#if @controller.errorDetail}}
          <p
            class="community-insights-error-detail"
          >{{@controller.errorDetail}}</p>
        {{/if}}
        <p class="community-insights-error-hint">{{i18n
            "music_tribe_insights.error_loading_hint"
          }}</p>
      </div>
    {{/if}}

    {{#if @controller.featureEnabled}}
      {{#if @controller.waitingForJob}}
        <div class="insights-loading">
          <span class="loading-spinner"></span>
          <span>{{i18n "music_tribe_insights.analysis_running"}}</span>
        </div>
      {{else if @controller.loading}}
        <div class="insights-loading">
          <span class="loading-spinner"></span>
          <span>{{i18n "music_tribe_insights.refreshing"}}</span>
        </div>
      {{else}}
        {{#if @controller.generatedAt}}
          <p class="insights-generated">
            {{i18n "music_tribe_insights.generated_at"}}:
            {{formatDate @controller.generatedAt format="medium"}}
          </p>
        {{/if}}

        {{#if @controller.postsAnalyzed}}
          <p class="insights-data-source">
            {{i18n
              "music_tribe_insights.data_source"
              count=@controller.postsAnalyzed
              days=@controller.daysAnalyzed
              max=@controller.maxPosts
            }}
          </p>
          <p class="insights-data-source insights-data-source-ai-note">
            {{i18n "music_tribe_insights.data_source_ai_note"}}
          </p>
        {{/if}}

        {{#if @controller.reportTypes.length}}
          <div class="insights-report-types">
            <table class="table report-types-table">
              <thead>
                <tr>
                  <th>{{i18n "music_tribe_insights.report_type"}}</th>
                  <th>{{i18n "music_tribe_insights.count"}}</th>
                  <th>{{i18n "music_tribe_insights.summary"}}</th>
                </tr>
              </thead>
              <tbody>
                {{#each @controller.reportTypes as |report|}}
                  <tr>
                    <td class="report-type-label">{{report.type}}</td>
                    <td class="report-type-count">{{report.count}}</td>
                    <td class="report-type-summary">{{report.summary}}</td>
                  </tr>
                {{/each}}
              </tbody>
            </table>
          </div>
        {{else if @controller.showNoRecurringThemes}}
          <div class="insights-empty">
            {{i18n "music_tribe_insights.no_recurring_themes"}}
          </div>
        {{else}}
          <div class="insights-empty">
            {{i18n "music_tribe_insights.no_insights"}}
          </div>
        {{/if}}
      {{/if}}
    {{/if}}
  </div>
</template>
