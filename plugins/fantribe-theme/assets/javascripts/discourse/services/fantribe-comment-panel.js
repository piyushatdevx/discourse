import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service from "@ember/service";

export default class FantribeCommentPanel extends Service {
  @tracked isOpen = false;
  @tracked topicId = null;
  @tracked topic = null;

  @action
  open(topicId, topic) {
    this.topicId = topicId;
    this.topic = topic;
    this.isOpen = true;
  }

  @action
  close() {
    this.isOpen = false;
    this.topicId = null;
    this.topic = null;
  }
}
