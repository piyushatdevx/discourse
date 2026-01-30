import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";

export default class FantribeNotifications extends Component {
  @service currentUser;
  @service router;

  @tracked dropdownOpen = false;

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
  }

  @action
  goToNotifications() {
    this.router.transitionTo("userNotifications", this.currentUser.username);
    this.dropdownOpen = false;
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
          <span class="fantribe-notifications__badge">
            {{this.displayCount}}
          </span>
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
              class="fantribe-notifications__see-all"
              {{on "click" this.goToNotifications}}
            >See All</button>
          </div>
          <div class="fantribe-notifications__list">
            <div class="fantribe-notifications__empty">
              {{#if this.hasUnread}}
                <p>You have {{this.unreadCount}} unread notifications</p>
              {{else}}
                <p>No new notifications</p>
              {{/if}}
              <button
                type="button"
                class="ft-btn ft-btn--primary ft-btn--sm"
                {{on "click" this.goToNotifications}}
              >
                View All Notifications
              </button>
            </div>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
