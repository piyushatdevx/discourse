export default {
  resource: "admin.dashboard",
  path: "/dashboard",
  map() {
    this.route("admin.dashboardCommunityInsights", {
      path: "/dashboard/community_insights",
      resetNamespace: true,
    });
  },
};
