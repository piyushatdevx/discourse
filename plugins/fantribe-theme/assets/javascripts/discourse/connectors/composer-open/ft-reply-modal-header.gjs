import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import { EDIT, REPLY } from "discourse/models/composer";
import { and } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import ftIcon from "../../helpers/ft-icon";

export default class FtReplyModalHeader extends Component {
  @service composer;
  @service currentUser;
  @service siteSettings;

  get model() {
    return this.args.outletArgs?.model;
  }

  get isReply() {
    return this.model?.action === REPLY;
  }

  get isEdit() {
    return this.model?.action === EDIT;
  }

  get themeEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get shouldRender() {
    return (
      this.themeEnabled && (this.isReply || this.isEdit) && this.currentUser
    );
  }

  get titleKey() {
    if (this.isEdit) {
      return "composer.edit_reply_title";
    }
    return "composer.reply";
  }

  get topic() {
    return this.model?.topic;
  }

  @action
  closeComposer() {
    this.composer.saveAndClose?.();
  }

  <template>
    {{#if this.shouldRender}}
      <div class="ft-reply-modal-header">
        <div class="ft-modal__title-bar">
          <h2 class="ft-modal__title">{{i18n this.titleKey}}</h2>
          <button
            type="button"
            class="ft-modal__close-btn"
            {{on "click" this.closeComposer}}
            title={{i18n "composer.save_and_close"}}
          >
            {{ftIcon "x"}}
          </button>
        </div>
        <div class="ft-modal__user-info">
          <div class="ft-modal__avatar">
            {{avatar this.currentUser imageSize="medium"}}
          </div>
          <div>
            <div class="ft-modal__user-name">{{this.currentUser.name}}</div>
            <div class="ft-modal__user-handle">
              @{{this.currentUser.username}}
            </div>
          </div>
        </div>
        {{#if (and this.isReply this.topic)}}
          <div class="ft-modal__tribe-section ft-reply-modal__replying-to">
            <label class="ft-modal__tribe-section-label">
              {{i18n "composer.replying_to"}}
            </label>
            <a
              href={{this.topic.url}}
              class="ft-modal__tribe-select-value ft-reply-modal__topic-link"
            >
              {{this.topic.title}}
            </a>
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
