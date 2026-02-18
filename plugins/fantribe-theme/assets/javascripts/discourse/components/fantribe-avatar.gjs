import Component from "@glimmer/component";

export default class FantribeAvatar extends Component {
  get sizeClass() {
    const size = this.args.size || "md";
    const sizeMap = {
      sm: "fantribe-avatar--sm",
      md: "fantribe-avatar--md",
      lg: "fantribe-avatar--lg",
      xl: "fantribe-avatar--xl",
    };
    return sizeMap[size];
  }

  get verificationClass() {
    const verification = this.args.verification;
    if (!verification) {
      return "";
    }
    const verificationMap = {
      bronze: "fantribe-avatar--bronze",
      silver: "fantribe-avatar--silver",
      gold: "fantribe-avatar--gold",
      blue: "fantribe-avatar--blue",
    };
    return verificationMap[verification];
  }

  get initials() {
    const name = this.args.name || "User";
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  }

  <template>
    <div class="fantribe-avatar {{this.sizeClass}} {{this.verificationClass}}">
      {{#if @src}}
        <img
          src={{@src}}
          alt={{if @alt @alt "User avatar"}}
          class="fantribe-avatar__image"
        />
      {{else}}
        <span class="fantribe-avatar__initials">{{this.initials}}</span>
      {{/if}}
    </div>
  </template>
}
