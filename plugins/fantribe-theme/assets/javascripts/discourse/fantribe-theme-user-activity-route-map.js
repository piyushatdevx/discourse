export default {
  resource: "user.userActivity",
  map() {
    this.route("ftPosts", { path: "ft-posts" });
    this.route("ftGearCollection", { path: "gear-collection" });
    this.route("ftCoCreations", { path: "co-creations" });
    this.route("ftShop", { path: "shop" });
    this.route("ftBookmarks", { path: "ft-bookmarks" });
    this.route("ftSettings", { path: "ft-settings" });
  },
};
