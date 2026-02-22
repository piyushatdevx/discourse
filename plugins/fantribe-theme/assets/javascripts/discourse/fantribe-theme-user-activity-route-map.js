export default {
  resource: "user.userActivity",
  map() {
    this.route("ftPosts", { path: "ft-posts" });
  },
};
