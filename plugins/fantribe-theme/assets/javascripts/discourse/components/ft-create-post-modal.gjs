import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { getUploadMarkdown } from "discourse/lib/uploads";
import { eq } from "discourse/truth-helpers";

const MAX_CHARS = 2000;

export default class FtCreatePostModal extends Component {
  @service currentUser;
  @service siteSettings;
  @service site;
  @service fantribeCreate;
  @service fantribeMembership;

  @tracked postTitle = "";
  @tracked postText = "";
  @tracked visibility = "public";
  @tracked isSubmitting = false;
  @tracked uploadedMedia = [];
  @tracked showScheduler = false;
  @tracked scheduledDate = "";
  @tracked scheduledTime = "";
  @tracked isUploading = false;
  @tracked isTribeDropdownOpen = false;
  @tracked _localCategory = undefined;

  get localCategory() {
    return this._localCategory !== undefined
      ? this._localCategory
      : this.fantribeCreate.postCategory;
  }

  get joinedTribes() {
    if (!this.currentUser) {
      return [];
    }
    return (this.site.categories || [])
      .filter(
        (cat) =>
          !cat.isUncategorizedCategory &&
          this.fantribeMembership.isMember(cat.id)
      )
      .slice(0, 8);
  }

  get hasTribeOptions() {
    return this.joinedTribes.length > 0;
  }

  tribeDotStyle(category) {
    return htmlSafe(`background-color: #${category.color || "0088cc"}`);
  }

  get selectedTribeLabel() {
    return this.localCategory?.name || "General";
  }

  get selectedTribeDotStyle() {
    if (this.localCategory) {
      return htmlSafe(
        `background-color: #${this.localCategory.color || "0088cc"}`
      );
    }
    return htmlSafe("background-color: #9ca3af");
  }

  get charCount() {
    return this.postText.length;
  }

  get isOverLimit() {
    return this.charCount > MAX_CHARS;
  }

  get isDisabled() {
    return (
      !this.postTitle.trim() ||
      !this.postText.trim() ||
      this.isOverLimit ||
      this.isSubmitting ||
      this.isUploading
    );
  }

  get hasUploadedMedia() {
    return this.uploadedMedia.length > 0;
  }

  @action
  selectTribe(category) {
    this._localCategory = category;
  }

  @action
  toggleTribeDropdown() {
    this.isTribeDropdownOpen = !this.isTribeDropdownOpen;
  }

  @action
  selectTribeFromDropdown(category) {
    this._localCategory = category;
    this.isTribeDropdownOpen = false;
  }

  @action
  closeTribeDropdown() {
    this.isTribeDropdownOpen = false;
  }

  @action
  updateTitle(event) {
    this.postTitle = event.target.value;
  }

  @action
  updateText(event) {
    this.postText = event.target.value;
  }

  @action
  setVisibility(value) {
    this.visibility = value;
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.fantribeCreate.closeCreatePostModal();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.fantribeCreate.closeCreatePostModal();
    }
  }

  @action
  triggerFileInput(type) {
    const input = document.querySelector(`.ft-modal__file-input--${type}`);
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
    this.uploadedMedia = this.uploadedMedia.filter((_, i) => i !== index);
  }

  @action
  toggleScheduler() {
    this.showScheduler = !this.showScheduler;
    if (!this.showScheduler) {
      this.scheduledDate = "";
      this.scheduledTime = "";
    }
  }

  @action
  updateScheduledDate(event) {
    this.scheduledDate = event.target.value;
  }

  @action
  updateScheduledTime(event) {
    this.scheduledTime = event.target.value;
  }

  @action
  async submitPost() {
    if (this.isDisabled) {
      return;
    }

    this.isSubmitting = true;

    try {
      const categoryId =
        this.localCategory?.id ||
        parseInt(this.siteSettings.default_composer_category, 10) ||
        this.site.uncategorized_category_id;

      const mediaParts = this.uploadedMedia.map((m) => m.uploadMarkdown);
      const rawParts = [...mediaParts, this.postText];
      const raw = rawParts.join("\n\n");

      const result = await ajax("/posts", {
        type: "POST",
        data: {
          raw,
          title: this.postTitle,
          category: categoryId,
          archetype: "regular",
        },
      });

      this.fantribeCreate.closeCreatePostModal();

      if (result?.post?.topic_id) {
        // Hard-navigate so the browser fully reloads the feed when the user
        // presses back, ensuring the new post appears without a manual refresh.
        const slug = result.post.topic_slug || String(result.post.topic_id);
        const postNum = result.post.post_number || 1;
        window.location.href = `/t/${slug}/${result.post.topic_id}/${postNum}`;
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmitting = false;
    }
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
      <div class="ft-modal">
        {{! Title Bar }}
        <div class="ft-modal__title-bar">
          <h2 class="ft-modal__title">Create Post</h2>
          <button
            type="button"
            class="ft-modal__close-btn"
            {{on "click" this.fantribeCreate.closeCreatePostModal}}
          >
            {{icon "xmark"}}
          </button>
        </div>

        {{! User Info }}
        <div class="ft-modal__user-info">
          {{#if this.currentUser}}
            <div class="ft-modal__avatar">
              {{avatar this.currentUser imageSize="medium"}}
            </div>
          {{/if}}
          <div>
            <div class="ft-modal__user-name">{{this.currentUser.name}}</div>
            <div
              class="ft-modal__user-handle"
            >@{{this.currentUser.username}}</div>
          </div>
        </div>

        {{! Tribe selector dropdown }}
        {{#if this.hasTribeOptions}}
          <div class="ft-modal__tribe-dropdown-wrap">
            <span class="ft-modal__tribe-dropdown-label">
              {{icon "paper-plane"}}
              <span>Posting to</span>
            </span>
            <div class="ft-modal__tribe-dropdown">
              <button
                type="button"
                class="ft-modal__tribe-dropdown-trigger
                  {{if
                    this.isTribeDropdownOpen
                    'ft-modal__tribe-dropdown-trigger--open'
                  }}"
                {{on "click" this.toggleTribeDropdown}}
              >
                <span
                  class="ft-modal__tribe-dropdown-dot"
                  style={{this.selectedTribeDotStyle}}
                ></span>
                <span
                  class="ft-modal__tribe-dropdown-value"
                >{{this.selectedTribeLabel}}</span>
                <span class="ft-modal__tribe-dropdown-chevron">
                  {{icon "chevron-down"}}
                </span>
              </button>

              {{#if this.isTribeDropdownOpen}}
                {{! template-lint-disable no-invalid-interactive }}
                <div
                  class="ft-modal__tribe-dropdown-backdrop"
                  {{on "click" this.closeTribeDropdown}}
                ></div>
                <div class="ft-modal__tribe-dropdown-menu">
                  <button
                    type="button"
                    class="ft-modal__tribe-dropdown-item
                      {{unless
                        this.localCategory
                        'ft-modal__tribe-dropdown-item--active'
                      }}"
                    {{on "click" (fn this.selectTribeFromDropdown null)}}
                  >
                    <span class="ft-modal__tribe-dropdown-item-icon">
                      {{icon "globe"}}
                    </span>
                    <span
                      class="ft-modal__tribe-dropdown-item-name"
                    >General</span>
                    {{#unless this.localCategory}}
                      <span class="ft-modal__tribe-dropdown-item-check">
                        {{icon "check"}}
                      </span>
                    {{/unless}}
                  </button>
                  {{#each this.joinedTribes as |tribe|}}
                    <button
                      type="button"
                      class="ft-modal__tribe-dropdown-item
                        {{if
                          (eq this.localCategory.id tribe.id)
                          'ft-modal__tribe-dropdown-item--active'
                        }}"
                      {{on "click" (fn this.selectTribeFromDropdown tribe)}}
                    >
                      <span
                        class="ft-modal__tribe-dropdown-item-dot"
                        style={{this.tribeDotStyle tribe}}
                      ></span>
                      <span
                        class="ft-modal__tribe-dropdown-item-name"
                      >{{tribe.name}}</span>
                      {{#if (eq this.localCategory.id tribe.id)}}
                        <span class="ft-modal__tribe-dropdown-item-check">
                          {{icon "check"}}
                        </span>
                      {{/if}}
                    </button>
                  {{/each}}
                </div>
              {{/if}}
            </div>
          </div>
        {{/if}}

        {{! Body }}
        <div class="ft-modal__body">
          <input
            type="text"
            class="ft-modal__title-input"
            placeholder="Post title..."
            value={{this.postTitle}}
            {{on "input" this.updateTitle}}
          />
          <textarea
            class="ft-modal__textarea"
            placeholder="What's on your mind? Share your music, updates, and vibes..."
            value={{this.postText}}
            {{on "input" this.updateText}}
          ></textarea>
          <div
            class="ft-modal__char-count
              {{if this.isOverLimit 'ft-modal__char-count--over'}}"
          >
            {{this.charCount}}/{{MAX_CHARS}}
          </div>

          {{! Hidden file inputs }}
          <input
            type="file"
            class="ft-modal__file-input ft-modal__file-input--image"
            accept="image/*"
            multiple
            {{on "change" (fn this.handleFileSelected "image")}}
          />
          <input
            type="file"
            class="ft-modal__file-input ft-modal__file-input--video"
            accept="video/*"
            multiple
            {{on "change" (fn this.handleFileSelected "video")}}
          />
          <input
            type="file"
            class="ft-modal__file-input ft-modal__file-input--audio"
            accept="audio/*"
            multiple
            {{on "change" (fn this.handleFileSelected "audio")}}
          />

          {{! Media Buttons }}
          <div class="ft-modal__media-buttons">
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--photo"
              disabled={{this.isUploading}}
              {{on "click" (fn this.triggerFileInput "image")}}
            >
              {{icon "image"}}
              <span>Photo</span>
            </button>
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--video"
              disabled={{this.isUploading}}
              {{on "click" (fn this.triggerFileInput "video")}}
            >
              {{icon "video"}}
              <span>Video</span>
            </button>
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--audio"
              disabled={{this.isUploading}}
              {{on "click" (fn this.triggerFileInput "audio")}}
            >
              {{icon "music"}}
              <span>Audio</span>
            </button>
          </div>

          {{! Upload progress }}
          {{#if this.isUploading}}
            <div class="ft-modal__upload-status">Uploading...</div>
          {{/if}}

          {{! Uploaded Media Previews }}
          {{#if this.hasUploadedMedia}}
            <div class="ft-modal__uploaded-media">
              {{#each this.uploadedMedia as |media index|}}
                <div class="ft-modal__uploaded-item">
                  <span class="ft-modal__uploaded-item-icon">
                    {{#if (eq media.type "image")}}
                      {{icon "image"}}
                    {{else if (eq media.type "video")}}
                      {{icon "video"}}
                    {{else}}
                      {{icon "music"}}
                    {{/if}}
                  </span>
                  <span
                    class="ft-modal__uploaded-item-name"
                  >{{media.name}}</span>
                  <button
                    type="button"
                    class="ft-modal__uploaded-item-remove"
                    {{on "click" (fn this.removeMedia index)}}
                  >
                    {{icon "xmark"}}
                  </button>
                </div>
              {{/each}}
            </div>
          {{/if}}

          {{! Schedule Panel }}
          {{#if this.showScheduler}}
            <div class="ft-modal__schedule-panel">
              <div class="ft-modal__schedule-panel-header">
                {{icon "calendar"}}
                <span>Schedule Post</span>
              </div>
              <div class="ft-modal__schedule-grid">
                <div class="ft-modal__schedule-field">
                  <label class="ft-modal__schedule-label">Date</label>
                  <input
                    type="date"
                    class="ft-modal__schedule-input"
                    value={{this.scheduledDate}}
                    {{on "input" this.updateScheduledDate}}
                  />
                </div>
                <div class="ft-modal__schedule-field">
                  <label class="ft-modal__schedule-label">Time</label>
                  <input
                    type="time"
                    class="ft-modal__schedule-input"
                    value={{this.scheduledTime}}
                    {{on "input" this.updateScheduledTime}}
                  />
                </div>
              </div>
            </div>
          {{/if}}

          {{! Visibility }}
          <div class="ft-modal__visibility-section">
            <span class="ft-modal__section-label">Who can see this?</span>
            <div class="ft-modal__visibility-grid">
              <button
                type="button"
                class="ft-modal__visibility-card
                  {{if
                    (eq this.visibility 'public')
                    'ft-modal__visibility-card--selected'
                  }}"
                {{on "click" (fn this.setVisibility "public")}}
              >
                {{icon "globe"}}
                <span>Public</span>
              </button>
              <button
                type="button"
                class="ft-modal__visibility-card
                  {{if
                    (eq this.visibility 'followers')
                    'ft-modal__visibility-card--selected'
                  }}"
                {{on "click" (fn this.setVisibility "followers")}}
              >
                {{icon "users"}}
                <span>Followers</span>
              </button>
              <button
                type="button"
                class="ft-modal__visibility-card
                  {{if
                    (eq this.visibility 'private')
                    'ft-modal__visibility-card--selected'
                  }}"
                {{on "click" (fn this.setVisibility "private")}}
              >
                {{icon "lock"}}
                <span>Private</span>
              </button>
            </div>
          </div>
        </div>

        {{! Footer }}
        <div class="ft-modal__footer">
          <button
            type="button"
            class="ft-modal__schedule-toggle
              {{if this.showScheduler 'ft-modal__schedule-toggle--active'}}"
            {{on "click" this.toggleScheduler}}
          >
            {{icon "clock"}}
            <span>{{if
                this.showScheduler
                "Cancel Schedule"
                "Schedule for Later"
              }}</span>
          </button>
          <div class="ft-modal__action-buttons">
            <button
              type="button"
              class="ft-modal__cancel-btn"
              {{on "click" this.fantribeCreate.closeCreatePostModal}}
            >Cancel</button>
            <button
              type="button"
              class="ft-modal__publish-btn
                {{if this.isDisabled 'ft-modal__publish-btn--disabled'}}"
              disabled={{this.isDisabled}}
              {{on "click" this.submitPost}}
            >
              {{#if this.showScheduler}}
                {{icon "calendar"}}
                Schedule Post
              {{else}}
                Publish Now
              {{/if}}
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
