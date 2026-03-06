import { withPluginApi } from "discourse/lib/plugin-api";
import DiscourseURL from "discourse/lib/url";

// Discourse user-profile routes that should redirect to the ft-posts tab.
// Using route names (not URL regex) is inherently safe — these names can only
// be reached via real user-profile URLs, so reserved /u/ paths like
// /u/account-created, /u/activate-account, /u/password-reset, etc. are
// never matched and need no explicit exclusion list.
//
//   user.summary     → /u/:username/summary
//   userActivity     → /u/:username/activity  (parent route, no sub-route matched)
//   userActivity.index → same path, when Ember resolves the auto-generated index
const PROFILE_REDIRECT_ROUTES = new Set([
  "user.summary",
  "userActivity",
  "userActivity.index",
]);

function initializeFantribe(api) {
  const siteSettings = api.container.lookup("service:site-settings");
  const currentUser = api.getCurrentUser();

  // Force class for FanTribe styling (both html and body for CSS selectors)
  document?.documentElement?.classList?.add("fantribe-theme");
  document?.body?.classList?.add("fantribe-theme");

  // Replace the default Discourse composer placeholder (which references
  // the toolbar we've hidden) with a simple FT-friendly prompt.
  // Done via the composer:opened app event so we hit the textarea after it renders.
  api.onAppEvent("composer:opened", () => {
    const textarea = document.querySelector("#reply-control .d-editor-input");
    if (textarea) {
      textarea.placeholder = "Write your reply...";
    }
  });

  if (siteSettings.fantribe_enable_glassmorphism) {
    document?.body?.classList?.add("fantribe-glassmorphism");
  }

  if (!currentUser) {
    document.body.classList.add("fantribe-anon");
  }

  if (siteSettings.fantribe_theme_enabled) {
    const router = api.container.lookup("service:router");
    if (router) {
      router.on("routeDidChange", () => {
        const routeName = router.currentRouteName;
        if (!routeName) {
          return;
        }

        // Toggle body classes using route names — more reliable than URL checks
        // because they reflect Ember's resolved route, not the raw URL string.
        document.body.classList.toggle(
          "ft-on-preferences",
          routeName.startsWith("preferences")
        );

        // ft-settings is a plugin-defined sub-route of userActivity; the URL
        // is the simplest stable key since the route name includes the full path.
        document.body.classList.toggle(
          "ft-on-settings-hub",
          Boolean(router.currentURL?.includes("/activity/ft-settings"))
        );

        // Redirect bare profile / summary / activity routes to the Posts tab.
        if (PROFILE_REDIRECT_ROUTES.has(routeName)) {
          // Walk up the route hierarchy to find the `user` route that carries
          // the :username param (userActivity uses resetNamespace so its own
          // params are empty; the username lives on the parent `user` route).
          let route = router.currentRoute;
          let username;
          while (route) {
            if (route.params?.username) {
              username = route.params.username;
              break;
            }
            route = route.parent;
          }

          if (username) {
            DiscourseURL.routeTo(`/u/${username}/activity/ft-posts`);
          }
        }
      });
    }
  }
}

export default {
  name: "fantribe-customizations",

  initialize() {
    withPluginApi((api) => initializeFantribe(api));
  },
};
