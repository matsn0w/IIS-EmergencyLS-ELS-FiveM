<template>
  <div class="flex justify-between items-center my-4">
    <h1 class="text-2xl font-bold">MISS ELS VCF Configurator</h1>

    <div class="float-right pr-3">
      <importButton @load="importedVCF = $event" />
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

    <extras class="card" />
    <statics class="card" />
    <sounds class="card" />
    <patterns class="card" />

    <div class="py-3">
      <button class="blue" type="submit">Generate VCF</button>
    </div>
  </form>
</template>

<script setup>
import { saveAs } from "file-saver";
import formatXml from "xml-formatter";

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
