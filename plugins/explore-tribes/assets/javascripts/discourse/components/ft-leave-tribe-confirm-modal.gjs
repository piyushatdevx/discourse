import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";

export default class FtLeaveTribeConfirmModal extends Component {
  get tribeName() {
    return this.args.tribeName ?? "this tribe";
  }

  get titleText() {
    return i18n("explore_tribes.leave_confirm.title");
  }

  get closeLabel() {
    return i18n("explore_tribes.leave_confirm.close");
  }

  get messageText() {
    return i18n("explore_tribes.leave_confirm.message", {
      name: this.tribeName,
    });
  }

  get cancelText() {
    return i18n("explore_tribes.leave_confirm.cancel");
  }

  get leaveButtonText() {
    return i18n("explore_tribes.leave_confirm.leave");
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose?.();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.args.onClose?.();
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-modal-backdrop ft-leave-tribe-confirm-modal__backdrop"
      role="dialog"
      aria-modal="true"
      aria-labelledby="ft-leave-tribe-confirm-title"
      {{on "click" this.handleBackdropClick}}
      {{on "keydown" this.handleKeydown}}
    >
      <div class="ft-modal ft-modal--sm ft-leave-tribe-confirm-modal">
        <div class="ft-modal__title-bar">
          <h2
            id="ft-leave-tribe-confirm-title"
            class="ft-modal__title"
          >{{this.titleText}}</h2>
          <button
            type="button"
            class="ft-modal__close-btn"
            aria-label={{this.closeLabel}}
            {{on "click" @onClose}}
          >
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="ft-leave-tribe-confirm-modal__body">
          <p class="ft-leave-tribe-confirm-modal__message">
            {{this.messageText}}
          </p>
        </div>
        <div class="ft-modal__footer">
          <button
            type="button"
            class="ft-modal__cancel-btn"
            {{on "click" @onClose}}
          >
            {{this.cancelText}}
          </button>
          <button
            type="button"
            class="ft-leave-tribe-confirm-modal__leave-btn"
            {{on "click" @onConfirm}}
          >
            {{this.leaveButtonText}}
          </button>
        </div>
      </div>
    </div>
  </template>
}
