import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import FantribeNavItem from "./fantribe-nav-item";
import FantribeSearchButton from "./fantribe-search-button";
import FantribeNotifications from "./fantribe-notifications";
import FantribeUserMenu from "./fantribe-user-menu";

export default class FantribeHeader extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;
  @service site;

  @tracked mobileMenuOpen = false;

  get logoUrl() {
    return (
      this.siteSettings.logo_url || "/plugins/fantribe-theme/images/logo.svg"
    );
  }

  get isLoggedIn() {
    return !!this.currentUser;
  }

  get currentPath() {
    return this.router.currentRouteName;
  }

  get isHomePage() {
    const route = this.router.currentRouteName;
    return (
      route === "discovery.latest" ||
      route === "discovery.categories" ||
      route === "discovery.top" ||
      route === "index"
    );
  }

  @action
  navigateToHome() {
    this.router.transitionTo("discovery.latest");
  }

  @action
  toggleMobileMenu() {
    this.mobileMenuOpen = !this.mobileMenuOpen;
  }

  <template>
    <header class="fantribe-header">
      <div class="fantribe-header__container">
        {{! Logo }}
        <button
          class="fantribe-header__logo"
          type="button"
          {{on "click" this.navigateToHome}}
        >
          <img
            src={{this.logoUrl}}
            alt="FanTribe"
            class="fantribe-header__logo-img"
          />
        </button>

        {{! Desktop Navigation - only show when logged in }}
        {{#if this.isLoggedIn}}
          <nav class="fantribe-header__nav fantribe-header__nav--desktop">
            <FantribeNavItem
              @route="discovery.latest"
              @label="Feed"
              @icon="house"
            />
            <FantribeNavItem
              @route="discovery.categories"
              @label="Tribes"
              @icon="users"
            />
            <FantribeNavItem
              @route="discovery.top"
              @label="Trending"
              @icon="fire"
            />
          </nav>
        {{/if}}

        {{! Right Side Actions }}
        <div class="fantribe-header__actions">
          {{#if this.isLoggedIn}}
            <FantribeSearchButton />
            <FantribeNotifications />
            <FantribeUserMenu @user={{this.currentUser}} />
          {{else}}
            <a href="/login" class="fantribe-header__login-btn">Log In</a>
            <a href="/signup" class="fantribe-header__signup-btn">Sign Up</a>
          {{/if}}
        </div>
      </div>
    </header>
  </template>
}
