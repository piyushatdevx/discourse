import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { eq, gt } from "discourse/truth-helpers";

export default class FantribeReactionBar extends Component {
  @tracked
  reactions = this.args.reactions || [
    { emoji: "❤️", label: "Love", count: 124 },
    { emoji: "🔥", label: "Fire", count: 89 },
    { emoji: "👏", label: "Clap", count: 45 },
    { emoji: "🎵", label: "Vibe", count: 67 },
  ];

  @tracked userReaction = null;

  @action
  handleReaction(emoji) {
    this.reactions = this.reactions.map((r) => {
      if (r.emoji === emoji) {
        // If user already reacted with this emoji, unreact
        if (this.userReaction === emoji) {
          this.userReaction = null;
          return { ...r, count: r.count - 1 };
        }
        // If user is switching reactions
        if (this.userReaction !== null) {
          this.userReaction = emoji;
          return { ...r, count: r.count + 1 };
        }
        // New reaction
        this.userReaction = emoji;
        return { ...r, count: r.count + 1 };
      }
      // Handle removing old reaction when switching
      if (this.userReaction === r.emoji && emoji !== r.emoji) {
        return { ...r, count: r.count - 1 };
      }
      return r;
    });
  }

  <template>
    <div class="fantribe-reaction-bar">
      {{#each this.reactions as |reaction|}}
        <button
          type="button"
          class="fantribe-reaction-bar__button
            {{if
              (eq this.userReaction reaction.emoji)
              'fantribe-reaction-bar__button--active'
            }}"
          title={{reaction.label}}
          {{on "click" (fn this.handleReaction reaction.emoji)}}
        >
          <span
            class="fantribe-reaction-bar__emoji
              {{if
                (eq this.userReaction reaction.emoji)
                'fantribe-reaction-bar__emoji--active'
              }}"
          >
            {{reaction.emoji}}
          </span>
          {{#if (gt reaction.count 0)}}
            <span class="fantribe-reaction-bar__count">{{reaction.count}}</span>
          {{/if}}
        </button>
      {{/each}}
    </div>
  </template>
}
