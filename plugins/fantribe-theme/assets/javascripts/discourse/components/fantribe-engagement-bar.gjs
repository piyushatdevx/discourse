import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ShareTopicModal from "discourse/components/modal/share-topic";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { extractError, popupAjaxError } from "discourse/lib/ajax-error";
import Composer from "discourse/models/composer";

// Keys must match discourse_reactions_enabled_reactions site setting values.
// Configure: discourse_reactions_enabled_reactions = "heart|fire|clap|musical_note"
//            discourse_reactions_reaction_for_like  = "heart"
const REACTIONS = [
  { emoji: "❤️", key: "heart" },
  { emoji: "🔥", key: "fire" },
  { emoji: "👏", key: "clap" },
  { emoji: "🎵", key: "musical_note" },
];

export default class FantribeEngagementBar extends Component {
  @service currentUser;
  @service composer;
  @service modal;

  @tracked isLoading = false;
  // null = use server state; array = user has interacted (optimistic update)
  @tracked _localReactions = null;
  @tracked _isBookmarked = false;

  get serverReactions() {
    return this.args.topic?.reactions || [];
  }

  get reactions() {
    return REACTIONS.map((r) => {
      const server = this.serverReactions.find((sr) => sr.id === r.key);
      let count, isActive;

      if (this._localReactions !== null) {
        const local = this._localReactions.find((lr) => lr.id === r.key);
        count = local ? local.count : (server?.count ?? 0);
        isActive = local
          ? local.current_user_used
          : (server?.current_user_used ?? false);
      } else {
        count = server?.count ?? 0;
        isActive = server?.current_user_used ?? false;
      }

      // Convert key to CSS-safe class fragment (musical_note → musical-note)
      const cssKey = r.key.replace(/_/g, "-");

      return {
        ...r,
        count,
        isActive,
        activeClass: isActive
          ? `fantribe-engagement__reaction--${cssKey}-active`
          : "",
      };
    });
  }

  get commentCount() {
    return this.args.commentCount || 0;
  }

  get canReact() {
    return !!(this.currentUser && this.args.firstPostId);
  }

  get isBookmarked() {
    return this._isBookmarked || this.args.topic?.bookmarked || false;
  }

  @action
  async toggleReaction(key, event) {
    event?.stopPropagation();

    if (!this.canReact || this.isLoading) {
      return;
    }

    const currentReactions = this.reactions;
    const clickedReaction = currentReactions.find((r) => r.key === key);
    const wasActive = clickedReaction?.isActive ?? false;
    // The reaction the user is switching away from (if any)
    const previouslyActive = currentReactions.find(
      (r) => r.isActive && r.key !== key
    );

    // Optimistic update — reflect change immediately in the UI
    this._localReactions = REACTIONS.map((r) => {
      const server = this.serverReactions.find((sr) => sr.id === r.key);
      const baseCount = server?.count ?? 0;
      const baseActive = server?.current_user_used ?? false;

      if (r.key === key) {
        return {
          id: r.key,
          count: wasActive ? Math.max(0, baseCount - 1) : baseCount + 1,
          current_user_used: !wasActive,
        };
      }

      if (!wasActive && previouslyActive && r.key === previouslyActive.key) {
        // Switching from another reaction — remove it optimistically
        return {
          id: r.key,
          count: Math.max(0, baseCount - 1),
          current_user_used: false,
        };
      }

      return { id: r.key, count: baseCount, current_user_used: baseActive };
    });

    this.isLoading = true;
    try {
      await ajax(
        `/discourse-reactions/posts/${this.args.firstPostId}/custom-reactions/${key}/toggle`,
        { type: "PUT" }
      );
    } catch (error) {
      // Always revert the optimistic update
      this._localReactions = null;
      // Rate-limit errors are expected behaviour — silently revert rather than
      // showing a disruptive dialog. All other errors surface normally.
      const message = extractError(error) || "";
      const isRateLimit =
        error?.jqXHR?.status === 429 ||
        message.toLowerCase().includes("too many") ||
        message.toLowerCase().includes("wait");
      if (!isRateLimit) {
        popupAjaxError(error);
      }
    } finally {
      this.isLoading = false;
    }
  }

  @action
  handleComment(event) {
    event.stopPropagation();

    const topic = this.args.topic;
    if (!topic) {
      return;
    }

    this.composer.open({
      action: Composer.REPLY,
      draftKey: topic.draft_key || `topic_${topic.id}`,
      draftSequence: topic.draft_sequence ?? 0,
      topic,
    });
  }

  @action
  handleShare(event) {
    event.stopPropagation();

    const topic = this.args.topic;
    if (!topic) {
      return;
    }

    this.modal.show(ShareTopicModal, {
      model: { topic, category: topic.category },
    });
  }

  @action
  handleBookmark(event) {
    event.stopPropagation();
    this._isBookmarked = !this.isBookmarked;
  }

  <template>
    <div class="fantribe-engagement">
      {{! Reaction row — one active reaction per user at a time }}
      <div class="fantribe-engagement__reactions">
        {{#each this.reactions as |reaction|}}
          <button
            type="button"
            class="fantribe-engagement__reaction {{reaction.activeClass}}"
            disabled={{this.isLoading}}
            {{on "click" (fn this.toggleReaction reaction.key)}}
          >
            <span
              class="fantribe-engagement__reaction-emoji"
            >{{reaction.emoji}}</span>
            {{#if reaction.count}}
              <span
                class="fantribe-engagement__reaction-count"
              >{{reaction.count}}</span>
            {{/if}}
          </button>
        {{/each}}
      </div>

      {{! Action bar — comment, share, save }}
      <div class="fantribe-engagement__actions">
        <button
          type="button"
          class="fantribe-engagement__action fantribe-engagement__action--comment"
          {{on "click" this.handleComment}}
        >
          {{icon "comment"}}
          {{#if this.commentCount}}
            <span>{{this.commentCount}}</span>
          {{/if}}
        </button>

        <button
          type="button"
          class="fantribe-engagement__action fantribe-engagement__action--share"
          {{on "click" this.handleShare}}
        >
          {{icon "share-nodes"}}
          <span>Share</span>
        </button>

        <button
          type="button"
          class="fantribe-engagement__action fantribe-engagement__action--bookmark
            {{if this.isBookmarked 'fantribe-engagement__action--active'}}"
          {{on "click" this.handleBookmark}}
        >
          {{#if this.isBookmarked}}
            {{icon "bookmark"}}
          {{else}}
            {{icon "far-bookmark"}}
          {{/if}}
          <span>Save</span>
        </button>
      </div>
    </div>
  </template>
}
