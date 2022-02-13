export default {
  generateVCF (data) {
    // create an empty document
    const doc = document.implementation.createDocument('', '', null)

    // create root element
    const vcfRoot = doc.createElement('vcfroot')
    vcfRoot.setAttribute('Description', data.description ?? '')
    vcfRoot.setAttribute('Author', data.author ?? '')

    doc.appendChild(vcfRoot)

    // extras
    const extras = doc.createElement('EOVERRIDE')

    data.extras.forEach((extra) => {
      let extraId = `${extra.id}`
      extraId = extraId.replace(/(^[^\d\n]*\d[^\d\n]*$)/gm, '0$1')
      const e = doc.createElement(`Extra${extraId}`)
      e.setAttribute('IsElsControlled', extra.enabled)

      if (extra.allowEnv) {
        e.setAttribute('AllowEnvLight', extra.allowEnv)

        if (extra.color) {
          e.setAttribute('Color', extra.color)
        }
      }

      extras.appendChild(e)
    })

    vcfRoot.appendChild(extras)

    // statics
    const statics = doc.createElement('STATIC')

    data.statics.forEach((stat) => {
      const s = doc.createElement(`Extra${stat.extra}`)
      s.setAttribute('Name', stat.name ?? `Extra${stat.extra}`)

      statics.appendChild(s)
    })

    vcfRoot.appendChild(statics)

    // sounds
    const sounds = doc.createElement('SOUNDS')

    data.sounds.forEach((option) => {
      const o = doc.createElement(option.name)
      o.setAttribute('AllowUse', option.allowUse)

      if (option.audioString) {
        o.setAttribute('AudioString', option.audioString)
      }

      if (data.useServerSirens && option.soundSet) {
        o.setAttribute('SoundSet', option.soundSet)
      }

      sounds.appendChild(o)
    })

    vcfRoot.appendChild(sounds)

    // patterns

    console.log(doc)

    return doc
  }
}
