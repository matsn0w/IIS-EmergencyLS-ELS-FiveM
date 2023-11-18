<template>
  <button class="blue outlined px-4" type="button" @click="vcf.click()">
    Import Existing VCF
  </button>

  <input ref="vcf" class="hidden" type="file" @change="loadVCF" />
</template>

<script setup>
const vcf = ref(null);

const emit = defineEmits(["load"]);

const loadVCF = (ev) => {
  const file = ev.target.files[0];
  const reader = new FileReader();

  reader.onload = (e) => emit("load", e.target.result);
  reader.readAsText(file);
};
</script>
