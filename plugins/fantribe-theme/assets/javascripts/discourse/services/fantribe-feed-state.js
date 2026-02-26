import { tracked } from "@glimmer/tracking";
import Service from "@ember/service";

export default class FantribeFeedState extends Service {
  @tracked pendingTopics = [];
  @tracked topicUpdates = {};

  prependTopic(topic) {
    this.pendingTopics = [topic, ...this.pendingTopics];
  }

  clearPending() {
    this.pendingTopics = [];
  }

  updateTopic(topicId, updates) {
    this.topicUpdates = {
      ...this.topicUpdates,
      [topicId]: { ...(this.topicUpdates[topicId] || {}), ...updates },
    };
  }
}
