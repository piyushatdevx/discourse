import Component from "@glimmer/component";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import ftIcon from "../helpers/ft-icon";

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
            {{ftIcon "edit3"}}
          </span>
          <div class="ft-create-menu__item-content">
            <span class="ft-create-menu__item-label">Create Post</span>
            <span class="ft-create-menu__item-desc">Share updates, music, and
              vibes</span>
          </div>
          <span class="ft-create-menu__badge">Suggested</span>
        </button>
      </div>
    </div>
  </template>
}
