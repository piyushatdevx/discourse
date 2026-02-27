import Component from "@glimmer/component";
import { service } from "@ember/service";
import FantribePostFullPage from "../../components/fantribe-post-full-page";

export default class FantribeFullPostConnector extends Component {
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get topic() {
    return this.args.outletArgs?.model;
  }

  <template>
    {{#if this.isEnabled}}
      <FantribePostFullPage @topic={{this.topic}} />
    {{/if}}
  </template>
}
