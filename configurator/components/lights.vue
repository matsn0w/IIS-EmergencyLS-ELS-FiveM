<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3 flex items-center gap-4">
      <h2>Lightables</h2>
      <button class="disabled:!bg-gray-300 disabled:!text-gray-500 disabled:!cursor-not-allowed blue" type="button" @click="addLightable('extra')" :disabled="availableExtraIds.length === 0">New extra</button>
      <button class="disabled:!bg-gray-300 disabled:!text-gray-500 disabled:!cursor-not-allowed blue" type="button" @click="addLightable('misc')" :disabled="availableMiscIds.length === 0">New misc</button>
    </header>

    <div class="p-3 overflow-x-auto">
      <table class="table-auto w-full">
        <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
          <tr>
            <th>Lightable type</th>
            <th>Lightable ID</th>
            <th>Is ELS controlled</th>
            <th>Allow env light</th>
            <th>Color</th>
            <th></th>
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <tr v-for="(lightable, index) in VCF.configuration.lightables" :key="lightable.id">
            <td class="font-bold">
              <select
                  v-model="lightable.type"
                  @change="lightable.id = getNewLightableId(lightable)"
              >
                <option value="extra" :disabled="availableExtraIds.length === 0">Extra</option>
                <option value="misc" :disabled="availableMiscIds.length === 0">Misc</option>
              </select>
            </td>
            <td>
              <select v-model="lightable.id">
                <option v-if="lightable.type === 'extra'" v-for="id in extraIds" :key="'extra_' + id" :value="id" :disabled="isLightableIdInUse(id)">{{ id }}</option>
                <option v-else-if="lightable.type === 'misc'" v-for="id in miscIds" :key="'misc_' + id" :disabled="isLightableIdInUse(id)" :value="id">{{ id }}</option>
              </select>
            </td>
            <td>
              <label class="cb-label">
                <input v-model="lightable.enabled" type="checkbox" />
              </label>
            </td>
            <td>
              <label class="cb-label">
                <input v-model="lightable.allowEnv" type="checkbox" />
              </label>
            </td>
            <td class="flex items-center gap-4">
              <div class="w-8 h-8 px-2 py-1 rounded-md inline-block" :class="lightable.color" />

              <select
                :class="!lightable.allowEnv ? 'cursor-not-allowed' : ''"
                :title="
                  !lightable.allowEnv
                    ? 'You need to allow env light to change the color'
                    : ''
                "
                v-model="lightable.color"
                :disabled="!lightable.allowEnv"
              >
                <option :value="null">Choose...</option>
                <option v-for="color in colors" :key="color" :value="color">
                  {{ color }}
                </option>
              </select>
            </td>
            <td>
              <button class="red" type="button" @click="removeLightable(index)"><XMarkIcon class="w-5 h-5" /></button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import {XMarkIcon} from "@heroicons/vue/24/solid"
import {Lightable, lightableType} from "~/types/lights";

const colors = ["blue", "amber", "red", "green", "white"];

const VCF = useVcfConfiguration();

const removeLightable = (index: number) => {
  return VCF.value.configuration.lightables.splice(index, 1)
}

const getNewLightableId = (lightable: Lightable|null = null, type: lightableType|null = null) => {
    if (type === 'extra' || lightable?.type === 'extra') {
      return availableExtraIds.value[0] ?? null;
    } else if (type === 'misc' || lightable?.type === 'misc') {
      return availableMiscIds.value[0] ?? null;
    }
}

const addLightable = (type: lightableType = 'extra') => {
  VCF.value.configuration.lightables.push({ type: type, id: getNewLightableId(null, type), enabled: true, allowEnv: false, color: null })
}
</script>
