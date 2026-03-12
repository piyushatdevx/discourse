import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { LinkTo } from "@ember/routing";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ftIcon from "../helpers/ft-icon";

export default class FtEditProfileModal extends Component {
  @tracked name = "";
  @tracked bio = "";
  @tracked location = "";
  @tracked website = "";
  @tracked isSaving = false;
  @tracked saveError = null;

  constructor(owner, args) {
    super(owner, args);
    const user = args.user;
    this.name = user?.name || "";
    this.bio = user?.bio_raw || "";
    this.location = user?.location || "";
    this.website = user?.website || "";
  }

  get hasChanges() {
    const user = this.args.user;
    return (
      this.name !== (user?.name || "") ||
      this.bio !== (user?.bio_raw || "") ||
      this.location !== (user?.location || "") ||
      this.website !== (user?.website || "")
    );
  }

  get isDisabled() {
    return this.isSaving || !this.hasChanges;
  }

  @action
  updateName(event) {
    this.name = event.target.value;
  }

  @action
  updateBio(event) {
    this.bio = event.target.value;
  }

  @action
  updateLocation(event) {
    this.location = event.target.value;
  }

  @action
  updateWebsite(event) {
    this.website = event.target.value;
  }

  @action
  async saveProfile() {
    if (this.isDisabled) {
      return;
    }

    this.isSaving = true;
    this.saveError = null;

    try {
      const username = this.args.user?.username;
      const result = await ajax(`/u/${username}.json`, {
        type: "PUT",
        data: {
          name: this.name,
          bio_raw: this.bio,
          location: this.location,
          website: this.website,
        },
      });

      const user = this.args.user;
      user.setProperties({
        name: this.name,
        bio_raw: this.bio,
        location: this.location,
        website: this.website,
        ...(result.user?.bio_excerpt && {
          bio_excerpt: result.user.bio_excerpt,
        }),
        ...(result.user?.bio_cooked && { bio_cooked: result.user.bio_cooked }),
        ...(result.user?.website_name !== undefined && {
          website_name: result.user.website_name,
        }),
      });

      if (this.args.onSave) {
        this.args.onSave();
      } else {
        this.args.onClose();
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSaving = false;
    }
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.args.onClose();
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{#if @user}}
      <div
        class="ft-modal-backdrop"
        role="dialog"
        aria-modal="true"
        aria-label="Edit profile"
        {{on "click" this.handleBackdropClick}}
        {{on "keydown" this.handleKeydown}}
      >
        <div class="ft-modal ft-edit-modal">

          {{! Header }}
          <div class="ft-modal__title-bar">
            <h2 class="ft-modal__title">Edit Profile</h2>
            <button
              type="button"
              class="ft-modal__close-btn"
              aria-label="Close"
              {{on "click" @onClose}}
            >
              {{ftIcon "x"}}
            </button>
          </div>

          {{! Avatar section }}
          <div class="ft-edit-modal__avatar-section">
            <div class="ft-edit-modal__avatar-wrap">
              {{avatar @user imageSize="large" class="ft-edit-modal__avatar"}}
            </div>
            <div class="ft-edit-modal__avatar-meta">
              <p class="ft-edit-modal__avatar-hint">
                To change your profile photo, update it in account preferences.
              </p>
              <LinkTo
                @route="preferences.account"
                @model={{@user}}
                class="ft-edit-modal__avatar-link"
                {{on "click" @onClose}}
              >
                {{icon "pencil"}}
                Change Photo
              </LinkTo>
            </div>
          </div>

          {{! Form fields }}
          <div class="ft-edit-modal__fields">

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-name">
                Display Name
              </label>
              <input
                type="text"
                id="ft-edit-name"
                class="ft-edit-modal__input"
                placeholder="Your full name"
                value={{this.name}}
                maxlength="255"
                {{on "input" this.updateName}}
              />
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-bio">
                Bio
              </label>
              <textarea
                id="ft-edit-bio"
                class="ft-edit-modal__textarea"
                placeholder="Tell the world about yourself..."
                {{on "input" this.updateBio}}
              >{{this.bio}}</textarea>
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-location">
                {{icon "location-dot"}}
                Location
              </label>
              <input
                type="text"
                id="ft-edit-location"
                class="ft-edit-modal__input"
                placeholder="City, Country"
                value={{this.location}}
                maxlength="255"
                {{on "input" this.updateLocation}}
              />
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-website">
                {{ftIcon "link2" size=14}}
                Website
              </label>
              <input
                type="url"
                id="ft-edit-website"
                class="ft-edit-modal__input"
                placeholder="https://yourwebsite.com"
                value={{this.website}}
                maxlength="500"
                {{on "input" this.updateWebsite}}
              />
            </div>

          </div>

          {{! Footer }}
          <div class="ft-modal__footer">
            <button
              type="button"
              class="ft-modal__cancel-btn"
              {{on "click" @onClose}}
            >
              Cancel
            </button>
            <button
              type="button"
              class="ft-edit-modal__save-btn
                {{if this.isDisabled 'ft-edit-modal__save-btn--disabled'}}"
              disabled={{this.isDisabled}}
              {{on "click" this.saveProfile}}
            >
              {{#if this.isSaving}}
                Saving…
              {{else}}
                Save Changes
              {{/if}}
            </button>
          </div>

        </div>
      </div>
    {{/if}}
  </template>
}
