import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq } from "discourse/truth-helpers";

const MAX_CHARS = 2000;

export default class FtCreatePostModal extends Component {
  @service currentUser;
  @service router;
  @service siteSettings;
  @service site;
  @service fantribeCreate;

  @tracked postTitle = "";
  @tracked postText = "";
  @tracked visibility = "public";
  @tracked isSubmitting = false;

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
      this.isSubmitting
    );
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
  async submitPost() {
    if (this.isDisabled) {
      return;
    }

    this.isSubmitting = true;

    try {
      const categoryId =
        parseInt(this.siteSettings.default_composer_category, 10) ||
        this.site.uncategorized_category_id;

      const result = await ajax("/posts", {
        type: "POST",
        data: {
          raw: this.postText,
          title: this.postTitle,
          category: categoryId,
          archetype: "regular",
        },
      });

      this.fantribeCreate.closeCreatePostModal();

      if (result?.post?.topic_slug && result?.post?.topic_id) {
        this.router.transitionTo(
          "topic.fromParamsNear",
          result.post.topic_slug,
          result.post.topic_id,
          result.post.post_number
        );
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

          {{! Media Buttons }}
          <div class="ft-modal__media-buttons">
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--photo"
            >
              {{icon "image"}}
              <span>Photo</span>
            </button>
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--video"
            >
              {{icon "video"}}
              <span>Video</span>
            </button>
            <button
              type="button"
              class="ft-modal__media-pill ft-modal__media-pill--audio"
            >
              {{icon "music"}}
              <span>Audio</span>
            </button>
          </div>

          {{! Tag Gear }}
          <div class="ft-modal__tag-gear">
            <label class="ft-modal__tag-gear-label">
              {{icon "tag"}}
              <span>Tag Gear</span>
            </label>
            <input
              type="text"
              class="ft-modal__tag-gear-input"
              placeholder="Search gear to tag..."
            />
          </div>

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
          <button type="button" class="ft-modal__schedule-toggle">
            {{icon "clock"}}
            <span>Schedule for Later</span>
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
            >Publish Now</button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
