import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";

export default class FantribeComposeBox extends Component {
  @service currentUser;
  @service composer;

  @action
  openComposer() {
    this.composer.open({
      action: "createTopic",
      draftKey: "new_topic",
      draftSequence: 0,
      title: "",
      body: "",
    });
  }

  get placeholderName() {
    return this.currentUser?.username ?? "User";
  }

  @action
  handleKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.openComposer();
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="fantribe-compose-box" {{on "click" this.openComposer}}>
      <div class="fantribe-compose-box__input-area">
        <div class="fantribe-compose-box__avatar">
          {{#if this.currentUser}}
            {{avatar this.currentUser imageSize="medium"}}
          {{else}}
            <span class="fantribe-compose-box__avatar-initials">?</span>
          {{/if}}
        </div>

        <div class="fantribe-compose-box__content">
          <div class="fantribe-compose-box__input-wrapper">
            <div class="fantribe-compose-box__input-placeholder">What's on your
              mind,
              {{this.placeholderName}}? Share what you're feeling...
            </div>
          </div>

          <div class="fantribe-compose-box__actions">
            <div class="fantribe-compose-box__media-buttons">
              <button
                type="button"
                class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--image"
                title="Add image"
              >
                📷
              </button>
              <button
                type="button"
                class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--video"
                title="Add video"
              >
                🎵
              </button>
              <button
                type="button"
                class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--emoji"
                title="Add emoji"
              >
                😊
              </button>
            </div>

            <span class="fantribe-compose-box__share-btn">
              Share
            </span>
          </div>
        </div>
      </div>
    </div>
  </template>
}
