import { withPluginApi } from "discourse/lib/plugin-api";

function initializeFantribe(api) {
  const siteSettings = api.container.lookup("service:site-settings");
  const currentUser = api.getCurrentUser();

  // Force body class for FanTribe styling
  document.body.classList.add("fantribe-theme");

  // Add glassmorphism class if enabled
  if (siteSettings.fantribe_enable_glassmorphism) {
    document.body.classList.add("fantribe-glassmorphism");
  }

  // Mark anonymous state for CSS-only UI gating
  if (!currentUser) {
    document.body.classList.add("fantribe-anon");
  }

  // Redirect the bare userActivity index (/u/:username/activity) to our FT
  // Posts tab. Using routeDidChange on the router service is safe — it fires
  // after the transition completes and triggers a fresh replaceWith, so it
  // never conflicts with Discourse's route lifecycle hooks.
  const router = api.container.lookup("service:router");
  if (router && siteSettings.fantribe_theme_enabled) {
    router.on("routeDidChange", (transition) => {
      const name = transition.to?.name ?? "";
      // Match the bare userActivity index. The full Ember route name is
      // "user.user-activity.index" but we guard loosely for any variation.
      if (name.includes("user-activity") && name.endsWith(".index")) {
        router.replaceWith("userActivity.ftPosts");
      }
    });
  }
}

export default {
  name: "fantribe-customizations",

  initialize() {
    withPluginApi((api) => initializeFantribe(api));
  },
};
