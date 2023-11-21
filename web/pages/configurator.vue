<template>
  <div class="flex justify-between items-center my-4">
    <h1 class="text-2xl font-bold">MISS ELS VCF Configurator</h1>

    <div class="flex gap-4">
      <importButton @load="importedVCF = $event" />
      <button
        @click="toggleDarkMode"
        class="blue outlined p-3 !text-yellow-400"
      >
        <SunIcon class="w-4 h-4" v-if="darkModeState === 'dark'" />
        <MoonIcon class="w-4 h-4" v-else />
      </button>
      <LocalStorageButton
        :state="saveVcfInBrowserStorageState"
        @click="toggleSaveVcfInBrowserStorage"
      />
    </div>
  </div>

  <div class="py-4" v-if="!hasReadLocalStorageNotice">
    <div class="rounded-md bg-yellow-50 p-4">
      <div class="flex">
        <div>
          <h3 class="text-sm font-medium text-yellow-800">
            Attention! From now on, we are storing data in the browser's memory.
          </h3>
          <div class="mt-2 text-sm">
            <p class="!text-yellow-700 font-normal">
              To prevent data loss, we store your current VCF in your local
              browser data.
              <br />
              When you revisit the configurator, the last VCF file you modified
              will be loaded again.
              <br />
              Do you not want this? Or do you want to start with an empty VCF?
              Then you can disable local storage.
              <br />
              This can be done via the button below or the button at the top
              right.
              <br />
              Resetting can be done via the button below or at the very bottom
              of the page.
            </p>
          </div>
          <div class="mt-4">
            <div class="-mx-2 -my-1.5 flex gap-4">
              <LocalStorageButton
                :state="saveVcfInBrowserStorageState"
                @click="toggleSaveVcfInBrowserStorage"
                :isForNotice="true"
              />
              <button @click="onResetVcfConfiguration" class="amber p-2">
                Reset VCF
              </button>
            </div>
          </div>
        </div>
        <div class="ml-auto pl-3">
          <div class="-mx-1.5 -my-1.5">
            <button
              type="button"
              class="amber p-1.5"
              @click="dismissLocalStorageNotice"
            >
              <span class="sr-only">Dismiss</span>
              <XMarkIcon class="w-6 h-6" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <form @submit.prevent="generateVCF">
    <div>
      <div class="md:flex md:items-center mb-3">
        <label for="description">Description</label>
        <input
          id="description"
          v-model="VCF.configuration.description"
          type="text"
        />
      </div>

      <div class="md:flex md:items-center mb-3">
        <label for="author">Author</label>
        <input id="author" v-model="VCF.configuration.author" type="text" />
      </div>

      <div class="md:flex md:items-center mb-3">
        <label for="version">VCF schema version</label>
        <p>{{ VCF.configuration.version ?? "Unknown" }}</p>
      </div>

      <template v-if="!isVcfSchemaVersionUpToDate">
        <div class="border-l-4 border-yellow-400 bg-yellow-50 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg
                class="h-5 w-5 text-yellow-400"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z"
                  clip-rule="evenodd"
                />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm !text-yellow-700">
                Please be aware! The VCF you have imported was generated with an
                older version of the configurator.
                <br />
                This means that some settings may not be available in the
                configurator, or have been enabled, disabled or changed by
                default.
                <br />

                Your VCF schema version is
                <span class="font-medium">
                  {{ VCF.configuration.version ?? "Unknown" }}
                </span>
                , the latest version is
                <span class="font-medium">{{ config.public.version }}</span>
                .
              </p>
            </div>
          </div>
        </div>
      </template>
    </div>

    <lights class="card" />
    <statics class="card" />
    <sounds class="card" />
    <patterns class="card" />

    <div class="py-3 flex gap-4">
      <button class="blue py-2 px-4" type="submit">Generate VCF</button>
      <button
        class="amber py-2 px-4"
        type="button"
        @click.prevent="onResetVcfConfiguration"
      >
        Reset VCF
      </button>
    </div>
  </form>
</template>

<script setup>
import { saveAs } from "file-saver";
import formatXml from "xml-formatter";
import { SunIcon, MoonIcon, XMarkIcon } from "@heroicons/vue/24/solid";
import { resetVcfConfiguration } from "~/composables/vcfConfiguration";
import LocalStorageButton from "~/components/LocalStorageButton.vue";
import { compareVersions } from "compare-versions";

const url = useRequestURL();
const config = useRuntimeConfig();

useHead({
  title: "MISS-ELS VCF Configurator",
});

useSeoMeta({
  ogSiteName: "MISS-ELS",
  title: "MISS-ELS VCF Configurator",
  ogTitle: "MISS-ELS VCF Configurator",
  ogDescription:
    "Using our VCF Configurator, you can easily generate configuration files for your vehicles.",
  ogImage: `${url.origin + config.app.baseURL}images/MISS-ELS.png`,
});

const isVcfSchemaVersionUpToDate = computed(() => {
  return (
    compareVersions(
      VCF.value.configuration.version ?? "0.0.0",
      config.public.version
    ) >= 0
  );
});

const onResetVcfConfiguration = () => {
  const result = window.confirm(
    "Are you sure you want to reset? All changes to the VCF will be lost."
  );
  if (result) {
    resetVcfConfiguration();
  }
};

const darkModeState = ref(localStorage.getItem("theme") ?? "light");

const toggleDarkMode = () => {
  document
    .getElementsByTagName("html")[0]
    ?.classList.remove(darkModeState.value);
  darkModeState.value = darkModeState.value === "light" ? "dark" : "light";
  document.getElementsByTagName("html")[0]?.classList.add(darkModeState.value);
};

onMounted(() => {
  if (!darkModeState.value) {
    darkModeState.value = "light";
  }

  document.getElementsByTagName("html")[0]?.classList.add(darkModeState.value);
});

watch(
  () => darkModeState.value,
  (newTheme) => {
    localStorage.setItem("theme", newTheme);
  }
);

const saveVcfInBrowserStorageState = ref(
  localStorage.getItem("saveVcfLocal") ?? "1"
);

const toggleSaveVcfInBrowserStorage = () => {
  saveVcfInBrowserStorageState.value =
    saveVcfInBrowserStorageState.value === "1" ? "0" : "1";

  if (saveVcfInBrowserStorageState.value === "0") {
    localStorage.removeItem("vcfConfiguration");
    localStorage.removeItem("vcfUpdated");
  }
};

onMounted(() => {
  if (!saveVcfInBrowserStorageState.value) {
    saveVcfInBrowserStorageState.value = "1";
  }
});

watch(
  () => saveVcfInBrowserStorageState.value,
  (saveVcfInBrowserStorageStateSetting) => {
    localStorage.setItem("saveVcfLocal", saveVcfInBrowserStorageStateSetting);
  }
);

const hasReadLocalStorageNotice = ref(
  Boolean(Number(localStorage.getItem("hasReadLocalStorageNotice"))) ?? false
);

const dismissLocalStorageNotice = () => {
  const result = window.confirm(
    "Are you sure you want to dismiss this message? You will never see it again."
  );
  if (result) {
    hasReadLocalStorageNotice.value = true;
    localStorage.setItem("hasReadLocalStorageNotice", "1");
  }
};

const VCF = useVcfConfiguration();

const importedVCF = ref("");

const generateVCF = () => {
  // generate the XML
  const xml = generateVcfDocument(VCF.value.configuration);
  let xmlString = new XMLSerializer().serializeToString(xml);

  // add XML header
  xmlString = '<?xml version="1.0" encoding="utf-8" ?>' + xmlString;

  // format the XML
  const formattedXml = formatXml(xmlString, {
    whiteSpaceAtEndOfSelfclosingTag: true,
  });

  // create a blob
  const blob = new Blob([formattedXml], {
    type: "application/xml",
  });
  const filename = VCF.value.description ?? "myVCF.xml";

  // download the XML as file
  saveAs(blob, filename);
};

watch(importedVCF, (newVcf, oldVcf) => {
  if (newVcf !== oldVcf) {
    const parsedVCF = generateStoreAttributesFromExistingVCF(newVcf);
    useImportExistingConfiguration(parsedVCF);
  }
});
</script>
