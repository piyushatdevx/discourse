import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ForgotPassword from "discourse/components/modal/forgot-password";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import getURL from "discourse/lib/get-url";
import { findAll } from "discourse/models/login-method";

export default class FantribeLoginForm extends Component {
  @service login;
  @service modal;
  @service router;

  @tracked loginName = "";
  @tracked loginPassword = "";
  @tracked isLoading = false;
  @tracked showSecondFactor = false;
  @tracked secondFactorToken = "";
  @tracked secondFactorMethod = null;
  @tracked errorMessage = "";
  @tracked maskPassword = true;

  get googleProvider() {
    return findAll().find((m) => m.name === "google_oauth2");
  }

  get signupUrl() {
    return getURL("/signup");
  }

  @action
  updateLoginName(event) {
    this.loginName = event.target.value;
  }

  @action
  updateLoginPassword(event) {
    this.loginPassword = event.target.value;
  }

  @action
  updateSecondFactorToken(event) {
    this.secondFactorToken = event.target.value;
  }

  @action
  togglePasswordMask() {
    this.maskPassword = !this.maskPassword;
  }

  @action
  handleForgotPassword(event) {
    event?.preventDefault();
    this.modal.show(ForgotPassword, {
      model: {
        emailOrUsername: this.loginName,
      },
    });
  }

  @action
  async submitLogin(event) {
    event?.preventDefault();

    if (!this.loginName.trim()) {
      this.errorMessage = "Please enter your email or username";
      return;
    }

    if (!this.loginPassword && !this.showSecondFactor) {
      this.errorMessage = "Please enter your password";
      return;
    }

    this.isLoading = true;
    this.errorMessage = "";

    try {
      const data = {
        login: this.loginName.trim(),
        password: this.loginPassword,
        timezone: moment.tz.guess(),
      };

      if (this.showSecondFactor && this.secondFactorToken) {
        data.second_factor_token = this.secondFactorToken;
        data.second_factor_method = this.secondFactorMethod;
      }

      const result = await ajax("/session", {
        type: "POST",
        data,
      });

      if (result?.error) {
        if (result.security_key_enabled || result.totp_enabled) {
          this.showSecondFactor = true;
          this.secondFactorMethod = result.totp_enabled ? 1 : 2;
          if (result.totp_enabled) {
            this.errorMessage =
              "Please enter your two-factor authentication code";
          }
        } else {
          this.errorMessage = result.error;
        }
      } else {
        // Success - redirect to home
        window.location.href = "/";
      }
    } catch (e) {
      const errorMsg =
        e.jqXHR?.responseJSON?.error ||
        e.jqXHR?.responseJSON?.message ||
        "Login failed. Please try again.";
      this.errorMessage = errorMsg;

      // Check if 2FA is required from error response
      const response = e.jqXHR?.responseJSON;
      if (response?.security_key_enabled || response?.totp_enabled) {
        this.showSecondFactor = true;
        this.secondFactorMethod = response.totp_enabled ? 1 : 2;
        this.errorMessage = "";
      }
    } finally {
      this.isLoading = false;
    }
  }

  @action
  loginWithGoogle(event) {
    event?.preventDefault();
    if (this.googleProvider) {
      this.login.externalLogin(this.googleProvider);
    }
  }

  @action
  navigateToSignup(event) {
    event?.preventDefault();
    this.router.transitionTo("signup");
  }

  <template>
    <div class="fantribe-login-card">
      {{! Title }}
      <h1 class="fantribe-login-title">Sign In</h1>

      {{! Error Message }}
      {{#if this.errorMessage}}
        <div class="fantribe-login-error">
          {{this.errorMessage}}
        </div>
      {{/if}}

      {{! Login Form }}
      <form class="fantribe-login-form" {{on "submit" this.submitLogin}}>
        {{#if this.showSecondFactor}}
          {{! Two-Factor Authentication }}
          <div class="fantribe-input-group">
            <label for="fantribe-login-2fa">Authentication Code</label>
            <input
              type="text"
              id="fantribe-login-2fa"
              placeholder="Enter code"
              value={{this.secondFactorToken}}
              autocomplete="one-time-code"
              inputmode="numeric"
              {{on "input" this.updateSecondFactorToken}}
            />
          </div>
        {{else}}
          {{! Email/Username Input }}
          <div class="fantribe-input-group">
            <label for="fantribe-login-email">Email or Username</label>
            <input
              type="text"
              id="fantribe-login-email"
              placeholder="Enter email or username"
              value={{this.loginName}}
              autocomplete="username"
              autocorrect="off"
              autocapitalize="off"
              {{on "input" this.updateLoginName}}
            />
          </div>

          {{! Password Input }}
          <div class="fantribe-input-group fantribe-input-password">
            <label for="fantribe-login-password">Password</label>
            <div class="fantribe-password-wrapper">
              <input
                type={{if this.maskPassword "password" "text"}}
                id="fantribe-login-password"
                placeholder="Enter password"
                value={{this.loginPassword}}
                autocomplete="current-password"
                maxlength="200"
                {{on "input" this.updateLoginPassword}}
              />
              <button
                type="button"
                class="fantribe-password-toggle"
                {{on "click" this.togglePasswordMask}}
              >
                {{#if this.maskPassword}}
                  {{icon "far-eye"}}
                {{else}}
                  {{icon "far-eye-slash"}}
                {{/if}}
              </button>
            </div>
            <div class="fantribe-forgot-password">
              <a href {{on "click" this.handleForgotPassword}}>
                Forgot password?
              </a>
            </div>
          </div>
        {{/if}}

        {{! Submit Button }}
        <button
          type="submit"
          class="fantribe-btn-primary {{if this.isLoading 'is-loading'}}"
          disabled={{this.isLoading}}
        >
          {{#if this.isLoading}}
            <span class="fantribe-spinner"></span>
          {{else}}
            Sign In
          {{/if}}
        </button>
      </form>

      {{! OAuth & Signup Section }}
      <div class="fantribe-oauth-signup-section">
        {{! Google OAuth }}
        {{#if this.googleProvider}}
          <button
            type="button"
            class="fantribe-btn-google"
            {{on "click" this.loginWithGoogle}}
          >
            <svg
              class="fantribe-google-icon"
              viewBox="0 0 24 24"
              width="24"
              height="24"
            >
              <path
                fill="#4285F4"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              ></path>
              <path
                fill="#34A853"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              ></path>
              <path
                fill="#FBBC05"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              ></path>
              <path
                fill="#EA4335"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              ></path>
            </svg>
            <span>Continue with Google</span>
          </button>
        {{/if}}

        {{! Sign up link — mirrors "Already have an account? Sign In" on signup page }}
        <div class="fantribe-signup-link">
          <span>Don't have an account?</span>
          <a href={{this.signupUrl}} {{on "click" this.navigateToSignup}}>Sign
            Up</a>
        </div>
      </div>
    </div>
  </template>
}
