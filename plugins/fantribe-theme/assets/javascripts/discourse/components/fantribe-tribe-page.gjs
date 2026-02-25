import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ftIcon from "../helpers/ft-icon";
import FantribeFeedCard from "./fantribe-feed-card";
import FtEditTribeModal from "./ft-edit-tribe-modal";

export default class FantribeTribePage extends Component {
  @service currentUser;
  @service fantribeMembership;
  @service fantribeCreate;
  @service router;

  @tracked isJoining = false;
  @tracked showEditModal = false;

  get category() {
    return this.args.category;
  }

  get topics() {
    return this.args.topics || [];
  }

  get coverStyle() {
    const cat = this.category;
    if (cat?.uploaded_background?.url) {
      return htmlSafe(`background-image: url(${cat.uploaded_background.url})`);
    }
    return htmlSafe(
      `background: linear-gradient(135deg, #${cat?.color || "0088cc"} 0%, #${cat?.color || "0088cc"}88 100%)`
    );
  }

  get logoColorStyle() {
    return htmlSafe(`background-color: #${this.category?.color || "0088cc"}`);
  }

  get hasLogo() {
    return !!this.category?.uploaded_logo?.url;
  }

  get hasEmoji() {
    return !!this.category?.emoji;
  }

  get emojiCode() {
    return `:${this.category?.emoji}:`;
  }

  get initialLetter() {
    return this.category?.name?.[0]?.toUpperCase() || "T";
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

  get postCount() {
    const count = this.category?.topic_count;
    if (count == null) {
      return null;
    }
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    }
    return `${count}`;
  }

  get isPrivate() {
    return this.category?.read_restricted;
  }

  get isMember() {
    return this.fantribeMembership.isMember(this.category?.id);
  }

  get isAdmin() {
    return this.currentUser?.admin;
  }

  get hasTopics() {
    return this.topics.length > 0;
  }

  @action
  openEditModal() {
    this.showEditModal = true;
  }

  @action
  closeEditModal() {
    this.showEditModal = false;
  }

  @action
  async handleJoin() {
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

  @action
  openComposeForTribe() {
    this.fantribeCreate.openCreatePostModal(this.category);
  }

  <template>
    <div class="ft-tribe-page">
      {{! Hero cover image }}
      <div class="ft-tribe-page__hero" style={{this.coverStyle}}>
        <div class="ft-tribe-page__hero-overlay"></div>
        <div class="ft-tribe-page__logo-wrapper">
          {{#if this.hasLogo}}
            <div class="ft-tribe-page__logo ft-tribe-page__logo--img">
              <img
                src={{@category.uploaded_logo.url}}
                alt={{@category.name}}
                class="ft-tribe-page__logo-img"
              />
            </div>
          {{else if this.hasEmoji}}
            <div class="ft-tribe-page__logo ft-tribe-page__logo--emoji">
              {{replaceEmoji this.emojiCode}}
            </div>
          {{else}}
            <div
              class="ft-tribe-page__logo ft-tribe-page__logo--initial"
              style={{this.logoColorStyle}}
            >
              {{this.initialLetter}}
            </div>
          {{/if}}
        </div>
      </div>

      {{! Info card }}
      <div class="ft-tribe-page__info">
        <div class="ft-tribe-page__info-header">
          <div class="ft-tribe-page__info-text">
            <h1 class="ft-tribe-page__name">{{@category.name}}</h1>
            <div class="ft-tribe-page__meta">
              {{#if this.isPrivate}}
                {{ftIcon "lock"}}
                <span>Private</span>
              {{else}}
                {{ftIcon "globe"}}
                <span>Public</span>
              {{/if}}
              {{#if this.memberCount}}
                {{ftIcon "users"}}
                <span>{{this.memberCount}} members</span>
              {{/if}}
              {{#if this.postCount}}
                {{ftIcon "message-circle"}}
                <span>{{this.postCount}} posts</span>
              {{/if}}
            </div>
          </div>

          <div class="ft-tribe-page__actions">
            {{#if this.isAdmin}}
              <button
                type="button"
                class="ft-tribe-page__edit-btn"
                {{on "click" this.openEditModal}}
              >
                {{ftIcon "edit3"}}
                <span>Edit</span>
              </button>
            {{/if}}
            {{#if this.currentUser}}
              <button
                type="button"
                class="ft-tribe-page__join-btn
                  {{if this.isMember 'ft-tribe-page__join-btn--joined'}}
                  {{if this.isJoining 'ft-tribe-page__join-btn--loading'}}"
                disabled={{this.isJoining}}
                {{on "click" this.handleJoin}}
              >
                {{#if this.isJoining}}
                  {{ftIcon "circle"}}
                {{else if this.isMember}}
                  {{ftIcon "check-circle"}}
                  <span>Joined</span>
                {{else}}
                  {{icon "arrow-right-to-bracket"}}
                  <span>Join Tribe</span>
                {{/if}}
              </button>
            {{/if}}
          </div>
        </div>

        {{#if @category.description_text}}
          <p
            class="ft-tribe-page__description"
          >{{@category.description_text}}</p>
        {{/if}}
      </div>

      {{! Compose box — only for members }}
      {{#if this.isMember}}
        {{! template-lint-disable no-invalid-interactive }}
        <div
          class="ft-tribe-page__compose"
          {{on "click" this.openComposeForTribe}}
        >
          <div class="ft-tribe-page__compose-avatar">
            {{#if this.currentUser}}
              {{avatar this.currentUser imageSize="medium"}}
            {{/if}}
          </div>
          <div class="ft-tribe-page__compose-placeholder">
            Write something in
            <strong>{{@category.name}}</strong>...
          </div>
          <button type="button" class="ft-tribe-page__compose-btn">
            {{ftIcon "send"}}
            <span>Post</span>
          </button>
        </div>
      {{/if}}

      {{! Posts list }}
      <div class="ft-tribe-page__posts">
        {{#if this.hasTopics}}
          {{#each this.topics as |topic|}}
            <FantribeFeedCard @topic={{topic}} @hideTribeBadge={{true}} />
          {{/each}}
        {{else}}
          <div class="ft-tribe-page__empty">
            <div class="ft-tribe-page__empty-icon">🏕️</div>
            <h3 class="ft-tribe-page__empty-title">No posts yet</h3>
            <p class="ft-tribe-page__empty-text">
              {{#if this.isMember}}
                Be the first to share something in this tribe!
              {{else}}
                Join this tribe to see and share posts.
              {{/if}}
            </p>
          </div>
        {{/if}}
      </div>
    </div>

    {{#if this.showEditModal}}
      <FtEditTribeModal
        @category={{@category}}
        @onClose={{this.closeEditModal}}
      />
    {{/if}}
  </template>
}
