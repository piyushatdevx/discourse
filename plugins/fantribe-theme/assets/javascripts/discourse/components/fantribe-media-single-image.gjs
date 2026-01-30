import Component from "@glimmer/component";
import { concat } from "@ember/helper";

export default class FantribeMediaSingleImage extends Component {
  get imageUrl() {
    return this.args.imageUrl;
  }

  get blurStyle() {
    return `background-image: url('${this.imageUrl}');`;
  }

  <template>
    {{#if this.imageUrl}}
      <div class="fantribe-media-image">
        <div
          class="fantribe-media-image__blur-bg"
          style={{this.blurStyle}}
        ></div>
        <div class="fantribe-media-image__main">
          <img src={{this.imageUrl}} alt="Post image" loading="lazy" />
        </div>
      </div>
    {{/if}}
  </template>
}
