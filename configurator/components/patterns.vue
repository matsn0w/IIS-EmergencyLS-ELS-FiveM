<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3">
      <h2>Patterns</h2>
    </header>

    <div v-for="(pattern, name, index) in patterns" :key="index">
      <header class="px-5 pt-3 flex items-center gap-4">
        <h3 class="font-bold">
          {{ name }}
        </h3>

        <button type="button" @click="addFlash(name)">
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
              <th>ID</th>
              <th>Duration</th>
              <th>Extras</th>
              <th />
            </tr>
          </thead>

          <tbody class="text-sm divide-y divide-gray-100">
            <tr v-for="flash, i in pattern.flashes" :key="i">
              <td>{{ flash.id }}</td>
              <td>
                <input v-model.number="flash.duration" type="number" min="0">
              </td>
              <td>
                <span v-for="extra, j in enabledExtras" :key="j" class="extra" :class="isExtraToggled(name, flash, extra) ? getExtraColor(extra) : ''" @click="toggleExtra(name, flash, extra)">
                  {{ extra.id }}
                </span>
              </td>
              <td>
                <button type="button" class="bg-red-500" @click="removeFlash(name, flash)">
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
import { mapFields } from 'vuex-map-fields'

export default {
  computed: {
    ...mapFields(['configuration.patterns']),

    enabledExtras () {
      return this.$store.state.configuration.extras.filter(extra => extra.enabled)
    }
  },

  methods: {
    addFlash (pattern) {
      this.$store.commit('addFlash', { pattern, flash: { duration: 100, extras: [] } })
    },

    removeFlash (pattern, flash) {
      this.$store.commit('removeFlash', { pattern, flash })
    },

    toggleExtra (pattern, flash, extra) {
      this.$store.commit('toggleExtra', { pattern, flash: flash.id, extra: extra.id })
    },

    isExtraToggled (pattern, flash, extra) {
      const p = this.patterns[pattern]
      const index = p.flashes.map(f => f.id).indexOf(flash.id)
      const extras = p.flashes[index].extras

      return extras.includes(extra.id)
    },

    getExtraColor (extra) {
      return extra.color || 'nocolor'
    }
  }
}
</script>

<style scoped>
.extra {
  @apply bg-gray-200 p-2 border-2 border-gray-200 rounded mr-3 select-none;
}
</style>
