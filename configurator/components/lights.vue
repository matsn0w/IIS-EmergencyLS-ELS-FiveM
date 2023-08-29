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
          <tr v-for="extra in VCF.configuration.extras" :key="extra.id">
            <td class="font-bold">Extra {{ extra.id }}</td>
            <td>
              <label class="cb-label">
                <input v-model="extra.enabled" type="checkbox" />
              </label>
            </td>
            <td>
              <label class="cb-label">
                <input v-model="extra.allowEnv" type="checkbox" />
              </label>
            </td>
            <td class="flex items-center gap-4">
              <div class="color-block" :class="extra.color" />

              <select
                :class="!extra.allowEnv ? 'cursor-not-allowed' : ''"
                :title="
                  !extra.allowEnv
                    ? 'You need to allow env light to change the color'
                    : ''
                "
                v-model="extra.color"
                :disabled="!extra.allowEnv"
              >
                <option :value="null">Choose...</option>
                <option v-for="color in colors" :key="color" :value="color">
                  {{ color }}
                </option>
              </select>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <header class="px-5 pt-3">
      <h2>Miscs</h2>
    </header>

    <div class="p-3 overflow-x-auto">
      <table class="table-auto w-full">
        <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
          <tr>
            <th>Misc</th>
            <th>Is ELS controlled</th>
            <th>Allow env light</th>
            <th>Color</th>
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <tr v-for="misc in VCF.configuration.miscs" :key="misc.id">
            <td class="font-bold">Misc {{ misc.id }}</td>
            <td>
              <label class="cb-label">
                <input v-model="misc.enabled" type="checkbox" />
              </label>
            </td>
            <td>
              <label class="cb-label">
                <input v-model="misc.allowEnv" type="checkbox" />
              </label>
            </td>
            <td class="flex items-center gap-4">
              <div class="color-block" :class="misc.color" />

              <select
                :class="!misc.allowEnv ? 'cursor-not-allowed' : ''"
                :title="
                  !misc.allowEnv
                    ? 'You need to allow env light to change the color'
                    : ''
                "
                v-model="misc.color"
                :disabled="!misc.allowEnv"
              >
                <option :value="null">Choose...</option>
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

<script setup>
const colors = ["blue", "amber", "red", "green", "white"];

const VCF = useVcfConfiguration();
</script>

<style scoped>
.color-block {
  display: inline-block;
  width: 20px;
  height: 20px;
}
</style>
