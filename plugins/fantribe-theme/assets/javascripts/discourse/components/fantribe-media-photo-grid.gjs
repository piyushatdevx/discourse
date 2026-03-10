import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { and, eq } from "discourse/truth-helpers";

export default class FantribeMediaPhotoGrid extends Component {
  get images() {
    return this.args.images || [];
  }

  get maxDisplayCount() {
    const count = this.images.length;
    if (count <= 4) {
      return count; // Show exactly what exists — no phantom empty cells
    }
    if (count <= 9) {
      return 9;
    }
    return 16;
  }

  get displayImages() {
    return this.images.slice(0, this.maxDisplayCount);
  }

  get hasMore() {
    return this.images.length > this.maxDisplayCount;
  }

  get moreCount() {
    return `+${this.images.length - this.maxDisplayCount}`;
  }

  get lastDisplayIndex() {
    return this.displayImages.length - 1;
  }

  get gridClass() {
    const count = this.images.length;
    const baseClass = "fantribe-media-grid";

    if (count === 2) {
      return `${baseClass} ${baseClass}--2`;
    }
    if (count === 3) {
      return `${baseClass} ${baseClass}--3`;
    }
    if (count === 4) {
      return `${baseClass} ${baseClass}--4`;
    }
    if (count <= 9) {
      return `${baseClass} ${baseClass}--more`;
    }
    return `${baseClass} ${baseClass}--large`;
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
          <button
            type="button"
            class="fantribe-media-grid__item
              {{if
                (and this.hasMore (eq index this.lastDisplayIndex))
                'fantribe-media-grid__item--more'
              }}"
            data-more-count={{if
              (and this.hasMore (eq index this.lastDisplayIndex))
              this.moreCount
            }}
            {{on "click" (fn this.handleImageClick index)}}
          >
            <div
              class="fantribe-media-grid__blur-bg"
              style={{this.blurStyle image.url}}
            ></div>
            <img src={{image.url}} alt="Gallery image" loading="lazy" />
          </button>
        {{/each}}
      </div>
    {{/if}}
  </template>
}
