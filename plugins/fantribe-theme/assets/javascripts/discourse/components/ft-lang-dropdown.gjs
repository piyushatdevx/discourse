import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import { eq } from "discourse/truth-helpers";

export const LANGUAGES = [
  { code: "en", flag: "🇺🇸", label: "EN", name: "English" },
  { code: "es", flag: "🇪🇸", label: "ES", name: "Español" },
  { code: "fr", flag: "🇫🇷", label: "FR", name: "Français" },
  { code: "de", flag: "🇩🇪", label: "DE", name: "Deutsch" },
  { code: "pt", flag: "🇧🇷", label: "PT", name: "Português" },
  { code: "hi", flag: "🇮🇳", label: "HI", name: "हिन्दी" },
  { code: "ar", flag: "🇸🇦", label: "AR", name: "العربية" },
];

export default class FtLangDropdown extends Component {
  @tracked isOpen = false;
  @tracked selected = LANGUAGES[0];

  @action
  toggle() {
    this.isOpen = !this.isOpen;
  }

  @action
  select(lang) {
    this.selected = lang;
    this.isOpen = false;
  }

  @action
  handleOutsideClick(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      this.isOpen = false;
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-lang-dropdown {{if this.isOpen 'ft-lang-dropdown--open'}}"
      {{on "focusout" this.handleOutsideClick}}
    >
      <button
        type="button"
        class="fantribe-login-header__btn fantribe-login-header__btn--lang"
        aria-haspopup="listbox"
        aria-expanded={{this.isOpen}}
        {{on "click" this.toggle}}
      >
        <span class="ft-lang-dropdown__flag" aria-hidden="true">
          {{this.selected.flag}}
        </span>
        <span class="ft-lang-dropdown__label">{{this.selected.label}}</span>
        <span
          class="ft-lang-dropdown__chevron
            {{if this.isOpen 'ft-lang-dropdown__chevron--open'}}"
        >
          {{icon "chevron-down"}}
        </span>
      </button>

      {{#if this.isOpen}}
        <div class="ft-lang-dropdown__menu" role="listbox">
          {{#each LANGUAGES as |lang|}}
            <button
              type="button"
              class="ft-lang-dropdown__option
                {{if
                  (eq this.selected.code lang.code)
                  'ft-lang-dropdown__option--active'
                }}"
              role="option"
              aria-selected={{eq this.selected.code lang.code}}
              {{on "click" (fn this.select lang)}}
            >
              <span class="ft-lang-dropdown__option-flag" aria-hidden="true">
                {{lang.flag}}
              </span>
              <span class="ft-lang-dropdown__option-name">{{lang.name}}</span>
              {{#if (eq this.selected.code lang.code)}}
                <span class="ft-lang-dropdown__option-check">
                  {{icon "check"}}
                </span>
              {{/if}}
            </button>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
