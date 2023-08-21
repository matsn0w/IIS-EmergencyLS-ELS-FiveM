<template>
  <label class="import-button">
    Import Existing VCF
    <input type="file" @change="loadVCF" />
  </label>
</template>

<script setup>
const emit = defineEmits(["load"]);

const loadVCF = (ev) => {
  const file = ev.target.files[0];
  const reader = new FileReader();

  reader.onload = (e) => emit("load", e.target.result);
  reader.readAsText(file);
};
</script>
