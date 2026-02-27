import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ftIcon from "../helpers/ft-icon";

export default class FtFiltersModal extends Component {
  @service fantribeFilter;
  @service site;

  @tracked openDropdown = null;
  @tracked selectedCategoryIds = [];

  constructor(owner, args) {
    super(owner, args);
    this.selectedCategoryIds = [...this.fantribeFilter.selectedCategoryIds];
  }

  get categories() {
    return this.site.categories || [];
  }

  get categoriesOpen() {
    return this.openDropdown === "categories";
  }

  // Map each category to { cat, isSelected } so templates can read it reactively
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

  @action
  toggleCategoriesDropdown() {
    this.openDropdown = this.categoriesOpen ? null : "categories";
  }

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

  @action
  removeCategory(cat) {
    this.selectedCategoryIds = this.selectedCategoryIds.filter(
      (id) => id !== cat.id
    );
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
      this.fantribeFilter.clearFilters();
    }
    this.args.onClose();
  }

  @action
  cancelFilters() {
    this.args.onClose();
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

          {{! Categories }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Categories</label>
            <button
              type="button"
              class="ft-filters-modal__trigger
                {{if this.categoriesOpen 'ft-filters-modal__trigger--open'}}"
              {{on "click" this.toggleCategoriesDropdown}}
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
              <div class="ft-filters-modal__dropdown" role="listbox">

                {{! All categories row }}
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

                {{! Individual category rows }}
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

          {{! Topics }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Topics</label>
            <button type="button" class="ft-filters-modal__trigger">
              <span
                class="ft-filters-modal__trigger-value ft-filters-modal__trigger-value--placeholder"
              >Select topics</span>
              <span class="ft-filters-modal__trigger-icon">
                {{ftIcon "chevron-down" size=16}}
              </span>
            </button>
          </div>

          {{! Tags }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Tags</label>
            <button type="button" class="ft-filters-modal__trigger">
              <span
                class="ft-filters-modal__trigger-value ft-filters-modal__trigger-value--placeholder"
              >Select tags</span>
              <span class="ft-filters-modal__trigger-icon">
                {{ftIcon "chevron-down" size=16}}
              </span>
            </button>
          </div>

          {{! Posted by }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Posted by</label>
            <button type="button" class="ft-filters-modal__trigger">
              <span
                class="ft-filters-modal__trigger-value ft-filters-modal__trigger-value--placeholder"
              >Select a person</span>
              <span class="ft-filters-modal__trigger-icon">
                {{ftIcon "chevron-down" size=16}}
              </span>
            </button>
          </div>

          {{! Only return topics/posts }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Only return topics/posts…</label>
            <button type="button" class="ft-filters-modal__trigger">
              <span
                class="ft-filters-modal__trigger-value ft-filters-modal__trigger-value--placeholder"
              >Select topics/posts</span>
              <span class="ft-filters-modal__trigger-icon">
                {{ftIcon "chevron-down" size=16}}
              </span>
            </button>
          </div>

          {{! Custom date range }}
          <div class="ft-filters-modal__field">
            <label class="ft-filters-modal__label">Custom date range</label>
            <button type="button" class="ft-filters-modal__trigger">
              <span
                class="ft-filters-modal__trigger-value ft-filters-modal__trigger-value--placeholder"
              >Select dates</span>
              <span class="ft-filters-modal__trigger-icon">
                {{ftIcon "calendar" size=16}}
              </span>
            </button>
          </div>

        </div>

        {{! Selected category chips }}
        {{#if this.hasSelectedCategories}}
          <div class="ft-filters-modal__chips">
            {{#each this.selectedCategories as |cat|}}
              <div class="ft-filters-modal__chip">
                <span class="ft-filters-modal__chip-label">{{cat.name}}</span>
                <button
                  type="button"
                  class="ft-filters-modal__chip-remove"
                  aria-label="Remove {{cat.name}}"
                  {{on "click" (fn this.removeCategory cat)}}
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
