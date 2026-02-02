import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";

const eq = (a, b) => a === b;

const heroSlides = [
  {
    id: 1,
    image:
      "https://images.unsplash.com/photo-1714972383523-7c636d2f0e9b?w=1920&h=1080&fit=crop",
    alt: "People having fun at music event",
  },
  {
    id: 2,
    image:
      "https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=1920&h=1080&fit=crop",
    alt: "Music festival crowd",
  },
  {
    id: 3,
    image:
      "https://images.unsplash.com/photo-1752761400309-83ce512dce78?w=1920&h=1080&fit=crop",
    alt: "Concert celebration with friends",
  },
  {
    id: 4,
    image:
      "https://images.unsplash.com/photo-1656369895489-e24a2d0816e9?w=1920&h=1080&fit=crop",
    alt: "Live music audience",
  },
  {
    id: 5,
    image:
      "https://images.unsplash.com/photo-1688591238746-d13a56a7202b?w=1920&h=1080&fit=crop",
    alt: "DJ party people",
  },
];

const heroAvatars = [
  "https://images.unsplash.com/photo-1760124146290-a896872ae49a?w=100&h=100&fit=crop",
  "https://images.unsplash.com/photo-1678726716469-91f527c06e54?w=100&h=100&fit=crop",
  "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=100&h=100&fit=crop",
];

const SLIDE_DURATION = 5000;

export default class LandingHero extends Component {
  @tracked currentSlide = 0;
  @tracked progress = 0;
  @tracked isPaused = false;

  slides = heroSlides;
  avatars = heroAvatars;
  animationFrameId = null;
  lastUpdateTime = Date.now();

  @action
  setupCarousel() {
    this.lastUpdateTime = Date.now();
    this.startAnimation();
  }

  @action
  cleanupCarousel() {
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
    }
  }

  startAnimation() {
    const animate = () => {
      if (this.isDestroyed || this.isDestroying) {
        return;
      }

      if (!this.isPaused) {
        const now = Date.now();
        const deltaTime = now - this.lastUpdateTime;
        this.lastUpdateTime = now;

        const newProgress = this.progress + (deltaTime / SLIDE_DURATION) * 100;

        if (newProgress >= 100) {
          this.currentSlide = (this.currentSlide + 1) % this.slides.length;
          this.progress = 0;
          this.lastUpdateTime = Date.now();
        } else {
          this.progress = newProgress;
        }
      } else {
        this.lastUpdateTime = Date.now();
      }

      this.animationFrameId = requestAnimationFrame(animate);
    };

    this.animationFrameId = requestAnimationFrame(animate);
  }

  @action
  goToSlide(index) {
    this.currentSlide = index;
    this.progress = 0;
    this.lastUpdateTime = Date.now();
  }

  @action
  handleMouseEnter() {
    this.isPaused = true;
  }

  @action
  handleMouseLeave() {
    this.isPaused = false;
    this.lastUpdateTime = Date.now();
  }

  get progressStyle() {
    return htmlSafe(`width: ${this.progress}%`);
  }

  <template>
    <section
      class="landing-hero"
      {{didInsert this.setupCarousel}}
      {{willDestroy this.cleanupCarousel}}
      {{on "mouseenter" this.handleMouseEnter}}
      {{on "mouseleave" this.handleMouseLeave}}
    >
      {{! Carousel Background Images }}
      {{#each this.slides as |slide index|}}
        <div
          class="landing-hero__slide
            {{if (eq index this.currentSlide) 'landing-hero__slide--active'}}"
        >
          <img
            src={{slide.image}}
            alt={{slide.alt}}
            class="landing-hero__image"
            loading={{if (eq index this.currentSlide) "eager" "lazy"}}
          />
        </div>
      {{/each}}

      {{! Gradient Overlay }}
      <div class="landing-hero__overlay"></div>

      {{! Progress Bar }}
      <div class="landing-hero__progress">
        <div
          class="landing-hero__progress-bar"
          style={{this.progressStyle}}
        ></div>
      </div>

      {{! Slide Indicators }}
      <div class="landing-hero__indicators">
        {{#each this.slides as |slide index|}}
          <button
            type="button"
            class="landing-hero__indicator
              {{if
                (eq index this.currentSlide)
                'landing-hero__indicator--active'
              }}"
            {{on "click" (fn this.goToSlide index)}}
            aria-label="Go to slide {{index}}"
          ></button>
        {{/each}}
      </div>

      {{! Content }}
      <div class="landing-hero__content">
        <div class="landing-hero__content-inner">
          {{! Badge }}
          <div class="landing-hero__badge">
            <span>Hey there, creator!</span>
          </div>

          {{! Headline }}
          <h1 class="landing-hero__title">You Belong Here</h1>

          {{! Subtext }}
          <p class="landing-hero__subtitle">
            Not just another platform. A real community where
            <span class="landing-hero__highlight">your voice matters</span>,
            your ideas shape products, and
            <span class="landing-hero__highlight">friendships form</span>
            over shared passion.
          </p>

          {{! CTA Buttons }}
          <div class="landing-hero__buttons">
            <button type="button" class="landing-hero__btn-primary">
              Yes, I'm Ready!
              <svg
                class="landing-hero__arrow"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M5 12h14M12 5l7 7-7 7" />
              </svg>
            </button>
            <button type="button" class="landing-hero__btn-secondary">
              Just Looking
            </button>
          </div>

          {{! Status Bar }}
          <div class="landing-hero__status">
            {{! Avatar Stack }}
            <div class="landing-hero__avatars">
              {{#each this.avatars as |avatar|}}
                <img
                  src={{avatar}}
                  alt="Tribe member"
                  class="landing-hero__avatar"
                />
              {{/each}}
              <div class="landing-hero__avatar-count">+2K</div>
            </div>

            <div class="landing-hero__divider"></div>

            {{! Live Indicator }}
            <div class="landing-hero__live">
              <span class="landing-hero__live-dot">
                <span class="landing-hero__live-ping"></span>
                <span class="landing-hero__live-solid"></span>
              </span>
              <span class="landing-hero__live-text">
                <strong>Live now:</strong>
              </span>
            </div>
          </div>

          {{! Member Count }}
          <p class="landing-hero__members">
            Join 241,532 tribe members sharing 1,203 stories
          </p>
        </div>
      </div>
    </section>

    <style>
      .landing-hero {
        position: relative;
        min-height: 100vh;
        display: flex;
        align-items: flex-end;
        overflow: hidden;
        margin: 0;
        padding: 0;
        width: 100%;
        box-sizing: border-box;
      }

      .landing-hero__slide {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        opacity: 0;
        transition: opacity 1000ms ease-in-out;
      }

      .landing-hero__slide--active {
        opacity: 1;
      }

      .landing-hero__image {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      .landing-hero__overlay {
        position: absolute;
        inset: 0;
        background: linear-gradient(
          to right,
          rgba(0, 0, 0, 0.7),
          rgba(0, 0, 0, 0.5),
          rgba(0, 0, 0, 0.3)
        );
      }

      .landing-hero__progress {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: rgba(255, 255, 255, 0.1);
        z-index: 20;
      }

      .landing-hero__progress-bar {
        height: 100%;
        background: rgba(255, 255, 255, 0.5);
        transition: width 50ms linear;
      }

      .landing-hero__indicators {
        position: absolute;
        bottom: 24px;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        gap: 8px;
        z-index: 20;
      }

      .landing-hero__indicator {
        height: 6px;
        width: 6px;
        border-radius: 9999px;
        background: rgba(255, 255, 255, 0.4);
        border: none;
        padding: 0;
        cursor: pointer;
        transition: all 300ms ease-in-out;
      }

      .landing-hero__indicator:hover {
        background: rgba(255, 255, 255, 0.6);
      }

      .landing-hero__indicator--active {
        width: 32px;
        background: white;
      }

      .landing-hero__content {
        position: relative;
        z-index: 10;
        width: 100%;
        max-width: 1280px;
        margin: 0 auto;
        padding: 32px 16px 64px;
      }

      @media (min-width: 640px) {
        .landing-hero__content {
          padding: 48px 24px 96px;
        }
      }

      .landing-hero__content-inner {
        max-width: 640px;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 24px;
      }

      @media (min-width: 768px) {
        .landing-hero__content-inner {
          gap: 32px;
        }
      }

      .landing-hero__badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 12px;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 9999px;
        color: #ffffff !important;
        font-size: 0.875rem;
      }

      @media (min-width: 768px) {
        .landing-hero__badge {
          padding: 8px 16px;
        }
      }

      .landing-hero__title {
        color: #ffffff !important;
        font-size: 1.875rem;
        font-weight: 700;
        line-height: 1.2;
        margin: 0;
      }

      @media (min-width: 768px) {
        .landing-hero__title {
          font-size: 2.5rem;
        }
      }

      @media (min-width: 1024px) {
        .landing-hero__title {
          font-size: 3rem;
        }
      }

      .landing-hero__subtitle {
        max-width: 32rem;
        color: rgba(255, 255, 255, 0.9) !important;
        font-size: 1rem;
        line-height: 1.6;
        margin: 0;
      }

      @media (min-width: 768px) {
        .landing-hero__subtitle {
          font-size: 1.125rem;
        }
      }

      .landing-hero__highlight {
        color: #ffffff !important;
        font-weight: 600;
      }

      .landing-hero__buttons {
        display: flex;
        flex-direction: column;
        gap: 12px;
        width: 100%;
      }

      @media (min-width: 640px) {
        .landing-hero__buttons {
          flex-direction: row;
          width: auto;
          gap: 16px;
        }
      }

      .landing-hero__btn-primary {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 12px 24px;
        background: #ff1744;
        color: white;
        border: none;
        border-radius: 9999px;
        font-size: 0.9375rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 200ms ease-in-out;
      }

      @media (min-width: 768px) {
        .landing-hero__btn-primary {
          padding: 16px 32px;
        }
      }

      .landing-hero__btn-primary:hover {
        background: #e6143d;
        box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
      }

      .landing-hero__arrow {
        width: 16px;
        height: 16px;
        transition: transform 200ms ease-in-out;
      }

      @media (min-width: 768px) {
        .landing-hero__arrow {
          width: 20px;
          height: 20px;
        }
      }

      .landing-hero__btn-primary:hover .landing-hero__arrow {
        transform: translateX(4px);
      }

      .landing-hero__btn-secondary {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 12px 24px;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(12px);
        color: white;
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: 9999px;
        font-size: 0.9375rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 200ms ease-in-out;
      }

      @media (min-width: 768px) {
        .landing-hero__btn-secondary {
          padding: 16px 32px;
        }
      }

      .landing-hero__btn-secondary:hover {
        background: rgba(255, 255, 255, 0.2);
      }

      .landing-hero__status {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 12px;
        padding: 10px 16px;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 9999px;
        font-size: 0.75rem;
        color: #ffffff !important;
      }

      @media (min-width: 768px) {
        .landing-hero__status {
          gap: 16px;
          padding: 12px 20px;
          font-size: 0.875rem;
        }
      }

      .landing-hero__avatars {
        display: flex;
      }

      .landing-hero__avatar {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        border: 2px solid white;
        margin-left: -8px;
        object-fit: cover;
      }

      .landing-hero__avatar:first-child {
        margin-left: 0;
      }

      @media (min-width: 768px) {
        .landing-hero__avatar {
          width: 32px;
          height: 32px;
          margin-left: -12px;
        }
      }

      .landing-hero__avatar-count {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.2);
        border: 2px solid white;
        margin-left: -8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 9px;
        font-weight: 600;
        color: white;
      }

      @media (min-width: 768px) {
        .landing-hero__avatar-count {
          width: 32px;
          height: 32px;
          margin-left: -12px;
          font-size: 10px;
        }
      }

      .landing-hero__divider {
        width: 1px;
        height: 16px;
        background: rgba(255, 255, 255, 0.3);
        display: none;
      }

      @media (min-width: 640px) {
        .landing-hero__divider {
          display: block;
        }
      }

      .landing-hero__live {
        display: flex;
        align-items: center;
        gap: 8px;
      }

      .landing-hero__live-dot {
        position: relative;
        display: inline-flex;
        width: 8px;
        height: 8px;
      }

      .landing-hero__live-ping {
        position: absolute;
        inset: 0;
        border-radius: 50%;
        background: #10b981;
        animation: landing-ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;
      }

      .landing-hero__live-solid {
        position: relative;
        display: inline-flex;
        width: 100%;
        height: 100%;
        border-radius: 50%;
        background: #10b981;
      }

      @keyframes landing-ping {
        0% {
          transform: scale(1);
          opacity: 1;
        }
        75%,
        100% {
          transform: scale(2);
          opacity: 0;
        }
      }

      .landing-hero__live-text {
        color: rgba(255, 255, 255, 0.8) !important;
      }

      .landing-hero__live-text strong {
        color: #ffffff !important;
        font-weight: 600;
      }

      .landing-hero__members {
        font-size: 0.75rem;
        color: rgba(255, 255, 255, 0.7) !important;
        padding-left: 8px;
        margin: 0;
      }

      @media (min-width: 768px) {
        .landing-hero__members {
          padding-left: 16px;
        }
      }

      .landing-hero__avatar-count {
        color: #ffffff !important;
      }
    </style>
  </template>
}
