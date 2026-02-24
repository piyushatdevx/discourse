import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { eq } from "discourse/truth-helpers";
import ftIcon from "discourse/plugins/fantribe-theme/discourse/helpers/ft-icon";

const STEP_COUNT = 3;

const PRESET_COLORS = [
  "FF1744",
  "0080FF",
  "FF6B6B",
  "51CF66",
  "FFB84D",
  "B197FC",
  "20C997",
  "FF922B",
  "1C7ED6",
  "F06595",
];

export default class FantribeCreateTribeModal extends Component {
  @service router;

  @tracked step = 1;
  @tracked tribeName = "";
  @tracked tribeSlug = "";
  @tracked tribeDescription = "";
  @tracked selectedColor = "FF1744";
  @tracked isPrivate = false;
  @tracked isSubmitting = false;
  @tracked slugEdited = false;

  get progress() {
    return (this.step / STEP_COUNT) * 100;
  }

  get progressStyle() {
    return htmlSafe(`width: ${this.progress}%`);
  }

  get stepTitle() {
    if (this.step === 1) {
      return "Name your Tribe";
    }
    if (this.step === 2) {
      return "Choose your look";
    }
    return "Set visibility";
  }

  get stepSubtitle() {
    if (this.step === 1) {
      return "Give your community an identity";
    }
    if (this.step === 2) {
      return "Pick a color that represents your tribe";
    }
    return "Control who can discover and join your tribe";
  }

  get canAdvance() {
    if (this.step === 1) {
      return (
        this.tribeName.trim().length >= 2 && this.tribeSlug.trim().length >= 2
      );
    }
    return true;
  }

  get isLastStep() {
    return this.step === STEP_COUNT;
  }

  get previewStyle() {
    return htmlSafe(
      `background: linear-gradient(135deg, #${this.selectedColor} 0%, #${this.selectedColor}88 100%)`
    );
  }

  colorSwatchStyle(color) {
    return htmlSafe(`background-color: #${color}`);
  }

  @action
  updateName(event) {
    this.tribeName = event.target.value;
    if (!this.slugEdited) {
      this.tribeSlug = event.target.value
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, "")
        .replace(/\s+/g, "-")
        .replace(/-+/g, "-")
        .slice(0, 50);
    }
  }

  @action
  updateSlug(event) {
    this.slugEdited = true;
    this.tribeSlug = event.target.value
      .toLowerCase()
      .replace(/[^a-z0-9-]/g, "")
      .slice(0, 50);
  }

  @action
  updateDescription(event) {
    this.tribeDescription = event.target.value;
  }

  @action
  selectColor(color) {
    this.selectedColor = color;
  }

  @action
  setPrivate(value) {
    this.isPrivate = value;
  }

  @action
  nextStep() {
    if (this.step < STEP_COUNT) {
      this.step += 1;
    }
  }

  @action
  prevStep() {
    if (this.step > 1) {
      this.step -= 1;
    }
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose();
    }
  }

  @action
  async createTribe() {
    if (this.isSubmitting) {
      return;
    }

    this.isSubmitting = true;

    try {
      const data = {
        name: this.tribeName.trim(),
        color: this.selectedColor,
        text_color: "FFFFFF",
      };
      const slug = this.tribeSlug.trim();
      if (slug) {
        data.slug = slug;
      }
      const description = this.tribeDescription.trim();
      if (description) {
        data.description = description;
      }

      const result = await ajax("/categories", {
        type: "POST",
        data,
      });

      this.args.onClose();

      const category = result?.category;
      if (category?.slug && category?.id) {
        this.router.transitionTo(
          "discovery.category",
          `${category.slug}/${category.id}`
        );
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-create-tribe-backdrop"
      {{on "click" this.handleBackdropClick}}
      role="dialog"
      aria-modal="true"
    >
      <div class="ft-create-tribe-modal">
        {{! Header }}
        <div class="ft-create-tribe-modal__header">
          <div class="ft-create-tribe-modal__header-text">
            <h2 class="ft-create-tribe-modal__title">Create a Tribe</h2>
            <p class="ft-create-tribe-modal__subtitle">Step
              {{this.step}}
              of
              {{STEP_COUNT}}</p>
          </div>
          <button
            type="button"
            class="ft-create-tribe-modal__close"
            {{on "click" @onClose}}
          >
            {{ftIcon "x"}}
          </button>
        </div>

        {{! Progress bar }}
        <div class="ft-create-tribe-modal__progress-track">
          <div
            class="ft-create-tribe-modal__progress-fill"
            style={{this.progressStyle}}
          ></div>
        </div>

        {{! Step heading }}
        <div class="ft-create-tribe-modal__step-header">
          <h3 class="ft-create-tribe-modal__step-title">{{this.stepTitle}}</h3>
          <p
            class="ft-create-tribe-modal__step-subtitle"
          >{{this.stepSubtitle}}</p>
        </div>

        {{! ── STEP 1: Identity ── }}
        {{#if (eq this.step 1)}}
          <div class="ft-create-tribe-modal__body">
            <div class="ft-create-tribe-modal__field">
              <label class="ft-create-tribe-modal__label">Tribe Name
                <span class="ft-create-tribe-modal__required">*</span></label>
              <input
                type="text"
                class="ft-create-tribe-modal__input"
                placeholder="e.g. Guitar Legends"
                value={{this.tribeName}}
                maxlength="50"
                {{on "input" this.updateName}}
              />
            </div>
            <div class="ft-create-tribe-modal__field">
              <label class="ft-create-tribe-modal__label">Handle
                <span class="ft-create-tribe-modal__required">*</span></label>
              <div class="ft-create-tribe-modal__input-prefix-wrap">
                <span class="ft-create-tribe-modal__input-prefix">@</span>
                <input
                  type="text"
                  class="ft-create-tribe-modal__input ft-create-tribe-modal__input--prefixed"
                  placeholder="guitar-legends"
                  value={{this.tribeSlug}}
                  maxlength="50"
                  {{on "input" this.updateSlug}}
                />
              </div>
              <p class="ft-create-tribe-modal__hint">URL: /c/{{this.tribeSlug}}</p>
            </div>
            <div class="ft-create-tribe-modal__field">
              <label class="ft-create-tribe-modal__label">Description
                <span
                  class="ft-create-tribe-modal__optional"
                >(optional)</span></label>
              <textarea
                class="ft-create-tribe-modal__textarea"
                placeholder="What is this tribe about? Who should join?"
                {{on "input" this.updateDescription}}
              >{{this.tribeDescription}}</textarea>
            </div>
          </div>
        {{/if}}

        {{! ── STEP 2: Appearance ── }}
        {{#if (eq this.step 2)}}
          <div class="ft-create-tribe-modal__body">
            {{! Color preview card }}
            <div
              class="ft-create-tribe-modal__preview"
              style={{this.previewStyle}}
            >
              <div class="ft-create-tribe-modal__preview-overlay"></div>
              <div class="ft-create-tribe-modal__preview-logo">
                {{this.tribeName}}
              </div>
            </div>

            <div class="ft-create-tribe-modal__field">
              <label class="ft-create-tribe-modal__label">Tribe Color</label>
              <div class="ft-create-tribe-modal__color-grid">
                {{#each PRESET_COLORS as |color|}}
                  <button
                    type="button"
                    class="ft-create-tribe-modal__color-swatch
                      {{if
                        (eq this.selectedColor color)
                        'ft-create-tribe-modal__color-swatch--selected'
                      }}"
                    style={{this.colorSwatchStyle color}}
                    {{on "click" (fn this.selectColor color)}}
                  >
                    {{#if (eq this.selectedColor color)}}
                      {{ftIcon "check"}}
                    {{/if}}
                  </button>
                {{/each}}
              </div>
            </div>
          </div>
        {{/if}}

        {{! ── STEP 3: Visibility ── }}
        {{#if (eq this.step 3)}}
          <div class="ft-create-tribe-modal__body">
            <div class="ft-create-tribe-modal__visibility-options">
              <button
                type="button"
                class="ft-create-tribe-modal__visibility-card
                  {{unless
                    this.isPrivate
                    'ft-create-tribe-modal__visibility-card--selected'
                  }}"
                {{on "click" (fn this.setPrivate false)}}
              >
                <div class="ft-create-tribe-modal__visibility-icon">
                  {{ftIcon "globe"}}
                </div>
                <div class="ft-create-tribe-modal__visibility-text">
                  <strong>Public</strong>
                  <p>Anyone can find and join this tribe. Great for growing a
                    community.</p>
                </div>
                {{#unless this.isPrivate}}
                  <span class="ft-create-tribe-modal__visibility-check">
                    {{ftIcon "check-circle"}}
                  </span>
                {{/unless}}
              </button>

              <button
                type="button"
                class="ft-create-tribe-modal__visibility-card
                  {{if
                    this.isPrivate
                    'ft-create-tribe-modal__visibility-card--selected'
                  }}"
                {{on "click" (fn this.setPrivate true)}}
              >
                <div class="ft-create-tribe-modal__visibility-icon">
                  {{ftIcon "lock"}}
                </div>
                <div class="ft-create-tribe-modal__visibility-text">
                  <strong>Private</strong>
                  <p>Only invited members can see this tribe. Best for exclusive
                    communities.</p>
                </div>
                {{#if this.isPrivate}}
                  <span class="ft-create-tribe-modal__visibility-check">
                    {{ftIcon "check-circle"}}
                  </span>
                {{/if}}
              </button>
            </div>
          </div>
        {{/if}}

        {{! Footer }}
        <div class="ft-create-tribe-modal__footer">
          {{#if (eq this.step 1)}}
            <button
              type="button"
              class="ft-create-tribe-modal__btn ft-create-tribe-modal__btn--ghost"
              {{on "click" @onClose}}
            >Cancel</button>
          {{else}}
            <button
              type="button"
              class="ft-create-tribe-modal__btn ft-create-tribe-modal__btn--ghost"
              {{on "click" this.prevStep}}
            >
              {{ftIcon "chevron-left"}}
              Back
            </button>
          {{/if}}

          {{#if this.isLastStep}}
            <button
              type="button"
              class="ft-create-tribe-modal__btn ft-create-tribe-modal__btn--primary
                {{if this.isSubmitting 'ft-create-tribe-modal__btn--loading'}}"
              disabled={{this.isSubmitting}}
              {{on "click" this.createTribe}}
            >
              {{#if this.isSubmitting}}
                Creating...
              {{else}}
                {{ftIcon "check"}}
                Create Tribe
              {{/if}}
            </button>
          {{else}}
            <button
              type="button"
              class="ft-create-tribe-modal__btn ft-create-tribe-modal__btn--primary
                {{unless
                  this.canAdvance
                  'ft-create-tribe-modal__btn--disabled'
                }}"
              disabled={{unless this.canAdvance true}}
              {{on "click" this.nextStep}}
            >
              Continue
              {{ftIcon "chevron-right"}}
            </button>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
