<template>
  <div class="background h-full w-full">
    <div
      class="buttons h-full flex flex-col lg:flex-row justify-center items-center gap-4 font-semibold text-white"
    >
      <button
        class="bg-blue-900 border border-gray-100 text-3xl rounded-lg shadow-lg flex items-center gap-3 p-4"
        type="button"
        @click="directDownload"
      >
        Download v{{ version }}
        <Icon name="uil:download-alt" />
      </button>

      <button
        class="bg-gray-800 border border-gray-100 text-3xl rounded-lg shadow-lg flex items-center gap-3 p-4"
        type="button"
        @click="viewRelease"
      >
        View latest release
        <Icon name="uil:external-link-alt" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const url = useRequestURL();
const config = useRuntimeConfig();

useSeoMeta({
  ogSiteName: "MISS-ELS",
  title: "MISS-ELS - server sided sirens for FiveM",
  ogTitle: "MISS-ELS - server sided sirens for FiveM",
  ogDescription:
    "Server-sided ELS for FiveM with custom patterns per vehicle, custom sirens, indicator control and more!",
  ogImage: `${url.origin + config.app.baseURL}images/MISS-ELS.png`,
});

definePageMeta({
  layout: "fullscreen",
});

import { version } from "../../resource/version.json";

const directDownload = async () => {
  await navigateTo(
    `https://github.com/matsn0w/MISS-ELS/releases/latest/download/MISS-ELS_v${version}.zip`,
    {
      external: true,
    }
  );
};

const viewRelease = async () => {
  await navigateTo("https://github.com/matsn0w/MISS-ELS/releases/latest", {
    external: true,
    open: {
      target: "_blank",
    },
  });
};
</script>

<style>
.background {
  background-image: url("/images/MISS-ELS.png");
  background-size: cover;
  background-position: center;
}

.buttons {
  backdrop-filter: blur(8px);
}
</style>
