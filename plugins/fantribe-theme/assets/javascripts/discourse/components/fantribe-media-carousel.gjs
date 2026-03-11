import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { throttle } from "@ember/runloop";
import { modifier } from "ember-modifier";
import concatClass from "discourse/helpers/concat-class";
import { isTesting } from "discourse/lib/environment";
import { eq } from "discourse/truth-helpers";
import ftIcon from "../helpers/ft-icon";
import FantribeMediaAudio from "./fantribe-media-audio";
import FantribeMediaSingleImage from "./fantribe-media-single-image";
import FantribeMediaVideo from "./fantribe-media-video";

const SCROLL_THROTTLE_MS = 50;

export default class FantribeMediaCarousel extends Component {
  @tracked currentIndex = 0;

  registerSlide = modifier((element, [index]) => {
    this.#slides.set(index, element);
    return () => {
      this.#slides.delete(index);
    };
  });
  setupTrack = modifier((element) => {
    const updateIndex = () => {
      const newIndex = this.#calculateNearestIndex(element);
      if (newIndex !== this.currentIndex) {
        this.pauseMediaAt(this.currentIndex);
        this.currentIndex = newIndex;
      }
    };

    const supportsScrollEnd = "onscrollend" in window;
    let scrollStopTimer;

    const onScroll = () => {
      if (!isTesting()) {
        throttle(this, updateIndex, SCROLL_THROTTLE_MS);
      }

      if (!supportsScrollEnd) {
        clearTimeout(scrollStopTimer);
        scrollStopTimer = setTimeout(updateIndex, 150);
      }
    };

    element.addEventListener("scroll", onScroll, { passive: true });

    if (supportsScrollEnd && !isTesting()) {
      element.addEventListener("scrollend", updateIndex);
    }

    return () => {
      element.removeEventListener("scroll", onScroll);
      if (supportsScrollEnd && !isTesting()) {
        element.removeEventListener("scrollend", updateIndex);
      }
      clearTimeout(scrollStopTimer);
    };
  });
  #slides = new Map();

  #calculateNearestIndex(track) {
    if (!track) {
      return this.currentIndex;
    }

    const trackCenter = track.scrollLeft + track.clientWidth / 2;
    let bestIndex = 0;
    let minDistance = Infinity;

    this.#slides.forEach((slide, index) => {
      const slideCenter = slide.offsetLeft + slide.offsetWidth / 2;
      const distance = Math.abs(slideCenter - trackCenter);
      if (distance < minDistance) {
        minDistance = distance;
        bestIndex = index;
      }
    });

    return bestIndex;
  }

  get #scrollBehavior() {
    return window.matchMedia?.("(prefers-reduced-motion: reduce)")?.matches
      ? "auto"
      : "smooth";
  }

  get mediaItems() {
    return this.args.mediaItems || [];
  }

  get isSingle() {
    return this.mediaItems.length < 2;
  }

  get indicatorText() {
    return `${this.currentIndex + 1}/${this.mediaItems.length}`;
  }

  get hasPrev() {
    return this.currentIndex > 0;
  }

  get hasNext() {
    return this.currentIndex < this.mediaItems.length - 1;
  }

  get prevIndex() {
    return this.currentIndex - 1;
  }

  get nextIndex() {
    return this.currentIndex + 1;
  }

  @action
  pauseMediaAt(index) {
    const slide = this.#slides.get(index);
    if (!slide) {
      return;
    }

    const video = slide.querySelector("video");
    const audio = slide.querySelector("audio");
    video?.pause();
    audio?.pause();
  }

  @action
  scrollToIndex(index) {
    const slide = this.#slides.get(index);
    if (slide) {
      this.pauseMediaAt(this.currentIndex);
      this.currentIndex = index;
      slide.scrollIntoView({
        behavior: this.#scrollBehavior,
        block: "nearest",
        inline: "center",
      });
    }
  }

  @action
  handleTrackClick(event) {
    event.stopPropagation();
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class={{concatClass
        "fantribe-media-carousel"
        (if this.isSingle "fantribe-media-carousel--single")
      }}
      {{on "click" this.handleTrackClick}}
    >
      <div class="fantribe-media-carousel__track" {{this.setupTrack}}>
        {{#each this.mediaItems as |item index|}}
          <div
            class={{concatClass
              "fantribe-media-carousel__slide"
              (if (eq this.currentIndex index) "is-active")
            }}
            data-index={{index}}
            {{this.registerSlide index}}
          >
            {{#if (eq item.type "video")}}
              <FantribeMediaVideo
                @videoUrl={{item.url}}
                @thumbnailUrl={{item.thumbnail_url}}
              />
            {{else if (eq item.type "audio")}}
              <FantribeMediaAudio @audioUrl={{item.url}} />
            {{else}}
              <FantribeMediaSingleImage @imageUrl={{item.url}} />
            {{/if}}
          </div>
        {{/each}}
      </div>

      {{#unless this.isSingle}}
        {{! Overlay indicator badge - top right }}
        <div class="fantribe-media-carousel__indicator">
          {{this.indicatorText}}
        </div>

        {{! Overlay nav buttons - left/right edges }}
        {{#if this.hasPrev}}
          <button
            type="button"
            class="fantribe-media-carousel__nav fantribe-media-carousel__nav--prev"
            aria-label="Previous"
            {{on "click" (fn this.scrollToIndex this.prevIndex)}}
          >
            {{ftIcon "chevron-left"}}
          </button>
        {{/if}}
        {{#if this.hasNext}}
          <button
            type="button"
            class="fantribe-media-carousel__nav fantribe-media-carousel__nav--next"
            aria-label="Next"
            {{on "click" (fn this.scrollToIndex this.nextIndex)}}
          >
            {{ftIcon "chevron-right"}}
          </button>
        {{/if}}
      {{/unless}}
    </div>
  </template>
}
