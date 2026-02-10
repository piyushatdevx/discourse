import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";

export default class FantribeTrendingPanel extends Component {
  @service router;

  @tracked groups = [];
  @tracked isLoading = true;

  @action
  async loadGroups() {
    try {
      const result = await ajax("/groups.json");
      const allGroups = result?.groups || [];
      this.groups = allGroups
        .filter(
          (g) =>
            g.visibility_level === 0 &&
            !g.automatic &&
            g.name !== "trust_level_0"
        )
        .slice(0, 6)
        .map((g) => ({
          id: g.id,
          name: g.full_name || g.name,
          slug: g.name,
          memberCount: g.user_count || 0,
        }));
    } catch {
      this.groups = [];
    } finally {
      this.isLoading = false;
    }
  }

  formatCount(count) {
    if (count >= 1000) {
      return (count / 1000).toFixed(1) + "K members";
    }
    return `${count} members`;
  }

  @action
  navigateToGroup(group) {
    this.router.transitionTo("group", group.slug);
  }

  @action
  viewAll() {
    this.router.transitionTo("groups");
  }

  <template>
    <div class="fantribe-trending-panel" {{didInsert this.loadGroups}}>
      <div class="fantribe-trending-panel__header">
        <h3 class="fantribe-trending-panel__title">
          {{icon "users"}}
          Trending Tribes
        </h3>
      </div>

      <div class="fantribe-trending-panel__content">
        {{#if this.isLoading}}
          <div class="fantribe-trending-panel__empty">
            <p>Loading...</p>
          </div>
        {{else if this.groups.length}}
          {{#each this.groups as |group|}}
            <button
              type="button"
              class="fantribe-trending-item"
              {{on "click" (fn this.navigateToGroup group)}}
            >
              <div class="fantribe-trending-item__info">
                <span
                  class="fantribe-trending-item__title"
                >{{group.name}}</span>
                <span class="fantribe-trending-item__count">
                  {{this.formatCount group.memberCount}}
                </span>
              </div>

              <span class="fantribe-trending-item__indicator">
                {{icon "arrow-trend-up"}}
              </span>
            </button>
          {{/each}}
        {{else}}
          <div class="fantribe-trending-panel__empty">
            <p>No tribes yet</p>
          </div>
        {{/if}}
      </div>

      <div class="fantribe-trending-panel__footer">
        <button
          type="button"
          class="fantribe-trending-panel__view-all"
          {{on "click" this.viewAll}}
        >
          View all tribes
        </button>
      </div>
    </div>
  </template>
}
