import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { eq } from "discourse/truth-helpers";
import FtCreateTribeModal from "discourse/plugins/fantribe-theme/discourse/components/ft-create-tribe-modal";
import ftIcon from "discourse/plugins/fantribe-theme/discourse/helpers/ft-icon";
import FantribeTribeCard from "./fantribe-tribe-card";

export default class FantribeExplorePage extends Component {
  @service currentUser;
  @service fantribeMembership;
  @service site;

  @tracked activeTab = "explore";
  @tracked searchQuery = "";
  @tracked showCreateModal = false;

  get isAdmin() {
    return this.currentUser?.admin;
  }

  @action
  initializeMembership() {
    this.fantribeMembership.initialize();
  }

  @action
  switchTab(tab) {
    this.activeTab = tab;
  }

  @action
  handleSearchInput(event) {
    this.searchQuery = event.target.value;
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

  get allDisplayCategories() {
    const cats = this.args.categories || [];
    return cats.filter((c) => {
      if (c.isUncategorizedCategory) {
        return false;
      }
      if (!this.isAdmin && c.read_restricted) {
        return false;
      }
      if (this.currentUser && this.fantribeMembership.isMember(c.id)) {
        return false;
      }
      return true;
    });
  }

  get filteredBySearch() {
    const query = this.searchQuery.toLowerCase().trim();
    const categories =
      this.activeTab === "explore"
        ? this.allDisplayCategories
        : this.joinedTribes;

    if (!query) {
      return categories;
    }

    return categories.filter(
      (cat) =>
        cat.name.toLowerCase().includes(query) ||
        (cat.description_text || "").toLowerCase().includes(query)
    );
  }

  @action
  openCreateModal() {
    this.showCreateModal = true;
  }

  @action
  closeCreateModal() {
    this.showCreateModal = false;
  }

  <template>
    <div class="ft-explore-page" {{didInsert this.initializeMembership}}>
      <div class="ft-explore-container">

        {{! Search Bar }}
        <div class="ft-explore-search">
          {{ftIcon "search"}}
          <input
            type="text"
            placeholder="Search tribes..."
            value={{this.searchQuery}}
            {{on "input" this.handleSearchInput}}
          />
        </div>

        {{! Header: subtitle + tabs }}
        <div class="ft-explore-header-row">
          <div class="ft-explore-header-left">
            <p class="ft-explore-subtitle">Join communities of creators who
              share your passion</p>
            <div class="ft-explore-tabs">
              <button
                type="button"
                class="ft-explore-tab
                  {{if (eq this.activeTab 'explore') 'ft-explore-tab--active'}}"
                {{on "click" (fn this.switchTab "explore")}}
              >
                {{ftIcon "compass"}}
                <span>Explore tribes</span>
              </button>
              <button
                type="button"
                class="ft-explore-tab
                  {{if
                    (eq this.activeTab 'my-tribes')
                    'ft-explore-tab--active'
                  }}"
                {{on "click" (fn this.switchTab "my-tribes")}}
              >
                {{ftIcon "users"}}
                <span>My tribes</span>
              </button>
            </div>
          </div>
        </div>

        {{! Cards Container }}
        {{#if this.filteredBySearch.length}}
          <div class="ft-explore-cards-container">
            <div class="ft-tribe-grid">
              {{#each this.filteredBySearch as |category|}}
                <FantribeTribeCard @category={{category}} />
              {{/each}}
            </div>
          </div>
        {{else}}
          <div class="ft-explore-empty">
            {{#if this.searchQuery}}
              <div class="ft-explore-empty-icon">🔍</div>
              <h3 class="ft-explore-empty-title">No tribes found</h3>
              <p class="ft-explore-empty-text">Try adjusting your search</p>
            {{else if (eq this.activeTab "my-tribes")}}
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
                {{ftIcon "compass"}}
                <span>Explore Tribes</span>
              </button>
            {{else}}
              <div class="ft-explore-empty-icon">🔍</div>
              <h3 class="ft-explore-empty-title">No tribes found</h3>
              <p class="ft-explore-empty-text">Check back later for new tribes</p>
            {{/if}}
          </div>
        {{/if}}

      </div>
    </div>

    {{#if this.showCreateModal}}
      <FtCreateTribeModal @onClose={{this.closeCreateModal}} />
    {{/if}}
  </template>
}
