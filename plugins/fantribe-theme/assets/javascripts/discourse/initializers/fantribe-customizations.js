import { withPluginApi } from "discourse/lib/plugin-api";

function initializeFantribe(api) {
  const siteSettings = api.container.lookup("service:site-settings");

  if (!siteSettings.fantribe_theme_enabled) {
    return;
  }

  // Add fantribe class to body for CSS targeting
  document.body.classList.add("fantribe-theme");

  // Add glassmorphism class if enabled
  if (siteSettings.fantribe_enable_glassmorphism) {
    document.body.classList.add("fantribe-glassmorphism");
  }
}

export default {
  name: "fantribe-customizations",

  initialize() {
    withPluginApi((api) => initializeFantribe(api));
  },
};
