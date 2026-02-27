import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import ftIcon from "../helpers/ft-icon";

const autoFocus = modifier((element) => {
  element.focus();
});

const TABS = [
  { id: "all", label: "All", icon: "layout-grid" },
  { id: "people", label: "People", icon: "user" },
  { id: "feed", label: "Feed", icon: "newspaper" },
  { id: "tribes", label: "Tribes", icon: "compass" },
  { id: "gear", label: "Gear", icon: "tag" },
];

export default class FtSearchModal extends Component {
  @service router;

  @tracked query = "";
  @tracked activeTab = "all";
  @tracked rawResults = null;
  @tracked isLoading = false;

  _debounceTimer = null;

  get tabsWithActive() {
    return TABS.map((tab) => ({
      ...tab,
      isActive: tab.id === this.activeTab,
    }));
  }

  get hasQuery() {
    return this.query.trim().length > 0;
  }

  get visibleResults() {
    if (!this.rawResults) {
      return [];
    }

    const limit = this.activeTab === "all" ? 4 : 10;
    const out = [];
    const topicsMap = {};
    (this.rawResults.topics || []).forEach((t) => {
      topicsMap[t.id] = t;
    });

    if (this.activeTab === "all" || this.activeTab === "feed") {
      (this.rawResults.posts || []).slice(0, limit).forEach((p) => {
        const topic = topicsMap[p.topic_id];
        const title =
          (topic && (topic.fancy_title || topic.title)) || "Untitled";
        out.push({
          type: "feed",
          item: p,
          isFeed: true,
          isPeople: false,
          isTribe: false,
          isGear: false,
          titleDisplay: htmlSafe(title),
        });
      });
    }

    if (this.activeTab === "all" || this.activeTab === "people") {
      (this.rawResults.users || []).slice(0, limit).forEach((u) => {
        out.push({
          type: "people",
          item: u,
          isFeed: false,
          isPeople: true,
          isTribe: false,
          isGear: false,
          titleDisplay: htmlSafe(`@${u.username}`),
        });
      });
    }

    if (this.activeTab === "all" || this.activeTab === "tribes") {
      (this.rawResults.categories || []).slice(0, limit).forEach((c) => {
        out.push({
          type: "tribe",
          item: c,
          isFeed: false,
          isPeople: false,
          isTribe: true,
          isGear: false,
          titleDisplay: htmlSafe(c.name),
        });
      });
    }

    if (this.activeTab === "all" || this.activeTab === "gear") {
      (this.rawResults.tags || []).slice(0, limit).forEach((t) => {
        out.push({
          type: "gear",
          item: t,
          isFeed: false,
          isPeople: false,
          isTribe: false,
          isGear: true,
          titleDisplay: htmlSafe(t.name),
        });
      });
    }

    return out;
  }

  get hasResults() {
    return this.visibleResults.length > 0;
  }

  @action
  updateQuery(event) {
    this.query = event.target.value;
    clearTimeout(this._debounceTimer);

    if (this.query.trim()) {
      this._debounceTimer = setTimeout(() => this._performSearch(), 300);
    } else {
      this.rawResults = null;
      this.isLoading = false;
    }
  }

  async _performSearch() {
    const q = this.query.trim();

    if (!q) {
      return;
    }

    this.isLoading = true;

    try {
      const [data, userSearchData] = await Promise.all([
        ajax("/search.json", { data: { q } }),
        ajax("/u/search/users.json", {
          data: { term: q, include_groups: false },
        }).catch(() => ({ users: [] })),
      ]);

      const mainUsers = data.users || [];
      const extraUsers = (userSearchData.users || []).filter(
        (eu) =>
          !mainUsers.some(
            (mu) => mu.username.toLowerCase() === eu.username.toLowerCase()
          )
      );

      data.users = [...mainUsers, ...extraUsers];
      this.rawResults = data;
    } catch {
      this.rawResults = null;
    } finally {
      this.isLoading = false;
    }
  }

  @action
  setTab(tabId) {
    this.activeTab = tabId;
  }

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.args.onClose();
    } else if (event.key === "Enter") {
      event.preventDefault();
      this.args.onClose();
    }
  }

  @action
  navigateToFeed(post) {
    this.router.transitionTo("topic", post.topic_slug, post.topic_id);
    this.args.onClose();
  }

  @action
  navigateToPerson(user) {
    this.router.transitionTo("user", user.username);
    this.args.onClose();
  }

  @action
  navigateToTribe(category) {
    this.router.transitionTo("discovery.category", category.slug);
    this.args.onClose();
  }

  @action
  navigateToGear(tag) {
    this.router.transitionTo("tag.show", tag.name);
    this.args.onClose();
  }

  avatarUrl(template, size = 20) {
    if (!template) {
      return null;
    }

    return template.replace("{size}", size);
  }

  formatCount(n) {
    if (!n) {
      return "0";
    }

    if (n >= 1000) {
      return (n / 1000).toFixed(1) + "k";
    }

    return String(n);
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-modal-backdrop"
      role="dialog"
      aria-modal="true"
      aria-label="Search"
      {{on "click" this.handleBackdropClick}}
      {{on "keydown" this.handleKeydown}}
    >
      <div class="ft-modal ft-search-modal">

        {{! Header }}
        <div class="ft-search-modal__header">
          <h2 class="ft-search-modal__title">Search</h2>
          <button
            type="button"
            class="ft-search-modal__close-btn"
            aria-label="Close"
            {{on "click" @onClose}}
          >
            {{ftIcon "x" size=20}}
          </button>
        </div>

        {{! Search input }}
        <div class="ft-search-modal__search-wrap">
          <label class="ft-search-modal__search-bar">
            {{ftIcon "search" size=18}}
            <input
              type="text"
              class="ft-search-modal__search-input"
              placeholder="Search people, gear, tribes..."
              value={{this.query}}
              {{autoFocus}}
              {{on "input" this.updateQuery}}
              {{on "keydown" this.handleKeydown}}
            />
          </label>
        </div>

        {{! Tabs }}
        <div class="ft-search-modal__tabs">
          {{#each this.tabsWithActive as |tab|}}
            <button
              type="button"
              class="ft-search-modal__tab
                {{if tab.isActive 'ft-search-modal__tab--active'}}"
              {{on "click" (fn this.setTab tab.id)}}
            >
              {{ftIcon tab.icon size=16}}
              {{tab.label}}
            </button>
          {{/each}}
        </div>

        {{! Results }}
        <div class="ft-search-modal__results">
          {{#if this.isLoading}}
            <div class="ft-search-modal__state">
              <div class="ft-search-modal__spinner"></div>
            </div>

          {{else if this.hasQuery}}
            {{#if this.hasResults}}
              {{#each this.visibleResults as |result|}}
                {{#if result.isFeed}}
                  <button
                    type="button"
                    class="ft-search-modal__result-item"
                    {{on "click" (fn this.navigateToFeed result.item)}}
                  >
                    <span
                      class="ft-search-modal__result-icon ft-search-modal__result-icon--feed"
                    >
                      {{ftIcon "newspaper" size=16}}
                    </span>
                    <span class="ft-search-modal__result-body">
                      <span
                        class="ft-search-modal__result-title"
                      >{{result.titleDisplay}}</span>
                      <span class="ft-search-modal__result-meta">
                        {{#if result.item.avatar_template}}
                          <img
                            src={{this.avatarUrl
                              result.item.avatar_template
                              16
                            }}
                            class="ft-search-modal__result-avatar"
                            alt=""
                          />
                        {{/if}}
                        <span>{{result.item.username}}</span>
                      </span>
                    </span>
                  </button>
                {{/if}}

                {{#if result.isPeople}}
                  <button
                    type="button"
                    class="ft-search-modal__result-item"
                    {{on "click" (fn this.navigateToPerson result.item)}}
                  >
                    <span
                      class="ft-search-modal__result-icon ft-search-modal__result-icon--people"
                    >
                      {{ftIcon "user" size=16}}
                    </span>
                    <span class="ft-search-modal__result-body">
                      <span
                        class="ft-search-modal__result-title"
                      >{{result.titleDisplay}}</span>
                      <span class="ft-search-modal__result-meta">
                        {{#if result.item.avatar_template}}
                          <img
                            src={{this.avatarUrl
                              result.item.avatar_template
                              16
                            }}
                            class="ft-search-modal__result-avatar"
                            alt=""
                          />
                        {{/if}}
                        <span>{{result.item.name}}</span>
                      </span>
                    </span>
                  </button>
                {{/if}}

                {{#if result.isTribe}}
                  <button
                    type="button"
                    class="ft-search-modal__result-item"
                    {{on "click" (fn this.navigateToTribe result.item)}}
                  >
                    <span
                      class="ft-search-modal__result-icon ft-search-modal__result-icon--tribe"
                    >
                      {{ftIcon "compass" size=16}}
                    </span>
                    <span class="ft-search-modal__result-body">
                      <span
                        class="ft-search-modal__result-title"
                      >{{result.titleDisplay}}</span>
                      <span class="ft-search-modal__result-meta">
                        {{ftIcon "users" size=10}}
                        <span>{{this.formatCount result.item.topic_count}}
                          posts</span>
                      </span>
                    </span>
                  </button>
                {{/if}}

                {{#if result.isGear}}
                  <button
                    type="button"
                    class="ft-search-modal__result-item"
                    {{on "click" (fn this.navigateToGear result.item)}}
                  >
                    <span
                      class="ft-search-modal__result-icon ft-search-modal__result-icon--gear"
                    >
                      {{ftIcon "tag" size=16}}
                    </span>
                    <span class="ft-search-modal__result-body">
                      <span
                        class="ft-search-modal__result-title"
                      >{{result.titleDisplay}}</span>
                      <span class="ft-search-modal__result-meta">
                        <span>{{this.formatCount result.item.count}} used</span>
                      </span>
                    </span>
                  </button>
                {{/if}}
              {{/each}}
            {{else}}
              <div class="ft-search-modal__state">
                {{ftIcon "search" size=32}}
                <p>No results found</p>
              </div>
            {{/if}}

          {{else}}
            <div class="ft-search-modal__state">
              {{ftIcon "search" size=40}}
              <p>Search anything</p>
            </div>
          {{/if}}
        </div>

      </div>
    </div>
  </template>
}
