import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { getUploadMarkdown } from "discourse/lib/uploads";
import { EDIT, REPLY } from "discourse/models/composer";
import { i18n } from "discourse-i18n";
import ftIcon from "../../helpers/ft-icon";

const MAX_CHARS = 2000;

export default class FtReplySimpleEditor extends Component {
  @service siteSettings;

  @tracked uploadedMedia = [];
  @tracked isUploading = false;

  get model() {
    return this.args.outletArgs?.model;
  }

  get isReply() {
    return this.model?.action === REPLY;
  }

  get isEdit() {
    return this.model?.action === EDIT;
  }

  get themeEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get shouldRender() {
    return this.themeEnabled && (this.isReply || this.isEdit) && this.model;
  }

  get replyText() {
    return this.model?.reply ?? "";
  }

  get charCount() {
    return this.replyText.length;
  }

  get isOverLimit() {
    return this.charCount > MAX_CHARS;
  }

  get hasUploadedMedia() {
    return this.uploadedMedia.length > 0;
  }

  @action
  updateReply(event) {
    const value = event.target.value;
    this.model?.set("reply", value);
  }

  @action
  triggerFileInput(type, event) {
    const root =
      event?.currentTarget?.closest(".ft-reply-simple-editor") || null;
    if (!root) {
      return;
    }

    const input = root.querySelector(
      `.ft-reply-simple-editor__file-input--${type}`
    );
    if (input) {
      input.value = "";
      input.click();
    }
  }

  @action
  async handleFileSelected(type, event) {
    const files = event.target.files;
    if (!files || files.length === 0) {
      return;
    }

    this.isUploading = true;

    try {
      for (const file of files) {
        const formData = new FormData();
        formData.append("file", file);
        formData.append("type", "composer");

        const upload = await ajax("/uploads.json", {
          type: "POST",
          data: formData,
          processData: false,
          contentType: false,
        });

        const uploadMarkdown = getUploadMarkdown(upload);
        this.uploadedMedia = [
          ...this.uploadedMedia,
          { type, name: file.name, uploadMarkdown },
        ];

        const current = this.model?.reply ?? "";
        const separator = current.length > 0 ? "\n\n" : "";
        this.model?.set("reply", `${current}${separator}${uploadMarkdown}`);
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isUploading = false;
      event.target.value = "";
    }
  }

  @action
  removeMedia(index) {
    const media = this.uploadedMedia[index];
    if (!media || !this.model) {
      return;
    }

    const current = this.model.reply ?? "";
    const newReply = current
      .replace(media.uploadMarkdown, "")
      .replace(/\n\n\n+/g, "\n\n")
      .trim();
    this.model.set("reply", newReply);
    this.uploadedMedia = this.uploadedMedia.filter((_, i) => i !== index);
  }

  <template>
    {{#if this.shouldRender}}
      <div class="ft-reply-simple-editor ft-modal__body">
        <textarea
          class="ft-modal__textarea ft-reply-simple-editor__textarea"
          placeholder={{i18n "composer.reply_placeholder_simple"}}
          value={{this.replyText}}
          {{on "input" this.updateReply}}
          rows={{6}}
        ></textarea>
        <div
          class="ft-modal__char-count
            {{if this.isOverLimit 'ft-modal__char-count--over'}}"
        >
          {{this.charCount}}/{{MAX_CHARS}}
        </div>

        <input
          type="file"
          class="ft-reply-simple-editor__file-input--image"
          accept="image/*"
          multiple
          {{on "change" (fn this.handleFileSelected "image")}}
        />

        <div class="ft-modal__media-buttons">
          <button
            type="button"
            class="ft-modal__media-pill ft-modal__media-pill--photo"
            disabled={{this.isUploading}}
            {{on "click" (fn this.triggerFileInput "image")}}
          >
            {{ftIcon "image"}}
            <span>Photo</span>
          </button>
        </div>

        {{#if this.isUploading}}
          <div class="ft-modal__upload-status">Uploading...</div>
        {{/if}}

        {{#if this.hasUploadedMedia}}
          <div class="ft-modal__uploaded-media">
            {{#each this.uploadedMedia as |media index|}}
              <div class="ft-modal__uploaded-item">
                <span class="ft-modal__uploaded-item-icon">
                  {{ftIcon "image"}}
                </span>
                <span class="ft-modal__uploaded-item-name">{{media.name}}</span>
                <button
                  type="button"
                  class="ft-modal__uploaded-item-remove"
                  {{on "click" (fn this.removeMedia index)}}
                >
                  {{ftIcon "x"}}
                </button>
              </div>
            {{/each}}
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
