import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class ExploreRoute extends DiscourseRoute {
  @service site;

  model() {
    return this.site.categories || [];
  }
}
