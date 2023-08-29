<template>
  <div class="flex flex-col justify-center h-full">
    <header class="px-5 pt-3">
      <h2>Patterns</h2>
    </header>

    <div v-for="(pattern, index) in VCF.configuration.patterns" :key="index">
      <header class="px-5 pt-3 flex items-center gap-4">
        <h3 class="font-bold">
          {{ pattern.name }}
        </h3>

        <button class="blue" type="button" @click="addFlash(pattern)">
          Add flash
        </button>

        <label :for="`isEmergency[${index}]`" class="cb-label">
          <input
            class="mr-2"
            :id="`isEmergency[${index}]`"
            v-model="pattern.isEmergency"
            type="checkbox"
          />
          Is emergency
        </label>

        <label :for="`flashHighBeam[${index}]`" class="cb-label">
          <input
            class="mr-2"
            :id="`flashHighBeam[${index}]`"
            v-model="pattern.flashHighBeam"
            type="checkbox"
          />
          Flash high beam
        </label>

        <label :for="`enableWarningBeep[${index}]`" class="cb-label">
          <input
            class="mr-2"
            :id="`enableWarningBeep[${index}]`"
            v-model="pattern.enableWarningBeep"
            type="checkbox"
          />
          Enable warning beep
        </label>
      </header>

      <div class="p-3 overflow-x-auto">
        <table class="table-auto w-full">
          <thead
            class="text-xs font-semibold uppercase text-gray-400 bg-gray-50"
          >
            <tr>
              <th>Duration</th>
              <th>Extras</th>
              <th>Miscs</th>
              <th />
            </tr>
          </thead>

          <tbody class="text-sm divide-y divide-gray-100">
            <tr v-for="(flash, i) in getFlashesForPattern(pattern)" :key="i">
              <td>
                <input v-model.number="flash.duration" type="number" min="0" />
              </td>
              <td>
                <span
                  v-for="(extra, j) in enabledExtras"
                  :key="j"
                  class="light"
                  :class="
                    isLightToggled(flash, extra) ? getLightColor(extra) : ''
                  "
                  @click="toggleLight(pattern, flash, extra)"
                  >{{ extra.id }}</span
                >
              </td>
              <td>
                <span
                  v-for="(misc, j) in enabledMiscs"
                  :key="j"
                  class="light"
                  :class="
                    isLightToggled(flash, misc) ? getLightColor(misc) : ''
                  "
                  @click="toggleLight(pattern, flash, misc)"
                  >{{ misc.id }}</span
                >
              </td>
              <td>
                <button
                  type="button"
                  class="red"
                  @click="removeFlash(pattern, flash)"
                >
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

<script setup>
const VCF = useVcfConfiguration();

const enabledExtras = computed(() =>
  VCF.value.configuration.extras.filter((extra) => extra.enabled)
);

const enabledMiscs = computed(() =>
  VCF.value.configuration.miscs.filter((misc) => misc.enabled)
);

const addFlash = (pattern) => {
  useAddFlash({ pattern });
};

const removeFlash = (pattern, flash) => {
  useRemoveFlash({ pattern, flash });
};

const toggleLight = (pattern, flash, light) => {
  useToggleLight({ pattern, flash, light });
};

const isLightToggled = (flash, light) => {
  const flashIndex = VCF.value.configuration.flashes
    .map((f) => f.id)
    .indexOf(flash.id);
  const extras = VCF.value.configuration.flashes[flashIndex].extras;
  const miscs = VCF.value.configuration.flashes[flashIndex].miscs;

  return isNaN(light.id) ? miscs.includes(light.id) : extras.includes(light.id);
};

const getLightColor = (light) => {
  return light.color || "nocolor";
};

const getFlashesForPattern = (pattern) => {
  return VCF.value.configuration.flashes.filter(
    (flash) => flash.pattern === pattern.name
  );
};
</script>

<style scoped>
.light {
  @apply bg-gray-200 px-3 py-2 border-2 border-gray-300 rounded mr-3 select-none text-center text-gray-500;
}
</style>
