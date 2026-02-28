import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service from "@ember/service";

export default class FantribeFilterService extends Service {
  @tracked selectedCategoryIds = [];
  @tracked selectedTagNames = [];
  @tracked selectedUsernames = [];
  @tracked topicSearchQuery = "";
  @tracked contentTypeFilter = "all";
  @tracked dateFrom = null;
  @tracked dateTo = null;
  @tracked isFiltersModalOpen = false;
  @tracked isSearchModalOpen = false;

  get hasFilters() {
    return (
      this.selectedCategoryIds.length > 0 ||
      this.selectedTagNames.length > 0 ||
      this.selectedUsernames.length > 0 ||
      this.topicSearchQuery.trim().length > 0 ||
      this.contentTypeFilter !== "all" ||
      this.dateFrom !== null ||
      this.dateTo !== null
    );
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
  openFiltersModal() {
    this.isFiltersModalOpen = true;
  }

  @action
  closeFiltersModal() {
    this.isFiltersModalOpen = false;
  }

  @action
  openSearchModal() {
    this.isSearchModalOpen = true;
  }

  @action
  closeSearchModal() {
    this.isSearchModalOpen = false;
  }

  @action
  removeCategoryById(id) {
    this.selectedCategoryIds = this.selectedCategoryIds.filter(
      (cid) => cid !== id
    );
  }

  @action
  removeTag(name) {
    this.selectedTagNames = this.selectedTagNames.filter((t) => t !== name);
  }

  @action
  removeUser(username) {
    this.selectedUsernames = this.selectedUsernames.filter(
      (u) => u !== username
    );
  }

  @action
  clearFilters() {
    this.selectedCategoryIds = [];
    this.selectedTagNames = [];
    this.selectedUsernames = [];
    this.topicSearchQuery = "";
    this.contentTypeFilter = "all";
    this.dateFrom = null;
    this.dateTo = null;
  }

  @action
  setFilters(categoryIds) {
    this.selectedCategoryIds = [...categoryIds];
  }

  @action
  setTagFilters(tagNames) {
    this.selectedTagNames = [...tagNames];
  }

  @action
  setUserFilters(usernames) {
    this.selectedUsernames = [...usernames];
  }

  @action
  setTopicSearch(query) {
    this.topicSearchQuery = query;
  }

  @action
  setContentTypeFilter(type) {
    this.contentTypeFilter = type;
  }

  @action
  setDateRange(from, to) {
    this.dateFrom = from;
    this.dateTo = to;
  }

  isCategorySelected(category) {
    return this.selectedCategoryIds.includes(category.id);
  }
}
