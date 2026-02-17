import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import replaceEmoji from "discourse/helpers/replace-emoji";

export default class FantribeTribeCard extends Component {
  @service router;

  get category() {
    return this.args.category;
  }

  get coverStyle() {
    const cat = this.category;
    if (cat?.uploaded_background?.url) {
      return htmlSafe(`background-image: url(${cat.uploaded_background.url})`);
    }
    if (cat?.uploaded_logo?.url) {
      return htmlSafe(`background-image: url(${cat.uploaded_logo.url})`);
    }
    return htmlSafe(
      `background: linear-gradient(135deg, #${cat?.color || "0088cc"} 0%, #${cat?.color || "0088cc"}99 100%)`
    );
  }

  get hasCoverImage() {
    return !!(
      this.category?.uploaded_background?.url ||
      this.category?.uploaded_logo?.url
    );
  }

  get topicCount() {
    return this.category?.topic_count || 0;
  }

  get memberLabel() {
    const count = this.topicCount;
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    }
    return `${count}`;
  }

  get description() {
    return this.category?.description_text || "";
  }

  get truncatedDescription() {
    const desc = this.description;
    if (desc.length > 100) {
      return desc.slice(0, 100).trim() + "...";
    }
    return desc;
  }

  get emojiCode() {
    return `:${this.category?.emoji}:`;
  }

  get iconColorStyle() {
    return htmlSafe(`background-color: #${this.category?.color || "0088cc"}`);
  }

  get parentCategoryName() {
    return this.category?.parentCategory?.name;
  }

  get subcategoryCount() {
    return this.category?.subcategories?.length || 0;
  }

  get hasEmoji() {
    return this.category?.emoji;
  }

  get hasIcon() {
    return this.category?.icon;
  }

  get hasLogo() {
    return !!this.category?.uploaded_logo?.url;
  }

  @action
  handleCardClick() {
    if (this.category?.slug) {
      this.router.transitionTo(
        "discovery.category",
        this.category.slug,
        this.category.id
      );
    }
  }

  @action
  handleJoinClick(event) {
    event.stopPropagation();
    this.handleCardClick();
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="ft-tribe-card" {{on "click" this.handleCardClick}}>
      {{! Cover Image }}
      <div class="ft-tribe-card__cover" style={{this.coverStyle}}>
        {{#if this.hasCoverImage}}
          <div class="ft-tribe-card__cover-overlay"></div>
        {{/if}}

        {{! Category Tag }}
        {{#if this.parentCategoryName}}
          <span class="ft-tribe-card__category-badge">
            {{this.parentCategoryName}}
          </span>
        {{/if}}
      </div>

      {{! Card Content }}
      <div class="ft-tribe-card__body">
        <div class="ft-tribe-card__info">
          <div class="ft-tribe-card__icon">
            {{#if this.hasLogo}}
              <img
                src={{@category.uploaded_logo.url}}
                alt={{@category.name}}
                class="ft-tribe-card__icon-img"
              />
            {{else if this.hasEmoji}}
              <span class="ft-tribe-card__icon-emoji">
                {{replaceEmoji this.emojiCode}}
              </span>
            {{else if this.hasIcon}}
              <span class="ft-tribe-card__icon-fa">
                {{icon @category.icon}}
              </span>
            {{else}}
              <span
                class="ft-tribe-card__icon-dot"
                style={{this.iconColorStyle}}
              ></span>
            {{/if}}
          </div>

          <div class="ft-tribe-card__details">
            <div class="ft-tribe-card__name-row">
              <h3 class="ft-tribe-card__name">{{@category.name}}</h3>
            </div>
            <div class="ft-tribe-card__meta">
              <span class="ft-tribe-card__meta-item">
                {{icon "globe"}}
                <span>Public</span>
              </span>
              <span class="ft-tribe-card__meta-sep">&bull;</span>
              <span class="ft-tribe-card__meta-item">
                {{icon "users"}}
                <span>{{this.memberLabel}} topics</span>
              </span>
            </div>
          </div>
        </div>

        {{! Description }}
        {{#if this.truncatedDescription}}
          <p
            class="ft-tribe-card__description"
          >{{this.truncatedDescription}}</p>
        {{/if}}

        {{! Activity }}
        <div class="ft-tribe-card__activity">
          <div class="ft-tribe-card__activity-dots">
            <div class="ft-tribe-card__dot ft-tribe-card__dot--1"></div>
            <div class="ft-tribe-card__dot ft-tribe-card__dot--2"></div>
            <div class="ft-tribe-card__dot ft-tribe-card__dot--3"></div>
          </div>
          <span class="ft-tribe-card__activity-text">
            {{this.topicCount}}
            topics
          </span>
        </div>

        {{! Enter Button }}
        <button
          type="button"
          class="ft-tribe-card__join-btn"
          {{on "click" this.handleJoinClick}}
        >
          Enter Tribe
        </button>
      </div>
    </div>
  </template>
}
