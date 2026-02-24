import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { getUploadMarkdown } from "discourse/lib/uploads";
import { eq } from "discourse/truth-helpers";
import ftIcon from "../helpers/ft-icon";

const MAX_CHARS = 2000;

export default class FtCreatePostModal extends Component {
  @service currentUser;
  @service router;
  @service siteSettings;
  @service site;
  @service fantribeCreate;
  @service fantribeMembership;
  @service fantribeFeedState;

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

  // Returns the first letter of a category name for use as a letter-avatar
  // fallback when the tribe has no uploaded logo.
  tribeLetter(category) {
    return (category?.name || "?").charAt(0).toUpperCase();
  }

  get selectedTribeLabel() {
    return this.localCategory?.name || "General";
  }

  get selectedTribeLogo() {
    return (
      this.localCategory?.uploaded_logo_url ||
      this.localCategory?.uploaded_logo?.url ||
      null
    );
  }

  get selectedTribeDotStyle() {
    if (this.localCategory) {
      return htmlSafe(
        `background-color: #${this.localCategory.color || "0088cc"}`
      );
    }
    return htmlSafe("background-color: #9ca3af");
  }

  tribeLogo(category) {
    return category?.uploaded_logo_url || category?.uploaded_logo?.url || null;
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

      if (result?.post?.topic_id) {
        // Construct a topic-shaped object from the API response so the new
        // post appears at the top of the feed instantly — no navigation needed.
        const newTopic = {
          id: result.post.topic_id,
          slug: result.post.topic_slug,
          title: result.post.topic_title || this.postTitle,
          excerpt: result.post.excerpt || this.postText.substring(0, 280),
          excerpt_truncated: !result.post.excerpt && this.postText.length > 280,
          created_at: result.post.created_at || new Date().toISOString(),
          creator: this.currentUser,
          posters: [{ extras: "latest", user: this.currentUser }],
          category_id: categoryId,
          like_count: 0,
          op_like_count: 0,
          op_liked: false,
          op_can_like: false,
          views: 0,
          posts_count: 1,
          first_post_id: result.post.id,
          image_url: null,
          image_urls: [],
        };
        this.fantribeFeedState.prependTopic(newTopic);
      }

      this.fantribeCreate.closeCreatePostModal();
      // Refresh the route model so the new post appears in the real topic list.
      // Fire-and-forget — the pending topic above shows instantly while this loads.
      this.router.refresh();
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
            {{ftIcon "x"}}
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

        {{! Tribe selector — full-width inline expand }}
        {{#if this.hasTribeOptions}}
          <div class="ft-modal__tribe-section">
            <label class="ft-modal__tribe-section-label">Posting to</label>
            <div class="ft-modal__tribe-select-wrap">
              <button
                type="button"
                class="ft-modal__tribe-select-trigger
                  {{if
                    this.isTribeDropdownOpen
                    'ft-modal__tribe-select-trigger--open'
                  }}"
                {{on "click" this.toggleTribeDropdown}}
              >
                {{! Trigger: logo img → letter avatar → globe icon (for General) }}
                {{#if this.localCategory}}
                  {{#if this.selectedTribeLogo}}
                    <img
                      src={{this.selectedTribeLogo}}
                      class="ft-modal__tribe-logo ft-modal__tribe-logo--trigger"
                      alt=""
                    />
                  {{else}}
                    <span
                      class="ft-modal__tribe-letter-avatar"
                      style={{this.selectedTribeDotStyle}}
                    >{{this.tribeLetter this.localCategory}}</span>
                  {{/if}}
                {{else}}
                  <span class="ft-modal__tribe-select-option-icon">
                    {{ftIcon "globe"}}
                  </span>
                {{/if}}
                <span
                  class="ft-modal__tribe-select-value"
                >{{this.selectedTribeLabel}}</span>
                <span class="ft-modal__tribe-select-chevron">
                  {{ftIcon "chevron-down"}}
                </span>
              </button>

              {{#if this.isTribeDropdownOpen}}
                <div class="ft-modal__tribe-select-options">
                  <button
                    type="button"
                    class="ft-modal__tribe-select-option
                      {{unless
                        this.localCategory
                        'ft-modal__tribe-select-option--active'
                      }}"
                    {{on "click" (fn this.selectTribeFromDropdown null)}}
                  >
                    <span class="ft-modal__tribe-select-option-icon">
                      {{ftIcon "globe"}}
                    </span>
                    <span
                      class="ft-modal__tribe-select-option-name"
                    >General</span>
                    {{#unless this.localCategory}}
                      <span class="ft-modal__tribe-select-check">
                        {{ftIcon "check"}}
                      </span>
                    {{/unless}}
                  </button>
                  {{#each this.joinedTribes as |tribe|}}
                    <button
                      type="button"
                      class="ft-modal__tribe-select-option
                        {{if
                          (eq this.localCategory.id tribe.id)
                          'ft-modal__tribe-select-option--active'
                        }}"
                      {{on "click" (fn this.selectTribeFromDropdown tribe)}}
                    >
                      {{! Option: logo img → letter avatar }}
                      {{#if (this.tribeLogo tribe)}}
                        <img
                          src={{this.tribeLogo tribe}}
                          class="ft-modal__tribe-logo ft-modal__tribe-logo--option"
                          alt=""
                        />
                      {{else}}
                        <span
                          class="ft-modal__tribe-letter-avatar ft-modal__tribe-letter-avatar--option"
                          style={{this.tribeDotStyle tribe}}
                        >{{this.tribeLetter tribe}}</span>
                      {{/if}}
                      <span
                        class="ft-modal__tribe-select-option-name"
                      >{{tribe.name}}</span>
                      {{#if (eq this.localCategory.id tribe.id)}}
                        <span class="ft-modal__tribe-select-check">
                          {{ftIcon "check"}}
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
              {{ftIcon "image"}}
              <span>Photo</span>
            </button>
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--video"
              disabled={{this.isUploading}}
              {{on "click" (fn this.triggerFileInput "video")}}
            >
              {{ftIcon "video"}}
              <span>Video</span>
            </button>
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--audio"
              disabled={{this.isUploading}}
              {{on "click" (fn this.triggerFileInput "audio")}}
            >
              {{ftIcon "music"}}
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
                      {{ftIcon "image"}}
                    {{else if (eq media.type "video")}}
                      {{ftIcon "video"}}
                    {{else}}
                      {{ftIcon "music"}}
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
                    {{ftIcon "x"}}
                  </button>
                </div>
              {{/each}}
            </div>
          {{/if}}
        </div>

        {{! Footer }}
        <div class="ft-modal__footer">
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
                {{ftIcon "calendar"}}
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
