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
      <button
          @click="toggleSaveVcfInBrowserStorage"
          class="blue outlined p-3"
      >
        <InboxArrowDownIcon class="w-4 h-4" v-if="saveVcfInBrowserStorageState === '1'" />
        <template v-else>
          <div class="relative">
            <InboxIcon
                class="w-4 h-4"
            />
            <XMarkIcon
                class="w-4 h-4 absolute top-0 left-0 !text-white"
            />
          </div>
        </template>
      </button>
    </div>
  </div>

  <div class="py-4" v-if="!hasReadLocalStorageNotice">
    <div class="rounded-md bg-blue-200 p-4">
      <div class="flex">
        <div>
          <h3 class="text-sm font-medium text-blue-800">Attention! From now on, we are storing data in the browser's memory.</h3>
          <div class="mt-2 text-sm text-blue-700">
            <p>
              To prevent data loss, we store your current VCF in your local browser data.<br />
              When you revisit the configurator, the last VCF file you modified will be loaded again.<br />
              Do you not want this? Or do you want to start with an empty VCF? Then you can disable local storage.<br />
              This can be done via the button below or the button at the top right.<br />
              Resetting can be done via the button below or at the very bottom of the page.
            </p>
          </div>
          <div class="mt-4">
            <div class="-mx-2 -my-1.5 flex gap-4">
              <button
                  @click="toggleSaveVcfInBrowserStorage"
                  class="blue p-3 flex items-center !text-white"
              >
                <InboxArrowDownIcon class="w-4 h-4" v-if="saveVcfInBrowserStorageState === '1'" />
                <template v-else>
                  <div class="relative">
                    <InboxIcon
                        class="w-4 h-4"
                    />
                    <XMarkIcon
                        class="w-4 h-4 absolute top-0 left-0"
                    />
                  </div>
                </template>
                <span class="ml-2">{{saveVcfInBrowserStorageState ==='1' ? 'Disable' : 'Enable'}} local VCF storage</span>
              </button>
              <button
                  @click="onResetVcfConfiguration"
                  class="amber py-2 px-4"
              >
                Reset VCF
              </button>
            </div>
        </div>
      </div>
        <div class="ml-auto pl-3">
          <div class="-mx-1.5 -my-1.5">
            <button
                type="button"
                class="blue outlined p-1.5"
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
    </div>

    <lights class="card" />
    <statics class="card" />
    <sounds class="card" />
    <patterns class="card" />

    <div class="py-3 flex gap-4">
      <button class="blue py-2 px-4" type="submit">Generate VCF</button>
      <button class="amber py-2 px-4" type="button" @click.prevent="onResetVcfConfiguration">Reset VCF</button>
    </div>
  </form>
</template>

<script setup>
import { saveAs } from "file-saver";
import formatXml from "xml-formatter";
import {
  SunIcon,
  MoonIcon,
  InboxArrowDownIcon,
  InboxIcon,
  XMarkIcon,
} from "@heroicons/vue/24/solid";
import {resetVcfConfiguration} from "~/composables/vcfConfiguration";

const onResetVcfConfiguration = () => {
  const result = window.confirm('Are you sure you want to reset? All changes to the VCF will be lost.');
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

const saveVcfInBrowserStorageState = ref(localStorage.getItem("saveVcfLocal") ?? "1");

const toggleSaveVcfInBrowserStorage = () => {
  saveVcfInBrowserStorageState.value = saveVcfInBrowserStorageState.value === "1" ? "0" : "1";

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
      localStorage.setItem("saveVcfLocal", saveVcfInBrowserStorageStateSetting)
    }
);

const hasReadLocalStorageNotice = ref(Boolean(Number(localStorage.getItem("hasReadLocalStorageNotice"))) ?? false);

const dismissLocalStorageNotice = () => {
  const result = window.confirm('Are you sure you want to dismiss this message? You will never see it again.');
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
