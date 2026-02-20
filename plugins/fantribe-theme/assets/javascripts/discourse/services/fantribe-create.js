import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service from "@ember/service";

export default class FantribeCreate extends Service {
  @tracked isCreateMenuOpen = false;
  @tracked isCreatePostModalOpen = false;
  @tracked postCategory = null;

  @action
  toggleCreateMenu() {
    this.isCreateMenuOpen = !this.isCreateMenuOpen;
  }

  @action
  closeCreateMenu() {
    this.isCreateMenuOpen = false;
  }

  @action
  openCreatePostModal(category = null) {
    this.postCategory = category;
    this.isCreateMenuOpen = false;
    this.isCreatePostModalOpen = true;
  }

  @action
  closeCreatePostModal() {
    this.isCreatePostModalOpen = false;
    this.postCategory = null;
  }
}
