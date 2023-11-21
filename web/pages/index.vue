<template>
  <div class="background h-full w-full">
    <div
      class="buttons h-full flex flex-col gap-8 items-center justify-center font-semibold text-white"
      v-if="!loading"
    >
      <div class="flex flex-col lg:flex-row justify-center items-center gap-4">
        <button
          class="bg-blue-900 border border-gray-100 text-3xl rounded-lg shadow-lg flex items-center gap-3 p-4"
          type="button"
          @click="directDownload"
        >
          Download v{{ latestRelease.tag_name }}
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

      <div class="bg-gray-800 p-2 rounded shadow-md">
        <p class="text-white font-semibold select-none">
          Total downloads: {{ totalDownloadCount }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const url = useRequestURL();
const config = useRuntimeConfig();
const { $octokit } = useNuxtApp();

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

const directDownload = async () => {
  await navigateTo(latestRelease.value.assets[0]?.browser_download_url, {
    external: true,
  });
};

const viewRelease = async () => {
  await navigateTo("https://github.com/matsn0w/MISS-ELS/releases/latest", {
    external: true,
    open: {
      target: "_blank",
    },
  });
};

const loading = ref(true);
const totalDownloadCount = ref(0);
const latestRelease = ref();

onMounted(async () => {
  const releasesRequest = await $octokit.request(
    "GET /repos/{owner}/{repo}/releases",
    {
      owner: "matsn0w",
      repo: "MISS-ELS",
      headers: {
        "X-GitHub-Api-Version": "2022-11-28",
      },
    }
  );

  releasesRequest.data.forEach((release) =>
    release.assets.forEach(
      (asset) => (totalDownloadCount.value += asset.download_count)
    )
  );

  const latestReleaseRequest = await $octokit.request(
    "GET /repos/{owner}/{repo}/releases/latest",
    {
      owner: "matsn0w",
      repo: "MISS-ELS",
      headers: {
        "X-GitHub-Api-Version": "2022-11-28",
      },
    }
  );

  latestRelease.value = latestReleaseRequest.data;
  loading.value = false;
});
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
