import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { htmlSafe } from "@ember/template";
import observeIntersection from "discourse/modifiers/observe-intersection";
import ftIcon from "../helpers/ft-icon";

export default class FantribeMediaVideo extends Component {
  @tracked isLoaded = false;
  @tracked isPlaying = false;
  @tracked isMuted = false;
  @tracked currentTime = 0;
  @tracked duration = 0;
  @tracked showControls = true;
  @tracked isFullscreen = false;
  @tracked generatedThumbnail = null;

  videoElement = null;
  containerElement = null;
  hideControlsTimeout = null;
  isPausedByViewport = false;

  willDestroy() {
    super.willDestroy?.();
    this.clearHideControlsTimeout();
    if (this.videoElement) {
      this.videoElement.pause();
      this.videoElement = null;
    }
  }

  get thumbnailUrl() {
    return this.args.thumbnailUrl || this.generatedThumbnail;
  }

  get videoUrl() {
    return this.args.videoUrl;
  }

  get progressPercent() {
    if (!this.duration) {
      return 0;
    }
    return (this.currentTime / this.duration) * 100;
  }

  get timeDisplay() {
    const formatTime = (seconds) => {
      const mins = Math.floor(seconds / 60);
      const secs = Math.floor(seconds % 60);
      return `${mins}:${secs.toString().padStart(2, "0")}`;
    };
    return `${formatTime(this.currentTime)} / ${formatTime(this.duration)}`;
  }

  @action
  handleVisibilityChange(entry) {
    if (!entry.isIntersecting && this.isPlaying && this.videoElement) {
      this.videoElement.pause();
      this.isPausedByViewport = true;
    }
  }

  @action
  setupContainer(element) {
    this.containerElement = element;
    this.generateThumbnailFromVideo();
  }

  @action
  generateThumbnailFromVideo() {
    if (
      this.args.thumbnailUrl ||
      this.generatedThumbnail ||
      !this.args.videoUrl
    ) {
      return;
    }

    const video = document.createElement("video");
    video.crossOrigin = "anonymous";
    video.muted = true;
    video.preload = "metadata";

    video.onloadeddata = () => {
      video.currentTime = 0.1;
    };

    video.onseeked = () => {
      try {
        const canvas = document.createElement("canvas");
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        const ctx = canvas.getContext("2d");
        ctx.drawImage(video, 0, 0);
        this.generatedThumbnail = canvas.toDataURL("image/jpeg", 0.8);
      } catch {
        // Cross-origin or other error - fail silently
      }
      video.remove();
    };

    video.onerror = () => {
      video.remove();
    };

    video.src = this.args.videoUrl;
  }

  @action
  setupVideo(element) {
    this.videoElement = element;
    if (this.videoElement) {
      this.videoElement.play().catch(() => {});
    }
  }

  @action
  handleThumbnailClick(event) {
    event.stopPropagation();
    this.isLoaded = true;
  }

  @action
  togglePlay(event) {
    event?.stopPropagation();
    if (!this.videoElement) {
      return;
    }

    if (this.isPlaying) {
      this.videoElement.pause();
    } else {
      this.isPausedByViewport = false;
      this.videoElement.play().catch(() => {});
    }
  }

  @action
  toggleMute(event) {
    event?.stopPropagation();
    if (!this.videoElement) {
      return;
    }
    this.videoElement.muted = !this.videoElement.muted;
    this.isMuted = this.videoElement.muted;
  }

  @action
  handleSeek(event) {
    event.stopPropagation();
    if (!this.videoElement || !this.duration) {
      return;
    }

    const rect = event.currentTarget.getBoundingClientRect();
    const clickX = event.clientX - rect.left;
    const percent = clickX / rect.width;
    this.videoElement.currentTime = percent * this.duration;
  }

  @action
  toggleFullscreen(event) {
    event?.stopPropagation();
    if (!this.containerElement) {
      return;
    }

    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      this.containerElement.requestFullscreen().catch(() => {});
    }
  }

  @action
  handleTimeUpdate() {
    if (this.videoElement) {
      this.currentTime = this.videoElement.currentTime;
    }
  }

  @action
  handleLoadedMetadata() {
    if (this.videoElement) {
      this.duration = this.videoElement.duration;
    }
  }

  @action
  handlePlayEvent() {
    this.isPlaying = true;
    this.scheduleHideControls();
  }

  @action
  handlePauseEvent() {
    this.isPlaying = false;
    this.showControls = true;
    this.clearHideControlsTimeout();
  }

  @action
  handleEnded() {
    this.isPlaying = false;
    this.showControls = true;
  }

  @action
  handleMouseMove() {
    this.showControls = true;
    this.scheduleHideControls();
  }

  @action
  handleMouseLeave() {
    if (this.isPlaying) {
      this.scheduleHideControls();
    }
  }

  @action
  handleControlsClick(event) {
    event.stopPropagation();
  }

  @action
  handleFullscreenChange() {
    this.isFullscreen = !!document.fullscreenElement;
  }

  scheduleHideControls() {
    this.clearHideControlsTimeout();
    if (this.isPlaying) {
      this.hideControlsTimeout = setTimeout(() => {
        this.showControls = false;
      }, 3000);
    }
  }

  clearHideControlsTimeout() {
    if (this.hideControlsTimeout) {
      clearTimeout(this.hideControlsTimeout);
      this.hideControlsTimeout = null;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="fantribe-media-video
        {{if this.isPlaying 'fantribe-media-video--playing'}}
        {{if this.isFullscreen 'fantribe-media-video--fullscreen'}}"
      {{didInsert this.setupContainer}}
      {{observeIntersection this.handleVisibilityChange threshold=0.5}}
      {{on "fullscreenchange" this.handleFullscreenChange}}
      {{on "mousemove" this.handleMouseMove}}
      {{on "mouseleave" this.handleMouseLeave}}
    >
      {{#if this.isLoaded}}
        <div class="fantribe-media-video__player">
          {{! template-lint-disable require-media-caption }}
          <video
            src={{this.videoUrl}}
            preload="metadata"
            playsinline
            {{didInsert this.setupVideo}}
            {{on "timeupdate" this.handleTimeUpdate}}
            {{on "loadedmetadata" this.handleLoadedMetadata}}
            {{on "ended" this.handleEnded}}
            {{on "play" this.handlePlayEvent}}
            {{on "pause" this.handlePauseEvent}}
            {{on "click" this.togglePlay}}
          >
          </video>

          <div
            class="fantribe-media-video__controls
              {{unless
                this.showControls
                'fantribe-media-video__controls--hidden'
              }}"
            {{on "click" this.handleControlsClick}}
          >
            <button
              type="button"
              class="fantribe-media-video__control-btn"
              aria-label={{if this.isPlaying "Pause" "Play"}}
              {{on "click" this.togglePlay}}
            >
              {{#if this.isPlaying}}
                {{ftIcon "pause" size=20}}
              {{else}}
                {{ftIcon "play" size=20}}
              {{/if}}
            </button>

            <button
              type="button"
              class="fantribe-media-video__progress"
              aria-label="Seek"
              {{on "click" this.handleSeek}}
            >
              <div
                class="fantribe-media-video__progress-bar"
                style={{htmlSafe (concat "width: " this.progressPercent "%")}}
              ></div>
            </button>

            <span class="fantribe-media-video__time">{{this.timeDisplay}}</span>

            <button
              type="button"
              class="fantribe-media-video__control-btn"
              aria-label={{if this.isMuted "Unmute" "Mute"}}
              {{on "click" this.toggleMute}}
            >
              {{#if this.isMuted}}
                {{ftIcon "volume-x" size=20}}
              {{else}}
                {{ftIcon "volume-2" size=20}}
              {{/if}}
            </button>

            <button
              type="button"
              class="fantribe-media-video__control-btn"
              aria-label={{if this.isFullscreen "Exit fullscreen" "Fullscreen"}}
              {{on "click" this.toggleFullscreen}}
            >
              {{#if this.isFullscreen}}
                {{ftIcon "minimize" size=20}}
              {{else}}
                {{ftIcon "maximize" size=20}}
              {{/if}}
            </button>
          </div>
        </div>
      {{else}}
        <div class="fantribe-media-video__thumbnail-wrapper">
          {{#if this.thumbnailUrl}}
            <img
              class="fantribe-media-video__thumbnail"
              src={{this.thumbnailUrl}}
              alt="Video thumbnail"
              loading="lazy"
            />
          {{else}}
            <div class="fantribe-media-video__placeholder"></div>
          {{/if}}

          <button
            type="button"
            class="fantribe-media-video__play-overlay"
            {{on "click" this.handleThumbnailClick}}
          >
            <div class="fantribe-media-video__play-btn">
              {{ftIcon "play" size=28}}
            </div>
          </button>
        </div>
      {{/if}}
    </div>
  </template>
}
