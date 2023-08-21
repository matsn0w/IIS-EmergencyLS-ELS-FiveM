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
            <th>Extra</th>
            <th>Name</th>
            <th />
          </tr>
        </thead>

        <tbody class="text-sm divide-y divide-gray-100">
          <template v-if="VCF.configuration.statics.length">
            <tr v-for="(s, index) in VCF.configuration.statics" :key="index">
              <td class="font-bold flex items-center">
                <span class="mr-4 align-middle">Extra</span>
                <span>
                  <input
                    v-model.number="s.extra"
                    type="number"
                    min="1"
                    max="12"
                  />
                </span>
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

<script setup>
const VCF = useVcfConfiguration();

const addStatic = () => {
  const highest = VCF.value.configuration.statics.value.at(-1)?.extra ?? 0;
  useAddStatic({ extra: highest + 1, name: null });
};

const removeStatic = (s) => {
  useRemoveStatic(s);
};
</script>
