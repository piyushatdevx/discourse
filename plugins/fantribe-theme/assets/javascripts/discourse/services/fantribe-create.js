import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service from "@ember/service";

export default class FantribeCreate extends Service {
  @tracked isCreateMenuOpen = false;
  @tracked isSidebarCreateMenuOpen = false;
  @tracked isCreatePostModalOpen = false;
  @tracked postCategory = null;
  @tracked editingPost = null;
  @tracked editingTopicTitle = "";
  @tracked editingTags = [];

  @action
  toggleCreateMenu() {
    this.isCreateMenuOpen = !this.isCreateMenuOpen;
  }

  @action
  closeCreateMenu() {
    this.isCreateMenuOpen = false;
  }

  @action
  openSidebarCreateMenu() {
    this.isSidebarCreateMenuOpen = true;
  }

  @action
  closeSidebarCreateMenu() {
    this.isSidebarCreateMenuOpen = false;
  }

  @action
  openCreatePostModal(category = null) {
    this.postCategory = category;
    this.editingPost = null;
    this.editingTopicTitle = "";
    this.editingTags = [];
    this.isCreateMenuOpen = false;
    this.isSidebarCreateMenuOpen = false;
    this.isCreatePostModalOpen = true;
  }

  @action
  openEditPostModal(post, topicTitle, tags) {
    this.editingPost = post;
    this.editingTopicTitle = topicTitle || "";
    this.editingTags = tags || [];
    this.postCategory = null;
    this.isCreateMenuOpen = false;
    // Do not open the create modal — the full-page edit view is shown via
    // the topic-above-posts connector when editingPost is set.
  }

  @action
  closeCreatePostModal() {
    this.isCreatePostModalOpen = false;
    this.postCategory = null;
    this.editingPost = null;
    this.editingTopicTitle = "";
    this.editingTags = [];
  }
}
