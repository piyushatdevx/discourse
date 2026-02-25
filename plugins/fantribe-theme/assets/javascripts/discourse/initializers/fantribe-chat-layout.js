import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "fantribe-chat-layout",

  initialize() {
    withPluginApi((api) => {
      // Override chat controller to always show channels list inside chat view
      api.modifyClass("controller:chat", {
        pluginId: "fantribe-theme",

        get shouldUseChatSidebar() {
          // Always show channels list inside fullscreen chat (except on mobile)
          return !this.site.mobileView;
        },

        // Keep the core sidebar behavior as-is
        get shouldUseCoreSidebar() {
          return this.siteSettings.navigation_menu === "sidebar";
        },
      });

      // Force full-screen chat mode - disable drawer completely
      api.modifyClass("service:chat-state-manager", {
        pluginId: "fantribe-theme",

        get isFullPagePreferred() {
          return true;
        },

        get isDrawerPreferred() {
          return false;
        },
      });
    });
  },
};
