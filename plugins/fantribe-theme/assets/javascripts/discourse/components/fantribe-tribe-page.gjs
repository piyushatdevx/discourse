import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import replaceEmoji from "discourse/helpers/replace-emoji";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseDebounce from "discourse/lib/debounce";
import { searchForTerm } from "discourse/lib/search";
import { i18n } from "discourse-i18n";
import FtLeaveTribeConfirmModal from "discourse/plugins/explore-tribes/discourse/components/ft-leave-tribe-confirm-modal";
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
  @tracked showLeaveConfirm = false;
  @tracked searchQuery = "";
  @tracked searchResults = null;
  @tracked isSearching = false;

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

  // Prefer this.topics.length so the count matches the list shown on the page.
  // category.topic_count can include the category definition topic (description),
  // which the topic list API excludes, causing an off-by-one (count 1 higher than visible posts).
  get postCount() {
    const topicsList = this.topics;
    const count =
      topicsList?.length != null
        ? topicsList.length
        : this.category?.topic_count;
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
    return this.displayTopics.length > 0;
  }

  get displayTopics() {
    if (this.searchQuery.trim() && this.searchResults) {
      return this.searchResults;
    }
    return this.topics;
  }

  get isSearchActive() {
    return this.searchQuery.trim().length > 0;
  }

  @action
  handleSearchInput(event) {
    this.searchQuery = event.target.value;
    if (this.searchQuery.trim()) {
      discourseDebounce(this, this.performSearch, 300);
    } else {
      this.searchResults = null;
    }
  }

  async performSearch() {
    const term = this.searchQuery.trim();
    if (!term || term.length < 2) {
      this.searchResults = null;
      return;
    }

    this.isSearching = true;
    try {
      const results = await searchForTerm(term, {
        searchContext: {
          type: "category",
          id: this.category.id,
          name: this.category.name,
        },
      });
      // Transform search posts into topic-like objects with full data
      const topicMap = new Map();
      (results.posts || []).forEach((post) => {
        if (post.topic && !topicMap.has(post.topic.id)) {
          const topic = post.topic;
          // Build transformed topic with poster info and missing fields
          const transformedTopic = {
            ...topic,
            // Add synthetic posters array from post's user data
            posters: [
              {
                user: {
                  id: post.user_id,
                  username: post.username,
                  name: post.name,
                  avatar_template: post.avatar_template,
                },
                description: "Original Poster",
              },
            ],
            // Ensure excerpt is available (use blurb as fallback)
            excerpt: topic.excerpt || post.blurb || "",
            // Mark as truncated if there's content (enables "Read more")
            excerptTruncated: !!(topic.excerpt || post.blurb),
            // Ensure image fields are present
            image_url: topic.image_url,
            image_urls:
              topic.image_urls || (topic.image_url ? [topic.image_url] : []),
            thumbnails: topic.thumbnails || [],
            // Add first post ID for expand functionality
            first_post_id: post.id,
          };
          topicMap.set(topic.id, transformedTopic);
        }
      });
      this.searchResults = Array.from(topicMap.values());
    } catch (e) {
      this.searchResults = [];
      // eslint-disable-next-line no-console
      console.warn(`Failed to load search results with error: ${e}`);
    } finally {
      this.isSearching = false;
    }
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
  handleJoin() {
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

    if (this.isMember) {
      this.showLeaveConfirm = true;
      return;
    }

    this.doSetLevel(this.fantribeMembership.watchingLevel);
  }

  @action
  closeLeaveConfirm() {
    this.showLeaveConfirm = false;
  }

  @action
  async confirmLeave() {
    this.doSetLevel(this.fantribeMembership.regularLevel);
    this.showLeaveConfirm = false;
  }

  async doSetLevel(newLevel) {
    const categoryId = this.category?.id;
    if (!categoryId) {
      return;
    }

    const currentlyMember = this.isMember;
    const previousLevel = currentlyMember
      ? this.fantribeMembership.watchingLevel
      : this.fantribeMembership.regularLevel;

    this.isJoining = true;
    this.fantribeMembership.setLevel(categoryId, newLevel);

    try {
      await ajax(`/category/${categoryId}/notifications`, {
        type: "POST",
        data: { notification_level: newLevel },
      });
    } catch (error) {
      this.fantribeMembership.setLevel(categoryId, previousLevel);
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
      {{! Search bar }}
      <div class="ft-tribe-page__search">
        {{ftIcon "search"}}
        <input
          type="text"
          placeholder={{i18n "fantribe.tribe_page.search_posts"}}
          value={{this.searchQuery}}
          {{on "input" this.handleSearchInput}}
        />
        {{#if this.isSearching}}
          <span class="ft-tribe-page__search-spinner">{{ftIcon "loader"}}</span>
        {{/if}}
      </div>

      {{! Main container }}
      <div class="ft-tribe-page__container">
        {{! Header card with cover + info }}
        <div class="ft-tribe-page__header-card">
          {{! Hero cover image }}
          <div class="ft-tribe-page__hero" style={{this.coverStyle}}></div>

          {{! Logo positioned overlapping cover }}
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

          {{! Info section }}
          <div class="ft-tribe-page__info">
            <div class="ft-tribe-page__info-header">
              <div class="ft-tribe-page__info-text">
                <h1 class="ft-tribe-page__name">{{@category.name}}</h1>
                <div class="ft-tribe-page__meta">
                  {{#if this.memberCount}}
                    {{ftIcon "users"}}
                    <span>{{i18n
                        "fantribe.tribe_page.members_count"
                        count=this.memberCount
                      }}</span>
                    <span class="ft-tribe-page__meta-dot">·</span>
                  {{/if}}
                  {{#if this.isPrivate}}
                    {{ftIcon "lock"}}
                    <span>{{i18n "fantribe.common.private"}}</span>
                  {{else}}
                    {{ftIcon "globe"}}
                    <span>{{i18n "fantribe.common.public"}}</span>
                  {{/if}}
                  {{#if this.postCount}}
                    <span class="ft-tribe-page__meta-dot">·</span>
                    {{ftIcon "file-text"}}
                    <span>{{i18n
                        "fantribe.tribe_page.posts_count"
                        count=this.postCount
                      }}</span>
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
                    <span>{{i18n "fantribe.common.edit"}}</span>
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
                      {{ftIcon "loader"}}
                    {{else if this.isMember}}
                      {{ftIcon "log-out"}}
                      <span>{{i18n "fantribe.common.leave"}}</span>
                    {{else}}
                      {{ftIcon "user-plus"}}
                      <span>{{i18n "fantribe.common.join_tribe"}}</span>
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
        </div>

        {{! Posts section }}
        <div class="ft-tribe-page__posts-wrapper">
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
                {{i18n "fantribe.tribe_page.write_something_in"}}
                <strong>{{@category.name}}</strong>...
              </div>
              <button type="button" class="ft-tribe-page__compose-btn">
                {{ftIcon "send"}}
                <span>{{i18n "fantribe.common.post"}}</span>
              </button>
            </div>
          {{/if}}

          {{! Posts list }}
          <div class="ft-tribe-page__posts">
            {{#if this.hasTopics}}
              {{#each this.displayTopics as |topic|}}
                <FantribeFeedCard @topic={{topic}} @hideTribeBadge={{true}} />
              {{/each}}
            {{else}}
              <div class="ft-tribe-page__empty">
                {{#if this.isSearchActive}}
                  <div class="ft-tribe-page__empty-icon">🔍</div>
                  <h3 class="ft-tribe-page__empty-title">{{i18n
                      "fantribe.search_modal.no_results"
                    }}</h3>
                  <p class="ft-tribe-page__empty-text">
                    {{i18n "fantribe.tribe_page.try_different_search"}}
                  </p>
                {{else}}
                  <div class="ft-tribe-page__empty-icon">🏕️</div>
                  <h3 class="ft-tribe-page__empty-title">{{i18n
                      "fantribe.feed_layout.empty_title"
                    }}</h3>
                  <p class="ft-tribe-page__empty-text">
                    {{#if this.isMember}}
                      {{i18n "fantribe.tribe_page.empty_member"}}
                    {{else}}
                      {{i18n "fantribe.tribe_page.empty_non_member"}}
                    {{/if}}
                  </p>
                {{/if}}
              </div>
            {{/if}}
          </div>
        </div>
      </div>
    </div>

    {{#if this.showEditModal}}
      <FtEditTribeModal
        @category={{@category}}
        @onClose={{this.closeEditModal}}
      />
    {{/if}}

    {{#if this.showLeaveConfirm}}
      <FtLeaveTribeConfirmModal
        @tribeName={{this.category.name}}
        @onClose={{this.closeLeaveConfirm}}
        @onConfirm={{this.confirmLeave}}
      />
    {{/if}}
  </template>
}
