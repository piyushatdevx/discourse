import Service from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class FantribeFilterService extends Service {
  @tracked selectedCategoryIds = [];
  _hasBeenInitialized = false;

  get hasFilters() {
    return this.selectedCategoryIds.length > 0;
  }

  get selectedCount() {
    return this.selectedCategoryIds.length;
  }

  @action
  toggleCategory(category) {
    const categoryId = category.id;
    const index = this.selectedCategoryIds.indexOf(categoryId);

    if (index === -1) {
      this.selectedCategoryIds = [...this.selectedCategoryIds, categoryId];
    } else {
      this.selectedCategoryIds = this.selectedCategoryIds.filter(
        (id) => id !== categoryId
      );
    }
  }

  @action
  selectCategory(category) {
    const categoryId = category.id;
    if (!this.selectedCategoryIds.includes(categoryId)) {
      this.selectedCategoryIds = [...this.selectedCategoryIds, categoryId];
    }
  }

  @action
  deselectCategory(category) {
    const categoryId = category.id;
    this.selectedCategoryIds = this.selectedCategoryIds.filter(
      (id) => id !== categoryId
    );
  }

  @action
  clearFilters() {
    this.selectedCategoryIds = [];
  }

  @action
  setFilters(categoryIds) {
    this.selectedCategoryIds = [...categoryIds];
  }

  isCategorySelected(category) {
    return this.selectedCategoryIds.includes(category.id);
  }

  initializeWithAllIfEmpty(categories) {
    if (
      !this._hasBeenInitialized &&
      categories?.length > 0 &&
      this.selectedCategoryIds.length === 0
    ) {
      this.selectedCategoryIds = categories.map((c) => c.id);
      this._hasBeenInitialized = true;
    }
  }
}
