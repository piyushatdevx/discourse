import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";
import FtEditTribeModal from "./ft-edit-tribe-modal";

export default class FantribeTribeHeader extends Component {
  @service currentUser;
  @service fantribeMembership;
  @service router;

  @tracked isJoining = false;
  @tracked showEditModal = false;

  get category() {
    return this.args.category;
  }

  get coverStyle() {
    const cat = this.category;
    if (cat?.uploaded_background?.url) {
      return htmlSafe(`background-image: url(${cat.uploaded_background.url})`);
    }
    return htmlSafe(
      `background: linear-gradient(135deg, #${cat?.color || "0088cc"} 0%, #${cat?.color || "0088cc"}66 100%)`
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

  get isMember() {
    return this.fantribeMembership.isMember(this.category?.id);
  }

  get isPrivate() {
    return this.category?.read_restricted;
  }

  get isAdmin() {
    return this.currentUser?.admin;
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

  <template>
    {{#if @category}}
      <div class="ft-tribe-header">
        <div class="ft-tribe-header__cover" style={{this.coverStyle}}>
          <div class="ft-tribe-header__cover-overlay"></div>
        </div>

        <div class="ft-tribe-header__content">
          <div class="ft-tribe-header__info">
            <h2 class="ft-tribe-header__name">{{@category.name}}</h2>
            {{#if @category.description_text}}
              <p
                class="ft-tribe-header__description"
              >{{@category.description_text}}</p>
            {{/if}}
            <div class="ft-tribe-header__meta">
              {{#if this.isPrivate}}
                {{ftIcon "lock"}}
                <span>{{i18n "fantribe.common.private"}}</span>
              {{else}}
                {{ftIcon "globe"}}
                <span>{{i18n "fantribe.common.public"}}</span>
              {{/if}}
              {{#if this.memberCount}}
                <span class="ft-tribe-header__meta-sep">&bull;</span>
                {{ftIcon "users"}}
                <span>{{i18n
                    "fantribe.tribe_page.members_count"
                    count=this.memberCount
                  }}</span>
              {{/if}}
            </div>
          </div>

          <div class="ft-tribe-header__actions">
            {{#if this.isAdmin}}
              <button
                type="button"
                class="ft-tribe-header__edit-btn"
                {{on "click" this.openEditModal}}
              >
                {{icon "wrench"}}
                <span>{{i18n "fantribe.common.edit_tribe"}}</span>
              </button>
            {{/if}}
            <button
              type="button"
              class="ft-tribe-header__join-btn
                {{if this.isMember 'ft-tribe-header__join-btn--joined'}}
                {{if this.isJoining 'ft-tribe-header__join-btn--loading'}}"
              disabled={{this.isJoining}}
              {{on "click" this.handleJoin}}
            >
              {{#if this.isJoining}}
                {{ftIcon "circle"}}
              {{else if this.isMember}}
                {{ftIcon "check-circle"}}
                <span>{{i18n "fantribe.common.joined"}}</span>
              {{else}}
                {{icon "arrow-right-to-bracket"}}
                <span>{{i18n "fantribe.common.join_tribe"}}</span>
              {{/if}}
            </button>
          </div>
        </div>
      </div>

      {{#if this.showEditModal}}
        <FtEditTribeModal
          @category={{@category}}
          @onClose={{this.closeEditModal}}
        />
      {{/if}}
    {{/if}}
  </template>
}
