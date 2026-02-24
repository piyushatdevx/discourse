import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";

// Notification level values from Discourse's CategoryUser model:
//   muted: 0 | regular: 1 | tracking: 2 | watching: 3 | watching_first_post: 4
const WATCHING_LEVEL = 3;
const REGULAR_LEVEL = 1;

export default class FantribeMembershipService extends Service {
  @service site;
  @service currentUser;

  // Tracked plain object so Glimmer re-renders components when levels change.
  // A new object reference is assigned on every setLevel() call.
  @tracked _levels = {};

  _initialized = false;

  // Called once (guarded) from the left sidebar and explore page didInsert hooks.
  // Reads the notification_level already bulk-preloaded by Discourse on site.categories.
  initialize() {
    if (this._initialized || !this.currentUser) {
      return;
    }

    const levels = {};
    for (const cat of this.site.categories || []) {
      if (cat.notification_level != null) {
        levels[cat.id] = cat.notification_level;
      }
    }
    this._levels = levels;
    this._initialized = true;
  }

  // Returns the current notification level for a category (defaults to regular).
  levelFor(categoryId) {
    return this._levels[categoryId] ?? REGULAR_LEVEL;
  }

  // A user is considered a "member" of a tribe at watching level or above.
  isMember(categoryId) {
    return this.levelFor(categoryId) >= WATCHING_LEVEL;
  }

  // Optimistically update a category's level (called before/after API response).
  setLevel(categoryId, level) {
    this._levels = { ...this._levels, [categoryId]: level };
  }

  get watchingLevel() {
    return WATCHING_LEVEL;
  }

  get regularLevel() {
    return REGULAR_LEVEL;
  }
}
