import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";

const POLL_INTERVAL_MS = 5000;
const POLL_MAX_ATTEMPTS = 24;

export default class UserActivityCommunityInsightsController extends Controller {
  @service dialog;

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
  @tracked expandedReportKey = null;
  @tracked hoveredPieReport = null;
  @tracked pieTooltipX = 0;
  @tracked pieTooltipY = 0;
  /** When we started the current refresh (ISO string); we keep polling until API returns generated_at >= this */
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

  get refreshButtonDisabled() {
    return this.refreshing;
  }

  _pieSlicePath(startPercent, endPercent, size = 180) {
    const cx = size / 2;
    const cy = size / 2;
    const r = size / 2 - 2;
    const startRad = (startPercent / 100) * 2 * Math.PI - Math.PI / 2;
    const endRad = (endPercent / 100) * 2 * Math.PI - Math.PI / 2;
    const x1 = cx + r * Math.cos(startRad);
    const y1 = cy + r * Math.sin(startRad);
    const x2 = cx + r * Math.cos(endRad);
    const y2 = cy + r * Math.sin(endRad);
    const large = endRad - startRad > Math.PI ? 1 : 0;
    return `M ${cx} ${cy} L ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2} Z`;
  }

  get reportTypesWithPercent() {
    const types = this.reportTypes || [];
    const expandedKey = this.expandedReportKey;
    const shades = ["#ff1744", "#e6143d", "#cc1236", "#b30f33", "#990d2d"];
    if (!types.length) {
      return [];
    }
    const max = Math.max(...types.map((r) => r.count || 0), 1);
    const total = types.reduce((sum, r) => sum + (r.count || 0), 0);
    let acc = 0;
    return types.map((r, index) => {
      const count = r.count || 0;
      const percent = Math.min(100, Math.round((count / max) * 100));
      const startPercent = total ? (acc / total) * 100 : 0;
      acc += count;
      const endPercent = total ? (acc / total) * 100 : 100;
      const piePercent = total ? Math.round((count / total) * 1000) / 10 : 0;
      const postIds = Array.isArray(r.post_ids) ? r.post_ids : [];
      const reportKey = `report-${index}-${r.type}`;
      const postDetails = Array.isArray(r.post_details) ? r.post_details : [];
      const topicSummaries = Array.isArray(r.topic_summaries)
        ? r.topic_summaries
        : [];
      const seenIds = new Set();
      const postLinks =
        postDetails.length > 0
          ? postDetails
              .filter((d) => {
                if (seenIds.has(d.id)) {
                  return false;
                }
                seenIds.add(d.id);
                return true;
              })
              .map((d) => ({
                id: d.id,
                title: d.title || `Post ${d.id}`,
                label: d.short_label || d.title || `Post ${d.id}`,
                url: getURL(`/p/${d.id}`),
              }))
          : [...new Set(postIds)].map((id) => ({
              id,
              title: `Post ${id}`,
              label: `Post #${id}`,
              url: getURL(`/p/${id}`),
            }));
      const topicLinks =
        topicSummaries.length > 0
          ? topicSummaries.map((t) => ({
              topicId: t.topic_id,
              title: t.title || `Topic ${t.topic_id}`,
              label:
                t.post_count > 1
                  ? `${t.title} (${t.post_count} posts)`
                  : t.title,
              url: getURL(`/t/${t.topic_slug}/${t.topic_id}`),
            }))
          : [];
      return {
        ...r,
        index,
        percent,
        percentStyle: `width: ${percent}%`,
        barHeightStyle: `height: ${Math.max(percent, 8)}%`,
        pieStart: startPercent,
        pieEnd: endPercent,
        pieStyle: `--start: ${startPercent}%; --end: ${endPercent}%`,
        piePercent,
        pieColor: shades[index % shades.length],
        piePath: this._pieSlicePath(startPercent, endPercent),
        postIds,
        isExpanded: expandedKey === reportKey,
        postLinks,
        topicLinks,
      };
    });
  }

  get pieChartStyle() {
    const types = this.reportTypesWithPercent;
    if (!types.length) {
      return "";
    }
    const total = types.reduce((s, r) => s + (r.count || 0), 0);
    if (!total) {
      return "";
    }
    const shades = ["#ff1744", "#e6143d", "#cc1236", "#b30f33", "#990d2d"];
    let acc = 0;
    const parts = types.map((r, i) => {
      const pct = ((r.count || 0) / total) * 100;
      const start = acc;
      acc += pct;
      const hex = shades[i % shades.length];
      return `${hex} ${start}% ${acc}%`;
    });
    return `background: conic-gradient(${parts.join(", ")});`;
  }

  @action
  setPieHover(report, event) {
    this.hoveredPieReport = report;
    if (!report) {
      this.pieTooltipX = 0;
      this.pieTooltipY = 0;
    } else if (event) {
      const offset = 12;
      this.pieTooltipX = event.clientX + offset;
      this.pieTooltipY = event.clientY + offset;
    }
  }

  @action
  setPieTooltipPosition(event) {
    if (!this.hoveredPieReport) {
      return;
    }
    const offset = 12;
    this.pieTooltipX = event.clientX + offset;
    this.pieTooltipY = event.clientY + offset;
  }

  @action
  togglePosts(report) {
    const key = report ? `report-${report.index}-${report.type}` : null;
    this.expandedReportKey = this.expandedReportKey === key ? null : key;
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
    if (responseJSON?.error) {
      return responseJSON.error;
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
