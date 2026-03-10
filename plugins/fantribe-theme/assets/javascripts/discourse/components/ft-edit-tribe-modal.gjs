import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

export default class FtEditTribeModal extends Component {
  @service router;

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

  constructor(owner, args) {
    super(owner, args);
    const cat = args.category;
    this.name = cat?.name || "";
    this.description = cat?.description_text || "";
    this.isPrivate = cat?.read_restricted ?? false;
    this.logoPreviewUrl =
      cat?.uploaded_logo?.url || cat?.uploaded_logo_url || null;
    this.coverPreviewUrl =
      cat?.uploaded_background?.url || cat?.uploaded_background_url || null;
  }

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
  triggerLogoInput() {
    document.querySelector(".ft-edit-tribe-modal__logo-input")?.click();
  }

  @action
  triggerCoverInput() {
    document.querySelector(".ft-edit-tribe-modal__cover-input")?.click();
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
    this.uploadedLogoId = -1;
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
    this.uploadedBackgroundId = -1;
  }

  @action
  async saveTribe() {
    if (this.isDisabled) {
      return;
    }

    this.isSaving = true;
    try {
      const permissions = this.isPrivate ? { staff: 1 } : { everyone: 1 };

      const data = {
        name: this.name.trim(),
        description: this.description.trim(),
        permissions,
      };

      if (this.uploadedLogoId !== null) {
        data.uploaded_logo_id = this.uploadedLogoId;
      }
      if (this.uploadedBackgroundId !== null) {
        data.uploaded_background_id = this.uploadedBackgroundId;
      }

      await ajax(`/categories/${this.args.category.id}.json`, {
        type: "PUT",
        data,
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
        aria-label={{i18n "fantribe.common.edit_tribe"}}
        {{on "click" this.handleBackdropClick}}
        {{on "keydown" this.handleKeydown}}
      >
        <div class="ft-modal ft-edit-modal ft-edit-tribe-modal">

          {{! Header }}
          <div class="ft-modal__title-bar">
            <h2 class="ft-modal__title">{{i18n
                "fantribe.common.edit_tribe"
              }}</h2>
            <button
              type="button"
              class="ft-modal__close-btn"
              aria-label={{i18n "fantribe.common.close"}}
              {{on "click" @onClose}}
            >
              {{ftIcon "x"}}
            </button>
          </div>

          {{! Fields }}
          <div class="ft-edit-modal__fields">

            {{! Cover Image }}
            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label">{{i18n
                  "fantribe.tribe_modal.cover_image"
                }}</label>
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
                        (i18n "fantribe.common.uploading")
                        (i18n "fantribe.tribe_modal.upload_cover_image")
                      }}</span>
                  </button>
                {{/if}}
                <input
                  type="file"
                  class="ft-edit-tribe-modal__cover-input"
                  accept="image/*"
                  {{on "change" this.handleCoverSelected}}
                />
              </div>
              <p class="ft-edit-tribe-modal__cover-hint">
                {{i18n "fantribe.tribe_modal.cover_hint"}}
              </p>
            </div>

            {{! Tribe Logo / Profile Image }}
            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label">{{i18n
                  "fantribe.tribe_modal.tribe_logo"
                }}</label>
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
                        (i18n "fantribe.common.uploading")
                        (i18n "fantribe.tribe_modal.upload_tribe_logo")
                      }}</span>
                  </button>
                {{/if}}
                <input
                  type="file"
                  class="ft-edit-tribe-modal__logo-input"
                  accept="image/*"
                  {{on "change" this.handleLogoSelected}}
                />
              </div>
              <p class="ft-edit-tribe-modal__cover-hint">
                {{i18n "fantribe.tribe_modal.logo_hint"}}
              </p>
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-tribe-edit-name">
                {{i18n "fantribe.tribe_modal.tribe_name"}}
              </label>
              <input
                type="text"
                id="ft-tribe-edit-name"
                class="ft-edit-modal__input"
                placeholder={{i18n
                  "fantribe.tribe_modal.tribe_name_placeholder"
                }}
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
                {{i18n "fantribe.common.description"}}
              </label>
              <textarea
                id="ft-tribe-edit-description"
                class="ft-edit-modal__textarea"
                placeholder={{i18n
                  "fantribe.tribe_modal.description_placeholder"
                }}
                {{on "input" this.updateDescription}}
              >{{this.description}}</textarea>
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label">{{i18n
                  "fantribe.common.visibility"
                }}</label>
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
                  <span>{{i18n "fantribe.common.public"}}</span>
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
                  <span>{{i18n "fantribe.common.private"}}</span>
                </button>
              </div>
              {{#if this.isPrivate}}
                <p class="ft-edit-tribe-modal__vis-hint">
                  {{i18n "fantribe.tribe_modal.private_hint"}}
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
              {{i18n "fantribe.common.cancel"}}
            </button>
            <button
              type="button"
              class="ft-edit-modal__save-btn
                {{if this.isDisabled 'ft-edit-modal__save-btn--disabled'}}"
              disabled={{this.isDisabled}}
              {{on "click" this.saveTribe}}
            >
              {{if
                this.isSaving
                (i18n "fantribe.common.saving")
                (i18n "fantribe.common.save_changes")
              }}
            </button>
          </div>

        </div>
      </div>
    {{/if}}
  </template>
}
