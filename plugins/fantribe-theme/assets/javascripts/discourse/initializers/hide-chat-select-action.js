import { removeChatComposerSecondaryActions } from "discourse/plugins/chat/discourse/lib/chat-message-interactor";

export default {
  name: "hide-chat-select-action",

  initialize() {
    removeChatComposerSecondaryActions(["select"]);
  },
};
