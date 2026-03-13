import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";
import DiscourseURL from "discourse/lib/url";
import FtLangDropdown from "../../components/ft-lang-dropdown";
import ftIcon from "../../helpers/ft-icon";

export default class FtPasswordResetPage extends Component {
  @service router;
  @service siteSettings;

  @tracked newPassword = "";
  @tracked confirmPassword = "";
  @tracked showPassword = false;
  @tracked showConfirmPassword = false;
  @tracked isSubmitting = false;
  @tracked errorMessage = "";
  @tracked successMessage = "";

  get isVisible() {
    return (
      this.siteSettings.fantribe_theme_enabled &&
      this.router.currentRouteName === "password-reset" &&
      !this.needs2FA
    );
  }

  get needs2FA() {
    try {
      const ctrl = getOwner(this).lookup("controller:password-reset");
      return ctrl?.securityKeyOrSecondFactorRequired;
    } catch {
      return false;
    }
  }

  get logoUrl() {
    return getURL("/plugins/fantribe-theme/images/logo.svg");
  }

  get homeUrl() {
    return getURL("/");
  }

  get helpUrl() {
    return "https://support.empowertribe.com";
  }

  get token() {
    return this.router.currentRoute?.params?.token;
  }

  get passwordsMatch() {
    return (
      this.newPassword.length > 0 && this.newPassword === this.confirmPassword
    );
  }

  get mismatchError() {
    return (
      this.confirmPassword.length > 0 &&
      this.newPassword !== this.confirmPassword
    );
  }

  get isDisabled() {
    return !this.passwordsMatch || this.isSubmitting;
  }

  @action
  handleNewPassword(event) {
    this.newPassword = event.target.value;
    this.errorMessage = "";
  }

  @action
  handleConfirmPassword(event) {
    this.confirmPassword = event.target.value;
    this.errorMessage = "";
  }

  @action
  toggleShowPassword() {
    this.showPassword = !this.showPassword;
  }

  @action
  toggleShowConfirmPassword() {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  @action
  async handleSubmit(event) {
    event?.preventDefault();

    if (this.isDisabled) {
      return;
    }

    if (this.mismatchError) {
      this.errorMessage = "Passwords do not match.";
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = "";

    try {
      const result = await ajax({
        url: getURL(`/u/password-reset/${this.token}.json`),
        type: "PUT",
        data: {
          password: this.newPassword,
          timezone: moment.tz.guess(),
        },
      });

      if (result.success) {
        this.successMessage = result.message;
        DiscourseURL.redirectTo(result.redirect_to || "/");
      } else if (result.errors) {
        const passwordErrors =
          result.errors["user_password.password"] || result.errors["password"];
        if (passwordErrors?.length > 0) {
          this.errorMessage =
            result.friendly_messages?.join("\n") || passwordErrors.join("\n");
        } else if (result.message) {
          this.errorMessage = result.message;
        }
      }
    } catch (e) {
      if (e.jqXHR?.status === 429) {
        this.errorMessage = "Too many attempts. Please wait and try again.";
      } else {
        this.errorMessage =
          e.jqXHR?.responseJSON?.errors?.[0] ||
          e.jqXHR?.responseJSON?.message ||
          "Something went wrong. Please try again.";
      }
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    {{#if this.isVisible}}
      <div class="ft-password-reset-overlay">
        {{#if this.errorMessage}}
          <div class="ft-password-reset-toast">
            <svg
              class="ft-toast-icon"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="12" y1="8" x2="12" y2="12"></line>
              <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            <span>{{this.errorMessage}}</span>
          </div>
        {{/if}}

        <header class="ft-password-reset-header">
          <a href={{this.homeUrl}} class="fantribe-login-header__logo">
            <img src={{this.logoUrl}} alt="FanTribe" />
          </a>
          <div class="fantribe-login-header__actions">
            <FtLangDropdown />
            <a
              href={{this.helpUrl}}
              class="fantribe-login-header__btn"
              target="_blank"
              rel="noopener noreferrer"
            >
              {{icon "headset"}}
              <span>Help</span>
            </a>
          </div>
        </header>

        <div class="ft-password-reset-center">
          <div class="ft-password-reset-card">
            <h2 class="ft-password-reset-title">Reset your password</h2>

            <div class="ft-password-reset-form">
              <div class="ft-password-reset-fields">
                <div class="ft-password-reset-field">
                  <label
                    for="ft-new-password"
                    class="ft-password-reset-label"
                  >New password</label>
                  <div class="ft-password-reset-input-wrapper">
                    <input
                      type={{if this.showPassword "text" "password"}}
                      id="ft-new-password"
                      class="ft-password-reset-input"
                      placeholder="Enter your new password"
                      autocomplete="new-password"
                      {{on "input" this.handleNewPassword}}
                    />
                    <button
                      type="button"
                      class="ft-password-reset-eye"
                      {{on "click" this.toggleShowPassword}}
                    >
                      {{ftIcon (if this.showPassword "eye-off" "eye")}}
                    </button>
                  </div>
                </div>

                <div class="ft-password-reset-field">
                  <label
                    for="ft-confirm-password"
                    class="ft-password-reset-label"
                  >Confirm password</label>
                  <div class="ft-password-reset-input-wrapper">
                    <input
                      type={{if this.showConfirmPassword "text" "password"}}
                      id="ft-confirm-password"
                      class="ft-password-reset-input
                        {{if this.mismatchError 'has-error'}}"
                      placeholder="Enter your confirm password"
                      autocomplete="new-password"
                      {{on "input" this.handleConfirmPassword}}
                    />
                    <button
                      type="button"
                      class="ft-password-reset-eye"
                      {{on "click" this.toggleShowConfirmPassword}}
                    >
                      {{ftIcon (if this.showConfirmPassword "eye-off" "eye")}}
                    </button>
                  </div>
                  {{#if this.mismatchError}}
                    <span class="ft-password-reset-error">Passwords do not match</span>
                  {{/if}}
                </div>
              </div>

              <button
                type="button"
                class="ft-password-reset-submit
                  {{if this.isSubmitting 'is-loading'}}"
                disabled={{this.isDisabled}}
                {{on "click" this.handleSubmit}}
              >
                {{#if this.isSubmitting}}
                  <span class="fantribe-spinner"></span>
                {{else}}
                  Reset password
                {{/if}}
              </button>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
