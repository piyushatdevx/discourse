import { withPluginApi } from "discourse/lib/plugin-api";
import DiscourseURL from "discourse/lib/url";

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
        const url = router.currentURL;
        if (!url) {
          return;
        }

        // Redirect bare profile / summary / activity URLs to the Posts tab.
        // Matches:  /u/:username
        //           /u/:username/summary
        //           /u/:username/activity   (no ft-posts sub-path yet)
        const isPrefs = url.startsWith("/u/") && url.includes("/preferences");
        document.body.classList.toggle("ft-on-preferences", isPrefs);

        const isSettingsHub =
          url.startsWith("/u/") && url.includes("/activity/ft-settings");
        document.body.classList.toggle("ft-on-settings-hub", isSettingsHub);

        const isProfileDefault =
          /^\/u\/[^/]+\/?$/.test(url) ||
          /^\/u\/[^/]+\/summary\/?$/.test(url) ||
          /^\/u\/[^/]+\/activity\/?$/.test(url);

        if (isProfileDefault) {
          const username = url.match(/^\/u\/([^/]+)/)?.[1];
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
