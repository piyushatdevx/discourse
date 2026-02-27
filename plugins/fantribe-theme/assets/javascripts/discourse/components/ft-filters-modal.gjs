import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { ajax } from "discourse/lib/ajax";
import ftIcon from "../helpers/ft-icon";

const positionDropdown = modifier((element) => {
  const field = element.closest(".ft-filters-modal__field");
  if (!field) {
    return;
  }

  const trigger =
    field.querySelector(".ft-filters-modal__trigger") ||
    field.querySelector(".ft-filters-modal__input-wrap");
  if (!trigger) {
    return;
  }

  const modal = element.closest(".ft-filters-modal");
  const modalRect = modal ? modal.getBoundingClientRect() : { top: 0, left: 0 };

  const triggerRect = trigger.getBoundingClientRect();
  const viewportHeight = window.innerHeight;
  const spaceBelow = viewportHeight - triggerRect.bottom;
  const spaceAbove = triggerRect.top;

  element.style.position = "fixed";
  element.style.width = `${triggerRect.width}px`;
  element.style.left = `${triggerRect.left - modalRect.left}px`;
  element.style.zIndex = "1100";

  const dropdownHeight = element.offsetHeight;

  if (spaceBelow >= dropdownHeight + 4 || spaceBelow >= spaceAbove) {
    element.style.top = `${triggerRect.bottom - modalRect.top + 4}px`;
    element.style.bottom = "auto";
  } else {
    element.style.bottom = `${viewportHeight - triggerRect.top + modalRect.top + 4}px`;
    element.style.top = "auto";
  }
});

const CONTENT_TYPE_OPTIONS = [
  { id: "all", label: "All" },
  { id: "topics_only", label: "Topics without replies" },
  { id: "with_replies", label: "Topics with replies" },
];

export default class FtFiltersModal extends Component {
  @service fantribeFilter;
  @service site;

  @tracked openDropdown = null;
  @tracked selectedCategoryIds = [];
  @tracked selectedTagNames = [];
  @tracked selectedUsernames = [];
  @tracked topicSearchQuery = "";
  @tracked contentTypeFilter = "all";
  @tracked dateFrom = null;
  @tracked dateTo = null;

  // User search state
  @tracked userSearchQuery = "";
  @tracked userSearchResults = [];
  @tracked isSearchingUsers = false;

  // Tag search state
  @tracked tagSearchQuery = "";
  @tracked tagSearchResults = [];
  @tracked isSearchingTags = false;

  _userSearchTimer = null;
  _tagSearchTimer = null;

  constructor(owner, args) {
    super(owner, args);
    this.selectedCategoryIds = [...this.fantribeFilter.selectedCategoryIds];
    this.selectedTagNames = [...this.fantribeFilter.selectedTagNames];
    this.selectedUsernames = [...this.fantribeFilter.selectedUsernames];
    this.topicSearchQuery = this.fantribeFilter.topicSearchQuery;
    this.contentTypeFilter = this.fantribeFilter.contentTypeFilter;
    this.dateFrom = this.fantribeFilter.dateFrom;
    this.dateTo = this.fantribeFilter.dateTo;
  }

  // ── Categories ──────────────────────────────────────────

  get categories() {
    return this.site.categories || [];
  }

  get categoriesOpen() {
    return this.openDropdown === "categories";
  }

  get categoriesWithSelection() {
    const ids = this.selectedCategoryIds;
    return this.categories.map((cat) => ({
      cat,
      isSelected: ids.includes(cat.id),
    }));
  }

  get allCategoriesSelected() {
    return this.selectedCategoryIds.length === 0;
  }

  get categoryTriggerLabel() {
    if (this.selectedCategoryIds.length === 0) {
      return "All categories";
    }
    return this.selectedCategoryIds
      .map((id) => this.categories.find((c) => c.id === id)?.name)
      .filter(Boolean)
      .join(", ");
  }

  get hasSelectedCategories() {
    return this.selectedCategoryIds.length > 0;
  }

  get selectedCategories() {
    return this.selectedCategoryIds
      .map((id) => this.categories.find((c) => c.id === id))
      .filter(Boolean);
  }

  // ── Tags ────────────────────────────────────────────────

  get tagsOpen() {
    return this.openDropdown === "tags";
  }

  get hasSelectedTags() {
    return this.selectedTagNames.length > 0;
  }

  // ── Topics (title search) ──────────────────────────────

  get hasTopicSearch() {
    return this.topicSearchQuery.trim().length > 0;
  }

  get topicSearchTriggerLabel() {
    if (!this.hasTopicSearch) {
      return "Search within feed";
    }
    return this.topicSearchQuery;
  }

  get topicsOpen() {
    return this.openDropdown === "topics";
  }

  // ── Posted By ──────────────────────────────────────────

  get postedByOpen() {
    return this.openDropdown === "postedBy";
  }

  get hasSelectedUsers() {
    return this.selectedUsernames.length > 0;
  }

  get postedByTriggerLabel() {
    if (this.selectedUsernames.length === 0) {
      return "Select a person";
    }
    return this.selectedUsernames.map((u) => `@${u}`).join(", ");
  }

  // ── Content Type ───────────────────────────────────────

  get contentTypeOpen() {
    return this.openDropdown === "contentType";
  }

  get contentTypeOptions() {
    return CONTENT_TYPE_OPTIONS.map((opt) => ({
      ...opt,
      isSelected: this.contentTypeFilter === opt.id,
    }));
  }

  get contentTypeTriggerLabel() {
    const option = CONTENT_TYPE_OPTIONS.find(
      (o) => o.id === this.contentTypeFilter
    );
    return option?.label || "All";
  }

  get hasContentTypeFilter() {
    return this.contentTypeFilter !== "all";
  }

  // ── Date Range ─────────────────────────────────────────

  get dateRangeOpen() {
    return this.openDropdown === "dateRange";
  }

  get hasDateRange() {
    return this.dateFrom !== null || this.dateTo !== null;
  }

  get dateTriggerLabel() {
    if (!this.dateFrom && !this.dateTo) {
      return "Select dates";
    }
    const from = this.dateFrom || "…";
    const to = this.dateTo || "…";
    return `${from} – ${to}`;
  }

  // ── All chips (unified) ────────────────────────────────

  get allChips() {
    const chips = [];
    this.selectedCategories.forEach((cat) =>
      chips.push({ type: "category", id: cat.id, label: cat.name, data: cat })
    );
    this.selectedTagNames.forEach((tag) =>
      chips.push({ type: "tag", id: tag, label: `#${tag}`, data: tag })
    );
    this.selectedUsernames.forEach((u) =>
      chips.push({ type: "user", id: u, label: `@${u}`, data: u })
    );
    if (this.hasTopicSearch) {
      chips.push({
        type: "search",
        id: "search",
        label: `"${this.topicSearchQuery}"`,
        data: null,
      });
    }
    if (this.hasContentTypeFilter) {
      const opt = CONTENT_TYPE_OPTIONS.find(
        (o) => o.id === this.contentTypeFilter
      );
      chips.push({
        type: "contentType",
        id: "contentType",
        label: opt?.label,
        data: null,
      });
    }
    if (this.hasDateRange) {
      chips.push({
        type: "dateRange",
        id: "dateRange",
        label: this.dateTriggerLabel,
        data: null,
      });
    }
    return chips;
  }

  get hasChips() {
    return this.allChips.length > 0;
  }

  // ── Actions: Dropdown toggles ──────────────────────────

  @action
  toggleDropdown(name) {
    this.openDropdown = this.openDropdown === name ? null : name;
  }

  @action
  openDropdownFor(name) {
    this.openDropdown = name;
  }

  // ── Actions: Categories ────────────────────────────────

  @action
  toggleCategory(cat) {
    const id = cat.id;
    if (this.selectedCategoryIds.includes(id)) {
      this.selectedCategoryIds = this.selectedCategoryIds.filter(
        (cid) => cid !== id
      );
    } else {
      this.selectedCategoryIds = [...this.selectedCategoryIds, id];
    }
  }

  @action
  selectAllCategories() {
    this.selectedCategoryIds = [];
  }

  // ── Actions: Tags ──────────────────────────────────────

  @action
  onTagSearchInput(event) {
    this.tagSearchQuery = event.target.value;
    clearTimeout(this._tagSearchTimer);
    if (this.tagSearchQuery.trim()) {
      this._tagSearchTimer = setTimeout(() => this._performTagSearch(), 300);
    } else {
      this.tagSearchResults = [];
    }
  }

  async _performTagSearch() {
    const term = this.tagSearchQuery.trim();
    if (!term) {
      return;
    }
    this.isSearchingTags = true;
    try {
      const data = await ajax("/tags/filter/search.json", {
        data: { q: term },
      });
      this.tagSearchResults = (data.results || []).filter(
        (t) => !this.selectedTagNames.includes(t.name)
      );
    } catch {
      this.tagSearchResults = [];
    } finally {
      this.isSearchingTags = false;
    }
  }

  @action
  selectTagFromSearch(tag) {
    if (!this.selectedTagNames.includes(tag.name)) {
      this.selectedTagNames = [...this.selectedTagNames, tag.name];
    }
    this.tagSearchQuery = "";
    this.tagSearchResults = [];
  }

  // ── Actions: Topics (search) ───────────────────────────

  @action
  onTopicSearchInput(event) {
    this.topicSearchQuery = event.target.value;
  }

  // ── Actions: Posted By ─────────────────────────────────

  @action
  onUserSearchInput(event) {
    this.userSearchQuery = event.target.value;
    clearTimeout(this._userSearchTimer);
    if (this.userSearchQuery.trim()) {
      this._userSearchTimer = setTimeout(() => this._performUserSearch(), 300);
    } else {
      this.userSearchResults = [];
    }
  }

  async _performUserSearch() {
    const term = this.userSearchQuery.trim();
    if (!term) {
      return;
    }
    this.isSearchingUsers = true;
    try {
      const data = await ajax("/u/search/users.json", {
        data: { term, limit: 8 },
      });
      this.userSearchResults = data.users || [];
    } catch {
      this.userSearchResults = [];
    } finally {
      this.isSearchingUsers = false;
    }
  }

  @action
  selectUser(user) {
    if (!this.selectedUsernames.includes(user.username)) {
      this.selectedUsernames = [...this.selectedUsernames, user.username];
    }
    this.userSearchQuery = "";
    this.userSearchResults = [];
  }

  // ── Actions: Content Type ──────────────────────────────

  @action
  selectContentType(optionId) {
    this.contentTypeFilter = optionId;
  }

  // ── Actions: Date Range ────────────────────────────────

  @action
  onDateFromChange(event) {
    this.dateFrom = event.target.value || null;
  }

  @action
  onDateToChange(event) {
    this.dateTo = event.target.value || null;
  }

  // ── Actions: Chips ─────────────────────────────────────

  @action
  removeChip(chip) {
    if (chip.type === "category") {
      this.selectedCategoryIds = this.selectedCategoryIds.filter(
        (id) => id !== chip.id
      );
    } else if (chip.type === "tag") {
      this.selectedTagNames = this.selectedTagNames.filter(
        (t) => t !== chip.id
      );
    } else if (chip.type === "user") {
      this.selectedUsernames = this.selectedUsernames.filter(
        (u) => u !== chip.id
      );
    } else if (chip.type === "search") {
      this.topicSearchQuery = "";
    } else if (chip.type === "contentType") {
      this.contentTypeFilter = "all";
    } else if (chip.type === "dateRange") {
      this.dateFrom = null;
      this.dateTo = null;
    }
  }

  // ── Actions: Modal controls ────────────────────────────

  @action
  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.args.onClose();
    }
  }

  @action
  handleKeydown(event) {
    if (event.key === "Escape") {
      if (this.openDropdown) {
        this.openDropdown = null;
      } else {
        this.args.onClose();
      }
    }
  }

  @action
  applyFilters() {
    if (this.selectedCategoryIds.length > 0) {
      this.fantribeFilter.setFilters(this.selectedCategoryIds);
    } else {
      this.fantribeFilter.selectedCategoryIds = [];
    }
    this.fantribeFilter.setTagFilters(this.selectedTagNames);
    this.fantribeFilter.setUserFilters(this.selectedUsernames);
    this.fantribeFilter.setTopicSearch(this.topicSearchQuery);
    this.fantribeFilter.setContentTypeFilter(this.contentTypeFilter);
    this.fantribeFilter.setDateRange(this.dateFrom, this.dateTo);
    this.args.onClose();
  }

  @action
  cancelFilters() {
    this.args.onClose();
  }

  avatarUrl(template, size = 24) {
    if (!template) {
      return null;
    }
    return template.replace("{size}", size);
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div
      class="ft-modal-backdrop"
      role="dialog"
      aria-modal="true"
      aria-label="Filters"
      {{on "click" this.handleBackdropClick}}
      {{on "keydown" this.handleKeydown}}
    >
      <div class="ft-modal ft-filters-modal">

        {{! Header }}
        <div class="ft-filters-modal__header">
          <h2 class="ft-filters-modal__title">Filters</h2>
          <button
            type="button"
            class="ft-filters-modal__close-btn"
            aria-label="Close"
            {{on "click" @onClose}}
          >
            {{ftIcon "x" size=20}}
          </button>
        </div>

        {{! Body — fields }}
        <div class="ft-filters-modal__body">

          {{! ─── Categories ──────────────────────────────── }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Categories</label>
            <button
              type="button"
              class="ft-filters-modal__trigger
                {{if this.categoriesOpen 'ft-filters-modal__trigger--open'}}"
              {{on "click" (fn this.toggleDropdown "categories")}}
            >
              <span
                class="ft-filters-modal__trigger-value
                  {{unless
                    this.hasSelectedCategories
                    'ft-filters-modal__trigger-value--placeholder'
                  }}"
              >{{this.categoryTriggerLabel}}</span>
              <span
                class="ft-filters-modal__trigger-icon
                  {{if
                    this.categoriesOpen
                    'ft-filters-modal__trigger-icon--open'
                  }}"
              >
                {{ftIcon "chevron-down" size=16}}
              </span>
            </button>

            {{#if this.categoriesOpen}}
              <div
                class="ft-filters-modal__dropdown ft-filters-modal__dropdown--absolute"
                role="listbox"
                {{positionDropdown}}
              >
                <button
                  type="button"
                  class="ft-filters-modal__dropdown-item"
                  role="option"
                  {{on "click" this.selectAllCategories}}
                >
                  <span
                    class="ft-filters-modal__checkbox
                      {{if
                        this.allCategoriesSelected
                        'ft-filters-modal__checkbox--checked'
                      }}"
                  ></span>
                  <span class="ft-filters-modal__dropdown-label">All categories</span>
                </button>
                <div class="ft-filters-modal__divider"></div>

                {{#each this.categoriesWithSelection as |item|}}
                  <button
                    type="button"
                    class="ft-filters-modal__dropdown-item"
                    role="option"
                    {{on "click" (fn this.toggleCategory item.cat)}}
                  >
                    <span
                      class="ft-filters-modal__checkbox
                        {{if
                          item.isSelected
                          'ft-filters-modal__checkbox--checked'
                        }}"
                    ></span>
                    <span
                      class="ft-filters-modal__dropdown-label"
                    >{{item.cat.name}}</span>
                  </button>
                  <div class="ft-filters-modal__divider"></div>
                {{/each}}
              </div>
            {{/if}}
          </div>

          {{! ─── Topics (title search) ───────────────────── }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Topics</label>
            <div
              class="ft-filters-modal__input-wrap
                {{if this.topicsOpen 'ft-filters-modal__input-wrap--open'}}"
            >
              <span class="ft-filters-modal__input-icon">
                {{ftIcon "search" size=14}}
              </span>
              <input
                type="text"
                class="ft-filters-modal__text-input"
                placeholder="Search within feed…"
                value={{this.topicSearchQuery}}
                {{on "input" this.onTopicSearchInput}}
                {{on "focus" (fn this.toggleDropdown "topics")}}
              />
            </div>
          </div>

          {{! ─── Tags ────────────────────────────────────── }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Tags</label>
            <div
              class="ft-filters-modal__input-wrap
                {{if this.tagsOpen 'ft-filters-modal__input-wrap--open'}}"
            >
              <span class="ft-filters-modal__input-icon">
                {{ftIcon "search" size=14}}
              </span>
              <input
                type="text"
                class="ft-filters-modal__text-input"
                placeholder="Search tags…"
                value={{this.tagSearchQuery}}
                {{on "input" this.onTagSearchInput}}
                {{on "focus" (fn this.openDropdownFor "tags")}}
              />
            </div>

            {{#if this.tagsOpen}}
              {{#if this.isSearchingTags}}
                <div
                  class="ft-filters-modal__dropdown ft-filters-modal__dropdown--absolute ft-filters-modal__dropdown--loading"
                  {{positionDropdown}}
                >
                  <span
                    class="ft-filters-modal__dropdown-label"
                  >Searching…</span>
                </div>
              {{else if this.tagSearchResults.length}}
                <div
                  class="ft-filters-modal__dropdown ft-filters-modal__dropdown--absolute"
                  role="listbox"
                  {{positionDropdown}}
                >
                  {{#each this.tagSearchResults as |tag|}}
                    <button
                      type="button"
                      class="ft-filters-modal__dropdown-item"
                      role="option"
                      {{on "click" (fn this.selectTagFromSearch tag)}}
                    >
                      <span
                        class="ft-filters-modal__dropdown-label"
                      >#{{tag.name}}</span>
                      {{#if tag.count}}
                        <span
                          class="ft-filters-modal__tag-count"
                        >×{{tag.count}}</span>
                      {{/if}}
                    </button>
                    <div class="ft-filters-modal__divider"></div>
                  {{/each}}
                </div>
              {{/if}}
            {{/if}}
          </div>

          {{! ─── Posted By ───────────────────────────────── }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Posted by</label>
            <div
              class="ft-filters-modal__input-wrap
                {{if this.postedByOpen 'ft-filters-modal__input-wrap--open'}}"
            >
              <span class="ft-filters-modal__input-icon">
                {{ftIcon "search" size=14}}
              </span>
              <input
                type="text"
                class="ft-filters-modal__text-input"
                placeholder="Search for a person…"
                value={{this.userSearchQuery}}
                {{on "input" this.onUserSearchInput}}
                {{on "focus" (fn this.openDropdownFor "postedBy")}}
              />
            </div>

            {{#if this.postedByOpen}}
              {{#if this.isSearchingUsers}}
                <div
                  class="ft-filters-modal__dropdown ft-filters-modal__dropdown--absolute ft-filters-modal__dropdown--loading"
                  {{positionDropdown}}
                >
                  <span
                    class="ft-filters-modal__dropdown-label"
                  >Searching…</span>
                </div>
              {{else if this.userSearchResults.length}}
                <div
                  class="ft-filters-modal__dropdown ft-filters-modal__dropdown--absolute"
                  role="listbox"
                  {{positionDropdown}}
                >
                  {{#each this.userSearchResults as |user|}}
                    <button
                      type="button"
                      class="ft-filters-modal__dropdown-item ft-filters-modal__user-item"
                      role="option"
                      {{on "click" (fn this.selectUser user)}}
                    >
                      {{#if user.avatar_template}}
                        <img
                          src={{this.avatarUrl user.avatar_template 24}}
                          class="ft-filters-modal__user-avatar"
                          alt=""
                        />
                      {{/if}}
                      <span class="ft-filters-modal__user-info">
                        <span
                          class="ft-filters-modal__user-name"
                        >{{user.name}}</span>
                        <span
                          class="ft-filters-modal__user-username"
                        >@{{user.username}}</span>
                      </span>
                    </button>
                    <div class="ft-filters-modal__divider"></div>
                  {{/each}}
                </div>
              {{/if}}
            {{/if}}
          </div>

          {{! ─── Only return topics/posts ────────────────── }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Only return topics/posts…</label>
            <button
              type="button"
              class="ft-filters-modal__trigger
                {{if this.contentTypeOpen 'ft-filters-modal__trigger--open'}}"
              {{on "click" (fn this.toggleDropdown "contentType")}}
            >
              <span
                class="ft-filters-modal__trigger-value
                  {{unless
                    this.hasContentTypeFilter
                    'ft-filters-modal__trigger-value--placeholder'
                  }}"
              >{{this.contentTypeTriggerLabel}}</span>
              <span
                class="ft-filters-modal__trigger-icon
                  {{if
                    this.contentTypeOpen
                    'ft-filters-modal__trigger-icon--open'
                  }}"
              >
                {{ftIcon "chevron-down" size=16}}
              </span>
            </button>

            {{#if this.contentTypeOpen}}
              <div
                class="ft-filters-modal__dropdown ft-filters-modal__dropdown--absolute"
                role="listbox"
                {{positionDropdown}}
              >
                {{#each this.contentTypeOptions as |opt|}}
                  <button
                    type="button"
                    class="ft-filters-modal__dropdown-item"
                    role="option"
                    {{on "click" (fn this.selectContentType opt.id)}}
                  >
                    <span
                      class="ft-filters-modal__radio
                        {{if
                          opt.isSelected
                          'ft-filters-modal__radio--selected'
                        }}"
                    ></span>
                    <span
                      class="ft-filters-modal__dropdown-label"
                    >{{opt.label}}</span>
                  </button>
                  <div class="ft-filters-modal__divider"></div>
                {{/each}}
              </div>
            {{/if}}
          </div>

          {{! ─── Custom date range ───────────────────────── }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Custom date range</label>
            <button
              type="button"
              class="ft-filters-modal__trigger
                {{if this.dateRangeOpen 'ft-filters-modal__trigger--open'}}"
              {{on "click" (fn this.toggleDropdown "dateRange")}}
            >
              <span
                class="ft-filters-modal__trigger-value
                  {{unless
                    this.hasDateRange
                    'ft-filters-modal__trigger-value--placeholder'
                  }}"
              >{{this.dateTriggerLabel}}</span>
              <span class="ft-filters-modal__trigger-icon">
                {{ftIcon "calendar" size=16}}
              </span>
            </button>

            {{#if this.dateRangeOpen}}
              <div
                class="ft-filters-modal__date-range-panel ft-filters-modal__date-range-panel--absolute"
                {{positionDropdown}}
              >
                <div class="ft-filters-modal__date-field">
                  <label class="ft-filters-modal__date-label">From</label>
                  <input
                    type="date"
                    class="ft-filters-modal__date-input"
                    value={{this.dateFrom}}
                    {{on "change" this.onDateFromChange}}
                  />
                </div>
                <div class="ft-filters-modal__date-field">
                  <label class="ft-filters-modal__date-label">To</label>
                  <input
                    type="date"
                    class="ft-filters-modal__date-input"
                    value={{this.dateTo}}
                    {{on "change" this.onDateToChange}}
                  />
                </div>
              </div>
            {{/if}}
          </div>

        </div>

        {{! Selected chips }}
        {{#if this.hasChips}}
          <div class="ft-filters-modal__chips">
            {{#each this.allChips as |chip|}}
              <div class="ft-filters-modal__chip">
                <span class="ft-filters-modal__chip-label">{{chip.label}}</span>
                <button
                  type="button"
                  class="ft-filters-modal__chip-remove"
                  aria-label="Remove {{chip.label}}"
                  {{on "click" (fn this.removeChip chip)}}
                >
                  {{ftIcon "x" size=8}}
                </button>
              </div>
            {{/each}}
          </div>
        {{/if}}

        {{! Footer }}
        <div class="ft-filters-modal__footer">
          <button
            type="button"
            class="ft-filters-modal__cancel-btn"
            {{on "click" this.cancelFilters}}
          >
            Cancel
          </button>
          <button
            type="button"
            class="ft-filters-modal__apply-btn"
            {{on "click" this.applyFilters}}
          >
            Apply
          </button>
        </div>

      </div>
    </div>
  </template>
}
