import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import observeIntersection from "discourse/modifiers/observe-intersection";
import ftIcon from "../helpers/ft-icon";

// Dynamic WaveSurfer loader - loads once and caches the promise
let waveSurferPromise = null;

function loadWaveSurfer() {
  if (waveSurferPromise) {
    return waveSurferPromise;
  }

  if (window.WaveSurfer) {
    return Promise.resolve(window.WaveSurfer);
  }

  waveSurferPromise = new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = "https://unpkg.com/wavesurfer.js@7/dist/wavesurfer.min.js";
    script.onload = () => resolve(window.WaveSurfer);
    script.onerror = () => reject(new Error("Failed to load WaveSurfer.js"));
    document.head.appendChild(script);
  });

  return waveSurferPromise;
}

export default class FantribeMediaAudio extends Component {
  @tracked isPlaying = false;
  @tracked duration = 0;
  @tracked currentTime = 0;
  @tracked isWaveformLoading = true;

  wavesurfer = null;
  containerElement = null;
  waveformElement = null;
  isPausedByViewport = false;

  willDestroy() {
    super.willDestroy?.();
    if (this.wavesurfer) {
      this.wavesurfer.destroy();
      this.wavesurfer = null;
    }
  }

  get audioUrl() {
    return this.args.audioUrl;
  }

  get trackTitle() {
    if (!this.audioUrl) {
      return "Audio Track";
    }
    try {
      const url = new URL(this.audioUrl, window.location.origin);
      const filename = url.pathname.split("/").pop();
      const name = decodeURIComponent(filename)
        .replace(/\.[^/.]+$/, "")
        .replace(/[-_]/g, " ");
      return name.replace(/\b\w/g, (c) => c.toUpperCase());
    } catch {
      return "Audio Track";
    }
  }

  get durationDisplay() {
    if (!this.duration) {
      return "0:00";
    }
    const mins = Math.floor(this.duration / 60);
    const secs = Math.floor(this.duration % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  }

  get currentTimeDisplay() {
    const mins = Math.floor(this.currentTime / 60);
    const secs = Math.floor(this.currentTime % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  }

  @action
  handleVisibilityChange(entry) {
    if (!entry.isIntersecting && this.isPlaying && this.wavesurfer) {
      this.wavesurfer.pause();
      this.isPausedByViewport = true;
    }
  }

  @action
  setupContainer(element) {
    this.containerElement = element;
  }

  @action
  setupWaveform(element) {
    if (!element || !this.audioUrl) {
      return;
    }

    this.isWaveformLoading = true;
    this.waveformElement = element;

    loadWaveSurfer()
      .then((WaveSurfer) => {
        if (this.isDestroying || this.isDestroyed) {
          return;
        }

        this.wavesurfer = WaveSurfer.create({
          container: this.waveformElement,
          waveColor: "rgba(255, 255, 255, 0.4)",
          progressColor: "rgba(255, 255, 255, 0.8)",
          cursorColor: "transparent",
          barWidth: 4,
          barGap: 2,
          barRadius: 9999,
          height: 64,
          responsive: true,
          normalize: true,
          hideScrollbar: true,
          url: this.audioUrl,
        });

        this.wavesurfer.on("decode", (duration) => {
          this.duration = duration;
        });

        this.wavesurfer.on("ready", () => {
          this.isWaveformLoading = false;
        });

        this.wavesurfer.on("play", () => {
          this.isPlaying = true;
        });

        this.wavesurfer.on("pause", () => {
          this.isPlaying = false;
        });

        this.wavesurfer.on("finish", () => {
          this.isPlaying = false;
          this.currentTime = 0;
        });

        this.wavesurfer.on("timeupdate", (time) => {
          this.currentTime = time;
        });

        this.wavesurfer.on("error", () => {
          this.isWaveformLoading = false;
        });
      })
      .catch(() => {
        this.isWaveformLoading = false;
      });
  }

  @action
  togglePlay(event) {
    event?.stopPropagation();
    if (!this.wavesurfer) {
      return;
    }

    this.isPausedByViewport = false;
    this.wavesurfer.playPause();
  }

  @action
  handleControlsClick(event) {
    event.stopPropagation();
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="fantribe-media-audio
        {{if this.isPlaying 'fantribe-media-audio--playing'}}"
      {{didInsert this.setupContainer}}
      {{observeIntersection this.handleVisibilityChange threshold=0.5}}
      {{on "click" this.handleControlsClick}}
    >
      <div class="fantribe-media-audio__header">
        <button
          type="button"
          class="fantribe-media-audio__play-btn"
          aria-label={{if this.isPlaying "Pause" "Play"}}
          {{on "click" this.togglePlay}}
        >
          {{#if this.isPlaying}}
            {{ftIcon "pause" size=20}}
          {{else}}
            {{ftIcon "play" size=20}}
          {{/if}}
        </button>
        <div class="fantribe-media-audio__info">
          <p class="fantribe-media-audio__title">{{this.trackTitle}}</p>
          <p class="fantribe-media-audio__duration">{{this.currentTimeDisplay}}
            /
            {{this.durationDisplay}}</p>
        </div>
      </div>

      <div
        class="fantribe-media-audio__waveform"
        {{didInsert this.setupWaveform}}
      >
        {{#if this.isWaveformLoading}}
          <div class="fantribe-media-audio__waveform-skeleton"></div>
        {{/if}}
      </div>
    </div>
  </template>
}
