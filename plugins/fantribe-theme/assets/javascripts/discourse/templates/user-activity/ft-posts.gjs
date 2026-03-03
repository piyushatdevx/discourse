import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import FantribeFeedCard from "discourse/plugins/fantribe-theme/discourse/components/fantribe-feed-card";

const FtPostsTemplate = <template>
  <div class="ft-user-posts">
    {{#if @model.topics.length}}
      <div class="ft-user-posts__feed">
        {{#each @model.topics as |topic|}}
          <FantribeFeedCard @topic={{topic}} />
        {{/each}}
      </div>
      {{#if @model.canLoadMore}}
        <div class="ft-user-posts__load-more">
          <button
            type="button"
            class="ft-user-posts__load-more-btn"
            disabled={{@model.isLoadingMore}}
            {{on "click" @model.loadMore}}
          >
            {{if @model.isLoadingMore "Loading..." "Load more"}}
          </button>
        </div>
      {{/if}}
    {{else}}
      <div class="ft-user-posts__empty">
        {{icon "bars-staggered"}}
        <p>No posts yet.</p>
      </div>
    {{/if}}
  </div>
</template>;

export default FtPostsTemplate;
