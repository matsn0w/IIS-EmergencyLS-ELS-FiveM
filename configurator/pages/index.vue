<template>
  <div class="container mx-auto">
    <div class="grid grid-rows-1 grid-flow-col grid-cols-1 my-4">
      <h1 class="text-2xl font-bold">
        MISS ELS VCF Configurator
      </h1>
      <div class="float-right pr-3">
        <importButton @load="importedVCF = $event" />
      </div>
    </div>
    <form @submit.prevent="generateVCF">
      <div>
        <div class="md:flex md:items-center mb-3">
          <label for="description">Description</label>
          <input id="description" v-model="description" type="text">
        </div>

        <div class="md:flex md:items-center mb-3">
          <label for="author">Author</label>
          <input id="author" v-model="author" type="text">
        </div>
      </div>

      <extras class="card" />
      <statics class="card" />
      <sounds class="card" />
      <patterns class="card" />

      <div class="py-3">
        <button type="submit">
          Generate VCF
        </button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapFields } from 'vuex-map-fields'
import { saveAs } from 'file-saver'
import formatXml from 'xml-formatter'
import Extras from '~/components/extras'
import Patterns from '~/components/patterns'
import Sounds from '~/components/sounds'
import Statics from '~/components/statics'
import ImportButton from '~/components/importButton'
import XMLGenerator from '~/helpers/xmlGenerator'
import generateStoreAttributesFromExistingVCF from '~/helpers/transformImportedVCF'

export default {
  components: { Extras, Statics, Sounds, Patterns, ImportButton },

  data: () => ({ importedVCF: '' }),
  computed: {
    ...mapFields([
      'configuration.author',
      'configuration.description'
    ])
  },
  watch: {
    importedVCF (newVCF, oldVCF) {
      if (newVCF !== oldVCF) {
        const parsedVCF = generateStoreAttributesFromExistingVCF(newVCF)

        this.$store.commit('importExistingConfiguration', parsedVCF)
      }
    }
  },
  methods: {
    generateVCF () {
      // generate the XML
      const xml = XMLGenerator.generateVCF(this.$store.state.configuration)
      let xmlString = new XMLSerializer().serializeToString(xml)

      // add XML header
      xmlString = '<?xml version="1.0" encoding="utf-8" ?>' + xmlString

      // format the XML
      const formattedXml = formatXml(xmlString, {
        whiteSpaceAtEndOfSelfclosingTag: true
      })

      // create a blob
      const blob = new Blob([formattedXml], {
        type: 'application/xml'
      })
      const filename = this.$store.state.configuration.description ?? 'myVCF.xml'

      // download the XML as file
      saveAs(blob, filename)
    }
  }
}
</script>
