import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";
import { i18n } from "discourse-i18n";

export default class FantribeAttentionPanel extends Component {
  @service currentUser;

  @tracked flaggedCount = 0;
  @tracked pendingUsersCount = 0;
  @tracked loaded = false;

  constructor() {
    super(...arguments);
    this.loadCounts();
  }

  get reviewableCount() {
    return this.currentUser?.reviewable_count ?? 0;
  }

  get hasItems() {
    return (
      this.reviewableCount > 0 ||
      this.flaggedCount > 0 ||
      this.pendingUsersCount > 0
    );
  }

  get showPanel() {
    return this.currentUser?.admin || this.currentUser?.moderator;
  }

  @action
  async loadCounts() {
    try {
      const usersData = await ajax("/admin/users/list/pending.json");
      if (Array.isArray(usersData)) {
        this.pendingUsersCount = usersData.length;
      }
    } catch {
      // endpoint may 403 for moderators, that's OK
    }

    try {
      const flagsData = await ajax("/admin/reports/bulk.json", {
        data: {
          reports: {
            flags_status: {
              start_date: moment().subtract(7, "days").format("YYYY-MM-DD"),
              end_date: moment().format("YYYY-MM-DD"),
            },
          },
        },
      });
      const flagsReport = flagsData?.reports?.find(
        (r) => r.type === "flags_status"
      );
      if (flagsReport?.data?.length) {
        this.flaggedCount = flagsReport.data.reduce(
          (sum, row) => sum + (row.y ?? 0),
          0
        );
      }
    } catch {
      // bulk report may fail, leave at 0
    }

    this.loaded = true;
  }

  <template>
    {{#if this.showPanel}}
      <div class="ft-attention-panel">
        {{#if this.hasItems}}
          <div class="ft-attention-panel__header">
            {{icon "triangle-exclamation"}}
            <span>{{i18n "fantribe_admin.attention_panel.title"}}</span>
          </div>

          <div class="ft-attention-panel__cards">
            {{#if this.reviewableCount}}
              <a
                href={{getURL "/review"}}
                class="ft-attention-panel__card ft-attention-panel__card--warning"
              >
                <span
                  class="ft-attention-panel__card-count"
                >{{this.reviewableCount}}</span>
                <span class="ft-attention-panel__card-label">{{i18n
                    "fantribe_admin.attention_panel.pending_reviewables"
                  }}</span>
              </a>
            {{/if}}

            {{#if this.flaggedCount}}
              <a
                href={{getURL "/admin/reports/flags_status"}}
                class="ft-attention-panel__card ft-attention-panel__card--danger"
              >
                <span
                  class="ft-attention-panel__card-count"
                >{{this.flaggedCount}}</span>
                <span class="ft-attention-panel__card-label">{{i18n
                    "fantribe_admin.attention_panel.flagged_posts"
                  }}</span>
              </a>
            {{/if}}

            {{#if this.pendingUsersCount}}
              <a
                href={{getURL "/admin/users/list/pending"}}
                class="ft-attention-panel__card ft-attention-panel__card--info"
              >
                <span
                  class="ft-attention-panel__card-count"
                >{{this.pendingUsersCount}}</span>
                <span class="ft-attention-panel__card-label">{{i18n
                    "fantribe_admin.attention_panel.pending_users"
                  }}</span>
              </a>
            {{/if}}
          </div>
        {{else if this.loaded}}
          <div class="ft-attention-panel ft-attention-panel--clear">
            <div class="ft-attention-panel__clear-message">
              {{icon "check-circle"}}
              <span>{{i18n "fantribe_admin.attention_panel.all_clear"}}</span>
            </div>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
