import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import { getUploadMarkdown } from "discourse/lib/uploads";
import { eq } from "discourse/truth-helpers";
import ftIcon from "../helpers/ft-icon";
import FantribePostMoreTopics from "./fantribe-post-more-topics";

const MAX_TAGS = 3;
// Matches Discourse upload markdown: ![filename|WxH](upload://hash.ext) or [filename|attachment](upload://hash.ext)
const UPLOAD_MD_RE = /!?\[[^\]]*\]\(upload:\/\/[^)]+\)/g;

export default class FantribePostEditPage extends Component {
  @service fantribeCreate;
  @service fantribeFeedState;
  @service router;
  @service site;
  @service toasts;

  @tracked postTitle = "";
  @tracked postText = "";
  @tracked selectedTags = [];
  @tracked tagInput = "";
  @tracked currentImageIndex = 0;
  @tracked isSubmitting = false;
  @tracked uploadedMedia = [];
  @tracked isUploading = false;
  @tracked _removedImageIndices = [];

  constructor(owner, args) {
    super(owner, args);
    document.body.classList.add("ft-full-post-active");
    this.postTitle = this.fantribeCreate.editingTopicTitle || "";
    this.postText = this._stripImageMarkdown(
      this.fantribeCreate.editingPost?.raw || ""
    );
    this.selectedTags = [...(this.fantribeCreate.editingTags || [])];
  }

  willDestroy() {
    super.willDestroy();
    document.body.classList.remove("ft-full-post-active");
  }

  // Strip Discourse upload markdown so the textarea shows only text content
  _stripImageMarkdown(raw) {
    return raw
      .replace(UPLOAD_MD_RE, "")
      .replace(/\n{3,}/g, "\n\n")
      .trim();
  }

  // ── Topic / Post getters ─────────────────────────────────────────────────

  get topic() {
    return this.args.topic;
  }

  get firstPost() {
    return this.topic?.postStream?.posts?.[0];
  }

  get poster() {
    return this.firstPost?.user || this.topic?.posters?.[0]?.user;
  }

  get displayName() {
    return (
      this.poster?.name ||
      this.poster?.username ||
      i18n("fantribe.common.unknown")
    );
  }

  get posterUsername() {
    return this.poster?.username || "unknown";
  }

  get posterRoleName() {
    return this.poster?.primary_group_name || null;
  }

  get tribeCategory() {
    const catId =
      this.topic?.category_id ||
      this.topic?.categoryId ||
      this.topic?.get?.("category_id");
    if (!catId) {
      return null;
    }
    return (this.site.categories || []).find((c) => c.id === catId) || null;
  }

  // ── Image carousel ────────────────────────────────────────────────────────

  get allImages() {
    const cooked = this.firstPost?.cooked;
    if (cooked) {
      const parser = new DOMParser();
      const doc = parser.parseFromString(cooked, "text/html");
      const lightboxLinks = doc.querySelectorAll("a.lightbox");
      if (lightboxLinks.length > 0) {
        return Array.from(lightboxLinks)
          .map((a, i) => ({ url: a.getAttribute("href"), originalIndex: i }))
          .filter((img) => img.url && !img.url.includes("emoji"));
      }
      const imgs = doc.querySelectorAll(
        "img[src]:not(.emoji):not(.avatar):not(.site-icon)"
      );
      return Array.from(imgs)
        .map((img, i) => ({ url: img.getAttribute("src"), originalIndex: i }))
        .filter((img) => img.url);
    }
    const url = this.topic?.image_url;
    return url ? [{ url, originalIndex: 0 }] : [];
  }

  get images() {
    const original = this.allImages.filter(
      (img) => !this._removedImageIndices.includes(img.originalIndex)
    );
    const newImages = this.uploadedMedia
      .filter((m) => m.type === "image")
      .map((m, i) => ({
        url: m.url,
        isNew: true,
        newIndex: i,
        uploadMarkdown: m.uploadMarkdown,
      }));
    return [...newImages, ...original];
  }

  get currentImage() {
    return this.images[this.currentImageIndex] || null;
  }

  get hasImages() {
    return this.images.length > 0;
  }

  get hasMultipleImages() {
    return this.images.length > 1;
  }

  get imageIndicator() {
    return `${this.currentImageIndex + 1}/${this.images.length}`;
  }

  get hasPrevImage() {
    return this.currentImageIndex > 0;
  }

  get hasNextImage() {
    return this.currentImageIndex < this.images.length - 1;
  }

  get carouselBgStyle() {
    const url = this.currentImage?.url;
    if (!url) {
      return htmlSafe("");
    }
    return htmlSafe(`background-image: url('${url}')`);
  }

  // ── Tags ─────────────────────────────────────────────────────────────────

  get canAddTag() {
    return this.selectedTags.length < MAX_TAGS;
  }

  // ── Uploads ───────────────────────────────────────────────────────────────

  get hasNonImageUploadedMedia() {
    return this.uploadedMedia.some((m) => m.type !== "image");
  }

  get nonImageUploadedMedia() {
    return this.uploadedMedia.filter((m) => m.type !== "image");
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  @action
  prevImage() {
    if (this.currentImageIndex > 0) {
      this.currentImageIndex--;
    }
  }

  @action
  nextImage() {
    if (this.currentImageIndex < this.images.length - 1) {
      this.currentImageIndex++;
    }
  }

  @action
  removeCurrentImage() {
    const current = this.images[this.currentImageIndex];
    if (!current) {
      return;
    }
    if (current.isNew) {
      this.removeMediaByMarkdown(current.uploadMarkdown);
    } else {
      this._removedImageIndices = [
        ...this._removedImageIndices,
        current.originalIndex,
      ];
    }
    if (this.currentImageIndex >= this.images.length) {
      this.currentImageIndex = Math.max(0, this.images.length - 1);
    }
  }

  @action
  updateTitle(event) {
    this.postTitle = event.target.value;
  }

  @action
  updateText(event) {
    this.postText = event.target.value;
    event.target.style.height = "auto";
    event.target.style.height = `${event.target.scrollHeight}px`;
  }

  @action
  updateTagInput(event) {
    this.tagInput = event.target.value;
  }

  @action
  handleTagKeydown(event) {
    if ((event.key === "Enter" || event.key === ",") && this.tagInput.trim()) {
      event.preventDefault();
      this.commitTag();
    } else if (event.key === "Backspace" && !this.tagInput) {
      this.selectedTags = this.selectedTags.slice(0, -1);
    }
  }

  @action
  commitTag() {
    const raw = this.tagInput.trim().replace(/,/g, "").replace(/\s+/g, "-");
    const tag = raw.toLowerCase();
    if (tag && this.canAddTag && !this.selectedTags.includes(tag)) {
      this.selectedTags = [...this.selectedTags, tag];
    }
    this.tagInput = "";
  }

  @action
  removeTag(tag) {
    this.selectedTags = this.selectedTags.filter((t) => t !== tag);
  }

  @action
  triggerFileInput(type) {
    const input = document.querySelector(`.ft-post-edit__file-input--${type}`);
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
          {
            type,
            name: file.name,
            uploadMarkdown,
            url: upload.url || upload.short_url,
          },
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
  removeMediaByMarkdown(uploadMarkdown) {
    this.uploadedMedia = this.uploadedMedia.filter(
      (m) => m.uploadMarkdown !== uploadMarkdown
    );
  }

  @action
  cancel() {
    this.fantribeCreate.closeCreatePostModal();
  }

  @action
  async save() {
    const editingPost = this.fantribeCreate.editingPost;
    const topicId = this.topic?.id;
    if (!editingPost || !topicId || this.isSubmitting) {
      return;
    }
    this.isSubmitting = true;
    try {
      // Reconstruct raw: user-edited text + original upload markdown (minus
      // any images the user explicitly removed via the trash button).
      // This preserves all image attachments that weren't deliberately deleted.
      const allUploads = (editingPost.raw || "").match(UPLOAD_MD_RE) || [];
      const remainingUploads = allUploads.filter(
        (_, i) => !this._removedImageIndices.includes(i)
      );

      const newMediaMarkdown = this.uploadedMedia.map((m) => m.uploadMarkdown);
      const allUploadMarkdown = [...newMediaMarkdown, ...remainingUploads];

      const rawToSave = allUploadMarkdown.length
        ? `${this.postText}\n\n${allUploadMarkdown.join("\n")}`.trim()
        : this.postText;

      const response = await ajax(`/posts/${editingPost.id}.json`, {
        type: "PUT",
        data: {
          post: { raw: rawToSave },
          title: this.postTitle ? this.postTitle.trim() : "",
        },
      });

      if (response && response.post && this.firstPost) {
        if (typeof this.firstPost.setProperties === "function") {
          this.firstPost.setProperties({
            raw: response.post.raw,
            cooked: response.post.cooked,
          });
        } else {
          try {
            this.firstPost.raw = response.post.raw;
            this.firstPost.cooked = response.post.cooked;
          } catch {
            // Ignored, might be a frozen object in some Ember strict modes
          }
        }
      }

      // Use the standard topic update endpoint for tags.
      // Discourse expects an array of tags (or an empty array `[]` to clear them).
      await ajax(`/t/${topicId}.json`, {
        type: "PUT",
        data: { tags: this.selectedTags || [] },
      });

      if (response?.post?.image_url && this.topic) {
        if (typeof this.topic.setProperties === "function") {
          this.topic.setProperties({
            image_url: response.post.image_url,
          });
        }
      }

      this.fantribeFeedState?.updateTopic?.(topicId, {
        title: this.postTitle,
        tags: this.selectedTags,
        image_url: response?.post?.image_url,
      });
      this.fantribeCreate.closeCreatePostModal();
      this.router.refresh();
      this.toasts.success({
        data: { message: i18n("fantribe.post_edit.updated_successfully") },
      });
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="ft-full-post-layout ft-full-post-layout--edit">
      <div class="ft-full-post-layout__content">
        <div class="ft-full-post ft-full-post--edit">
          <div class="ft-full-post__card">

            {{! ===== HEADER ===== }}
            <div class="ft-full-post__header">
              <div class="ft-full-post__header-left">
                <button
                  type="button"
                  class="ft-full-post__back-btn"
                  {{on "click" this.cancel}}
                >
                  {{ftIcon "chevron-left"}}
                </button>

                <div class="ft-full-post__author-block">
                  <div class="ft-full-post__avatar-wrapper">
                    {{#if this.poster}}
                      {{avatar this.poster imageSize="medium"}}
                    {{/if}}
                  </div>
                  <div class="ft-full-post__author-meta">
                    <span
                      class="ft-full-post__author-name"
                    >{{this.displayName}}</span>
                    <div class="ft-full-post__author-info">
                      <span
                        class="ft-full-post__author-handle"
                      >@{{this.posterUsername}}</span>
                      <span class="ft-full-post__separator">&middot;</span>
                      <span class="ft-full-post__timestamp">
                        {{#if this.firstPost.createdAt}}
                          {{formatDate this.firstPost.createdAt format="tiny"}}
                        {{else if this.topic.created_at}}
                          {{formatDate this.topic.created_at format="tiny"}}
                        {{/if}}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="ft-full-post__header-right">
                {{#if this.tribeCategory}}
                  <span
                    class="ft-full-post__category-pill ft-full-post__category-pill--edit"
                  >
                    {{this.tribeCategory.name}}
                  </span>
                {{/if}}
                {{#if this.posterRoleName}}
                  <span
                    class="ft-full-post__role-badge ft-full-post__role-badge--edit"
                  >{{this.posterRoleName}}</span>
                {{/if}}
                <button type="button" class="ft-post-edit__more-btn">
                  {{ftIcon "more-horizontal" size=20}}
                </button>
              </div>
            </div>

            {{! ===== EDIT CONTENT ===== }}
            <div class="ft-post-edit__content">

              {{! Title field }}
              <div
                class="ft-post-edit__field-wrap ft-post-edit__field-wrap--title"
              >
                <input
                  type="text"
                  class="ft-post-edit__title-input"
                  value={{this.postTitle}}
                  placeholder={{i18n
                    "fantribe.post_modal.post_title_placeholder"
                  }}
                  {{on "input" this.updateTitle}}
                />
              </div>

              {{! Body text field }}
              <div
                class="ft-post-edit__field-wrap ft-post-edit__field-wrap--body"
              >
                <textarea
                  class="ft-post-edit__body-input"
                  placeholder={{i18n "fantribe.post_edit.body_placeholder"}}
                  {{on "input" this.updateText}}
                >{{this.postText}}</textarea>
              </div>

              {{! Image + Tags section }}
              <div class="ft-post-edit__image-section">

                {{! Carousel }}
                {{#if this.hasImages}}
                  <div class="ft-full-post__carousel ft-post-edit__carousel">
                    {{! Blurred bg — pointer-events: none so it doesn't block nav clicks }}
                    <div
                      class="ft-post-edit__carousel-bg"
                      style={{this.carouselBgStyle}}
                    ></div>
                    <img
                      src={{this.currentImage.url}}
                      alt={{i18n "fantribe.post_full.post_image_alt"}}
                      class="ft-full-post__carousel-img ft-post-edit__carousel-img"
                    />

                    {{! Counter badge }}
                    {{#if this.hasMultipleImages}}
                      <div class="ft-full-post__img-indicator">
                        {{this.imageIndicator}}
                      </div>
                    {{/if}}

                    {{! Prev arrow — always rendered for images, hidden via CSS when at start }}
                    <button
                      type="button"
                      class={{if
                        this.hasPrevImage
                        "ft-full-post__carousel-nav ft-full-post__carousel-nav--prev"
                        "ft-full-post__carousel-nav ft-full-post__carousel-nav--prev ft-full-post__carousel-nav--hidden"
                      }}
                      {{on "click" this.prevImage}}
                    >
                      {{ftIcon "chevron-left"}}
                    </button>

                    {{! Next arrow — always rendered, hidden when at end }}
                    <button
                      type="button"
                      class={{if
                        this.hasNextImage
                        "ft-full-post__carousel-nav ft-full-post__carousel-nav--next"
                        "ft-full-post__carousel-nav ft-full-post__carousel-nav--next ft-full-post__carousel-nav--hidden"
                      }}
                      {{on "click" this.nextImage}}
                    >
                      {{ftIcon "chevron-right"}}
                    </button>

                    {{! Delete image button }}
                    <button
                      type="button"
                      class="ft-post-edit__delete-img-btn"
                      {{on "click" this.removeCurrentImage}}
                    >
                      {{ftIcon "trash2" size=20}}
                    </button>
                  </div>
                {{/if}}

                {{! Tags section }}
                <div class="ft-post-edit__tags-row">
                  <span class="ft-post-edit__tags-label">{{i18n
                      "fantribe.post_edit.tags_label"
                    }}</span>
                  <div class="ft-post-edit__tags-chips">
                    {{#each this.selectedTags as |tag|}}
                      <span class="ft-post-edit__tag-chip">
                        {{ftIcon "tag" size=14}}
                        <span>{{tag}}</span>
                        <button
                          type="button"
                          class="ft-post-edit__tag-remove"
                          {{on "click" (fn this.removeTag tag)}}
                        >&times;</button>
                      </span>
                    {{/each}}
                    {{#if this.canAddTag}}
                      <input
                        type="text"
                        class="ft-post-edit__tag-input"
                        value={{this.tagInput}}
                        placeholder={{if
                          this.selectedTags.length
                          (i18n "fantribe.post_modal.add_tag")
                          (i18n "fantribe.post_modal.add_up_to_3_tags")
                        }}
                        {{on "input" this.updateTagInput}}
                        {{on "keydown" this.handleTagKeydown}}
                        {{on "blur" this.commitTag}}
                      />
                    {{/if}}
                  </div>
                </div>

                {{! Add Media Section }}
                <div class="ft-post-edit__add-media-row">
                  <span class="ft-post-edit__add-media-label">Add media:</span>
                  <div class="ft-post-edit__media-actions">
                    <button
                      type="button"
                      class="ft-post-edit__media-btn"
                      disabled={{this.isUploading}}
                      {{on "click" (fn this.triggerFileInput "image")}}
                    >
                      {{ftIcon "image"}}
                      <span>Photo</span>
                    </button>
                    <button
                      type="button"
                      class="ft-post-edit__media-btn"
                      disabled={{this.isUploading}}
                      {{on "click" (fn this.triggerFileInput "video")}}
                    >
                      {{ftIcon "video"}}
                      <span>Video</span>
                    </button>
                    <button
                      type="button"
                      class="ft-post-edit__media-btn"
                      disabled={{this.isUploading}}
                      {{on "click" (fn this.triggerFileInput "audio")}}
                    >
                      {{ftIcon "music"}}
                      <span>Audio</span>
                    </button>
                  </div>
                </div>

                {{! Hidden file inputs }}
                <input
                  type="file"
                  class="ft-post-edit__file-input ft-post-edit__file-input--image"
                  accept="image/*"
                  multiple
                  style="display: none;"
                  {{on "change" (fn this.handleFileSelected "image")}}
                />
                <input
                  type="file"
                  class="ft-post-edit__file-input ft-post-edit__file-input--video"
                  accept="video/*"
                  multiple
                  style="display: none;"
                  {{on "change" (fn this.handleFileSelected "video")}}
                />
                <input
                  type="file"
                  class="ft-post-edit__file-input ft-post-edit__file-input--audio"
                  accept="audio/*"
                  multiple
                  style="display: none;"
                  {{on "change" (fn this.handleFileSelected "audio")}}
                />

                {{! Upload progress }}
                {{#if this.isUploading}}
                  <div class="ft-post-edit__upload-status">Uploading...</div>
                {{/if}}

                {{! Non-image uploaded media previews (video/audio) }}
                {{#if this.hasNonImageUploadedMedia}}
                  <div class="ft-post-edit__uploaded-media">
                    {{#each this.nonImageUploadedMedia as |media|}}
                      <div class="ft-post-edit__uploaded-item">
                        <span class="ft-post-edit__uploaded-item-icon">
                          {{#if (eq media.type "video")}}
                            {{ftIcon "video"}}
                          {{else}}
                            {{ftIcon "music"}}
                          {{/if}}
                        </span>
                        <span
                          class="ft-post-edit__uploaded-item-name"
                        >{{media.name}}</span>
                        <button
                          type="button"
                          class="ft-post-edit__uploaded-item-remove"
                          {{on
                            "click"
                            (fn this.removeMediaByMarkdown media.uploadMarkdown)
                          }}
                        >
                          {{ftIcon "x"}}
                        </button>
                      </div>
                    {{/each}}
                  </div>
                {{/if}}

              </div>
            </div>

            {{! ===== FOOTER ===== }}
            <div class="ft-post-edit__footer">
              <button
                type="button"
                class="ft-post-edit__cancel-btn"
                {{on "click" this.cancel}}
              >
                {{i18n "fantribe.common.cancel"}}
              </button>
              <button
                type="button"
                class="ft-post-edit__save-btn"
                disabled={{this.isSubmitting}}
                {{on "click" this.save}}
              >
                {{if
                  this.isSubmitting
                  (i18n "fantribe.common.saving")
                  (i18n "fantribe.common.save")
                }}
              </button>
            </div>

          </div>
        </div>
      </div>

      <div class="ft-full-post-layout__sidebar">
        <FantribePostMoreTopics @topic={{this.topic}} />
      </div>
    </div>
  </template>
}
