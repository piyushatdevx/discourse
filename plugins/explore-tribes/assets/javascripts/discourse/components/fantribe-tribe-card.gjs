import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ftIcon from "discourse/plugins/fantribe-theme/discourse/helpers/ft-icon";

export default class FantribeTribeCard extends Component {
  @service router;
  @service currentUser;
  @service fantribeMembership;

  @tracked isJoining = false;

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

  get memberCount() {
    const count = this.category?.member_count;
    if (count == null) {
      return null;
    }
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

  get hasEmoji() {
    return this.category?.emoji;
  }

  get hasIcon() {
    return this.category?.icon;
  }

  get hasLogo() {
    return !!this.category?.uploaded_logo?.url;
  }

  get isMember() {
    return this.fantribeMembership.isMember(this.category?.id);
  }

  get isPrivate() {
    return this.category?.read_restricted;
  }

  @action
  handleCardClick() {
    const cat = this.category;
    if (cat?.slug && cat?.id) {
      this.router.transitionTo("discovery.category", `${cat.slug}/${cat.id}`);
    }
  }

  @action
  async handleJoinClick(event) {
    event.stopPropagation();

    if (!this.currentUser) {
      this.router.transitionTo("login");
      return;
    }

    if (this.isJoining) {
      return;
    }

    const categoryId = this.category?.id;
    if (!categoryId) {
      return;
    }

    const currentlyMember = this.isMember;
    const newLevel = currentlyMember
      ? this.fantribeMembership.regularLevel
      : this.fantribeMembership.watchingLevel;

    this.isJoining = true;
    this.fantribeMembership.setLevel(categoryId, newLevel);

    try {
      await ajax(`/category/${categoryId}/notifications`, {
        type: "POST",
        data: { notification_level: newLevel },
      });
    } catch (error) {
      this.fantribeMembership.setLevel(
        categoryId,
        currentlyMember
          ? this.fantribeMembership.watchingLevel
          : this.fantribeMembership.regularLevel
      );
      popupAjaxError(error);
    } finally {
      this.isJoining = false;
    }
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
                {{#if this.isPrivate}}
                  {{ftIcon "lock"}}
                  <span>Private</span>
                {{else}}
                  {{ftIcon "globe"}}
                  <span>Public</span>
                {{/if}}
              </span>
              <span class="ft-tribe-card__meta-sep">&bull;</span>
              <span class="ft-tribe-card__meta-item">
                {{ftIcon "users"}}
                <span>{{if this.memberCount this.memberCount "–"}}</span>
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

        {{! Activity dots }}
        <div class="ft-tribe-card__activity">
          <div class="ft-tribe-card__activity-dots">
            <div class="ft-tribe-card__dot ft-tribe-card__dot--1"></div>
            <div class="ft-tribe-card__dot ft-tribe-card__dot--2"></div>
            <div class="ft-tribe-card__dot ft-tribe-card__dot--3"></div>
          </div>
          <span class="ft-tribe-card__activity-text">
            {{@category.topic_count}}
            active today
          </span>
        </div>

        {{! Join / Joined button }}
        <button
          type="button"
          class="ft-tribe-card__join-btn
            {{if this.isMember 'ft-tribe-card__join-btn--joined'}}
            {{if this.isJoining 'ft-tribe-card__join-btn--loading'}}"
          disabled={{this.isJoining}}
          {{on "click" this.handleJoinClick}}
        >
          {{#if this.isJoining}}
            {{ftIcon "circle"}}
          {{else if this.isMember}}
            {{ftIcon "check-circle"}}
            <span>Joined</span>
          {{else}}
            {{ftIcon "user-plus"}}
            <span>Join Tribe</span>
          {{/if}}
        </button>
      </div>
    </div>
  </template>
}
