import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import ftIcon from "../helpers/ft-icon";

export default class FantribePostMoreTopics extends Component {
  @service site;
  @service router;

  @tracked topics = null;

  constructor(owner, args) {
    super(owner, args);
    this.loadTopics();
  }

  async loadTopics() {
    try {
      const [newData, unreadData] = await Promise.all([
        ajax("/new.json").catch(() => null),
        ajax("/unread.json").catch(() => null),
      ]);

      const newTopics = newData?.topic_list?.topics || [];
      const unreadTopics = unreadData?.topic_list?.topics || [];

      const seen = new Set();
      const merged = [...newTopics, ...unreadTopics].filter((t) => {
        if (seen.has(t.id)) {
          return false;
        }
        seen.add(t.id);
        return true;
      });

      // Supplement with latest if not enough
      if (merged.length < 3) {
        const latestData = await ajax("/latest.json").catch(() => null);
        for (const t of latestData?.topic_list?.topics || []) {
          if (!seen.has(t.id)) {
            seen.add(t.id);
            merged.push(t);
          }
        }
      }

      this.topics = merged.slice(0, 6).map((t) => ({
        ...t,
        category:
          (this.site.categories || []).find((c) => c.id === t.category_id) ||
          null,
      }));
    } catch {
      this.topics = [];
    }
  }

  @action
  goToTopic(slug, id, event) {
    event.preventDefault();
    this.router.transitionTo("topic", slug, id);
  }

  @action
  viewAll(event) {
    event.preventDefault();
    this.router.transitionTo("discovery.latest");
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="ft-post-more-topics">
      <div class="ft-post-more-topics__header">
        {{ftIcon "trending-up" size=20}}
        <span class="ft-post-more-topics__title">New &amp; Unread Topics</span>
      </div>

      <div class="ft-post-more-topics__content">
        {{#if this.topics}}
          <div class="ft-post-more-topics__list">
            {{#each this.topics as |topic|}}
              <button
                type="button"
                class="ft-post-more-topics__item"
                {{on "click" (fn this.goToTopic topic.slug topic.id)}}
              >
                <div class="ft-post-more-topics__item-left">
                  <div class="ft-post-more-topics__thumb">
                    {{#if topic.image_url}}
                      <img
                        src={{topic.image_url}}
                        alt={{topic.title}}
                        class="ft-post-more-topics__thumb-img"
                        loading="lazy"
                      />
                    {{else}}
                      <div class="ft-post-more-topics__thumb-placeholder">
                        {{ftIcon "image" size=18}}
                      </div>
                    {{/if}}
                  </div>
                  <div class="ft-post-more-topics__item-meta">
                    <span
                      class="ft-post-more-topics__item-title"
                    >{{topic.title}}</span>
                    {{#if topic.category}}
                      <span
                        class="ft-post-more-topics__category-badge"
                      >{{topic.category.name}}</span>
                    {{/if}}
                  </div>
                </div>
                <div class="ft-post-more-topics__item-icon">
                  {{ftIcon "arrow-up-right" size=12}}
                </div>
              </button>
            {{/each}}
          </div>
        {{/if}}
      </div>

      <button
        type="button"
        class="ft-post-more-topics__view-all"
        {{on "click" this.viewAll}}
      >
        View all
      </button>
    </div>
  </template>
}
