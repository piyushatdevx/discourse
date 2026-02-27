import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ftIcon from "../helpers/ft-icon";

export default class FantribeTrendingPanel extends Component {
  @service router;
  @service site;

  get tribes() {
    return this.site.trending_tribes || [];
  }

  formatMemberCount(count) {
    if (!count) {
      return "0 members";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K members";
    }
    return `${count} members`;
  }

  formatPostCount(count) {
    if (!count) {
      return "0 posts";
    }
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K posts";
    }
    return `${count} posts`;
  }

  @action
  navigateToTribe(tribe) {
    this.router.transitionTo("discovery.category", tribe.slug);
  }

  @action
  viewAll() {
    this.router.transitionTo("explore");
  }

  <template>
    <div class="ft-trending-panel">
      {{! Header }}
      <div class="ft-trending-panel__header">
        <div class="ft-trending-panel__header-inner">
          {{ftIcon "trending-up" size=20}}
          <h3 class="ft-trending-panel__title">Trending Tribes</h3>
        </div>
      </div>

      {{! Tribe list — styled to match Figma (node 478-22218) }}
      <div class="ft-trending-panel__list">
        {{#if this.tribes.length}}
          {{#each this.tribes as |tribe|}}
            <button
              type="button"
              class="ft-trending-panel__item"
              {{on "click" (fn this.navigateToTribe tribe)}}
            >
              {{! Tribe info }}
              <div class="ft-trending-panel__item-body">
                <span
                  class="ft-trending-panel__item-name"
                >#{{tribe.name}}</span>
                <div class="ft-trending-panel__item-meta">
                  <span class="ft-trending-panel__item-stat">
                    {{ftIcon "users" size=12}}
                    <span>{{this.formatMemberCount tribe.member_count}}</span>
                  </span>
                  <span class="ft-trending-panel__item-stat">
                    {{ftIcon "image" size=12}}
                    <span>{{this.formatPostCount tribe.post_count}}</span>
                  </span>
                </div>
              </div>

              {{! Arrow — animates on hover via CSS }}
              <span class="ft-trending-panel__item-chevron">
                {{ftIcon "trend-arrow" size=12}}
              </span>
            </button>
          {{/each}}
        {{else}}
          <div class="ft-trending-panel__empty">
            <p>No active tribes yet</p>
          </div>
        {{/if}}
      </div>

      {{! Footer }}
      <div class="ft-trending-panel__footer">
        <button
          type="button"
          class="ft-trending-panel__see-all"
          {{on "click" this.viewAll}}
        >
          View all
        </button>
      </div>
    </div>
  </template>
}
