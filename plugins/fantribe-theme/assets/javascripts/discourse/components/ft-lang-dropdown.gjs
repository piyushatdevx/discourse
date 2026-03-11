import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { next } from "@ember/runloop";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import cookie from "discourse/lib/cookie";
import { eq } from "discourse/truth-helpers";

export const LANGUAGES = [
  { code: "en", flag: "🇺🇸", label: "EN", name: "English" },
  { code: "es", flag: "🇪🇸", label: "ES", name: "Español" },
  { code: "fr", flag: "🇫🇷", label: "FR", name: "Français" },
  { code: "de", flag: "🇩🇪", label: "DE", name: "Deutsch" },
  { code: "pt", flag: "🇧🇷", label: "PT", name: "Português" },
];

export default class FtLangDropdown extends Component {
  @service currentUser;
  @service siteSettings;

  @tracked isOpen = false;
  @tracked isSubmitting = false;
  @tracked
  supportsSetLocaleEndpoint =
    window.localStorage?.getItem("ft_locale_endpoint_supported") !== "false";
  @tracked selectedCode = "en";

  constructor() {
    super(...arguments);
    this.selectedCode = this.initialSelectedCode;
    this.syncLocaleFromCookieAfterLogin();
  }

  get initialSelectedCode() {
    const candidates = [
      cookie("user_locale"),
      cookie("locale"),
      this.currentUser?.locale,
      window.I18n?.currentLocale?.(),
      window.I18n?.locale,
      "en",
    ].filter(Boolean);

    const match = candidates
      .map((locale) => this.languageForLocale(locale))
      .find(Boolean);
    return match?.code || "en";
  }

  get selected() {
    return (
      this.languages.find((lang) =>
        this.sameLocale(lang.code, this.selectedCode)
      ) ||
      this.languages[0] ||
      LANGUAGES[0]
    );
  }

  get languages() {
    return LANGUAGES;
  }

  get availableLocales() {
    const raw = this.siteSettings?.available_locales;
    const locales = Array.isArray(raw) ? raw : (raw || "").split("|");
    return new Set(locales.filter(Boolean).map((l) => this.normalizeLocale(l)));
  }

  languageForLocale(locale) {
    return this.languages.find((lang) => this.sameLocale(lang.code, locale));
  }

  normalizeLocale(locale) {
    return (locale || "").toString().trim().toLowerCase().replace("-", "_");
  }

  sameLocale(a, b) {
    const aNorm = this.normalizeLocale(a);
    const bNorm = this.normalizeLocale(b);
    return aNorm === bNorm;
  }

  normalizeForPersistence(locale) {
    return locale;
  }

  persistLocaleCookies(locale) {
    const persisted = this.normalizeForPersistence(locale);
    cookie("user_locale", persisted, { expires: 365 });
    cookie("locale", persisted, { expires: 365 });
  }

  async persistViaCurrentUser(locale) {
    if (!this.currentUser) {
      return this.normalizeForPersistence(locale);
    }

    const candidates = [locale];

    for (const candidate of candidates) {
      try {
        this.currentUser.set("locale", candidate);
        await this.currentUser.save(["locale"]);
        return candidate;
      } catch {
        // Try next variant.
      }
    }

    return this.normalizeForPersistence(locale);
  }

  @action
  toggle() {
    if (this.isSubmitting) {
      return;
    }
    this.isOpen = !this.isOpen;
  }

  @action
  async select(lang) {
    if (
      !lang?.code ||
      this.isSubmitting ||
      this.sameLocale(lang.code, this.selectedCode)
    ) {
      return;
    }

    this.isOpen = false;
    this.isSubmitting = true;
    this.persistLocaleCookies(lang.code);

    try {
      if (this.supportsSetLocaleEndpoint) {
        await ajax("/user-language/set.json", {
          type: "POST",
          data: { locale: lang.code },
        });
        window.localStorage?.setItem("ft_locale_endpoint_supported", "true");
        this.selectedCode = this.normalizeForPersistence(lang.code);
      } else {
        const persistedLocale = await this.persistViaCurrentUser(lang.code);
        this.persistLocaleCookies(persistedLocale);
        this.selectedCode = persistedLocale;
      }
    } catch (error) {
      if (
        error?.jqXHR?.status === 404 ||
        error?.status === 404 ||
        error?.jqXHR?.status === 422 ||
        error?.status === 422
      ) {
        this.supportsSetLocaleEndpoint = false;
        window.localStorage?.setItem("ft_locale_endpoint_supported", "false");
        const persistedLocale = await this.persistViaCurrentUser(lang.code);
        this.persistLocaleCookies(persistedLocale);
        this.selectedCode = persistedLocale;
      } else {
        popupAjaxError(error);
        return;
      }
    } finally {
      this.isSubmitting = false;
    }

    // Ensure language updates everywhere immediately.
    window.location.reload();
  }

  async syncLocaleFromCookieAfterLogin() {
    if (!this.currentUser) {
      return;
    }

    const cookieLocale = cookie("user_locale") || cookie("locale");
    const userLocale = this.currentUser.locale;
    const syncAttemptKey = "ft_locale_sync_attempted_for";

    if (!cookieLocale || this.sameLocale(cookieLocale, userLocale)) {
      window.sessionStorage?.removeItem(syncAttemptKey);
      return;
    }

    if (window.sessionStorage?.getItem(syncAttemptKey) === cookieLocale) {
      return;
    }
    window.sessionStorage?.setItem(syncAttemptKey, cookieLocale);

    try {
      this.persistLocaleCookies(cookieLocale);
      if (this.supportsSetLocaleEndpoint) {
        await ajax("/user-language/set.json", {
          type: "POST",
          data: { locale: cookieLocale },
        });
        window.localStorage?.setItem("ft_locale_endpoint_supported", "true");
      } else {
        const persistedLocale = await this.persistViaCurrentUser(cookieLocale);
        this.persistLocaleCookies(persistedLocale);
      }

      this.selectedCode = this.normalizeForPersistence(cookieLocale);
    } catch (error) {
      if (
        error?.jqXHR?.status === 404 ||
        error?.status === 404 ||
        error?.jqXHR?.status === 422 ||
        error?.status === 422
      ) {
        this.supportsSetLocaleEndpoint = false;
        window.localStorage?.setItem("ft_locale_endpoint_supported", "false");
      }
    }
  }

  @action
  handleOutsideClick(event) {
    if (!this.isOpen) {
      return;
    }

    if (!event.currentTarget.contains(event.relatedTarget)) {
      // Avoid mutating tracked state in the same render computation that consumed it.
      next(this, () => {
        this.isOpen = false;
      });
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
          {{#each this.languages as |lang|}}
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
