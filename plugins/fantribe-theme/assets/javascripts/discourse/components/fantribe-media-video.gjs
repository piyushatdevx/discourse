import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";

export default class FantribeMediaVideo extends Component {
  @tracked isPlaying = false;

  get thumbnailUrl() {
    return this.args.thumbnailUrl;
  }

  get videoUrl() {
    return this.args.videoUrl;
  }

  get duration() {
    return this.args.duration || "";
  }

  @action
  handlePlay(event) {
    event.stopPropagation();
    this.isPlaying = true;
    // In production, this would start video playback
  }

  <template>
    <div class="fantribe-media-video">
      {{#if this.thumbnailUrl}}
        <img
          class="fantribe-media-video__thumbnail"
          src={{this.thumbnailUrl}}
          alt="Video thumbnail"
          loading="lazy"
        />
      {{/if}}

      {{#unless this.isPlaying}}
        <button
          type="button"
          class="fantribe-media-video__overlay"
          {{on "click" this.handlePlay}}
        >
          <div class="fantribe-media-video__play-btn">
            {{icon "play"}}
          </div>
        </button>

        {{#if this.duration}}
          <span class="fantribe-media-video__duration">{{this.duration}}</span>
        {{/if}}
      {{/unless}}
    </div>
  </template>
}
