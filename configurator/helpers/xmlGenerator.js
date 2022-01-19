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
      const e = doc.createElement(`Extra${extra.id}`)
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
    // patterns

    console.log(doc)

    return doc
  }
}
