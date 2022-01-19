import { getField, updateField } from 'vuex-map-fields'

export const state = () => ({
  configuration: {
    author: null,
    description: null,
    extras: [
      { id: 1, enabled: false, allowEnv: false, color: null },
      { id: 2, enabled: false, allowEnv: false, color: null },
      { id: 3, enabled: false, allowEnv: false, color: null },
      { id: 4, enabled: false, allowEnv: false, color: null },
      { id: 5, enabled: false, allowEnv: false, color: null },
      { id: 6, enabled: false, allowEnv: false, color: null },
      { id: 7, enabled: false, allowEnv: false, color: null },
      { id: 8, enabled: false, allowEnv: false, color: null },
      { id: 9, enabled: false, allowEnv: false, color: null },
      { id: 10, enabled: false, allowEnv: false, color: null },
      { id: 11, enabled: false, allowEnv: false, color: null },
      { id: 12, enabled: false, allowEnv: false, color: null }
    ],
    statics: [],
    sounds: [],
    patterns: []
  }
})

export const getters = {
  getField
}

export const mutations = {
  updateField
}
