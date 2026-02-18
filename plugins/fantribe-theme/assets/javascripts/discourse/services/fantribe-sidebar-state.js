import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service from "@ember/service";

export default class FantribeSidebarState extends Service {
  @tracked isCollapsed = false;
  @tracked isMobileOpen = false;

  @action
  toggle() {
    if (window.innerWidth < 1024) {
      this.isMobileOpen = !this.isMobileOpen;
    } else {
      this.isCollapsed = !this.isCollapsed;
    }
  }

  @action
  closeMobile() {
    this.isMobileOpen = false;
  }
}
