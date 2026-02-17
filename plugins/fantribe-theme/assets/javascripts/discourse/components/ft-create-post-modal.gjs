import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import ftIcon from "../helpers/ft-icon";
import { animateModalIn, animateModalOut } from "../lib/spring-animation";

export default class FtCreatePostModal extends Component {
  @service currentUser;
  @service composer;

  @tracked postText = "";
  @tracked visibility = "public";
  @tracked gearTags = [];
  @tracked visibilityDropdownOpen = false;

  _animHandle = null;
  _modalElement = null;

  willDestroy() {
    super.willDestroy(...arguments);
    if (this._animHandle) {
      this._animHandle.cancel();
    }
  }

  get isDisabled() {
    return !this.postText.trim();
  }

  get visibilityIcon() {
    switch (this.visibility) {
      case "public":
        return "globe";
      case "private":
        return "lock";
      case "tribe":
        return "users";
      default:
        return "globe";
    }
  }

  get visibilityLabel() {
    switch (this.visibility) {
      case "public":
        return "Public";
      case "private":
        return "Only Me";
      case "tribe":
        return "Tribe Only";
      default:
        return "Public";
    }
  }

  @action
  setupModal(element) {
    this._modalElement = element;
    this._animHandle = animateModalIn(element);
  }

  @action
  updateText(event) {
    this.postText = event.target.value;
  }

  @action
  setVisibility(value) {
    this.visibility = value;
    this.visibilityDropdownOpen = false;
  }

  @action
  toggleVisibilityDropdown(event) {
    event.stopPropagation();
    this.visibilityDropdownOpen = !this.visibilityDropdownOpen;
  }

  @action
  closeVisibilityDropdown() {
    this.visibilityDropdownOpen = false;
  }

  @action
  async handleClose() {
    if (this._modalElement) {
      await new Promise((resolve) => {
        this._animHandle = animateModalOut(this._modalElement, resolve);
      });
    }
    this.args.onClose?.();
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.handleClose();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.handleClose();
    }
  }

  @action
  async submitPost() {
    if (this.isDisabled) {
      return;
    }
    this.composer.open({
      action: "createTopic",
      draftKey: "new_topic",
      draftSequence: 0,
      title: "",
      body: this.postText,
    });
    this.handleClose();
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-modal-backdrop"
      {{on "click" this.handleBackdropClick}}
      {{on "keydown" this.handleKeydown}}
      role="dialog"
      aria-modal="true"
    >
      <div class="ft-modal" {{on "insert" this.setupModal}}>
        {{! Modal Header }}
        <div class="ft-modal__header">
          <div class="ft-modal__header-left">
            {{#if this.currentUser}}
              <div class="ft-modal__avatar">
                {{avatar this.currentUser imageSize="medium"}}
              </div>
            {{/if}}
            <div>
              <div class="ft-modal__user-name">
                {{this.currentUser.name}}
              </div>
              <button
                type="button"
                class="ft-modal__visibility-btn"
                {{on "click" this.toggleVisibilityDropdown}}
              >
                {{ftIcon this.visibilityIcon size=16}}
                <span>{{this.visibilityLabel}}</span>
                {{ftIcon "chevron-right" size=12}}
              </button>

              {{#if this.visibilityDropdownOpen}}
                <div class="ft-modal__visibility-dropdown ft-animate-dropdown">
                  <button
                    type="button"
                    class="ft-modal__visibility-option"
                    {{on "click" (fn this.setVisibility "public")}}
                  >
                    {{ftIcon "globe" size=20}}
                    <span>Public</span>
                  </button>
                  <button
                    type="button"
                    class="ft-modal__visibility-option"
                    {{on "click" (fn this.setVisibility "private")}}
                  >
                    {{ftIcon "lock" size=20}}
                    <span>Only Me</span>
                  </button>
                  <button
                    type="button"
                    class="ft-modal__visibility-option"
                    {{on "click" (fn this.setVisibility "tribe")}}
                  >
                    {{ftIcon "users" size=20}}
                    <span>Tribe Only</span>
                  </button>
                </div>
              {{/if}}
            </div>
          </div>
          <button
            type="button"
            class="ft-modal__close-btn"
            {{on "click" this.handleClose}}
          >
            {{ftIcon "x" size=20}}
          </button>
        </div>

        {{! Modal Body }}
        <div class="ft-modal__body">
          <textarea
            class="ft-modal__textarea"
            placeholder="What's on your mind?"
            value={{this.postText}}
            {{on "input" this.updateText}}
          ></textarea>
        </div>

        {{! Modal Footer }}
        <div class="ft-modal__footer">
          <div class="ft-modal__tools">
            <button type="button" class="ft-modal__tool-btn" title="Add Media">
              {{ftIcon "image" size=20}}
            </button>
            <button type="button" class="ft-modal__tool-btn" title="Tag Gear">
              {{ftIcon "tag" size=20}}
            </button>
            <button type="button" class="ft-modal__tool-btn" title="Schedule">
              {{ftIcon "calendar" size=20}}
            </button>
            <button type="button" class="ft-modal__tool-btn" title="AI Assist">
              {{ftIcon "sparkles" size=20}}
            </button>
          </div>
          <button
            type="button"
            class="ft-modal__submit-btn
              {{if this.isDisabled 'ft-modal__submit-btn--disabled'}}"
            disabled={{this.isDisabled}}
            {{on "click" this.submitPost}}
          >
            Post
          </button>
        </div>
      </div>
    </div>
  </template>
}
