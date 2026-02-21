import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { eq } from "discourse/truth-helpers";
import FantribeCreateTribeModal from "./fantribe-create-tribe-modal";
import FantribeTribeCard from "./fantribe-tribe-card";

export default class FantribeExplorePage extends Component {
  @service currentUser;
  @service fantribeMembership;
  @service site;

  @tracked activeTab = "explore";
  @tracked activeFilter = "All";
  @tracked isFilterOpen = false;
  @tracked isCreateTribeOpen = false;

  isActiveFilter = (filter) => filter === this.activeFilter;

  get isAdmin() {
    return this.currentUser?.admin;
  }

  @action
  initializeMembership() {
    this.fantribeMembership.initialize();
  }

  @action
  openCreateTribe() {
    this.isCreateTribeOpen = true;
  }

  @action
  closeCreateTribe() {
    this.isCreateTribeOpen = false;
  }

  @action
  switchTab(tab) {
    this.activeTab = tab;
  }

  get joinedTribes() {
    if (!this.currentUser) {
      return [];
    }
    return (this.site.categories || []).filter(
      (cat) =>
        !cat.isUncategorizedCategory &&
        !cat.read_restricted_for_non_admins &&
        this.fantribeMembership.isMember(cat.id)
    );
  }

  get hasJoinedTribes() {
    return this.joinedTribes.length > 0;
  }

  get parentCategories() {
    const cats = this.args.categories || [];
    return cats.filter(
      (c) => !c.parent_category_id && !c.isUncategorizedCategory
    );
  }

  get filterOptions() {
    const parents = this.parentCategories;
    const names = parents.map((c) => c.name);
    return ["All", ...new Set(names)];
  }

  get allDisplayCategories() {
    const cats = this.args.categories || [];
    return cats.filter((c) => {
      if (c.isUncategorizedCategory) {
        return false;
      }
      if (!this.isAdmin && c.read_restricted) {
        return false;
      }
      // Hide tribes the user has already joined — they belong in "My Tribes"
      if (this.currentUser && this.fantribeMembership.isMember(c.id)) {
        return false;
      }
      return true;
    });
  }

  get filteredCategories() {
    if (this.activeFilter === "All") {
      return this.allDisplayCategories;
    }
    return this.allDisplayCategories.filter((c) => {
      if (c.name === this.activeFilter) {
        return true;
      }
      const parent = c.parentCategory;
      return parent && parent.name === this.activeFilter;
    });
  }

  get showCategoryLabel() {
    return this.activeFilter !== "All";
  }

  @action
  toggleFilter() {
    this.isFilterOpen = !this.isFilterOpen;
  }

  @action
  closeFilter() {
    this.isFilterOpen = false;
  }

  @action
  selectFilter(filter) {
    this.activeFilter = filter;
    this.isFilterOpen = false;
  }

  <template>
    <div class="ft-explore-page" {{didInsert this.initializeMembership}}>
      <div class="ft-explore-container">

        {{! ── TAB SWITCHER ── }}
        <div class="ft-explore-tabs">
          <button
            type="button"
            class="ft-explore-tab
              {{if (eq this.activeTab 'explore') 'ft-explore-tab--active'}}"
            {{on "click" (fn this.switchTab "explore")}}
          >
            {{icon "compass"}}
            <span>Explore Tribes</span>
          </button>
          <button
            type="button"
            class="ft-explore-tab
              {{if (eq this.activeTab 'my-tribes') 'ft-explore-tab--active'}}"
            {{on "click" (fn this.switchTab "my-tribes")}}
          >
            {{icon "users"}}
            <span>My Tribes</span>
            {{#if this.hasJoinedTribes}}
              <span
                class="ft-explore-tab__badge"
              >{{this.joinedTribes.length}}</span>
            {{/if}}
          </button>
        </div>

        {{! ── EXPLORE TRIBES TAB ── }}
        {{#if (eq this.activeTab "explore")}}
          {{! Page header }}
          <div class="ft-explore-header">
            <div class="ft-explore-header__text">
              <h1 class="ft-explore-title">Explore Tribes</h1>
              <p class="ft-explore-subtitle">Join communities of creators who
                share your passion</p>
            </div>
            {{#if this.isAdmin}}
              <button
                type="button"
                class="ft-explore-create-btn"
                {{on "click" this.openCreateTribe}}
              >
                {{icon "plus"}}
                <span>Create Tribe</span>
              </button>
            {{/if}}
          </div>

          {{! Filter dropdown }}
          <div class="ft-explore-filters">
            <div class="ft-filter-dropdown">
              <button
                class="ft-filter-dropdown__trigger"
                type="button"
                {{on "click" this.toggleFilter}}
              >
                {{icon "sliders"}}
                <span>Filter: {{this.activeFilter}}</span>
                <span
                  class="ft-filter-dropdown__chevron
                    {{if
                      this.isFilterOpen
                      'ft-filter-dropdown__chevron--open'
                    }}"
                >
                  {{icon "chevron-down"}}
                </span>
              </button>

              {{#if this.isFilterOpen}}
                {{! template-lint-disable no-invalid-interactive }}
                <div
                  class="ft-filter-dropdown__backdrop"
                  {{on "click" this.closeFilter}}
                ></div>

                <div class="ft-filter-dropdown__menu">
                  {{#each this.filterOptions as |filter|}}
                    <button
                      class="ft-filter-dropdown__item
                        {{if
                          (this.isActiveFilter filter)
                          'ft-filter-dropdown__item--active'
                        }}"
                      type="button"
                      {{on "click" (fn this.selectFilter filter)}}
                    >
                      <span>{{filter}}</span>
                      {{#if (this.isActiveFilter filter)}}
                        {{icon "check"}}
                      {{/if}}
                    </button>
                  {{/each}}
                </div>
              {{/if}}
            </div>
          </div>

          {{! Results count }}
          <div class="ft-explore-results-count">
            <p>
              Showing
              <span
                class="ft-count-number"
              >{{this.filteredCategories.length}}</span>
              tribes
              {{#if this.showCategoryLabel}}
                in
                <span class="ft-count-category">{{this.activeFilter}}</span>
              {{/if}}
            </p>
          </div>

          {{! Tribe grid or empty state }}
          {{#if this.filteredCategories.length}}
            <div class="ft-tribe-grid">
              {{#each this.filteredCategories as |category|}}
                <FantribeTribeCard @category={{category}} />
              {{/each}}
            </div>
          {{else}}
            <div class="ft-explore-empty">
              <div class="ft-explore-empty-icon">🔍</div>
              <h3 class="ft-explore-empty-title">No tribes found</h3>
              <p class="ft-explore-empty-text">Try adjusting your search or
                filters</p>
            </div>
          {{/if}}
        {{/if}}

        {{! ── MY TRIBES TAB ── }}
        {{#if (eq this.activeTab "my-tribes")}}
          <div class="ft-my-tribes-tab">
            {{#if this.hasJoinedTribes}}
              <div class="ft-section-header">
                <div class="ft-section-header__text">
                  <h2 class="ft-section-title">My Tribes</h2>
                  <p class="ft-section-subtitle">Communities you've joined</p>
                </div>
              </div>
              <div class="ft-my-tribes-grid">
                {{#each this.joinedTribes as |category|}}
                  <FantribeTribeCard @category={{category}} />
                {{/each}}
              </div>
            {{else}}
              <div class="ft-explore-empty">
                <div class="ft-explore-empty-icon">🏕️</div>
                <h3 class="ft-explore-empty-title">No tribes yet</h3>
                <p class="ft-explore-empty-text">Explore and join tribes to see
                  them here</p>
                <button
                  type="button"
                  class="ft-explore-create-btn"
                  style="margin-top: 16px;"
                  {{on "click" (fn this.switchTab "explore")}}
                >
                  {{icon "compass"}}
                  <span>Explore Tribes</span>
                </button>
              </div>
            {{/if}}
          </div>
        {{/if}}

      </div>

      {{! Create Tribe modal — admin only }}
      {{#if this.isCreateTribeOpen}}
        <FantribeCreateTribeModal @onClose={{this.closeCreateTribe}} />
      {{/if}}
    </div>
  </template>
}
