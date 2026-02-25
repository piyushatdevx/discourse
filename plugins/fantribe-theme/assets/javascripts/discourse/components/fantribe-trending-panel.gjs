import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import ftIcon from "../helpers/ft-icon";

function dotStyle(color) {
  return htmlSafe(`background-color: #${color}`);
}

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

      {{! Tribe list — styled to match Figma RightSidebar.tsx }}
      <div class="ft-trending-panel__list">
        {{#if this.tribes.length}}
          {{#each this.tribes as |tribe|}}
            <button
              type="button"
              class="ft-trending-panel__item"
              {{on "click" (fn this.navigateToTribe tribe)}}
            >
              {{! Logo or colour dot }}
              <div class="ft-trending-panel__item-lead">
                {{#if tribe.logo_url}}
                  <img
                    src={{tribe.logo_url}}
                    class="ft-trending-panel__item-logo"
                    alt=""
                  />
                {{else}}
                  <span
                    class="ft-trending-panel__item-dot"
                    style={{dotStyle tribe.color}}
                  ></span>
                {{/if}}
              </div>

              {{! Tribe info }}
              <div class="ft-trending-panel__item-body">
                <span class="ft-trending-panel__item-name">{{tribe.name}}</span>
                <div class="ft-trending-panel__item-meta">
                  {{ftIcon "users" size=12}}
                  <span>{{this.formatMemberCount tribe.member_count}}</span>
                  <span class="ft-trending-panel__item-meta-sep">·</span>
                  {{ftIcon "message-circle" size=12}}
                  <span>{{this.formatPostCount tribe.post_count}}</span>
                </div>
              </div>

              {{! Chevron — animates on hover via CSS }}
              <span class="ft-trending-panel__item-chevron">
                {{ftIcon "chevron-right" size=16}}
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
          See all tribes
        </button>
      </div>
    </div>
  </template>
}
