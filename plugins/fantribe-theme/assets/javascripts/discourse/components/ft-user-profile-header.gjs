import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";
import FtEditProfileModal from "./ft-edit-profile-modal";
import FtShareProfileModal from "./ft-share-profile-modal";

// Maps Discourse trust level → FanTribe tier.
// TL0 (new) has no ring; TL1+ earn their tier.
const TRUST_LEVEL_TIERS = [
  null, // TL0 — no tier yet
  { key: "bronze", label: "Bronze" },
  { key: "silver", label: "Silver" },
  { key: "gold", label: "Gold" },
  { key: "platinum", label: "Platinum" }, // TL4
];

export default class FtUserProfileHeader extends Component {
  @service currentUser;
  @service dialog;
  @service router;

  @tracked showShareModal = false;
  @tracked showEditModal = false;

  // ── Tier ──────────────────────────────────────────────────────
  get tier() {
    const tl = this.args.user?.trust_level ?? 0;
    return (
      TRUST_LEVEL_TIERS[Math.min(tl, TRUST_LEVEL_TIERS.length - 1)] || null
    );
  }

  get isOwnProfile() {
    return this.currentUser && this.currentUser.id === this.args.user?.id;
  }

  // ── Stats ──────────────────────────────────────────────────────
  get tribeCount() {
    return this.args.user?.ft_tribe_count ?? 0;
  }

  get coCreationCount() {
    return this.args.user?.ft_co_creation_count ?? 0;
  }

  // ── Cover ──────────────────────────────────────────────────────
  get coverStyle() {
    const url = this.args.user?.profile_background_upload_url;
    if (url) {
      return htmlSafe(`background-image: url('${url}')`);
    }
    return null;
  }

  get hasCover() {
    return !!this.args.user?.profile_background_upload_url;
  }

  // ── Meta ───────────────────────────────────────────────────────
  get joinedDate() {
    return this.args.user?.created_at;
  }

  get location() {
    return this.args.user?.location;
  }

  get website() {
    return this.args.user?.website;
  }

  get websiteName() {
    return this.args.user?.website_name;
  }

  get bio() {
    return this.args.user?.bio_cooked;
  }

  // ── Modal actions ──────────────────────────────────────────────
  @action
  openShareModal() {
    this.showShareModal = true;
  }

  @action
  closeShareModal() {
    this.showShareModal = false;
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
  goToSettings() {
    this.router.transitionTo("userActivity.ftSettings", this.args.user);
  }

  @action
  confirmLogout() {
    this.dialog.confirm({
      message: i18n("fantribe.log_out_confirm"),
      class: "logout-confirm",
      didConfirm: () => {
        getOwner(this).lookup("route:application").send("logout");
      },
    });
  }

  <template>
    {{#if @user}}
      <div class="ft-profile">

        {{! ── Cover image ── }}
        <div
          class="ft-profile__cover
            {{if
              this.hasCover
              'ft-profile__cover--has-image'
              'ft-profile__cover--gradient'
            }}"
          style={{this.coverStyle}}
        >
          <div class="ft-profile__cover-overlay"></div>
          <div class="ft-profile__cover-actions">
            <button
              type="button"
              class="ft-profile__cover-btn"
              {{on "click" this.openShareModal}}
              aria-label="Share profile"
            >
              {{ftIcon "share2"}}
            </button>
            {{#if this.isOwnProfile}}
              <button
                type="button"
                class="ft-profile__cover-btn"
                {{on "click" this.goToSettings}}
                aria-label="Settings"
              >
                {{ftIcon "settings"}}
              </button>
              <button
                type="button"
                class="ft-profile__cover-btn"
                {{on "click" this.confirmLogout}}
                aria-label={{i18n "user.log_out"}}
              >
                {{ftIcon "log-out"}}
              </button>
            {{/if}}
          </div>
        </div>

        {{! ── Profile card ── }}
        <div class="ft-profile__card">
          <div class="ft-profile__card-inner">

            {{! Avatar }}
            <div class="ft-profile__avatar-wrap">
              <div
                class="ft-profile__avatar-ring
                  {{if
                    this.tier
                    (concat 'ft-profile__avatar-ring--' this.tier.key)
                  }}"
              >
                {{avatar @user imageSize="large" class="ft-profile__avatar"}}
              </div>
            </div>

            {{! Name, tier badge, handle, bio, meta }}
            <div class="ft-profile__info">

              {{! Name row: name + tier badge inline + action button }}
              <div class="ft-profile__name-row">
                <div class="ft-profile__name-group">
                  <h1 class="ft-profile__name">
                    {{@user.name}}
                  </h1>
                  <p class="ft-profile__handle">@{{@user.username}}</p>
                </div>

                {{! Edit Profile button (own profile only) }}
                {{#if this.isOwnProfile}}
                  <button
                    type="button"
                    class="ft-profile__edit-btn"
                    {{on "click" this.openEditModal}}
                  >
                    {{icon "pencil"}}
                    Edit Profile
                  </button>
                {{/if}}
              </div>

              {{! Bio }}
              {{#if this.bio}}
                <div class="ft-profile__bio">{{htmlSafe this.bio}}</div>
              {{/if}}

              {{! Meta: location · joined · website }}
              <div class="ft-profile__meta">
                {{#if this.location}}
                  <span class="ft-profile__meta-item">
                    {{icon "location-dot"}}
                    {{this.location}}
                  </span>
                {{/if}}
                {{#if this.joinedDate}}
                  <span class="ft-profile__meta-item">
                    {{ftIcon "calendar" size=14}}
                    Joined
                    {{formatDate this.joinedDate leaveAgo=true}}
                  </span>
                {{/if}}
                {{#if this.websiteName}}
                  <a
                    href={{this.website}}
                    target="_blank"
                    rel="nofollow ugc noopener noreferrer"
                    class="ft-profile__meta-item ft-profile__meta-item--link"
                  >
                    {{ftIcon "link2"}}
                    {{this.websiteName}}
                  </a>
                {{/if}}
              </div>
            </div>
          </div>

        </div>
      </div>

      {{! ── Modals ── }}
      {{#if this.showShareModal}}
        <FtShareProfileModal
          @user={{@user}}
          @onClose={{this.closeShareModal}}
        />
      {{/if}}

      {{#if this.showEditModal}}
        <FtEditProfileModal @user={{@user}} @onClose={{this.closeEditModal}} />
      {{/if}}

    {{/if}}
  </template>
}
