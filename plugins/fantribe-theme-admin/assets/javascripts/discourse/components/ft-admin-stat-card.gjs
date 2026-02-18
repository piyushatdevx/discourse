import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class FtAdminStatCard extends Component {
  get formattedValue() {
    const val = this.args.value;
    if (val == null) {
      return "\u2014";
    }
    if (typeof val === "number") {
      return val.toLocaleString();
    }
    return val;
  }

  get trendIcon() {
    const pct = this.args.trendPercent;
    if (pct == null || pct === 0) {
      return null;
    }
    return pct > 0 ? "arrow-up" : "arrow-down";
  }

  get trendLabel() {
    const pct = this.args.trendPercent;
    if (pct == null) {
      return "";
    }
    if (pct === 0) {
      return i18n("fantribe_admin.stat_card.no_change");
    }
    const abs = Math.abs(pct);
    const formatted = Number.isInteger(abs) ? abs : abs.toFixed(1);
    return `${formatted}% ${i18n("fantribe_admin.stat_card.vs_last_period")}`;
  }

  get trendClass() {
    const pct = this.args.trendPercent;
    const higher = this.args.higherIsBetter !== false;
    if (pct == null || pct === 0) {
      return "ft-stat-card__trend--neutral";
    }
    const isPositive = higher ? pct > 0 : pct < 0;
    return isPositive
      ? "ft-stat-card__trend--positive"
      : "ft-stat-card__trend--negative";
  }

  get sparklinePath() {
    const data = this.args.sparklineData;
    if (!data || data.length < 2) {
      return null;
    }
    const max = Math.max(...data);
    const min = Math.min(...data);
    const range = max - min || 1;
    const width = 120;
    const height = 32;
    const step = width / (data.length - 1);

    const points = data.map((v, idx) => {
      const x = idx * step;
      const y = height - ((v - min) / range) * height;
      return `${x},${y}`;
    });
    return htmlSafe(`M${points.join(" L")}`);
  }

  <template>
    <div class="ft-stat-card {{if @className @className}}">
      <div class="ft-stat-card__header">
        <span class="ft-stat-card__title">{{@title}}</span>
        {{#if @icon}}
          <span class="ft-stat-card__icon">{{icon @icon}}</span>
        {{/if}}
      </div>

      <div class="ft-stat-card__value">{{this.formattedValue}}</div>

      {{#if this.sparklinePath}}
        <svg
          class="ft-stat-card__sparkline"
          viewBox="0 0 120 32"
          preserveAspectRatio="none"
          aria-hidden="true"
        >
          <path
            d={{this.sparklinePath}}
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          />
        </svg>
      {{/if}}

      {{#if @trendPercent}}
        <div class="ft-stat-card__trend {{this.trendClass}}">
          {{#if this.trendIcon}}
            {{icon this.trendIcon}}
          {{/if}}
          <span>{{this.trendLabel}}</span>
        </div>
      {{else}}
        {{#if @subtitle}}
          <div class="ft-stat-card__subtitle">{{@subtitle}}</div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}
