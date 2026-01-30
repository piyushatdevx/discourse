import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "fantribe-hide-native-header",

  initialize() {
    withPluginApi("1.14.0", (api) => {
      const siteSettings = api.container.lookup("service:site-settings");

      if (!siteSettings.fantribe_theme_enabled) {
        return;
      }

      // Hide native Discourse header via CSS class on page change
      api.onPageChange(() => {
        document.body.classList.add("fantribe-custom-header");
      });

      // Also add immediately on initialization
      document.body.classList.add("fantribe-custom-header");
    });
  },
};
