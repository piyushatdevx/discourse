import Component from "@glimmer/component";
import { service } from "@ember/service";

export default class ChatEmojiPicker extends Component {
  @service site;

  <template>{{#if this.site.desktopView}}{{/if}}</template>
}
