export default function generateStoreAttributesFromExistingVCF (data) {
  const parsedVCF = new DOMParser().parseFromString(data, 'text/xml')

  const DOMRegex = (subject, regex) => {
    const output = []
    for (const i of subject.querySelectorAll('*')) {
      output.push(i)
    }
    return output
  }

  const description = parsedVCF.querySelector('vcfroot').getAttribute('Description')
  const author = parsedVCF.querySelector('vcfroot').getAttribute('Author')

  const eoverride = parsedVCF.querySelector('EOVERRIDE')
  const extras = DOMRegex(eoverride, /(?<!t)EXTRA/)

  const patternsObject = parsedVCF.querySelector('PATTERN')
  const PRIMARY = patternsObject.querySelector('PRIMARY')
  const SECONDARY = patternsObject.querySelector('SECONDARY')
  const REARREDS = patternsObject.querySelector('REARREDS')

  const soundsObject = parsedVCF.querySelector('SOUNDS')
  const sounds = DOMRegex(soundsObject, /\b(?:MainHorn|NineMode|SrnTone1|SrnTone2|SrnTone3|SrnTone4)\b/g)

  const staticsObject = parsedVCF.querySelector('STATIC')
  const statics = DOMRegex(staticsObject, /(?<!t)EXTRA/) ?? null

  const vcf = {}
  vcf.patterns = []
  vcf.extras = []
  vcf.statics = []
  vcf.sounds = []
  vcf.author = author
  vcf.description = description
  vcf.flashes = []

  vcf.patterns.push({
    isEmergency: PRIMARY.getAttribute('isEmergengy') ?? true,
    name: PRIMARY.nodeName
  })

  vcf.patterns.push({
    isEmergency: SECONDARY.getAttribute('isEmergengy') ?? true,
    name: SECONDARY.nodeName
  })

  vcf.patterns.push({
    isEmergency: REARREDS.getAttribute('isEmergengy') ?? true,
    name: REARREDS.nodeName
  })

  let UniqueFlashId = 1;

  PRIMARY.childNodes.forEach((elem) => {
    if (elem.nodeName === 'Flash') {
      const enabledExtras = elem.getAttribute('Extras').split(',')
      vcf.flashes.push({
        id: UniqueFlashId,
        duration: parseInt(elem.getAttribute('Duration')) ?? null,
        extras: enabledExtras.map(extra => parseInt(extra)) ?? [],
        pattern: 'PRIMARY'
      })
      UniqueFlashId++
    }
  })

  SECONDARY.childNodes.forEach((elem) => {
    if (elem.nodeName === 'Flash') {
      const enabledExtras = elem.getAttribute('Extras').split(',')
      vcf.flashes.push({
        id: UniqueFlashId,
        duration: parseInt(elem.getAttribute('Duration')) ?? null,
        extras: enabledExtras.map(extra => parseInt(extra)) ?? [],
        pattern: 'SECONDARY'
      })
      UniqueFlashId++
    }
  })

  REARREDS.childNodes.forEach((elem) => {
    if (elem.nodeName === 'Flash') {
      const enabledExtras = elem.getAttribute('Extras').split(',')
      vcf.flashes.push({
        id: UniqueFlashId,
        duration: parseInt(elem.getAttribute('Duration')) ?? null,
        extras: enabledExtras.map(extra => parseInt(extra)) ?? [],
        pattern: 'REARREDS'
      })
      UniqueFlashId++
    }
  })

  extras.forEach((extra) => {
    vcf.extras.push({
      id: extra.nodeName.match(/([0-9]|[1-9][0-9])$/g)[0],
      enabled: extra.getAttribute('IsElsControlled') ?? false,
      allowEnv: extra.getAttribute('AllowEnvLight') ?? false,
      color: extra.getAttribute('Color') ?? null
    })
  })

  statics.forEach((staticExtra) => {
    vcf.extras.push({
      extra: staticExtra.getAttribute('extra'),
      name: staticExtra.getAttribute('name') ?? null
    })
  })

  sounds.forEach((sound) => {
    vcf.sounds.push({
      allowUse: sound.getAttribute('AllowUse') ?? false,
      audioString: sound.getAttribute('AudioString') ?? null,
      name: sound.nodeName,
      soundset: sound.getAttribute('Soundset') ?? null
    })
  })

  return vcf
}
