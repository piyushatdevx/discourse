import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service from "@ember/service";

export default class FantribeCreate extends Service {
  @tracked isCreateMenuOpen = false;
  @tracked isCreatePostModalOpen = false;

  @action
  toggleCreateMenu() {
    this.isCreateMenuOpen = !this.isCreateMenuOpen;
  }

  @action
  closeCreateMenu() {
    this.isCreateMenuOpen = false;
  }

  @action
  openCreatePostModal() {
    this.isCreateMenuOpen = false;
    this.isCreatePostModalOpen = true;
  }

  @action
  closeCreatePostModal() {
    this.isCreatePostModalOpen = false;
  }
}
