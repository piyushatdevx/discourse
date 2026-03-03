import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import service from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

const POLL_INTERVAL_MS = 5000;
const POLL_MAX_ATTEMPTS = 24;

export default class AdminDashboardCommunityInsights extends Controller {
  @service dialog;
  @service siteSettings;

  @tracked reportTypes = [];
  @tracked generatedAt = null;
  @tracked postsAnalyzed = null;
  @tracked daysAnalyzed = null;
  @tracked maxPosts = null;
  @tracked loading = true;
  @tracked refreshing = false;
  @tracked error = null;
  @tracked errorDetail = null;
  @tracked waitingForJob = false;
  _refreshStartedAt = null;

  _pollTimer = null;

  constructor(...args) {
    super(...args);
    this.loadInsights();
  }

  willDestroy() {
    this._stopPolling();
    super.willDestroy();
  }

  get featureEnabled() {
    return this.siteSettings.music_tribe_insights_enabled;
  }

  get refreshButtonDisabled() {
    return this.refreshing || !this.featureEnabled;
  }

  get showNoRecurringThemes() {
    return (
      this.generatedAt &&
      !this.reportTypes.length &&
      !this.loading &&
      !this.waitingForJob
    );
  }

  async loadInsights() {
    this.loading = true;
    this.error = null;
    this.errorDetail = null;
    try {
      const data = await ajax("/admin/dashboard/community_insights.json");
      this.reportTypes = data.report_types || [];
      this.generatedAt = data.generated_at || null;
      this.postsAnalyzed = data.posts_analyzed ?? null;
      this.daysAnalyzed = data.days_analyzed ?? null;
      this.maxPosts = data.max_posts ?? null;
    } catch (e) {
      this.error = "music_tribe_insights.error_loading";
      this.errorDetail = this._ajaxErrorMessage(e);
    } finally {
      this.loading = false;
    }
  }

  _ajaxErrorMessage(e) {
    if (!e) {
      return null;
    }
    const xhr = e.jqXHR ?? e;
    const status = xhr?.status;
    const responseJSON = xhr?.responseJSON;
    if (responseJSON?.errors?.length) {
      return responseJSON.errors.join(" ");
    }
    if (status === 0) {
      return "Connection refused – start the Rails server (e.g. bin/rails s or pnpm dev).";
    }
    if (status === 404) {
      return "404 Not Found – ensure Rails is running and the plugin is enabled.";
    }
    if (status === 502 || status === 503) {
      return "Backend unreachable – start Rails so the Ember proxy can reach it.";
    }
    if (status) {
      return `HTTP ${status}`;
    }
    if (e.message) {
      return e.message;
    }
    return null;
  }

  _stopPolling() {
    if (this._pollTimer) {
      clearTimeout(this._pollTimer);
      this._pollTimer = null;
    }
    this.waitingForJob = false;
  }

  async _pollUntilComplete(attempt = 0) {
    if (attempt >= POLL_MAX_ATTEMPTS) {
      this._stopPolling();
      this._refreshStartedAt = null;
      return;
    }
    try {
      const data = await ajax("/admin/dashboard/community_insights.json");
      const newGeneratedAt = data.generated_at || null;
      this.reportTypes = data.report_types || [];
      this.generatedAt = newGeneratedAt;
      this.postsAnalyzed = data.posts_analyzed ?? null;
      this.daysAnalyzed = data.days_analyzed ?? null;
      this.maxPosts = data.max_posts ?? null;
      const startedAt = this._refreshStartedAt;
      const isNewResult =
        newGeneratedAt &&
        (!startedAt ||
          new Date(newGeneratedAt).getTime() >=
            new Date(startedAt).getTime() - 2000);
      if (isNewResult) {
        this._stopPolling();
        this._refreshStartedAt = null;
        return;
      }
    } catch {
      // ignore fetch errors during poll
    }
    this._pollTimer = setTimeout(() => {
      this._pollUntilComplete(attempt + 1);
    }, POLL_INTERVAL_MS);
  }

  @action
  async refresh() {
    this.refreshing = true;
    this.error = null;
    this.errorDetail = null;
    this._refreshStartedAt = new Date().toISOString();
    try {
      await ajax("/admin/community_insights/refresh.json", {
        type: "POST",
      });
      this.dialog.alert(i18n("music_tribe_insights.job.enqueued"));
      this.refreshing = false;
      this.waitingForJob = true;
      setTimeout(() => this._pollUntilComplete(), POLL_INTERVAL_MS);
    } catch (e) {
      this.error = "music_tribe_insights.error_loading";
      this.errorDetail = this._ajaxErrorMessage(e);
      this.refreshing = false;
      this._refreshStartedAt = null;
    }
  }
}
