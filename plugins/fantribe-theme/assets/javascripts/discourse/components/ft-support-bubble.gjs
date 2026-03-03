import getURL from "discourse/lib/get-url";

<template>
  <a
    href="https://support.empowertribe.com"
    target="_blank"
    rel="noopener noreferrer"
    class="ft-support-bubble"
    aria-label="Support"
    title="Support"
  >
    <img
      class="ft-support-bubble__gif"
      src={{getURL "/plugins/fantribe-theme/images/uli-greetings.gif"}}
      alt="Support"
    />
  </a>
</template>
