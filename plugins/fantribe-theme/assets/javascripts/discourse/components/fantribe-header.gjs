import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import ftIcon from "../helpers/ft-icon";
import FtCreateMenu from "./ft-create-menu";
import FtCreatePostModal from "./ft-create-post-modal";
import FtCreateTribeModal from "./ft-create-tribe-modal";

export default class FantribeHeader extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;
  @service fantribeCreate;

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
        {{! Left section: hamburger + logo }}
        <div class="fantribe-header__left-group">
          <button
            class="fantribe-header__sidebar-toggle"
            type="button"
            {{on "click" @onToggleSidebar}}
          >
            {{ftIcon "menu"}}
          </button>

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
        </div>

        {{! Center Search Bar }}
        <div class="fantribe-header__search" role="search">
          <span class="fantribe-header__search-icon">
            {{ftIcon "search"}}
          </span>
          <input
            type="text"
            id="fantribe-header_search-input"
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
              {{on "click" this.fantribeCreate.toggleCreateMenu}}
            >
              {{ftIcon "plus"}}
              <span>Create</span>
            </button>

            {{#if this.fantribeCreate.isCreateMenuOpen}}
              <FtCreateMenu />
            {{/if}}
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
                {{ftIcon "menu"}}
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

    {{#if this.fantribeCreate.isCreatePostModalOpen}}
      <FtCreatePostModal />
    {{/if}}

    {{#if this.fantribeCreate.isCreateTribeModalOpen}}
      <FtCreateTribeModal
        @onClose={{this.fantribeCreate.closeCreateTribeModal}}
      />
    {{/if}}
  </template>
}
