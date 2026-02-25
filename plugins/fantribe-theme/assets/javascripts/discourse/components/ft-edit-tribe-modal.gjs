import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ftIcon from "../helpers/ft-icon";

export default class FtEditTribeModal extends Component {
  @service router;

  @tracked name = "";
  @tracked description = "";
  @tracked color = "#0088cc";
  @tracked isPrivate = false;
  @tracked isSaving = false;

  constructor(owner, args) {
    super(owner, args);
    const cat = args.category;
    this.name = cat?.name || "";
    this.description = cat?.description_text || "";
    this.color = cat?.color ? `#${cat.color}` : "#0088cc";
    this.isPrivate = cat?.read_restricted ?? false;
  }

  get colorSwatchStyle() {
    return htmlSafe(`background-color: ${this.color}`);
  }

  get isDisabled() {
    return this.isSaving || !this.name.trim();
  }

  @action
  updateName(event) {
    this.name = event.target.value;
  }

  @action
  updateDescription(event) {
    this.description = event.target.value;
  }

  @action
  updateColor(event) {
    this.color = event.target.value;
  }

  @action
  setPublic() {
    this.isPrivate = false;
  }

  @action
  setPrivate() {
    this.isPrivate = true;
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.args.onClose();
    }
  }

  @action
  async saveTribe() {
    if (this.isDisabled) {
      return;
    }

    this.isSaving = true;
    try {
      // `permissions` is a top-level param (not nested under `category`).
      // Public  → everyone can read/post (permission level 1 = full).
      // Private → only staff can access.
      const permissions = this.isPrivate ? { staff: 1 } : { everyone: 1 };

      await ajax(`/categories/${this.args.category.id}.json`, {
        type: "PUT",
        data: {
          category: {
            name: this.name.trim(),
            description: this.description.trim(),
            color: this.color.replace(/^#/, ""),
          },
          permissions,
        },
      });
      this.args.onClose();
      this.router.refresh();
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSaving = false;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{#if @category}}
      <div
        class="ft-modal-backdrop"
        role="dialog"
        aria-modal="true"
        aria-label="Edit tribe"
        {{on "click" this.handleBackdropClick}}
        {{on "keydown" this.handleKeydown}}
      >
        <div class="ft-modal ft-edit-modal ft-edit-tribe-modal">

          {{! Header }}
          <div class="ft-modal__title-bar">
            <h2 class="ft-modal__title">Edit Tribe</h2>
            <button
              type="button"
              class="ft-modal__close-btn"
              aria-label="Close"
              {{on "click" @onClose}}
            >
              {{ftIcon "x"}}
            </button>
          </div>

          {{! Fields }}
          <div class="ft-edit-modal__fields">

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-tribe-edit-name">
                Tribe Name
              </label>
              <input
                type="text"
                id="ft-tribe-edit-name"
                class="ft-edit-modal__input"
                placeholder="Tribe name"
                value={{this.name}}
                maxlength="50"
                {{on "input" this.updateName}}
              />
            </div>

            <div class="ft-edit-modal__field">
              <label
                class="ft-edit-modal__label"
                for="ft-tribe-edit-description"
              >
                Description
              </label>
              <textarea
                id="ft-tribe-edit-description"
                class="ft-edit-modal__textarea"
                placeholder="What is this tribe about?"
                {{on "input" this.updateDescription}}
              >{{this.description}}</textarea>
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label">Tribe Color</label>
              <div class="ft-edit-tribe-modal__color-row">
                <span
                  class="ft-edit-tribe-modal__color-swatch"
                  style={{this.colorSwatchStyle}}
                ></span>
                <input
                  type="color"
                  class="ft-edit-tribe-modal__color-input"
                  value={{this.color}}
                  {{on "input" this.updateColor}}
                />
                <span class="ft-edit-tribe-modal__color-value">
                  {{this.color}}
                </span>
              </div>
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label">Visibility</label>
              <div class="ft-edit-tribe-modal__visibility-row">
                <button
                  type="button"
                  class="ft-edit-tribe-modal__vis-btn
                    {{unless
                      this.isPrivate
                      'ft-edit-tribe-modal__vis-btn--active'
                    }}"
                  {{on "click" this.setPublic}}
                >
                  {{ftIcon "globe"}}
                  <span>Public</span>
                </button>
                <button
                  type="button"
                  class="ft-edit-tribe-modal__vis-btn
                    {{if
                      this.isPrivate
                      'ft-edit-tribe-modal__vis-btn--active'
                    }}"
                  {{on "click" this.setPrivate}}
                >
                  {{ftIcon "lock"}}
                  <span>Private</span>
                </button>
              </div>
              {{#if this.isPrivate}}
                <p class="ft-edit-tribe-modal__vis-hint">
                  Only staff will be able to access this tribe.
                </p>
              {{/if}}
            </div>

          </div>

          {{! Footer }}
          <div class="ft-modal__footer">
            <button
              type="button"
              class="ft-modal__cancel-btn"
              {{on "click" @onClose}}
            >
              Cancel
            </button>
            <button
              type="button"
              class="ft-edit-modal__save-btn
                {{if this.isDisabled 'ft-edit-modal__save-btn--disabled'}}"
              disabled={{this.isDisabled}}
              {{on "click" this.saveTribe}}
            >
              {{if this.isSaving "Saving…" "Save Changes"}}
            </button>
          </div>

        </div>
      </div>
    {{/if}}
  </template>
}
