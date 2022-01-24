<template>
  <div class="container mx-auto">
    <h1 class="my-4 text-2xl font-bold">
      MISS ELS VCF Configurator
    </h1>

    <form @submit.prevent="generateVCF">
      <div>
        <div class="md:flex md:items-center mb-3">
          <label for="description">Description</label>
          <input id="description" v-model="description" type="text">
        </div>

        <div class="md:flex md:items-center mb-3">
          <label for="author">Author</label>
          <input id="author" v-model="author" type="text">
        </div>
      </div>

      <extras class="card" />
      <statics class="card" />
      <sounds class="card" />
      <patterns class="card" />

      <div class="py-3">
        <button type="submit">
          Generate VCF
        </button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapFields } from 'vuex-map-fields'
import Extras from '~/components/extras'
import Patterns from '~/components/patterns'
import Sounds from '~/components/sounds'
import Statics from '~/components/statics'
import XMLGenerator from '~/helpers/xmlGenerator'

export default {
  components: { Extras, Statics, Sounds, Patterns },

  computed: {
    ...mapFields([
      'configuration.author',
      'configuration.description'
    ])
  },

  methods: {
    generateVCF () {
      XMLGenerator.generateVCF(this.$store.state.configuration)
    }
  }
}
</script>

<style>
.card {
  @apply px-3 py-1 my-3 rounded-md shadow;
}

.card h2 {
  @apply font-semibold text-gray-800;
}

button {
  @apply px-2 py-1 bg-blue-500 text-white rounded-md shadow;
}

thead {
  @apply font-semibold uppercase text-gray-400 bg-gray-50;
}

tbody {
  @apply divide-y divide-gray-100;
}

th, td {
  @apply p-2 align-middle;
}

th {
  @apply font-semibold text-left;
}

label {
  @apply block text-gray-500 font-bold md:text-right mb-1 md:mb-0 pr-4;
}

input[type=text], input[type=number] {
  @apply bg-gray-200 appearance-none border-2 border-gray-200 rounded w-full p-2 text-gray-700 leading-tight align-middle;
}

input[type=text]:focus, input[type=number]:focus {
  @apply focus:outline-none focus:bg-white focus:border-blue-500;
}

select {
  @apply
    form-select appearance-none
    block w-full
    px-3 py-1.5
    text-base font-normal text-gray-700
    bg-white bg-clip-padding bg-no-repeat
    border border-solid border-gray-300 rounded
    transition ease-in-out
    m-0
    focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none;
}

.form-select {
  -moz-padding-start: calc(.75rem - 3px);
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
  background-position: right .75rem center;
  background-size: 16px 12px;
}

.checkbox {
  display: flex;
  flex-direction: row-reverse;
  align-items: center;
  gap: .25rem;
}
</style>
