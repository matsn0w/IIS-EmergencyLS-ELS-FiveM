import { getField, updateField } from 'vuex-map-fields'

export const state = () => ({
  flashID: 1,
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
    useServerSirens: false,
    sounds: [
      { name: 'MainHorn', allowUse: true, audioString: 'SIRENS_AIRHORN', soundSet: null },
      { name: 'NineMode', allowUse: true },
      { name: 'SrnTone1', allowUse: true, audioString: 'VEHICLES_HORNS_SIREN_1', soundSet: 'DLC_WMSIRENS_SOUNDSET' },
      { name: 'SrnTone2', allowUse: true, audioString: 'VEHICLES_HORNS_SIREN_2', soundSet: 'DLC_WMSIRENS_SOUNDSET' },
      { name: 'SrnTone3', allowUse: true, audioString: 'VEHICLES_HORNS_POLICE_WARNING', soundSet: 'DLC_WMSIRENS_SOUNDSET' },
      { name: 'SrnTone4', allowUse: true, audioString: 'VEHICLES_HORNS_AMBULANCE_WARNING', soundSet: 'DLC_WMSIRENS_SOUNDSET' }
    ],
    patterns: {
      PRIMARY: { isEmergency: true, flashes: [] },
      SECONDARY: { isEmergency: true, flashes: [] },
      REARREDS: { isEmergency: true, flashes: [] }
    }
  }
})

export const getters = {
  getField
}

export const mutations = {
  updateField,

  addStatic (state, value) {
    state.configuration.statics.push(value)
  },

  removeStatic (state, value) {
    const index = state.configuration.statics.map(item => item.extra).indexOf(value.extra)
    state.configuration.statics.splice(index, 1)
  },

  addFlash (state, value) {
    // add flash to pattern
    state.configuration.patterns[value.pattern].flashes.push(value.flash)

    // increase flash ID
    value.flash.id = state.flashID++
  },

  removeFlash (state, value) {
    const p = state.configuration.patterns[value.pattern]
    const index = p.flashes.map(f => f.id).indexOf(value.flash.id)

    if (index !== -1) {
      p.flashes.splice(index, 1)
    }
  },

  toggleExtra (state, value) {
    const p = state.configuration.patterns[value.pattern]
    const index = p.flashes.map(f => f.id).indexOf(value.flash)
    const extras = p.flashes[index].extras

    if (extras.includes(value.extra)) {
      extras.splice(extras.indexOf(value.extra), 1)
    } else {
      extras.push(value.extra)
    }
  }
}
