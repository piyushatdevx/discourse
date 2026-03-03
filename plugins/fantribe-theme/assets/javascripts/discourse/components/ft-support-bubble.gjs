import getURL from "discourse/lib/get-url";
import ftIcon from "../helpers/ft-icon";

<template>
  <a
    href="https://support.empowertribe.com"
    target="_blank"
    rel="noopener noreferrer"
    class="ft-support-bubble"
    aria-label="Support"
    title="Support"
  >
    {{! Default state: question mark icon }}
    <span class="ft-support-bubble__icon" aria-hidden="true">
      {{ftIcon "question" size=26}}
    </span>

    {{! Hover state: animated GIF }}
    <img
      class="ft-support-bubble__gif"
      src={{getURL "/plugins/fantribe-theme/images/uli-greetings.gif"}}
      alt=""
      aria-hidden="true"
    />
  </a>
</template>
