import Component from "@glimmer/component";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { and, eq } from "discourse/truth-helpers";

export default class FantribeMediaPhotoGrid extends Component {
  get images() {
    return this.args.images || [];
  }

  get displayImages() {
    // Show max 4 images in grid
    return this.images.slice(0, 4);
  }

  get hasMore() {
    return this.images.length > 4;
  }

  get moreCount() {
    return `+${this.images.length - 4}`;
  }

  get gridClass() {
    const count = Math.min(this.images.length, 4);
    const baseClass = "fantribe-media-grid";
    if (count === 2) return `${baseClass} ${baseClass}--2`;
    if (count === 3) return `${baseClass} ${baseClass}--3`;
    if (count >= 4)
      return `${baseClass} ${baseClass}--${this.hasMore ? "more" : "4"}`;
    return baseClass;
  }

  @action
  handleImageClick(index, event) {
    event.stopPropagation();
    // Open lightbox/gallery view
  }

  blurStyle(url) {
    return `background-image: url('${url}');`;
  }

  <template>
    {{#if this.images.length}}
      <div class={{this.gridClass}}>
        {{#each this.displayImages as |image index|}}
          <div
            class="fantribe-media-grid__item
              {{if
                (and this.hasMore (eq index 3))
                'fantribe-media-grid__item--more'
              }}"
            data-more-count={{if
              (and this.hasMore (eq index 3))
              this.moreCount
            }}
            {{on "click" (fn this.handleImageClick index)}}
          >
            <div
              class="fantribe-media-grid__blur-bg"
              style={{this.blurStyle image.url}}
            ></div>
            <img src={{image.url}} alt="Gallery image" loading="lazy" />
          </div>
        {{/each}}
      </div>
    {{/if}}
  </template>
}
