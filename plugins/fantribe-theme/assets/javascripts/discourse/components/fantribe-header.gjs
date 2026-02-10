import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";

export default class FantribeHeader extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;
  @service composer;

  @tracked mobileMenuOpen = false;

  get logoUrl() {
    return (
      this.siteSettings.logo_url || "/plugins/fantribe-theme/images/logo.svg"
    );
  }

  get isLoggedIn() {
    return !!this.currentUser;
  }

  @action
  navigateToHome() {
    this.router.transitionTo("discovery.latest");
  }

  @action
  handleSearchFocus() {
    this.router.transitionTo("full-page-search");
  }

  @action
  handleSearchKeydown(event) {
    if (event.key === "Enter") {
      const q = event.target.value.trim();
      if (q) {
        this.router.transitionTo("full-page-search", { queryParams: { q } });
      } else {
        this.router.transitionTo("full-page-search");
      }
    }
  }

  @action
  openComposer() {
    this.composer.open({
      action: "createTopic",
      draftKey: "new_topic",
      draftSequence: 0,
    });
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
            alt="CreatorTribe"
            class="fantribe-header__logo-img"
          />
        </button>

        {{! Center Search Bar }}
        <div class="fantribe-header__search" role="search">
          <span class="fantribe-header__search-icon">
            {{icon "magnifying-glass"}}
          </span>
          <input
            type="text"
            class="fantribe-header__search-input"
            placeholder="Search people, gear, or tribes..."
            {{on "focus" this.handleSearchFocus}}
            {{on "keydown" this.handleSearchKeydown}}
          />
        </div>

        {{! Right Side Actions }}
        <div class="fantribe-header__actions">
          {{#if this.isLoggedIn}}
            <button
              type="button"
              class="fantribe-header__create-btn"
              {{on "click" this.openComposer}}
            >
              {{icon "plus"}}
              <span>Create</span>
            </button>
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
