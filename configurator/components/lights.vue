<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3 flex items-center gap-4">
      <h2>Lightables</h2>
      <button class="disabled:!bg-gray-300 disabled:!text-gray-500 disabled:!cursor-not-allowed blue" type="button" @click="addLightable('extra')" :disabled="!canAddNewLightableOfType('extra')">New extra</button>
      <button class="disabled:!bg-gray-300 disabled:!text-gray-500 disabled:!cursor-not-allowed blue" type="button" @click="addLightable('misc')" :disabled="!canAddNewLightableOfType('misc')">New misc</button>
    </header>

    <div class="p-3 overflow-x-auto">
      {{VCF.configuration.lightables.map((lightable) => lightable.id)}}
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
                <option value="extra">Extra</option>
                <option value="misc">Misc</option>
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
import {letterLightableId, Lightable, lightableType, numericalLightableId} from "~/types/lights";

const colors = ["blue", "amber", "red", "green", "white"];

const VCF = useVcfConfiguration();
const miscIds = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
const extraIds = [1,2,3,4,5,6,7,8,9,10,11,12]

const removeLightable = (index: number) => {
  return VCF.value.configuration.lightables.splice(index, 1)
}

const canAddNewLightableOfType = (type: lightableType) => {
  const ids = type === 'extra' ? extraIds : miscIds;
  return VCF.value.configuration.lightables.filter((lightable) => lightable.type === type).length < ids.length
}

const isLightableIdInUse = (id: letterLightableId|numericalLightableId) => VCF.value.configuration.lightables.map((lightable) => lightable.id).includes(id)

const getNewLightableId = (lightable: Lightable|null = null, type: lightableType|null = null) => {
  const extras = VCF.value.configuration.lightables.filter((lightable) => lightable.type === 'extra')
  const miscs = VCF.value.configuration.lightables.filter((lightable) => lightable.type === 'misc')
  const lastExtra = extras.sort((a, b) => a.id - b.id).at(-1)
  const lastMisc = miscs.sort((a, b) => a.id - b.id).at(-1)

  if (!lightable) {
    if (type === 'extra') {
      const lastExtraId = lastExtra?.id ?? 0

      if (lastExtraId < 26) {
        return lastExtraId + 1
      }
    } else if (type === 'misc') {
      const lastMiscId = lastMisc?.id ?? null
      return lastMiscId === null ? 'a' : miscIds[miscIds.findIndex((id) => id === lastMiscId) + 1]
    }
  }

  if (lightable?.type === 'extra') {

  } else if (lightable?.type === 'misc') {
    const lastMiscId = lastMisc?.id ?? null
    return lastMiscId === null ? 'a' : miscIds[miscIds.findIndex((id) => id === lastMiscId) + 1]
  }
}

const addLightable = (type: lightableType = 'extra') => {
  VCF.value.configuration.lightables.push({ type: type, id: getNewLightableId(null, type), enabled: true, allowEnv: false, color: null })
}
</script>
