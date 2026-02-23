import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ftIcon from "../helpers/ft-icon";

// Maps Discourse trust level → FanTribe tier identity.
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

  // null = use server value
  @tracked followLoading = false;
  @tracked _isFollowing = null; // null = use server value
  @tracked _followerCount = null;

  // ----------------------------------------------------------------
  // Tier helpers
  // ----------------------------------------------------------------

  get tier() {
    const tl = this.args.user?.trust_level ?? 0;
    return (
      TRUST_LEVEL_TIERS[Math.min(tl, TRUST_LEVEL_TIERS.length - 1)] || null
    );
  }

  // ----------------------------------------------------------------
  // Follow state — optimistic with server fallback
  // ----------------------------------------------------------------

  get isFollowing() {
    return this._isFollowing !== null
      ? this._isFollowing
      : (this.args.user?.ft_is_following ?? false);
  }

  get followerCount() {
    return this._followerCount !== null
      ? this._followerCount
      : (this.args.user?.ft_follower_count ?? 0);
  }

  get followingCount() {
    return this.args.user?.ft_following_count ?? 0;
  }

  get isOwnProfile() {
    return this.currentUser && this.currentUser.id === this.args.user?.id;
  }

  get canFollow() {
    return !!(this.currentUser && !this.isOwnProfile);
  }

  // ----------------------------------------------------------------
  // Tribe count — categories the user is watching (joined tribes)
  // ----------------------------------------------------------------

  get tribeCount() {
    // ft_tribe_count = CategoryUser.watching count, added by fantribe-theme serializer.
    return this.args.user?.ft_tribe_count ?? 0;
  }

  // ----------------------------------------------------------------
  // Cover image
  // ----------------------------------------------------------------

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

  // ----------------------------------------------------------------
  // Meta
  // ----------------------------------------------------------------

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
    return this.args.user?.bio_excerpt;
  }

  get postCount() {
    // ft_post_count added by fantribe-theme serializer extension (public).
    // post_count is staff-only in Discourse's native serializer.
    return this.args.user?.ft_post_count ?? this.args.user?.post_count ?? 0;
  }

  // ----------------------------------------------------------------
  // Actions
  // ----------------------------------------------------------------

  @action
  async toggleFollow() {
    if (!this.canFollow || this.followLoading) {
      return;
    }

    const wasFollowing = this.isFollowing;
    const username = this.args.user?.username;

    // Optimistic update
    this._isFollowing = !wasFollowing;
    this._followerCount = wasFollowing
      ? Math.max(0, this.followerCount - 1)
      : this.followerCount + 1;

    this.followLoading = true;
    try {
      const result = await ajax(`/u/${username}/follow`, {
        type: wasFollowing ? "DELETE" : "PUT",
      });
      // Reconcile with server counts
      this._followerCount = result.ft_follower_count ?? this._followerCount;
      this._isFollowing = result.ft_is_following ?? !wasFollowing;
    } catch (error) {
      // Revert optimistic update on error
      this._isFollowing = wasFollowing;
      this._followerCount = wasFollowing
        ? this.followerCount + 1
        : Math.max(0, this.followerCount - 1);
      popupAjaxError(error);
    } finally {
      this.followLoading = false;
    }
  }

  @action
  shareProfile() {
    // Use native share if available, otherwise copy URL
    const url = window.location.href;
    if (navigator.share) {
      navigator.share({
        url,
        title: this.args.user?.name || this.args.user?.username,
      });
    } else {
      navigator.clipboard?.writeText(url);
    }
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
              {{on "click" this.shareProfile}}
              aria-label="Share profile"
            >
              {{ftIcon "share2"}}
            </button>
            {{#if this.isOwnProfile}}
              <LinkTo
                @route="preferences.profile"
                @model={{@user}}
                class="ft-profile__cover-btn"
              >
                {{ftIcon "settings"}}
              </LinkTo>
            {{/if}}
          </div>
        </div>

        {{! ── Profile card ── }}
        <div class="ft-profile__card">
          <div class="ft-profile__card-inner">

            {{! ── Left: avatar + tier ring ── }}
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
              {{#if this.tier}}
                <div
                  class="ft-profile__tier-badge ft-profile__tier-badge--{{this.tier.key}}"
                >
                  {{ftIcon "zap"}}
                  {{this.tier.label}}
                </div>
              {{/if}}
            </div>

            {{! ── Right: name + info + actions ── }}
            <div class="ft-profile__info">
              <div class="ft-profile__name-row">
                <div>
                  <h1 class="ft-profile__name">
                    {{@user.name}}
                    {{#if @user.title}}
                      <span
                        class="ft-profile__title-badge"
                      >{{@user.title}}</span>
                    {{/if}}
                  </h1>
                  <p class="ft-profile__handle">@{{@user.username}}</p>
                </div>

                {{! Subscribe / Edit buttons }}
                {{#if this.canFollow}}
                  <button
                    type="button"
                    class="ft-profile__follow-btn
                      {{if
                        this.isFollowing
                        'ft-profile__follow-btn--following'
                      }}
                      {{if
                        this.followLoading
                        'ft-profile__follow-btn--loading'
                      }}"
                    disabled={{this.followLoading}}
                    {{on "click" this.toggleFollow}}
                  >
                    {{#if this.isFollowing}}
                      {{ftIcon "check"}}
                      Following
                    {{else}}
                      {{ftIcon "user-plus"}}
                      Subscribe
                    {{/if}}
                  </button>
                {{else if this.isOwnProfile}}
                  <LinkTo
                    @route="preferences.profile"
                    @model={{@user}}
                    class="ft-profile__edit-btn"
                  >
                    {{ftIcon "edit3"}}
                    Edit Profile
                  </LinkTo>
                {{/if}}
              </div>

              {{! Bio }}
              {{#if this.bio}}
                <p class="ft-profile__bio">{{this.bio}}</p>
              {{/if}}

              {{! Meta row: location · joined · website }}
              <div class="ft-profile__meta">
                {{#if this.location}}
                  <span class="ft-profile__meta-item">
                    {{icon "location-dot"}}
                    {{this.location}}
                  </span>
                {{/if}}
                {{#if this.joinedDate}}
                  <span class="ft-profile__meta-item">
                    {{ftIcon "calendar"}}
                    Joined
                    {{formatDate this.joinedDate leaveAgo=true}}
                  </span>
                {{/if}}
                {{#if this.websiteName}}
                  <a
                    href={{this.website}}
                    target="_blank"
                    rel="nofollowugc noopener noreferrer"
                    class="ft-profile__meta-item ft-profile__meta-item--link"
                  >
                    {{ftIcon "link2"}}
                    {{this.websiteName}}
                  </a>
                {{/if}}
              </div>
            </div>
          </div>

          {{! ── Stats row ── }}
          <div class="ft-profile__stats">
            <div class="ft-profile__stat">
              <span class="ft-profile__stat-value">{{this.followerCount}}</span>
              <span class="ft-profile__stat-label">Followers</span>
            </div>
            <div class="ft-profile__stat ft-profile__stat--divider">
              <span
                class="ft-profile__stat-value"
              >{{this.followingCount}}</span>
              <span class="ft-profile__stat-label">Following</span>
            </div>
            <div class="ft-profile__stat ft-profile__stat--divider">
              <span class="ft-profile__stat-value">{{this.tribeCount}}</span>
              <span class="ft-profile__stat-label">Tribes</span>
            </div>
            <div class="ft-profile__stat ft-profile__stat--divider">
              <span class="ft-profile__stat-value">{{this.postCount}}</span>
              <span class="ft-profile__stat-label">Posts</span>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
