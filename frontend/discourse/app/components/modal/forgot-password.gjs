import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { isEmpty } from "@ember/utils";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { ajax } from "discourse/lib/ajax";
import { extractError } from "discourse/lib/ajax-error";
import cookie from "discourse/lib/cookie";
import getURL from "discourse/lib/get-url";
import { escapeExpression } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";

export default class ForgotPassword extends Component {
  @service siteSettings;

  @tracked
  emailOrUsername = cookie("email") || this.args.model?.emailOrUsername || "";
  @tracked disabled = false;
  @tracked helpSeen = false;
  @tracked offerHelp;
  @tracked flash;

  get submitDisabled() {
    if (this.disabled) {
      return true;
    } else if (this.siteSettings.hide_email_address_taken) {
      return !this.emailOrUsername.includes("@");
    } else {
      return isEmpty(this.emailOrUsername.trim());
    }
  }

  @action
  updateEmailOrUsername(event) {
    this.emailOrUsername = event.target.value;
  }

  @action
  help() {
    this.offerHelp = i18n("forgot_password.help", { basePath: getURL("") });
    this.helpSeen = true;
  }

  @action
  async resetPassword() {
    if (this.submitDisabled) {
      return false;
    }

    this.disabled = true;
    this.flash = null;

    try {
      const data = await ajax("/session/forgot_password", {
        data: { login: this.emailOrUsername.trim() },
        type: "POST",
      });

      const emailOrUsername = escapeExpression(this.emailOrUsername);

      let key = "forgot_password.complete";
      key += emailOrUsername.match(/@/) ? "_email" : "_username";

      if (data.user_found === false) {
        key += "_not_found";

        this.flash = htmlSafe(
          i18n(key, {
            email: emailOrUsername,
            username: emailOrUsername,
          })
        );
      } else {
        key += data.user_found ? "_found" : "";

        this.emailOrUsername = "";
        this.offerHelp = i18n(key, {
          email: emailOrUsername,
          username: emailOrUsername,
        });

        this.helpSeen = !data.user_found;
      }
    } catch (error) {
      this.flash = extractError(error);
    } finally {
      this.disabled = false;
    }
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @flash={{this.flash}}
      @flashType="error"
      class="forgot-password-modal"
    >
      <:body>
        {{#if this.offerHelp}}
          <div class="forgot-password-modal__header">
            <h2 class="forgot-password-modal__title">Reset your password</h2>
          </div>
          <div class="forgot-password-modal__help-content">
            {{htmlSafe this.offerHelp}}
          </div>
          <div class="forgot-password-modal__actions">
            <DButton
              @action={{@closeModal}}
              @label="forgot_password.button_ok"
              type="submit"
              class="btn-primary forgot-password-modal__btn"
            />
            {{#unless this.helpSeen}}
              <DButton
                @action={{this.help}}
                @label="forgot_password.button_help"
                @icon="circle-question"
                class="forgot-password-modal__btn forgot-password-modal__btn--secondary"
              />
            {{/unless}}
          </div>
        {{else}}
          <div class="forgot-password-modal__header">
            <h2 class="forgot-password-modal__title">Reset your password</h2>
            <p class="forgot-password-modal__subtitle">Verify your email
              address, and we'll send you a password reset email.</p>
          </div>
          <div class="forgot-password-modal__form">
            <div class="forgot-password-modal__field">
              <label
                for="username-or-email"
                class="forgot-password-modal__label"
              >Email</label>
              <input
                {{on "input" this.updateEmailOrUsername}}
                value={{this.emailOrUsername}}
                placeholder="your.email@example.com"
                type="text"
                id="username-or-email"
                autocorrect="off"
                autocapitalize="off"
                class="forgot-password-modal__input"
              />
            </div>
            <button
              type="submit"
              disabled={{this.submitDisabled}}
              class="forgot-password-modal__submit"
              {{on "click" this.resetPassword}}
            >
              Send link
            </button>
          </div>
        {{/if}}
      </:body>
    </DModal>
  </template>
}
