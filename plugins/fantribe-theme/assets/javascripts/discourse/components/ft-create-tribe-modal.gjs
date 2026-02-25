import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ftIcon from "../helpers/ft-icon";

export default class FtCreateTribeModal extends Component {
  @service router;
  @service fantribeCreate;

  @tracked name = "";
  @tracked description = "";
  @tracked isPrivate = false;
  @tracked isSaving = false;

  @tracked isUploadingLogo = false;
  @tracked logoPreviewUrl = null;
  @tracked uploadedLogoId = null;

  @tracked isUploadingCover = false;
  @tracked coverPreviewUrl = null;
  @tracked uploadedBackgroundId = null;

  get isDisabled() {
    return (
      this.isSaving ||
      this.isUploadingLogo ||
      this.isUploadingCover ||
      !this.name.trim()
    );
  }

  get coverStyle() {
    if (this.coverPreviewUrl) {
      return htmlSafe(`background-image: url('${this.coverPreviewUrl}')`);
    }
    return null;
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
      this.fantribeCreate.closeCreateTribeModal();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.fantribeCreate.closeCreateTribeModal();
    }
  }

  @action
  triggerLogoInput() {
    document.querySelector(".ft-create-tribe-modal__logo-input")?.click();
  }

  @action
  triggerCoverInput() {
    document.querySelector(".ft-create-tribe-modal__cover-input")?.click();
  }

  async uploadFile(file) {
    const formData = new FormData();
    formData.append("file", file);
    formData.append("type", "composer");
    return ajax("/uploads.json", {
      type: "POST",
      data: formData,
      processData: false,
      contentType: false,
    });
  }

  @action
  async handleLogoSelected(event) {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }
    this.isUploadingLogo = true;
    try {
      const upload = await this.uploadFile(file);
      this.uploadedLogoId = upload.id;
      this.logoPreviewUrl = upload.url;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isUploadingLogo = false;
      event.target.value = "";
    }
  }

  @action
  removeLogo() {
    this.logoPreviewUrl = null;
    this.uploadedLogoId = null;
  }

  @action
  async handleCoverSelected(event) {
    const file = event.target.files?.[0];
    if (!file) {
      return;
    }
    this.isUploadingCover = true;
    try {
      const upload = await this.uploadFile(file);
      this.uploadedBackgroundId = upload.id;
      this.coverPreviewUrl = upload.url;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isUploadingCover = false;
      event.target.value = "";
    }
  }

  @action
  removeCover() {
    this.coverPreviewUrl = null;
    this.uploadedBackgroundId = null;
  }

  @action
  async createTribe() {
    if (this.isDisabled) {
      return;
    }
    this.isSaving = true;
    try {
      const data = {
        name: this.name.trim(),
        description: this.description.trim(),
        color: "0088CC",
        text_color: "FFFFFF",
        permissions: this.isPrivate ? { staff: 1 } : { everyone: 1 },
      };
      if (this.uploadedLogoId) {
        data.uploaded_logo_id = this.uploadedLogoId;
      }
      if (this.uploadedBackgroundId) {
        data.uploaded_background_id = this.uploadedBackgroundId;
      }

      await ajax("/categories.json", {
        type: "POST",
        data,
      });
      this.fantribeCreate.closeCreateTribeModal();
      this.router.refresh();
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSaving = false;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-modal-backdrop"
      role="dialog"
      aria-modal="true"
      aria-label="Create tribe"
      {{on "click" this.handleBackdropClick}}
      {{on "keydown" this.handleKeydown}}
    >
      <div class="ft-modal ft-edit-modal ft-create-tribe-modal">

        {{! Header }}
        <div class="ft-modal__title-bar">
          <h2 class="ft-modal__title">Create Tribe</h2>
          <button
            type="button"
            class="ft-modal__close-btn"
            aria-label="Close"
            {{on "click" this.fantribeCreate.closeCreateTribeModal}}
          >
            {{ftIcon "x"}}
          </button>
        </div>

        {{! Fields }}
        <div class="ft-edit-modal__fields">

          {{! Cover Image }}
          <div class="ft-edit-modal__field">
            <label class="ft-edit-modal__label">Cover Image</label>
            <div class="ft-edit-tribe-modal__cover-wrap">
              {{#if this.coverPreviewUrl}}
                <div
                  class="ft-edit-tribe-modal__cover-preview"
                  style={{this.coverStyle}}
                >
                  <button
                    type="button"
                    class="ft-edit-tribe-modal__cover-remove"
                    aria-label="Remove cover image"
                    {{on "click" this.removeCover}}
                  >
                    {{ftIcon "x"}}
                  </button>
                </div>
              {{else}}
                <button
                  type="button"
                  class="ft-edit-tribe-modal__cover-upload-btn"
                  disabled={{this.isUploadingCover}}
                  {{on "click" this.triggerCoverInput}}
                >
                  {{ftIcon "image"}}
                  <span>{{if
                      this.isUploadingCover
                      "Uploading..."
                      "Upload Cover Image"
                    }}</span>
                </button>
              {{/if}}
              <input
                type="file"
                class="ft-create-tribe-modal__cover-input"
                accept="image/*"
                {{on "change" this.handleCoverSelected}}
              />
            </div>
            <p class="ft-edit-tribe-modal__cover-hint">
              Recommended: 1200×400px or wider. Shown at the top of your tribe
              page.
            </p>
          </div>

          {{! Tribe Logo / Profile Image }}
          <div class="ft-edit-modal__field">
            <label class="ft-edit-modal__label">Tribe Logo</label>
            <div class="ft-edit-tribe-modal__logo-wrap">
              {{#if this.logoPreviewUrl}}
                <div class="ft-edit-tribe-modal__logo-preview">
                  <img src={{this.logoPreviewUrl}} alt="Tribe logo" />
                  <button
                    type="button"
                    class="ft-edit-tribe-modal__logo-remove"
                    aria-label="Remove logo"
                    {{on "click" this.removeLogo}}
                  >
                    {{ftIcon "x"}}
                  </button>
                </div>
              {{else}}
                <button
                  type="button"
                  class="ft-edit-tribe-modal__logo-upload-btn"
                  disabled={{this.isUploadingLogo}}
                  {{on "click" this.triggerLogoInput}}
                >
                  {{ftIcon "image"}}
                  <span>{{if
                      this.isUploadingLogo
                      "Uploading..."
                      "Upload Tribe Logo"
                    }}</span>
                </button>
              {{/if}}
              <input
                type="file"
                class="ft-create-tribe-modal__logo-input"
                accept="image/*"
                {{on "change" this.handleLogoSelected}}
              />
            </div>
            <p class="ft-edit-tribe-modal__cover-hint">
              Square image, min 100×100px. Shown as your tribe's profile
              picture.
            </p>
          </div>

          <div class="ft-edit-modal__field">
            <label class="ft-edit-modal__label" for="ft-tribe-create-name">
              Tribe Name
            </label>
            <input
              type="text"
              id="ft-tribe-create-name"
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
              for="ft-tribe-create-description"
            >
              Description
            </label>
            <textarea
              id="ft-tribe-create-description"
              class="ft-edit-modal__textarea"
              placeholder="What is this tribe about?"
              {{on "input" this.updateDescription}}
            ></textarea>
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
                  {{if this.isPrivate 'ft-edit-tribe-modal__vis-btn--active'}}"
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
            {{on "click" this.fantribeCreate.closeCreateTribeModal}}
          >
            Cancel
          </button>
          <button
            type="button"
            class="ft-edit-modal__save-btn
              {{if this.isDisabled 'ft-edit-modal__save-btn--disabled'}}"
            disabled={{this.isDisabled}}
            {{on "click" this.createTribe}}
          >
            {{if this.isSaving "Creating…" "Create Tribe"}}
          </button>
        </div>

      </div>
    </div>
  </template>
}
