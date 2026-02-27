import Component from "@glimmer/component";
import { service } from "@ember/service";
import FantribePostEditPage from "../../components/fantribe-post-edit-page";
import FantribePostFullPage from "../../components/fantribe-post-full-page";

export default class FantribeFullPostConnector extends Component {
  @service fantribeCreate;
  @service siteSettings;

  get isEnabled() {
    return this.siteSettings.fantribe_theme_enabled;
  }

  get topic() {
    return this.args.outletArgs?.model;
  }

  get isEditing() {
    const editingPost = this.fantribeCreate.editingPost;
    return (
      !!editingPost &&
      (editingPost.topic_id === this.topic?.id ||
        editingPost.topicId === this.topic?.id)
    );
  }

  <template>
    {{#if this.isEnabled}}
      {{#if this.isEditing}}
        <FantribePostEditPage @topic={{this.topic}} />
      {{else}}
        <FantribePostFullPage @topic={{this.topic}} />
      {{/if}}
    {{/if}}
  </template>
}
