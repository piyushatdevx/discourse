import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
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
        <div class="fantribe-compose-box__input-placeholder">
          Share your sound...
        </div>
      </div>

      <div class="fantribe-compose-box__actions">
        <button
          type="button"
          class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--photo"
          title="Photo"
        >
          {{ftIcon "image"}}
          <span>Photo</span>
        </button>
        <button
          type="button"
          class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--video"
          title="Video"
        >
          {{ftIcon "video"}}
          <span>Video</span>
        </button>
        <button
          type="button"
          class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--audio"
          title="Audio"
        >
          {{ftIcon "headphones"}}
          <span>Audio</span>
        </button>
        <button
          type="button"
          class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--gear"
          title="Tag Gear"
        >
          {{ftIcon "tag"}}
          <span>Tag Gear</span>
        </button>
      </div>
    </div>
  </template>
}
