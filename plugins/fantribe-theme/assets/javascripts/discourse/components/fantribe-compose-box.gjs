import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
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

  @action
  handleKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.openComposer();
    }
  }

  <template>
    <div
      class="fantribe-compose-box"
      role="button"
      tabindex="0"
      {{on "click" this.openComposer}}
      {{on "keydown" this.handleKeydown}}
    >
      <div class="fantribe-compose-box__input-area">
        <div class="fantribe-compose-box__avatar">
          {{#if this.currentUser}}
            {{avatar this.currentUser imageSize="medium"}}
          {{else}}
            <span class="fantribe-compose-box__avatar-initials">?</span>
          {{/if}}
        </div>

        <div class="fantribe-compose-box__input-wrapper">
          <div class="fantribe-compose-box__input-placeholder">What's on your
            mind?</div>
        </div>
      </div>

      <div class="fantribe-compose-box__actions">
        <div class="fantribe-compose-box__media-buttons">
          <span
            class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--image"
            title="Add image"
          >
            {{icon "image"}}
          </span>
          <span
            class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--video"
            title="Add video"
          >
            {{icon "video"}}
          </span>
          <span
            class="fantribe-compose-box__media-btn fantribe-compose-box__media-btn--emoji"
            title="Add emoji"
          >
            {{icon "face-smile"}}
          </span>
        </div>

        <span class="fantribe-compose-box__share-btn">
          {{icon "paper-plane"}}
          Share
        </span>
      </div>
    </div>
  </template>
}
