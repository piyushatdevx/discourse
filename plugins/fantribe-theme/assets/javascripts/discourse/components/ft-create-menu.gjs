import Component from "@glimmer/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

const CREATE_MENU_ITEMS = [
  {
    id: "create-post",
    icon: "edit3",
    iconMod: "blue",
    labelKey: "fantribe.create_menu.create_post",
    descKey: "fantribe.create_menu.create_post_desc",
    action: "handleCreatePost",
  },
  {
    id: "create-tribe",
    icon: "compass",
    iconMod: "darkRed",
    labelKey: "fantribe.create_menu.create_tribe",
    descKey: "fantribe.create_menu.create_tribe_desc",
    action: "handleCreateTribe",
    adminOnly: true,
  },
  /*
  {
    id: "sell-gear",
    icon: "shopping-bag",
    iconMod: "green",
    labelKey: "fantribe.create_menu.sell_gear",
    descKey: "fantribe.create_menu.sell_gear_desc",
    suggested: false,
    action: "handleSellGear",
  },
  {
    id: "co-create-request",
    icon: "users",
    iconMod: "purple",
    labelKey: "fantribe.create_menu.co_create_request",
    descKey: "fantribe.create_menu.co_create_request_desc",
    suggested: false,
    action: "handleCoCreateRequest",
  },
  {
    id: "start-event",
    icon: "radio",
    iconMod: "red",
    labelKey: "fantribe.create_menu.start_event",
    descKey: "fantribe.create_menu.start_event_desc",
    suggested: false,
    action: "handleStartEvent",
  },
  {
    id: "create-video",
    icon: "video",
    iconMod: "orange",
    labelKey: "fantribe.create_menu.create_video",
    descKey: "fantribe.create_menu.create_video_desc",
    suggested: false,
    action: "handleCreateVideo",
  },
  */
];

export default class FtCreateMenu extends Component {
  @service currentUser;
  @service fantribeCreate;

  fnHelper = fn;

  get useClickOutside() {
    return this.args.useClickOutside !== false;
  }

  get menuItems() {
    const items = CREATE_MENU_ITEMS;
    if (this.currentUser?.admin) {
      return items;
    }
    return items.filter((item) => !item.adminOnly);
  }

  get closeCallback() {
    if (this.useClickOutside) {
      return this.fantribeCreate.closeCreateMenu.bind(this.fantribeCreate);
    }
    return this.fantribeCreate.closeSidebarCreateMenu.bind(this.fantribeCreate);
  }

  get clickOutsideTargetSelector() {
    return (
      this.args.clickOutsideTargetSelector ?? ".fantribe-header__create-btn"
    );
  }

  get isSidebarVariant() {
    return this.args.variant === "sidebar";
  }

  @action
  handleCreatePost() {
    this.fantribeCreate.openCreatePostModal();
  }

  @action
  handleCreateTribe() {
    this.fantribeCreate.openCreateTribeModal();
  }

  @action
  handleSellGear() {
    // Placeholder for future implementation
  }

  @action
  handleCoCreateRequest() {
    // Placeholder for future implementation
  }

  @action
  handleStartEvent() {
    // Placeholder for future implementation
  }

  @action
  handleCreateVideo() {
    // Placeholder for future implementation
  }

  @action
  handleItemClick(item) {
    const handler = this[item.action];
    if (typeof handler === "function") {
      handler.call(this);
    }
  }

  <template>
    <div
      class="ft-create-menu
        {{if this.isSidebarVariant 'ft-create-menu--sidebar'}}"
      {{closeOnClickOutside
        this.closeCallback
        (hash targetSelector=this.clickOutsideTargetSelector)
      }}
      ...attributes
    >
      <div class="ft-create-menu__items">
        {{#each this.menuItems as |item|}}
          <button
            type="button"
            class="ft-create-menu__item"
            {{on "click" (this.fnHelper this.handleItemClick item)}}
          >
            <span
              class="ft-create-menu__icon ft-create-menu__icon--{{item.iconMod}}"
            >
              {{ftIcon item.icon}}
            </span>
            <div class="ft-create-menu__item-content">
              <span class="ft-create-menu__item-label">{{i18n
                  item.labelKey
                }}</span>
              <span class="ft-create-menu__item-desc">{{i18n
                  item.descKey
                }}</span>
            </div>
            {{#if item.suggested}}
              <span class="ft-create-menu__badge">{{i18n
                  "fantribe.create_menu.suggested"
                }}</span>
            {{/if}}
          </button>
        {{/each}}
      </div>
    </div>
  </template>
}
