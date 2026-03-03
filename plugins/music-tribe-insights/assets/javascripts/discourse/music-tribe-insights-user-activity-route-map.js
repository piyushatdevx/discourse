export default {
  resource: "user.userActivity",
  map() {
    this.route("communityInsights", { path: "community-insights" });
  },
};
