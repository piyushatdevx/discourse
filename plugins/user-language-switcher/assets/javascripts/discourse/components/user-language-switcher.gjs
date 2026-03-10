import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import DMenu from "discourse/float-kit/components/d-menu";
import icon from "discourse/helpers/d-icon";
import cookie from "discourse/lib/cookie";
import I18n, { i18n } from "discourse-i18n";

export default class UserLanguageSwitcher extends Component {
  @service siteSettings;
  @service currentUser;

  @action
  async changeLocale(locale) {
    if (!locale || locale === this.currentLocale) {
      return;
    }

    if (this.currentUser) {
      this.currentUser.set("locale", locale);
      await this.currentUser.save(["locale"]);
    } else {
      cookie("locale", locale, { path: "/" });
    }

    this.dMenu?.close();
    // Hard reload so all UI strings switch to the new locale
    window.location.reload();
  }

  get currentLocale() {
    return I18n.locale;
  }

  get currentLanguageCode() {
    return this.currentLocale.split("_")[0].toUpperCase();
  }

  get content() {
    const langs = (this.siteSettings.available_locales || []).map(
      ({ value, name }) => ({
        name,
        value,
        isActive: value === this.currentLocale,
      })
    );

    return langs;
  }

  @action
  onRegisterApi(api) {
    this.dMenu = api;
  }

  <template>
    <DMenu
      @identifier="user-language-switcher"
      @title={{i18n "user_language_switcher.title"}}
      class="btn-flat user-language-switcher"
      @onRegisterApi={{this.onRegisterApi}}
    >
      <:trigger>
        <span class="user-language-switcher__locale">
          {{this.currentLanguageCode}}
        </span>
        {{icon "angle-down"}}
      </:trigger>
      <:content>
        <DropdownMenu as |dropdown|>
          {{#each this.content as |option|}}
            <dropdown.item
              class="locale-options {{if option.isActive '--selected'}}"
              data-menu-option-id={{option.value}}
            >
              <DButton
                @translatedLabel={{option.name}}
                @action={{fn this.changeLocale option.value}}
              />
            </dropdown.item>
          {{/each}}
        </DropdownMenu>
      </:content>
    </DMenu>
  </template>
}
