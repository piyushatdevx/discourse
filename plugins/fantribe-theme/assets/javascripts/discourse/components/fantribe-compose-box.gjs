import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

export default class FantribeComposeBox extends Component {
  @service currentUser;
  @service fantribeCreate;

  @action
  openModal() {
    this.fantribeCreate.openCreatePostModal();
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="fantribe-compose-box" {{on "click" this.openModal}}>
      <div class="fantribe-compose-box__input-area">
        <div class="fantribe-compose-box__avatar">
          {{#if this.currentUser}}
            {{avatar this.currentUser imageSize="medium"}}
          {{/if}}
        </div>

        <div class="fantribe-compose-box__content">
          <div class="fantribe-compose-box__input-placeholder">
            {{i18n "fantribe.compose.placeholder"}}
          </div>

          <div class="fantribe-compose-box__actions">
            <button
              type="button"
              class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--photo"
              title={{i18n "fantribe.compose.photo"}}
            >
              {{ftIcon "image"}}
              <span>{{i18n "fantribe.compose.photo"}}</span>
            </button>
            <button
              type="button"
              class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--video"
              title={{i18n "fantribe.compose.video"}}
            >
              {{ftIcon "video"}}
              <span>{{i18n "fantribe.compose.video"}}</span>
            </button>
            <button
              type="button"
              class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--audio"
              title={{i18n "fantribe.compose.audio"}}
            >
              {{ftIcon "headphones"}}
              <span>{{i18n "fantribe.compose.audio"}}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
