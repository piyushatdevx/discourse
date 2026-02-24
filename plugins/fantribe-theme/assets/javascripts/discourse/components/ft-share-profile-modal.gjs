import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import ftIcon from "../helpers/ft-icon";

export default class FtShareProfileModal extends Component {
  @tracked copied = false;
  #copyTimer = null;

  get profileUrl() {
    return `${window.location.origin}/u/${this.args.user?.username}`;
  }

  @action
  async copyLink() {
    try {
      await navigator.clipboard.writeText(this.profileUrl);
    } catch {
      // Fallback for browsers without Clipboard API
      const input = document.createElement("input");
      input.value = this.profileUrl;
      document.body.appendChild(input);
      input.select();

      document.execCommand("copy");
      document.body.removeChild(input);
    }
    this.copied = true;
    clearTimeout(this.#copyTimer);
    this.#copyTimer = setTimeout(() => {
      this.copied = false;
    }, 2500);
  }

  @action
  shareToTwitter() {
    const name = this.args.user?.name || this.args.user?.username;
    const text = `Check out ${name}'s profile on FanTribe`;
    const tweetUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(this.profileUrl)}`;
    window.open(tweetUrl, "_blank", "noopener,noreferrer,width=600,height=400");
  }

  @action
  shareToWhatsApp() {
    const name = this.args.user?.name || this.args.user?.username;
    const text = `Check out ${name}'s profile on FanTribe: ${this.profileUrl}`;
    const waUrl = `https://wa.me/?text=${encodeURIComponent(text)}`;
    window.open(waUrl, "_blank", "noopener,noreferrer");
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

  get truncatedUrl() {
    const url = this.profileUrl;
    return url.length > 42 ? `${url.substring(0, 42)}…` : url;
  }

  get twitterLogoHtml() {
    return htmlSafe(
      `<svg class="ft-share-modal__social-icon" viewBox="0 0 24 24" fill="currentColor" width="18" height="18" aria-hidden="true">
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.73-8.835L2.253 2.25h7.177l4.27 5.634zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
      </svg>`
    );
  }

  get whatsappLogoHtml() {
    return htmlSafe(
      `<svg class="ft-share-modal__social-icon" viewBox="0 0 24 24" fill="currentColor" width="18" height="18" aria-hidden="true">
        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
      </svg>`
    );
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{#if @user}}
      <div
        class="ft-modal-backdrop"
        role="dialog"
        aria-modal="true"
        aria-label="Share profile"
        {{on "click" this.handleBackdropClick}}
        {{on "keydown" this.handleKeydown}}
      >
        <div class="ft-modal ft-share-modal">

          {{! Header }}
          <div class="ft-modal__title-bar">
            <h2 class="ft-modal__title">Share Profile</h2>
            <button
              type="button"
              class="ft-modal__close-btn"
              aria-label="Close"
              {{on "click" @onClose}}
            >
              {{ftIcon "x"}}
            </button>
          </div>

          {{! Profile preview card }}
          <div class="ft-share-modal__preview">
            <div class="ft-share-modal__preview-avatar">
              {{avatar @user imageSize="large"}}
            </div>
            <div class="ft-share-modal__preview-info">
              <div class="ft-share-modal__preview-name">
                {{#if
                  @user.name
                }}{{@user.name}}{{else}}{{@user.username}}{{/if}}
              </div>
              <div
                class="ft-share-modal__preview-handle"
              >@{{@user.username}}</div>
            </div>
          </div>

          {{! Copy link row }}
          <div class="ft-share-modal__section">
            <p class="ft-share-modal__section-label">Profile link</p>
            <div class="ft-share-modal__link-row">
              <div class="ft-share-modal__link-display">
                {{ftIcon "link2" size=14}}
                <span
                  class="ft-share-modal__link-text"
                >{{this.truncatedUrl}}</span>
              </div>
              <button
                type="button"
                class="ft-share-modal__copy-btn
                  {{if this.copied 'ft-share-modal__copy-btn--copied'}}"
                {{on "click" this.copyLink}}
              >
                {{#if this.copied}}
                  {{ftIcon "check" size=14}}
                  Copied!
                {{else}}
                  Copy Link
                {{/if}}
              </button>
            </div>
          </div>

          {{! Social share }}
          <div class="ft-share-modal__section">
            <p class="ft-share-modal__section-label">Share on social</p>
            <div class="ft-share-modal__socials-row">
              <button
                type="button"
                class="ft-share-modal__social-btn ft-share-modal__social-btn--twitter"
                {{on "click" this.shareToTwitter}}
              >
                {{this.twitterLogoHtml}}
                <span>X (Twitter)</span>
              </button>
              <button
                type="button"
                class="ft-share-modal__social-btn ft-share-modal__social-btn--whatsapp"
                {{on "click" this.shareToWhatsApp}}
              >
                {{this.whatsappLogoHtml}}
                <span>WhatsApp</span>
              </button>
            </div>
          </div>

        </div>
      </div>
    {{/if}}
  </template>
}
