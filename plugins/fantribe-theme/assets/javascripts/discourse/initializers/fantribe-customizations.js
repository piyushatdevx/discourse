import { withPluginApi } from "discourse/lib/plugin-api";

function initializeFantribe(api) {
  const siteSettings = api.container.lookup("service:site-settings");
  const currentUser = api.getCurrentUser();

  // FORCE body class for debugging - normally this checks fantribe_theme_enabled
  document.body.classList.add("fantribe-theme");

  // Add glassmorphism class if enabled
  if (siteSettings.fantribe_enable_glassmorphism) {
    document.body.classList.add("fantribe-glassmorphism");
  }

  // Mark anonymous state for CSS-only UI gating
  if (!currentUser) {
    document.body.classList.add("fantribe-anon");
  }
}

export default {
  name: "fantribe-customizations",

  initialize() {
    withPluginApi((api) => initializeFantribe(api));
  },
};
