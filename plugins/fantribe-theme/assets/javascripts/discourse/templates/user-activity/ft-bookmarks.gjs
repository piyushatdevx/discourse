import icon from "discourse/helpers/d-icon";
import FantribeFeedCard from "discourse/plugins/fantribe-theme/discourse/components/fantribe-feed-card";

const FtBookmarksTemplate = <template>
  <div class="ft-user-posts">
    {{#if @model.length}}
      <div class="ft-user-posts__feed">
        {{#each @model as |topic|}}
          <FantribeFeedCard @topic={{topic}} />
        {{/each}}
      </div>
    {{else}}
      <div class="ft-user-posts__empty">
        {{icon "bookmark"}}
        <p>No bookmarks yet. Save posts to find them here.</p>
      </div>
    {{/if}}
  </div>
</template>;

export default FtBookmarksTemplate;
