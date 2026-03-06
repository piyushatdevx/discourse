import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";
import PreloadStore from "discourse/lib/preload-store";
import FtLangDropdown from "../../components/ft-lang-dropdown";

export default class FtAccountCreatedPage extends Component {
  @service router;
  @service siteSettings;

  @tracked otpCode = "";
  @tracked isSubmitting = false;
  @tracked resendSuccess = false;
  @tracked errorMessage = "";

  get isVisible() {
    return (
      this.siteSettings.fantribe_theme_enabled &&
      this.router.currentRouteName?.startsWith("account-created")
    );
  }

  get accountCreated() {
    return PreloadStore.get("accountCreated");
  }

  get email() {
    return this.accountCreated?.email || "";
  }

  get username() {
    return this.accountCreated?.username || "";
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

  get isComplete() {
    return this.otpCode.length >= 6;
  }

  get isDisabled() {
    return !this.isComplete || this.isSubmitting;
  }

  @action
  handleOtpInput(event) {
    const inputs = [
      ...document.querySelectorAll(".ft-account-created-otp .ft-otp-input"),
    ];
    const index = inputs.indexOf(event.target);
    const val = event.target.value.replace(/\D/g, "").slice(-1);
    event.target.value = val;
    this.otpCode = inputs.map((inp) => inp.value).join("");
    if (val && index < 5) {
      inputs[index + 1]?.focus();
    }
  }

  @action
  handleOtpKeyDown(event) {
    const inputs = [
      ...document.querySelectorAll(".ft-account-created-otp .ft-otp-input"),
    ];
    const index = inputs.indexOf(event.target);
    if (event.key === "Backspace" && !event.target.value && index > 0) {
      inputs[index - 1]?.focus();
    }
  }

  @action
  handlePaste(event) {
    event.preventDefault();
    const pasted = event.clipboardData
      .getData("text")
      .replace(/\D/g, "")
      .slice(0, 6);
    const inputs = [
      ...document.querySelectorAll(".ft-account-created-otp .ft-otp-input"),
    ];
    pasted.split("").forEach((char, i) => {
      if (inputs[i]) {
        inputs[i].value = char;
      }
    });
    this.otpCode = pasted;
    inputs[Math.min(pasted.length, 5)]?.focus();
  }

  @action
  async submitCode(event) {
    event?.preventDefault();
    if (this.isDisabled) {
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = "";

    try {
      const result = await ajax("/u/confirm-signup-otp", {
        type: "POST",
        data: { email: this.email, code: this.otpCode },
      });

      if (result.needs_approval) {
        window.location.href = getURL("/u/account-created");
      } else {
        window.location.href = result.redirect_to || getURL("/");
      }
    } catch (e) {
      this.errorMessage =
        e.jqXHR?.responseJSON?.errors?.[0] ||
        "Verification failed. Please try again.";
    } finally {
      this.isSubmitting = false;
    }
  }

  @action
  async resendCode(event) {
    event?.preventDefault();
    if (!this.email) {
      return;
    }

    this.errorMessage = "";

    try {
      await ajax("/u/resend-signup-otp", {
        type: "POST",
        data: { email: this.email },
      });
      this.resendSuccess = true;
    } catch (e) {
      this.errorMessage =
        e.jqXHR?.responseJSON?.errors?.[0] ||
        "Could not resend code. Please try again.";
    }
  }

  <template>
    {{#if this.isVisible}}
      <div class="ft-account-created-overlay">
        <header class="ft-account-created-header">
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

        <div class="ft-account-created-center">
          <div class="ft-account-created-card">
            <div class="ft-account-created-heading">
              <h1 class="ft-account-created-title">We sent you a code</h1>
              {{#if this.email}}
                <p class="ft-account-created-subtitle">Enter it below to verify
                  {{this.email}}</p>
              {{else}}
                <p class="ft-account-created-subtitle">Enter the code from your
                  email</p>
              {{/if}}
            </div>

            {{#if this.errorMessage}}
              <div class="fantribe-login-error">
                {{this.errorMessage}}
              </div>
            {{/if}}

            <div class="ft-otp-group ft-account-created-otp">
              <label class="ft-otp-label">Verification code</label>
              <div class="ft-otp-inputs">
                <input
                  type="text"
                  inputmode="numeric"
                  maxlength="1"
                  class="ft-otp-input"
                  autocomplete="one-time-code"
                  {{on "input" this.handleOtpInput}}
                  {{on "keydown" this.handleOtpKeyDown}}
                  {{on "paste" this.handlePaste}}
                />
                <input
                  type="text"
                  inputmode="numeric"
                  maxlength="1"
                  class="ft-otp-input"
                  {{on "input" this.handleOtpInput}}
                  {{on "keydown" this.handleOtpKeyDown}}
                />
                <input
                  type="text"
                  inputmode="numeric"
                  maxlength="1"
                  class="ft-otp-input"
                  {{on "input" this.handleOtpInput}}
                  {{on "keydown" this.handleOtpKeyDown}}
                />
                <input
                  type="text"
                  inputmode="numeric"
                  maxlength="1"
                  class="ft-otp-input"
                  {{on "input" this.handleOtpInput}}
                  {{on "keydown" this.handleOtpKeyDown}}
                />
                <input
                  type="text"
                  inputmode="numeric"
                  maxlength="1"
                  class="ft-otp-input"
                  {{on "input" this.handleOtpInput}}
                  {{on "keydown" this.handleOtpKeyDown}}
                />
                <input
                  type="text"
                  inputmode="numeric"
                  maxlength="1"
                  class="ft-otp-input"
                  {{on "input" this.handleOtpInput}}
                  {{on "keydown" this.handleOtpKeyDown}}
                />
              </div>
            </div>

            <div class="ft-account-created-actions">
              <button
                type="button"
                class="fantribe-btn-primary
                  {{if this.isSubmitting 'is-loading'}}"
                disabled={{this.isDisabled}}
                {{on "click" this.submitCode}}
              >
                {{#if this.isSubmitting}}
                  <span class="fantribe-spinner"></span>
                {{else}}
                  Next
                {{/if}}
              </button>
              <button
                type="button"
                class="ft-account-created-resend"
                {{on "click" this.resendCode}}
              >
                {{#if this.resendSuccess}}
                  Code sent!
                {{else}}
                  Didn't receive a code?
                {{/if}}
              </button>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
