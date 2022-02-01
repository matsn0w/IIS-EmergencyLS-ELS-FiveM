<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3">
      <h2>Extras</h2>
    </header>

    <div class="p-3 overflow-x-auto">
      <table class="table-auto w-full">
        <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
          <tr>
            <th>Extra</th>
            <th>Is ELS controlled</th>
            <th>Allow env light</th>
            <th>Color</th>
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <tr v-for="extra in extras" :key="extra.id">
            <td class="font-bold">
              Extra {{ extra.id }}
            </td>
            <td>
              <input v-model="extra.enabled" type="checkbox">
            </td>
            <td>
              <input v-model="extra.allowEnv" type="checkbox">
            </td>
            <td class="flex items-center gap-4">
              <div class="color-block" :class="extra.color" />
              <select v-model="extra.color" :disabled="!extra.allowEnv">
                <option :value="null">
                  Choose...
                </option>
                <option v-for="color in colors" :key="color" :value="color">
                  {{ color }}
                </option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import { mapMultiRowFields } from 'vuex-map-fields'

export default {
  data: () => ({
    colors: ['blue', 'amber', 'red', 'green', 'white']
  }),

  computed: {
    ...mapMultiRowFields(['configuration.extras'])
  }
}
</script>

<style scoped>
.color-block {
  display: inline-block;
  width: 20px;
  height: 20px;
}
</style>
