import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";

const ChatNavbarFilter = <template>
  <DButton
    @icon="magnifying-glass"
    @action={{@onToggleFilter}}
    class={{concatClass
      "btn-transparent c-navbar__filter"
      (if @isFiltering "active")
    }}
  />
</template>;

export default ChatNavbarFilter;
