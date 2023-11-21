<script lang="ts">
import {
  InboxArrowDownIcon,
  InboxIcon,
  XMarkIcon
} from "@heroicons/vue/24/solid";

export default defineComponent({
  components: {InboxArrowDownIcon, XMarkIcon, InboxIcon},
  props: {
    state: {
      type: String,
      required: true,
    },
    isForNotice: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['click']
})
</script>

<template>
  <button
      @click="$emit('click')"
      class="blue flex items-center"
      :class="isForNotice ? '!text-white p-2' : 'outlined p-3'"
  >
    <InboxArrowDownIcon class="w-4 h-4" v-if="state === '1'" />
    <template v-else>
      <div class="relative">
        <InboxIcon
            class="w-4 h-4"
        />
        <XMarkIcon
            class="w-4 h-4 absolute top-0 left-0 "
        />
      </div>
    </template>
    <span class="ml-2" v-if="isForNotice">{{state ==='1' ? 'Disable' : 'Enable'}} local VCF storage</span>
  </button>
</template>