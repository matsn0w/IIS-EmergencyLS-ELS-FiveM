<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3">
      <h2>Patterns</h2>
    </header>

    <div v-for="(pattern, index) in patterns" :key="index">
      <header class="px-5 pt-3 flex items-center gap-4">
        <h3 class="font-bold">
          {{ pattern.name }}
        </h3>

        <button type="button" @click="addFlash(pattern)">
          Add flash
        </button>

        <div class="checkbox">
          <label :for="`isEmergency[${index}]`">Is emergency</label>
          <input :id="`isEmergency[${index}]`" v-model="pattern.isEmergency" type="checkbox">
        </div>
      </header>

      <div class="p-3 overflow-x-auto">
        <table class="table-auto w-full">
          <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
            <tr>
              <th>Duration</th>
              <th>Extras</th>
              <th />
            </tr>
          </thead>

          <tbody class="text-sm divide-y divide-gray-100">
            <tr v-for="flash, i in getFlashesForPattern(pattern)" :key="i">
              <td>
                <input v-model.number="flash.duration" type="number" min="0">
              </td>
              <td>
                <span
                  v-for="extra, j in enabledExtras"
                  :key="j"
                  class="extra"
                  :class="isExtraToggled(pattern, flash, extra) ? getExtraColor(extra) : ''"
                  @click="toggleExtra(pattern, flash, extra)"
                >{{ extra.id }}</span>
              </td>
              <td>
                <button type="button" class="bg-red-500" @click="removeFlash(pattern, flash)">
                  &times;
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { mapMultiRowFields } from 'vuex-map-fields'

export default {
  computed: {
    ...mapMultiRowFields([
      'configuration.patterns',
      'configuration.flashes'
    ]),

    enabledExtras () {
      return this.$store.state.configuration.extras.filter(extra => extra.enabled)
    }
  },

  methods: {
    addFlash (pattern) {
      this.$store.commit('addFlash', { pattern })
    },

    removeFlash (pattern, flash) {
      this.$store.commit('removeFlash', { pattern, flash })
    },

    toggleExtra (pattern, flash, extra) {
      this.$store.commit('toggleExtra', { pattern, flash, extra })
    },

    isExtraToggled (pattern, flash, extra) {
      const flashIndex = this.flashes.map(f => f.id).indexOf(flash.id)
      const extras = this.flashes[flashIndex].extras

      return extras.includes(extra.id)
    },

    getExtraColor (extra) {
      return extra.color || 'nocolor'
    },

    getFlashesForPattern (pattern) {
      return this.flashes.filter(flash => flash.pattern === pattern.name)
    }
  }
}
</script>

<style scoped>
.extra {
  @apply bg-gray-200 px-3 py-2 border-2 border-gray-300 rounded mr-3 select-none text-center text-gray-500;
}
</style>
