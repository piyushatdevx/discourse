import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ChatRetentionReminderText from "discourse/plugins/chat/discourse/components/chat-retention-reminder-text";

export default class ChatRetentionReminder extends Component {
  @service currentUser;

  get show() {
    return false;
  }

  @action
  async dismiss() {
    try {
      await ajax("/chat/dismiss-retention-reminder", {
        method: "POST",
        data: { chatable_type: this.args.channel.chatableType },
      });
      const field = this.args.channel.isDirectMessageChannel
        ? "needs_dm_retention_reminder"
        : "needs_channel_retention_reminder";
      this.currentUser.set(field, false);
    } catch (e) {
      popupAjaxError(e);
    }
  }

  <template>
    {{#if this.show}}
      <div class="chat-retention-reminder">
        <ChatRetentionReminderText @channel={{@channel}} />
        <DButton
          @action={{this.dismiss}}
          @icon="xmark"
          class="no-text btn-icon btn-transparent dismiss-btn"
        />
      </div>
    {{/if}}
  </template>
}
