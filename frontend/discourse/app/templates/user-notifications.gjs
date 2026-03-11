import { on } from "@ember/modifier";
import LoadMore from "discourse/components/load-more";
import bodyClass from "discourse/helpers/body-class";
import hideApplicationFooter from "discourse/helpers/hide-application-footer";
import { i18n } from "discourse-i18n";

export default <template>
  {{#if @controller.model.canLoadMore}}
    {{hideApplicationFooter}}
  {{/if}}

  {{bodyClass "user-notifications-page"}}

  <div
    class="ft-notifications-page
      {{if @controller.showUnreadOnly 'ft-notif--show-unread'}}"
  >
    {{! Combined header + filter card }}
    <div class="ft-notifications-page__header-card">
      <div class="ft-notifications-page__header">
        <h1 class="ft-notifications-page__title">
          {{i18n "user.notifications"}}
        </h1>
        {{#unless @controller.allNotificationsRead}}
          <button
            type="button"
            class="ft-notifications-page__mark-all-read"
            {{on "click" @controller.resetNew}}
          >
            {{i18n "fantribe.notifications.mark_all_read"}}
          </button>
        {{/unless}}
      </div>

      <div class="ft-notifications-page__filters">
        <button
          type="button"
          class="ft-notif-filter ft-notif-filter--all"
          {{on "click" @controller.showAll}}
        >
          {{i18n "user.filters.all"}}
        </button>
        <button
          type="button"
          class="ft-notif-filter ft-notif-filter--unread"
          {{on "click" @controller.showUnread}}
        >
          {{i18n "fantribe.notifications.unread"}}
        </button>
      </div>
    </div>

    {{! Notifications list card }}
    <section
      class="ft-notifications-page__content user-content"
      id="user-content"
    >
      {{#if @controller.showUnreadEmptyState}}
        <div class="ft-notifications-empty">
          <div class="ft-notifications-empty__icon-wrap">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="32"
              height="32"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <path d="M10.268 21a2 2 0 0 0 3.464 0" />
              <path
                d="M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326"
              />
            </svg>
          </div>
          <h2 class="ft-notifications-empty__title">
            {{i18n "fantribe.notifications.empty_title"}}
          </h2>
          <p class="ft-notifications-empty__body">
            {{i18n "fantribe.notifications.unread_empty_body"}}
          </p>
        </div>
      {{else}}
        <LoadMore
          @action={{@controller.loadMore}}
          class="notification-history user-stream"
        >
          {{outlet}}
        </LoadMore>
      {{/if}}
    </section>
  </div>
</template>
