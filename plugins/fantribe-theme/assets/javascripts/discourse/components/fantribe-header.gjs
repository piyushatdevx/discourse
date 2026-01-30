import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
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

  @action
  closeMobileMenu() {
    this.mobileMenuOpen = false;
  }

  @action
  goToLogin() {
    this.mobileMenuOpen = false;
    this.router.transitionTo("login");
  }

  @action
  goToSignup() {
    this.mobileMenuOpen = false;
    this.router.transitionTo("signup");
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
            {{! Desktop: show buttons }}
            <a href="/login" class="fantribe-header__login-btn">Log In</a>
            <a href="/signup" class="fantribe-header__signup-btn">Sign Up</a>

            {{! Mobile: show hamburger menu }}
            <div class="fantribe-header__mobile-menu">
              <button
                class="fantribe-header__hamburger"
                type="button"
                {{on "click" this.toggleMobileMenu}}
              >
                {{icon "bars"}}
              </button>

              {{#if this.mobileMenuOpen}}
                <div
                  class="fantribe-header__mobile-dropdown"
                  {{closeOnClickOutside
                    this.closeMobileMenu
                    (hash targetSelector=".fantribe-header__hamburger")
                  }}
                >
                  <div class="fantribe-header__mobile-dropdown-header">
                    <span>Welcome to FanTribe</span>
                  </div>
                  <div class="fantribe-header__mobile-dropdown-actions">
                    <button
                      type="button"
                      class="fantribe-header__mobile-login"
                      {{on "click" this.goToLogin}}
                    >Log In</button>
                    <button
                      type="button"
                      class="fantribe-header__mobile-signup"
                      {{on "click" this.goToSignup}}
                    >Sign Up</button>
                  </div>
                </div>
              {{/if}}
            </div>
          {{/if}}
        </div>
      </div>
    </header>
  </template>
}
