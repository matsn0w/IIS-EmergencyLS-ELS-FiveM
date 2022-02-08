<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3 flex items-center">
      <h2 class="mr-4">
        Statics
      </h2>

      <button type="button" @click="addStatic">
        New
      </button>
    </header>

    <div class="p-3 overflow-x-auto">
      <table class="table-auto w-full">
        <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
          <tr>
            <th>Extra</th>
            <th>Name</th>
            <th />
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <template v-if="statics.length">
            <tr v-for="s, index in statics" :key="index">
              <td class="font-bold flex items-center">
                <span class="mr-4 align-middle">Extra</span>
                <span>
                  <input v-model.number="s.extra" type="number" min="1" max="12">
                </span>
              </td>
              <td>
                <input v-model="s.name" type="text">
              </td>
              <td>
                <button type="button" class="bg-red-500" @click="removeStatic(s)">
                  &times;
                </button>
              </td>
            </tr>
          </template>

          <tr v-else>
            <td colspan="2"><em>You have not configured any static extras. Create one by clicking the '<strong>New</strong>' button.</em></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mapMultiRowFields } from 'vuex-map-fields'

export default {
  computed: {
    ...mapMultiRowFields(['configuration.statics'])
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
