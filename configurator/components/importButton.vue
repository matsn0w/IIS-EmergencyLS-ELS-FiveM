<template>
  <label class="import-button">
    Import Existing VCF
    <input type="file" @change="loadVCF">
  </label>
</template>

<script>
export default {
  name: 'ImportButton',
  methods: {
    loadVCF (ev) {
      const file = ev.target.files[0]
      const reader = new FileReader()

      reader.onload = e => this.$emit('load', e.target.result)
      reader.readAsText(file)
    }
  }
}
</script>
