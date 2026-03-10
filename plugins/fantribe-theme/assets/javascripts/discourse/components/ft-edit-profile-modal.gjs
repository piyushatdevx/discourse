import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

export default class FtEditProfileModal extends Component {
  @service router;

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
      await ajax(`/u/${username}.json`, {
        type: "PUT",
        data: {
          name: this.name,
          bio_raw: this.bio,
          location: this.location,
          website: this.website,
        },
      });

      this.args.onClose();
      // Reload the current route so the updated profile info is displayed.
      this.router.refresh();
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
        aria-label={{i18n "fantribe.edit_profile.title"}}
        {{on "click" this.handleBackdropClick}}
        {{on "keydown" this.handleKeydown}}
      >
        <div class="ft-modal ft-edit-modal">

          {{! Header }}
          <div class="ft-modal__title-bar">
            <h2 class="ft-modal__title">{{i18n
                "fantribe.edit_profile.title"
              }}</h2>
            <button
              type="button"
              class="ft-modal__close-btn"
              aria-label={{i18n "fantribe.common.close"}}
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
                {{i18n "fantribe.edit_profile.photo_hint"}}
              </p>
              <LinkTo
                @route="preferences.account"
                @model={{@user}}
                class="ft-edit-modal__avatar-link"
                {{on "click" @onClose}}
              >
                {{icon "pencil"}}
                {{i18n "fantribe.edit_profile.change_photo"}}
              </LinkTo>
            </div>
          </div>

          {{! Form fields }}
          <div class="ft-edit-modal__fields">

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-name">
                {{i18n "fantribe.edit_profile.display_name"}}
              </label>
              <input
                type="text"
                id="ft-edit-name"
                class="ft-edit-modal__input"
                placeholder={{i18n
                  "fantribe.edit_profile.full_name_placeholder"
                }}
                value={{this.name}}
                maxlength="255"
                {{on "input" this.updateName}}
              />
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-bio">
                {{i18n "fantribe.common.bio"}}
              </label>
              <textarea
                id="ft-edit-bio"
                class="ft-edit-modal__textarea"
                placeholder={{i18n "fantribe.edit_profile.bio_placeholder"}}
                {{on "input" this.updateBio}}
              >{{this.bio}}</textarea>
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-location">
                {{icon "location-dot"}}
                {{i18n "fantribe.common.location"}}
              </label>
              <input
                type="text"
                id="ft-edit-location"
                class="ft-edit-modal__input"
                placeholder={{i18n
                  "fantribe.edit_profile.location_placeholder"
                }}
                value={{this.location}}
                maxlength="255"
                {{on "input" this.updateLocation}}
              />
            </div>

            <div class="ft-edit-modal__field">
              <label class="ft-edit-modal__label" for="ft-edit-website">
                {{ftIcon "link2" size=14}}
                {{i18n "fantribe.common.website"}}
              </label>
              <input
                type="url"
                id="ft-edit-website"
                class="ft-edit-modal__input"
                placeholder={{i18n "fantribe.edit_profile.website_placeholder"}}
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
              {{i18n "fantribe.common.cancel"}}
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
                {{i18n "fantribe.common.save_changes"}}
              {{/if}}
            </button>
          </div>

        </div>
      </div>
    {{/if}}
  </template>
}
