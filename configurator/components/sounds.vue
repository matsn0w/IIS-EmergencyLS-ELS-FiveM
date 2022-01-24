<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3 flex items-center">
      <h2 class="mr-4">
        Sounds
      </h2>

      <div class="checkbox">
        <label for="useServerSirens">
          Use <a href="https://github.com/Walsheyy/WMServerSirens" target="_blank">WMServerSirens</a>
        </label>
        <input id="useServerSirens" v-model="useServerSirens" type="checkbox">
      </div>
    </header>

    <div class="p-3 overflow-x-auto">
      <table class="table-auto w-full">
        <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
          <tr>
            <th>Option</th>
            <th>Allow use</th>
            <th>Audio string</th>
            <th v-if="useServerSirens">
              Soundset
            </th>
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <tr v-for="option, index in sounds" :key="index">
            <td class="font-bold">
              {{ option.name }}
            </td>
            <td>
              <input v-model="option.allowUse" type="checkbox">
            </td>
            <td>
              <input v-if="option.allowUse && option['audioString'] !== undefined" v-model="option.audioString" type="text">
            </td>
            <td v-if="option.allowUse && useServerSirens">
              <input v-if="option['soundSet'] !== undefined" v-model="option.soundSet" type="text">
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mapMultiRowFields, mapFields } from 'vuex-map-fields'

export default {
  computed: {
    ...mapFields([
      'configuration.useServerSirens'
    ]),

    ...mapMultiRowFields([
      'configuration.statics',
      'configuration.sounds'
    ])
  },

  methods: {
    addStatic () {
      const highest = this.statics.at(-1)?.extra ?? 0
      this.$store.commit('addStatic', { extra: highest + 1, name: null })
    },

    removeStatic (s) {
      this.$store.commit('removeStatic', s)
    }
  }
}
</script>
