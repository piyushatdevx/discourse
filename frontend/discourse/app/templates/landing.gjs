import bodyClass from "discourse/helpers/body-class";
import LandingHero from "discourse/components/landing/hero";
import LiveRightNow from "discourse/components/landing/live-right-now";
import Tribes from "discourse/components/landing/tribes";
import RealStories from "discourse/components/landing/real-stories";
import CommunityHeroes from "discourse/components/landing/community-heroes";
import TribeCta from "discourse/components/landing/tribe-cta";

export default <template>
  {{bodyClass "landing-page"}}

  <div class="landing-page-wrapper">
    <LandingHero />
    <LiveRightNow />
    <Tribes />
    <RealStories />
    <CommunityHeroes />
    <TribeCta />
  </div>

  <style>
    body.landing-page {
      overflow-x: hidden;
    }

    body.landing-page #main-outlet-wrapper {
      display: block !important;
      grid-template-columns: none !important;
    }

    body.landing-page #main-outlet {
      padding: 0 !important;
      margin: 0 !important;
      max-width: none !important;
    }

    body.landing-page .wrap {
      max-width: none !important;
      padding: 0 !important;
      margin: 0 !important;
    }

    .landing-page-wrapper {
      width: 100%;
      margin: 0;
      padding: 0;
      overflow-x: hidden;
    }
  </style>
</template>
