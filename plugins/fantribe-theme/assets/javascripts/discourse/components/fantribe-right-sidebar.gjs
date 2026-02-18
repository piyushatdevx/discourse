import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import FantribeAvatar from "./fantribe-avatar";

export default class FantribeRightSidebar extends Component {
  get trendingTribes() {
    return [
      {
        name: "Synthwave Producers",
        members: "12.5K",
        category: "Electronic",
        isNew: true,
      },
      { name: "Indie Bedroom Artists", members: "8.3K", category: "Indie" },
      { name: "Lo-Fi Beats Collective", members: "15.2K", category: "Hip-Hop" },
      { name: "Guitar Pedalheads", members: "6.7K", category: "Gear" },
      { name: "Vocal Mix Masters", members: "9.1K", category: "Production" },
    ];
  }

  get liveStreams() {
    return [
      {
        userName: "DJ Nova",
        title: "Late Night Mix Session 🌙",
        viewers: "2.3K",
        verification: "gold",
      },
      {
        userName: "Luna Rose",
        title: "Writing new track live!",
        viewers: "1.8K",
        verification: "blue",
      },
      {
        userName: "Beat Maker Pro",
        title: "Lo-fi beats to study to",
        viewers: "892",
        verification: "silver",
      },
    ];
  }

  @action
  viewAllTribes() {
    // eslint-disable-next-line no-console
    console.log("View all tribes clicked");
  }

  @action
  viewAllStreams() {
    // eslint-disable-next-line no-console
    console.log("View all streams clicked");
  }

  @action
  discoverCreators() {
    // eslint-disable-next-line no-console
    console.log("Discover creators clicked");
  }

  <template>
    <div class="fantribe-right-sidebar">
      {{! Trending Tribes Widget }}
      <div class="fantribe-right-sidebar__widget">
        <div class="fantribe-right-sidebar__widget-header">
          {{icon "arrow-trend-up"}}
          <h3>Trending Tribes</h3>
        </div>

        <div class="fantribe-right-sidebar__widget-content">
          {{#each this.trendingTribes as |tribe|}}
            <button type="button" class="fantribe-right-sidebar__tribe-item">
              <div class="fantribe-right-sidebar__tribe-info">
                <div class="fantribe-right-sidebar__tribe-name-row">
                  <span
                    class="fantribe-right-sidebar__tribe-name"
                  >{{tribe.name}}</span>
                  {{#if tribe.isNew}}
                    <span class="fantribe-right-sidebar__new-badge">NEW</span>
                  {{/if}}
                </div>
                <div class="fantribe-right-sidebar__tribe-meta">
                  {{icon "users"}}
                  <span>{{tribe.members}} members</span>
                  <span>·</span>
                  <span>{{tribe.category}}</span>
                </div>
              </div>
              {{icon "chevron-right"}}
            </button>
          {{/each}}
        </div>

        <div class="fantribe-right-sidebar__widget-footer">
          <button
            type="button"
            class="fantribe-right-sidebar__footer-btn"
            {{on "click" this.viewAllTribes}}
          >
            See all tribes
          </button>
        </div>
      </div>

      {{! Live Now Widget }}
      <div class="fantribe-right-sidebar__widget">
        <div class="fantribe-right-sidebar__widget-header">
          <div class="fantribe-right-sidebar__live-icon-wrapper">
            {{icon "broadcast-tower"}}
            <span class="fantribe-right-sidebar__live-ping"></span>
            <span class="fantribe-right-sidebar__live-dot"></span>
          </div>
          <h3>Live Now</h3>
        </div>

        <div class="fantribe-right-sidebar__widget-content">
          {{#each this.liveStreams as |stream|}}
            <button type="button" class="fantribe-right-sidebar__stream-item">
              <div class="fantribe-right-sidebar__stream-avatar-wrapper">
                <FantribeAvatar
                  @name={{stream.userName}}
                  @size="sm"
                  @verification={{stream.verification}}
                />
                <div class="fantribe-right-sidebar__stream-live-badge">
                  <span class="fantribe-right-sidebar__stream-ping"></span>
                  <span class="fantribe-right-sidebar__stream-dot"></span>
                </div>
              </div>

              <div class="fantribe-right-sidebar__stream-info">
                <span
                  class="fantribe-right-sidebar__stream-name"
                >{{stream.userName}}</span>
                <p>{{stream.title}}</p>
                <div class="fantribe-right-sidebar__stream-viewers">
                  <div class="fantribe-right-sidebar__live-badge">
                    {{icon "play"}}
                    <span>LIVE</span>
                  </div>
                  <span>{{stream.viewers}} watching</span>
                </div>
              </div>
            </button>
          {{/each}}
        </div>

        <div class="fantribe-right-sidebar__widget-footer">
          <button
            type="button"
            class="fantribe-right-sidebar__footer-btn fantribe-right-sidebar__footer-btn--live"
            {{on "click" this.viewAllStreams}}
          >
            View all live streams
          </button>
        </div>
      </div>

      {{! Suggested For You }}
      <div class="fantribe-right-sidebar__suggested">
        <h3>Suggested for you</h3>
        <p>Connect with creators who share your vibe</p>
        <button
          type="button"
          class="fantribe-right-sidebar__discover-btn"
          {{on "click" this.discoverCreators}}
        >
          Discover Creators
        </button>
      </div>
    </div>
  </template>
}
