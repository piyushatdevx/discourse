import { withPluginApi } from "discourse/lib/plugin-api";
import LazyVideo from "../discourse/components/lazy-video";
import getVideoAttributes from "../lib/lazy-video-attributes";

function applyLazyVideoDecorator(cooked, helper, api) {
  if (cooked.classList.contains("d-editor-preview")) {
    return;
  }

  const lazyContainers = cooked.querySelectorAll(".lazy-video-container");

  lazyContainers.forEach((container) => {
    const siteSettings = api.container.lookup("service:site-settings");
    const videoAttributes = getVideoAttributes(container);

    if (siteSettings[`lazy_${videoAttributes.providerName}_enabled`]) {
      const onLoadedVideo = () => {
        const postId = cooked.closest("article")?.dataset?.postId;
        if (postId) {
          api.preventCloak(parseInt(postId, 10));
        }
      };

      const lazyVideo = document.createElement("p");
      lazyVideo.classList.add("lazy-video-wrapper");

      helper.renderGlimmer(
        lazyVideo,
        <template>
          <LazyVideo
            @videoAttributes={{@data.param}}
            @onLoadedVideo={{@data.onLoadedVideo}}
          />
        </template>,
        { param: videoAttributes, onLoadedVideo }
      );

      container.replaceWith(lazyVideo);
    }
  });
}

function initLazyEmbed(api) {
  const decorator = (cooked, helper) =>
    applyLazyVideoDecorator(cooked, helper, api);

  // Stream (topic posts)
  api.decorateCookedElement(decorator, { onlyStream: true });

  // Non-stream (e.g. feed cards, DecoratedHtml) so video player shows in feed
  api.decorateCookedElement(decorator, { onlyStream: false });
}

export default {
  name: "discourse-lazy-videos",

  initialize() {
    withPluginApi(initLazyEmbed);
  },
};
