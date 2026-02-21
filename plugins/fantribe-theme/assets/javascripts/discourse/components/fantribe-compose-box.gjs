import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";

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
            Share your sound...
          </div>

          <div class="fantribe-compose-box__actions">
            <button
              type="button"
              class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--photo"
              title="Photo"
            >
              {{icon "image"}}
              <span>Photo</span>
            </button>
            <button
              type="button"
              class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--video"
              title="Video"
            >
              {{icon "video"}}
              <span>Video</span>
            </button>
            <button
              type="button"
              class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--audio"
              title="Audio"
            >
              {{icon "headphones"}}
              <span>Audio</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
