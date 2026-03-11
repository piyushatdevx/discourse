import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import ftIcon from "discourse/plugins/fantribe-theme/discourse/helpers/ft-icon";

const SETTINGS_SECTIONS = [
  {
    id: "account",
    labelKey: "fantribe.settings_hub.account.label",
    descriptionKey: "fantribe.settings_hub.account.description",
    route: "preferences.account",
    iconType: "d",
    iconName: "user",
    colorClass: "ft-settings-hub__section--blue",
  },
  {
    id: "notifications",
    labelKey: "fantribe.settings_hub.notifications.label",
    descriptionKey: "fantribe.settings_hub.notifications.description",
    route: "preferences.notifications",
    iconType: "ft",
    iconName: "bell",
    colorClass: "ft-settings-hub__section--purple",
  },
  {
    id: "privacy",
    labelKey: "fantribe.settings_hub.privacy.label",
    descriptionKey: "fantribe.settings_hub.privacy.description",
    route: "preferences.users",
    iconType: "ft",
    iconName: "lock",
    colorClass: "ft-settings-hub__section--green",
  },
  {
    id: "appearance",
    labelKey: "fantribe.settings_hub.appearance.label",
    descriptionKey: "fantribe.settings_hub.appearance.description",
    route: "preferences.interface",
    iconType: "ft",
    iconName: "sliders-horizontal",
    colorClass: "ft-settings-hub__section--amber",
  },
  {
    id: "email",
    labelKey: "fantribe.settings_hub.email.label",
    descriptionKey: "fantribe.settings_hub.email.description",
    route: "preferences.email",
    iconType: "ft",
    iconName: "send",
    colorClass: "ft-settings-hub__section--coral",
  },
  {
    id: "profile",
    labelKey: "fantribe.settings_hub.profile_settings.label",
    descriptionKey: "fantribe.settings_hub.profile_settings.description",
    route: "preferences.profile",
    iconType: "ft",
    iconName: "edit3",
    colorClass: "ft-settings-hub__section--teal",
  },
];

export default class FtSettingsHub extends Component {
  @service router;

  @action
  goBack() {
    this.router.transitionTo("userActivity.ftPosts", this.args.model);
  }

  @action
  navigateTo(route, event) {
    event.preventDefault();
    this.router.transitionTo(route, this.args.model);
  }

  <template>
    {{#if @model}}
      <div class="ft-settings-hub">

        {{! Back bar }}
        <div class="ft-settings-hub__topbar">
          <button
            type="button"
            class="ft-settings-hub__back-btn"
            {{on "click" this.goBack}}
            aria-label={{i18n "fantribe.settings_hub.back"}}
          >
            {{ftIcon "chevron-left" size=18}}
            <span>{{i18n "fantribe.settings_hub.back"}}</span>
          </button>
          <span class="ft-settings-hub__topbar-title">
            {{ftIcon "settings" size=16}}
            {{i18n "fantribe.settings_hub.title"}}
          </span>
        </div>

        {{! Hero: avatar + name }}
        <div class="ft-settings-hub__hero">
          <div class="ft-settings-hub__hero-avatar">
            {{avatar @model imageSize="medium" class="ft-settings-hub__avatar"}}
          </div>
          <div class="ft-settings-hub__hero-info">
            <h1 class="ft-settings-hub__hero-name">{{@model.name}}</h1>
            <p class="ft-settings-hub__hero-handle">@{{@model.username}}</p>
          </div>
        </div>

        {{! Section navigation grid }}
        <nav class="ft-settings-hub__grid" aria-label="Settings sections">
          {{#each SETTINGS_SECTIONS as |section|}}
            <button
              type="button"
              class="ft-settings-hub__section {{section.colorClass}}"
              {{on "click" (fn this.navigateTo section.route)}}
            >
              <div class="ft-settings-hub__section-icon-wrap">
                {{#if (eq section.iconType "d")}}
                  {{icon section.iconName}}
                {{else}}
                  {{ftIcon section.iconName size=20}}
                {{/if}}
              </div>
              <div class="ft-settings-hub__section-text">
                <span class="ft-settings-hub__section-label">{{i18n
                    section.labelKey
                  }}</span>
                <span class="ft-settings-hub__section-desc">{{i18n
                    section.descriptionKey
                  }}</span>
              </div>
              {{ftIcon "chevron-right" size=16}}
            </button>
          {{/each}}
        </nav>

      </div>
    {{/if}}
  </template>
}
