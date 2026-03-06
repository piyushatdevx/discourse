import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";
import FtCreateMenu from "./ft-create-menu";
import FtCreatePostModal from "./ft-create-post-modal";
import FtCreateTribeModal from "./ft-create-tribe-modal";

export default class FantribeHeader extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;
  @service fantribeCreate;
  @service fantribeFilter;

  @tracked mobileMenuOpen = false;
  @tracked isMobileCreateSheetOpen = false;

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
  handleMobileSearchClick() {
    if (this.fantribeFilter) {
      this.fantribeFilter.openSearchModal();
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

  @action
  toggleMobileCreateSheet() {
    this.isMobileCreateSheetOpen = !this.isMobileCreateSheetOpen;
  }

  @action
  closeMobileCreateSheet(event) {
    if (!event || event.target === event.currentTarget) {
      this.isMobileCreateSheetOpen = false;
    }
  }

  @action
  closeMobileCreateSheetFromButton() {
    this.isMobileCreateSheetOpen = false;
  }

  @action
  closeMobileCreateSheetOnKey(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.isMobileCreateSheetOpen = false;
    }
  }

  @action
  openMobileCreatePost() {
    this.isMobileCreateSheetOpen = false;
    this.fantribeCreate.openCreatePostModal();
  }

  @action
  openMobileCreateTribe() {
    this.isMobileCreateSheetOpen = false;
    this.fantribeCreate.openCreateTribeModal();
  }

  <template>
    <header class="fantribe-header">
      <div class="fantribe-header__container">
        {{#if this.isLoggedIn}}
          <div class="fantribe-header__mobile-layout">
            <div class="fantribe-header__mobile-create-area">
              <button
                class="fantribe-header__mobile-create"
                type="button"
                aria-label={{i18n "fantribe.header.create_aria"}}
                {{on "click" this.toggleMobileCreateSheet}}
              >
                {{ftIcon "plus" size=16}}
              </button>
            </div>

            <button
              class="fantribe-header__logo fantribe-header__logo--mobile"
              type="button"
              {{on "click" this.navigateToHome}}
            >
              <img
                src={{this.logoUrl}}
                alt="CreatorTribe"
                class="fantribe-header__logo-img"
              />
            </button>

            <button
              class="fantribe-header__mobile-search"
              type="button"
              aria-label={{i18n "fantribe.header.search_aria"}}
              {{on "click" this.handleMobileSearchClick}}
            >
              {{ftIcon "search" size=20}}
            </button>
          </div>

          <div class="fantribe-header__desktop-layout">
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
            </div>
          </div>
        {{else}}
          <div
            class="fantribe-header__desktop-layout fantribe-header__desktop-layout--anon"
          >
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
            </div>
          </div>
        {{/if}}
      </div>
    </header>

    {{#if this.isMobileCreateSheetOpen}}
      <div class="ft-mobile-create-backdrop-wrapper">
        <div
          class="ft-mobile-create-overlay"
          role="button"
          tabindex="0"
          aria-label={{i18n "fantribe.create_menu.close"}}
          {{on "click" this.closeMobileCreateSheet}}
          {{on "keydown" this.closeMobileCreateSheetOnKey}}
        ></div>
        <div class="ft-mobile-create-backdrop" aria-hidden="true"></div>
        <div class="ft-mobile-create-sheet">
          <div class="ft-mobile-create-sheet__header">
            <span class="ft-mobile-create-sheet__title">Create</span>
            <button
              type="button"
              class="ft-mobile-create-sheet__close"
              aria-label={{i18n "fantribe.create_menu.close"}}
              {{on "click" this.closeMobileCreateSheetFromButton}}
            >
              <svg
                class="ft-mobile-create-sheet__close-icon"
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 20 20"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M15 5L5 15"
                  stroke="#FF8098"
                  stroke-width="1.67"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
                <path
                  d="M5 5L15 15"
                  stroke="#FF8098"
                  stroke-width="1.67"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
            </button>
          </div>
          <div class="ft-mobile-create-sheet__items">
            <button
              type="button"
              class="ft-mobile-create-sheet__item"
              {{on "click" this.openMobileCreatePost}}
            >
              <span
                class="ft-mobile-create-sheet__icon ft-mobile-create-sheet__icon--blue"
              >
                {{ftIcon "edit3"}}
              </span>
              <div class="ft-mobile-create-sheet__item-content">
                <span class="ft-mobile-create-sheet__item-label">
                  {{i18n "fantribe.create_menu.create_post"}}
                </span>
                <span class="ft-mobile-create-sheet__item-desc">
                  {{i18n "fantribe.create_menu.create_post_desc"}}
                </span>
              </div>
            </button>

            {{#if this.currentUser.admin}}
              <button
                type="button"
                class="ft-mobile-create-sheet__item"
                {{on "click" this.openMobileCreateTribe}}
              >
                <span
                  class="ft-mobile-create-sheet__icon ft-mobile-create-sheet__icon--darkRed"
                >
                  {{ftIcon "compass"}}
                </span>
                <div class="ft-mobile-create-sheet__item-content">
                  <span class="ft-mobile-create-sheet__item-label">
                    {{i18n "fantribe.create_menu.create_tribe"}}
                  </span>
                  <span class="ft-mobile-create-sheet__item-desc">
                    {{i18n "fantribe.create_menu.create_tribe_desc"}}
                  </span>
                </div>
              </button>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}

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
