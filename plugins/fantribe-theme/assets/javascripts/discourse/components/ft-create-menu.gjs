import Component from "@glimmer/component";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";

export default class FtCreateMenu extends Component {
  @service fantribeCreate;

  @action
  handleCreatePost() {
    this.fantribeCreate.openCreatePostModal();
  }

  <template>
    <div
      class="ft-create-menu"
      {{closeOnClickOutside
        this.fantribeCreate.closeCreateMenu
        (hash targetSelector=".fantribe-header__create-btn")
      }}
    >
      <div class="ft-create-menu__header">
        <span class="ft-create-menu__title">Create Something</span>
      </div>

      <div class="ft-create-menu__items">
        <button
          type="button"
          class="ft-create-menu__item"
          {{on "click" this.handleCreatePost}}
        >
          <span class="ft-create-menu__icon ft-create-menu__icon--blue">
            {{icon "pencil-alt"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Create Post</span>
            <span class="ft-create-menu__item-desc">Share updates, music, and
              vibes</span>
          </div>
          <span class="ft-create-menu__badge">Suggested</span>
        </button>

        <button type="button" class="ft-create-menu__item">
          <span class="ft-create-menu__icon ft-create-menu__icon--green">
            {{icon "store"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Sell Gear</span>
            <span class="ft-create-menu__item-desc">List equipment for sale</span>
          </div>
        </button>

        <button type="button" class="ft-create-menu__item">
          <span class="ft-create-menu__icon ft-create-menu__icon--purple">
            {{icon "people-group"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Co-Create Request</span>
            <span class="ft-create-menu__item-desc">Find collaborators</span>
          </div>
        </button>

        <button type="button" class="ft-create-menu__item">
          <span class="ft-create-menu__icon ft-create-menu__icon--red">
            {{icon "tower-broadcast"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Start Event</span>
            <span class="ft-create-menu__item-desc">Host a live session</span>
          </div>
        </button>

        <button type="button" class="ft-create-menu__item">
          <span class="ft-create-menu__icon ft-create-menu__icon--orange">
            {{icon "video"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Create Video</span>
            <span class="ft-create-menu__item-desc">Upload video content</span>
          </div>
        </button>

        <button type="button" class="ft-create-menu__item">
          <span class="ft-create-menu__icon ft-create-menu__icon--pink">
            {{icon "gift"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Create Reward</span>
            <span class="ft-create-menu__item-desc">Offer fan rewards</span>
          </div>
        </button>
      </div>
    </div>
  </template>
}
