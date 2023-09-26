<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3 flex items-center">
      <h2 class="mr-4">Statics</h2>

      <button class="blue" type="button" @click="addStatic">New</button>
    </header>

    <div class="p-3 overflow-x-auto">
      <table class="table-auto w-full">
        <thead class="text-xs font-semibold uppercase text-gray-400 bg-gray-50">
          <tr>
            <th>Lightable type</th>
            <th>Lightable id</th>
            <th>Name</th>
            <th />
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <template v-if="VCF.configuration.statics.length">
            <tr v-for="(s, index) in VCF.configuration.statics" :key="index">
              <td>
                <select
                    v-model.number="s.type"
                >
                  <option value="extra" :disabled="availableStaticExtraIds.length === 0">Extra</option>
                  <option value="misc" :disabled="availableStaticMiscIds.length === 0">Misc</option>
                </select>
              </td>
              <td>
                <select
                    v-model.number="s.id"
                >
                  <option v-for="extraId in elsEnabledExtraIds" :value="extraId" v-if="s.type === 'extra'" :key="`extra_${extraId}`" :disabled="isLightableIdInUseByStatic(extraId)">{{extraId}}</option>
                  <option v-for="miscId in elsEnabledMiscIds" :value="miscId" :key="`misc_${miscId}`" v-else :disabled="isLightableIdInUseByStatic(miscId)">{{miscId}}</option>
                </select>
              </td>
              <td>
                <input v-model="s.name" type="text" />
              </td>
              <td>
                <button type="button" class="red" @click="removeStatic(s)">
                  &times;
                </button>
              </td>
            </tr>
          </template>

          <tr v-else>
            <td colspan="2">
              <em
                >You have not configured any static extras. Create one by
                clicking the '<strong>New</strong>' button.</em
              >
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import {letterLightableId, numericalLightableId} from "~/types/lights";
import {staticType} from "~/types/static";

const VCF = useVcfConfiguration();
const isLightableIdInUseByStatic = (id: letterLightableId|numericalLightableId) => useVcfConfiguration().value.configuration.statics.map((staticElement: staticType) => staticElement.id).includes(id)

const elsEnabledExtraIds = computed(() => extraIds.filter(extraId => isLightableIdInUse(extraId)))
const elsEnabledMiscIds = computed(() => miscIds.filter(miscId => isLightableIdInUse(miscId)))
const availableStaticMiscIds = computed(() => elsEnabledMiscIds.value.filter(miscId => !isLightableIdInUseByStatic(miscId)))
const availableStaticExtraIds = computed(() => elsEnabledExtraIds.value.filter(extraId => !isLightableIdInUseByStatic(extraId)))

const addStatic = () => {
  useAddStatic({ id: null, type: 'extra', name: null });
};

const removeStatic = (s: staticType) => {
  useRemoveStatic(s);
};
</script>
