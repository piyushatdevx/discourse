import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import concatClass from "discourse/helpers/concat-class";
import { i18n } from "discourse-i18n";
import ChannelsListDirect from "discourse/plugins/chat/discourse/components/channels-list-direct";
import ChannelsListPublic from "discourse/plugins/chat/discourse/components/channels-list-public";
import ChannelsListStarred from "discourse/plugins/chat/discourse/components/channels-list-starred";

export default class ChannelsList extends Component {
  @service chat;
  @service chatChannelsManager;

  @tracked activeTab = "channels";

  @action
  switchTab(tabId) {
    this.activeTab = tabId;
  }

  get isChannelsTab() {
    return this.activeTab === "channels";
  }

  get isDMsTab() {
    return this.activeTab === "dms";
  }

  get isStarredTab() {
    return this.activeTab === "starred";
  }

  get channelsUnreadCount() {
    return (
      this.chatChannelsManager.publicMessageChannelsWithActivity?.length || 0
    );
  }

  get dmsUnreadCount() {
    return (
      this.chatChannelsManager.directMessageChannelsWithActivity?.length || 0
    );
  }

  get starredUnreadCount() {
    return this.chatChannelsManager.starredChannelsWithActivity?.length || 0;
  }

  <template>
    <div
      role="region"
      aria-label={{i18n "chat.aria_roles.channels_list"}}
      class="channels-list"
    >
      <div class="channels-list__tabs">
        <button
          type="button"
          class={{concatClass
            "channels-list__tab"
            (if this.isChannelsTab "active")
          }}
          {{on "click" (fn this.switchTab "channels")}}
        >
          {{i18n "chat.chat_channels"}}
          {{#if this.channelsUnreadCount}}
            <span
              class="channels-list__tab-badge"
            >{{this.channelsUnreadCount}}</span>
          {{/if}}
        </button>
        {{#if this.chat.userCanAccessDirectMessages}}
          <button
            type="button"
            class={{concatClass
              "channels-list__tab"
              (if this.isDMsTab "active")
            }}
            {{on "click" (fn this.switchTab "dms")}}
          >
            {{i18n "chat.messages_tab"}}
            {{#if this.dmsUnreadCount}}
              <span
                class="channels-list__tab-badge"
              >{{this.dmsUnreadCount}}</span>
            {{/if}}
          </button>
        {{/if}}
        <button
          type="button"
          class={{concatClass
            "channels-list__tab"
            (if this.isStarredTab "active")
          }}
          {{on "click" (fn this.switchTab "starred")}}
        >
          {{i18n "chat.starred"}}
          {{#if this.starredUnreadCount}}
            <span
              class="channels-list__tab-badge"
            >{{this.starredUnreadCount}}</span>
          {{/if}}
        </button>
      </div>

      {{#if this.isChannelsTab}}
        <ChannelsListPublic />
      {{else if this.isDMsTab}}
        <ChannelsListDirect />
      {{else if this.isStarredTab}}
        <ChannelsListStarred />
      {{/if}}
    </div>
  </template>
}
