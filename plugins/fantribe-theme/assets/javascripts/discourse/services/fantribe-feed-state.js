import { tracked } from "@glimmer/tracking";
import Service from "@ember/service";

export default class FantribeFeedState extends Service {
  @tracked pendingTopics = [];

  prependTopic(topic) {
    this.pendingTopics = [topic, ...this.pendingTopics];
  }

  clearPending() {
    this.pendingTopics = [];
  }
}
