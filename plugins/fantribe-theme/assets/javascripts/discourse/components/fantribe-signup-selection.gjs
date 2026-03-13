import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { later } from "@ember/runloop";
import { service } from "@ember/service";
import getURL from "discourse/lib/get-url";
import DiscourseURL from "discourse/lib/url";
import { findAll } from "discourse/models/login-method";

export default class FantribeSignupSelection extends Component {
  @service login;

  @tracked showSelection = true;
  @tracked isLeaving = false;

  constructor() {
    super(...arguments);
    document.body.classList.add("fantribe-signup-selection-active");
  }

  willDestroy() {
    super.willDestroy(...arguments);
    document.body.classList.remove("fantribe-signup-selection-active");
  }

  get googleProvider() {
    return findAll().find((m) => m.name === "google_oauth2");
  }

  get facebookProvider() {
    return findAll().find((m) => m.name === "facebook");
  }

  get loginUrl() {
    return getURL("/login");
  }

  @action
  continueWithGoogle(event) {
    event?.preventDefault();
    if (this.googleProvider) {
      this.login.externalLogin(this.googleProvider, {
        signup: true,
      });
    }
  }

  @action
  continueWithFacebook(event) {
    event?.preventDefault();
    if (this.facebookProvider) {
      this.login.externalLogin(this.facebookProvider, {
        signup: true,
      });
    }
  }

  @action
  goToCreateAccount() {
    this.isLeaving = true;

    later(
      this,
      () => {
        this.showSelection = false;
        document.body.classList.remove("fantribe-signup-selection-active");
        document.body.classList.add("fantribe-signup-form-entering");

        later(
          this,
          () => {
            document.body.classList.remove("fantribe-signup-form-entering");
          },
          500
        );
      },
      350
    );
  }

  @action
  navigateToLogin(event) {
    event?.preventDefault();
    DiscourseURL.routeTo(this.loginUrl);
  }

  <template>
    {{#if this.showSelection}}
      <div
        class="fantribe-signup-selection
          {{if this.isLeaving 'fantribe-signup-selection--leaving'}}"
      >
        <div class="fantribe-signup-selection__card">
          <h1 class="fantribe-signup-selection__title">Sign Up</h1>

          <div class="fantribe-signup-selection__content">
            <div class="fantribe-signup-selection__social-buttons">
              {{#if this.googleProvider}}
                <button
                  type="button"
                  class="fantribe-signup-selection__social-btn"
                  {{on "click" this.continueWithGoogle}}
                >
                  <svg
                    class="fantribe-signup-selection__social-icon"
                    viewBox="0 0 24 24"
                    width="20"
                    height="20"
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

              {{#if this.facebookProvider}}
                <button
                  type="button"
                  class="fantribe-signup-selection__social-btn"
                  {{on "click" this.continueWithFacebook}}
                >
                  <svg
                    class="fantribe-signup-selection__social-icon"
                    viewBox="0 0 24 24"
                    width="20"
                    height="20"
                  >
                    <path
                      fill="#1877F2"
                      d="M24 12c0-6.627-5.373-12-12-12S0 5.373 0 12c0 5.99 4.388 10.954 10.125 11.854V15.47H7.078V12h3.047V9.356c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.875V12h3.328l-.532 3.47h-2.796v8.384C19.612 22.954 24 17.99 24 12z"
                    ></path>
                  </svg>
                  <span>Continue with Facebook</span>
                </button>
              {{/if}}
            </div>

            <span class="fantribe-signup-selection__or">Or</span>

            <button
              type="button"
              class="fantribe-signup-selection__create-btn"
              {{on "click" this.goToCreateAccount}}
            >
              Create account
            </button>
          </div>

          <div class="fantribe-signup-selection__signin">
            <span>Already have an account?</span>
            <a href={{this.loginUrl}} {{on "click" this.navigateToLogin}}>Sign
              In</a>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
