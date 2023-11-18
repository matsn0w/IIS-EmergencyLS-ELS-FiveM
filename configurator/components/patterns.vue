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

          <tbody>
            <tr>
              <td class="pt-4 pb-8 align-top font-semibold text-sm w-32">
                Preview
              </td>
              <td class="pt-4 pb-8 align-top">
                <span
                  v-for="(extra, j) in enabledExtras"
                  :key="j"
                  :id="`${pattern.name}_extra_${extra.id}`"
                  class="light py-4"
                  >{{ extra?.id }}</span
                >
              </td>
              <td class="pt-4 pb-8 align-top">
                <span
                  v-for="(misc, j) in enabledMiscs"
                  :key="j"
                  class="light"
                  :id="`${pattern.name}_misc_${misc.id}`"
                  >{{ misc.id }}</span
                >
              </td>
              <td class="pt-4 pb-8 align-top">
                <div class="flex gap-4">
                  <button
                    type="button"
                    class="green"
                    @click="playPreview(pattern)"
                    v-if="!pattern.isPlayingPreview"
                  >
                    <PlayIcon class="w-4 h-4" />
                  </button>

                  <button
                      type="button"
                      class="amber"
                      @click="pattern.loopPreview = false; pattern.isPlayingPreview = false"
                      v-else
                  >
                    <PlayPauseIcon class="w-4 h-4" />
                  </button>

                  <button
                    type="button"
                    :class="pattern.loopPreview ? 'blue border-[1px]' : 'blue outlined'"
                    @click="pattern.loopPreview = !pattern.loopPreview"
                  >
                    <ArrowPathRoundedSquareIcon class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>

          <tbody class="text-sm divide-y divide-gray-100">
            <tr v-for="(flash, i) in getFlashesForPattern(pattern)" :key="i">
              <td class="w-32">
                <input v-model.number="flash.duration" type="number" min="0" />
              </td>
              <td class="py-4">
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
                  <XMarkIcon class="w-4 h-4" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import {letterLightableId, Lightable, numericalLightableId} from "~/types/lights";
import {patternType} from "~/types/patterns";
import {flashType} from "~/types/flash";
import {
  XMarkIcon,
  PlayIcon,
  PlayPauseIcon,
  ArrowPathRoundedSquareIcon,
} from "@heroicons/vue/24/solid";

const VCF = useVcfConfiguration();

const enabledExtras = computed(() =>
  VCF.value.configuration.lightables.filter(
    (lightable) => lightable.enabled && lightable.type === "extra" && lightableIsNotInUseAsStatic(lightable.id)
  )
);

const enabledMiscs = computed(() =>
  VCF.value.configuration.lightables.filter(
    (lightable) => lightable.enabled && lightable.type === "misc"  && lightableIsNotInUseAsStatic(lightable.id)
  )
);

const addFlash = (pattern: patternType) => {
  useAddFlash(pattern);
};

const removeFlash = (pattern: patternType, flash: flashType) => {
  useRemoveFlash(pattern, flash);
};

const playPreview = async (pattern: patternType) => {

  pattern.isPlayingPreview = true

  const flashes = getFlashesForPattern(pattern)

  for (const flash of flashes) {
    for (const extraId of flash.extras) {
      const extra = enabledExtras.value.find((extra) => extra.id === extraId);
      const color = getLightColor(extra);

      document
        .querySelector(`#${pattern.name}_extra_${extraId}`)
        .classList.toggle(color);
    }

    for (const miscId of flash.miscs) {
      const misc = enabledMiscs.value.find((misc) => misc.id === miscId)
      const color = getLightColor(misc);
      console.log(`#${pattern.name}_misc_${miscId}`)
      document
        .querySelector(`#${pattern.name}_misc_${miscId}`)
        ?.classList.toggle(color);
    }

    await new Promise((resolve) => {
      setTimeout(resolve, flash.duration);
    });

    for (const extraId of flash.extras) {
      const extra = enabledExtras.value.find((extra) => extra.id === extraId);
      const color = getLightColor(extra);

      document
        .querySelector(`#${pattern.name}_extra_${extraId}`)
        ?.classList.toggle(color);
    }

    for (const miscId of flash.miscs) {
      const misc = enabledMiscs.value.find((misc) => misc.id === miscId);
      const color = getLightColor(misc);

      document
        .querySelector(`#${pattern.name}_misc_${miscId}`)
        .classList.toggle(color);
    }
  }

  if (
      pattern?.loopPreview && pattern?.isPlayingPreview
  ) {
    return await playPreview(pattern);
  }

  pattern.isPlayingPreview = false
};

const toggleLight = (pattern: patternType, flash: flashType, light: Lightable) => {
  useToggleLight(pattern, flash, light);
};

const isLightToggled = (flash: flashType, light: Lightable) => {
  const flashIndex = VCF.value.configuration.flashes
    .map((f) => f.id)
    .indexOf(flash.id);
  const extras = VCF.value.configuration.flashes[flashIndex].extras;
  const miscs = VCF.value.configuration.flashes[flashIndex].miscs;

  return Number(light.id) ? extras.includes(light.id as numericalLightableId) : miscs.includes(light.id as letterLightableId);
};

const getLightColor = (light: Lightable) => {
  return light?.color ?? "nocolor";
};

const getFlashesForPattern = (pattern: patternType) => {
  return VCF.value.configuration.flashes.filter(
    (flash) => flash.pattern === pattern.name
  );
};
</script>

<style scoped>
.light {
  @apply bg-gray-200 px-3 py-2 border-2 border-gray-300 rounded mr-3 select-none text-center text-gray-500;
}

.light.red,
.light.green,
.light.amber,
.light.blue {
  @apply text-white
}
</style>
