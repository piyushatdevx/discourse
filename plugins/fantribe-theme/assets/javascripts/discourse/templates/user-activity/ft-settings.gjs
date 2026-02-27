import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import { eq } from "discourse/truth-helpers";
import ftIcon from "discourse/plugins/fantribe-theme/discourse/helpers/ft-icon";

const SETTINGS_SECTIONS = [
  {
    id: "account",
    label: "Account & Security",
    description: "Email, password, and linked accounts",
    route: "preferences.account",
    iconType: "d",
    iconName: "user",
    colorClass: "ft-settings-hub__section--blue",
  },
  {
    id: "notifications",
    label: "Notifications",
    description: "Control what alerts you receive",
    route: "preferences.notifications",
    iconType: "ft",
    iconName: "bell",
    colorClass: "ft-settings-hub__section--purple",
  },
  {
    id: "privacy",
    label: "Privacy & Safety",
    description: "Manage blocked users and visibility",
    route: "preferences.users",
    iconType: "ft",
    iconName: "lock",
    colorClass: "ft-settings-hub__section--green",
  },
  {
    id: "appearance",
    label: "Appearance",
    description: "Theme, font size, and interface options",
    route: "preferences.interface",
    iconType: "ft",
    iconName: "sliders-horizontal",
    colorClass: "ft-settings-hub__section--amber",
  },
  {
    id: "email",
    label: "Email Preferences",
    description: "Digest emails and notification delivery",
    route: "preferences.email",
    iconType: "ft",
    iconName: "send",
    colorClass: "ft-settings-hub__section--coral",
  },
  {
    id: "profile",
    label: "Profile Settings",
    description: "Update name, bio, and other profile details",
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
            aria-label="Back to profile"
          >
            {{ftIcon "chevron-left" size=18}}
            <span>Back to Profile</span>
          </button>
          <span class="ft-settings-hub__topbar-title">
            {{ftIcon "settings" size=16}}
            Settings
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
                <span
                  class="ft-settings-hub__section-label"
                >{{section.label}}</span>
                <span
                  class="ft-settings-hub__section-desc"
                >{{section.description}}</span>
              </div>
              {{ftIcon "chevron-right" size=16}}
            </button>
          {{/each}}
        </nav>

      </div>
    {{/if}}
  </template>
}
