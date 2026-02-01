import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import { ajax } from "discourse/lib/ajax";
import { getRenderDirector } from "discourse/lib/notification-types-manager";
import Notification from "discourse/models/notification";

export default class FantribeNotifications extends Component {
  @service currentUser;
  @service router;
  @service site;
  @service siteSettings;

  @tracked dropdownOpen = false;
  @tracked notifications = [];
  @tracked notificationRows = [];

  get unreadCount() {
    if (!this.currentUser) {
      return 0;
    }
    return (
      (this.currentUser.unread_notifications || 0) +
      (this.currentUser.unread_high_priority_notifications || 0)
    );
  }

  get hasUnread() {
    return this.unreadCount > 0;
  }

  get displayCount() {
    if (this.unreadCount > 99) {
      return "99+";
    }
    return this.unreadCount;
  }

  @action
  toggleDropdown(event) {
    event.stopPropagation();
    this.dropdownOpen = !this.dropdownOpen;
    if (this.dropdownOpen && this.currentUser) {
      this.loadNotifications();
    }
  }

  async loadNotifications() {
    if (!this.currentUser) return;
    try {
      const data = await ajax("/notifications", {
        data: { limit: 15, recent: true },
      });
      const list = data?.notifications ?? [];
      this.notifications = await Notification.initializeNotifications(list);
      this.notificationRows = this.#buildNotificationRows(this.notifications);
    } catch {
      this.notifications = [];
      this.notificationRows = [];
    }
  }

  #buildNotificationRows(list) {
    const lookup = this.site?.notificationLookup;
    if (!lookup || !list?.length) return [];
    return list.map((notification) => {
      const typeName = lookup[notification.notification_type];
      const director = typeName
        ? getRenderDirector(
            typeName,
            notification,
            this.currentUser,
            this.siteSettings,
            this.site
          )
        : null;
      return {
        notification,
        label: director?.label ?? "",
        description: director?.description ?? "",
        icon: director?.icon ?? "bell",
        href: director?.linkHref ?? null,
        read: notification.read,
      };
    });
  }

  @action
  goToNotifications() {
    this.router.transitionTo("userNotifications", this.currentUser.username);
    this.dropdownOpen = false;
  }

  @action
  async markAllRead() {
    await ajax("/notifications/mark-read", { type: "PUT" });
    this.currentUser.set("unread_notifications", 0);
    this.currentUser.set("unread_high_priority_notifications", 0);
    this.currentUser.set("all_unread_notifications_count", 0);
    this.currentUser.set("grouped_unread_notifications", {});
  }

  @action
  closeDropdown() {
    this.dropdownOpen = false;
  }

  <template>
    <div class="fantribe-notifications">
      <button
        class="fantribe-notifications__btn"
        type="button"
        aria-label="Notifications"
        {{on "click" this.toggleDropdown}}
      >
        {{icon "bell"}}
        {{#if this.hasUnread}}
          <span class="fantribe-notifications__badge" aria-label="Unread notifications"></span>
        {{/if}}
      </button>

      {{#if this.dropdownOpen}}
        <div
          class="fantribe-notifications__dropdown"
          {{closeOnClickOutside
            this.closeDropdown
            (hash targetSelector=".fantribe-notifications__btn")
          }}
        >
          <div class="fantribe-notifications__header">
            <span>Notifications</span>
            <button
              type="button"
              class="fantribe-notifications__mark-read"
              {{on "click" this.markAllRead}}
            >Mark all read</button>
          </div>
          <div class="fantribe-notifications__list">
            {{#if this.notificationRows.length}}
              <ul class="fantribe-notifications__items">
                {{#each this.notificationRows as |row|}}
                  <li class="fantribe-notifications__item">
                    {{#if row.href}}
                      <a
                        href={{row.href}}
                        class="fantribe-notifications__item-link"
                      >
                        <span class="fantribe-notifications__item-icon">
                          {{icon row.icon}}
                        </span>
                        <div class="fantribe-notifications__item-content">
                          <span class="fantribe-notifications__item-label">
                            {{row.label}}
                          </span>
                          {{#if row.description}}
                            <span class="fantribe-notifications__item-description">
                              {{row.description}}
                            </span>
                          {{/if}}
                        </div>
                        <span class="fantribe-notifications__item-time">
                          {{formatDate row.notification.created_at format="tiny" leaveAgo="true"}}
                        </span>
                      </a>
                    {{else}}
                      <div class="fantribe-notifications__item-link">
                        <span class="fantribe-notifications__item-icon">
                          {{icon row.icon}}
                        </span>
                        <div class="fantribe-notifications__item-content">
                          <span class="fantribe-notifications__item-label">
                            {{row.label}}
                          </span>
                          {{#if row.description}}
                            <span class="fantribe-notifications__item-description">
                              {{row.description}}
                            </span>
                          {{/if}}
                        </div>
                        <span class="fantribe-notifications__item-time">
                          {{formatDate row.notification.created_at format="tiny" leaveAgo="true"}}
                        </span>
                      </div>
                    {{/if}}
                  </li>
                {{/each}}
              </ul>
            {{else}}
              <div class="fantribe-notifications__empty">
                <p>No new notifications</p>
              </div>
            {{/if}}
          </div>
          <div class="fantribe-notifications__footer">
            <button
              type="button"
              class="fantribe-notifications__view-all"
              {{on "click" this.goToNotifications}}
            >
              View all notifications
            </button>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
