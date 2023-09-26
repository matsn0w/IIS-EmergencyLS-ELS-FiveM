import {vcfConfig} from "~/types/vcfConfig";
import {Color, letterLightableId, numericalLightableId} from "~/types/lights";
import {soundType} from "~/types/sounds";

/**
 * This method takes in an existing VCF file (as XML string), parses the XML
 * and maps it to an expected format for the VueX store.
 *
 */
export const generateStoreAttributesFromExistingVCF = (data: any) => {
  const vcf: vcfConfig = {
    flashID: 1,
    configuration: {
      author: null,
      description: null,
      lightables: [],
      statics: [],
      useServerSirens: false,
      sounds: [],
      patterns: [],
      flashes: [],
    }
  };

  // parse the XML string
  const parsedVCF = new DOMParser().parseFromString(data, "text/xml");

  // get basic document info
  vcf.configuration.description = parsedVCF
    .querySelector("vcfroot")
    .getAttribute("Description") ?? null;
  vcf.configuration.author = parsedVCF.querySelector("vcfroot").getAttribute("Author");

  // EOVERRIDE section
  const eoverride = parsedVCF.querySelector("EOVERRIDE");
  const lights = Array.from(eoverride.querySelectorAll("*"));

  const extras = lights.filter((light) => {
    return light.nodeName.startsWith("Extra");
  });

  const miscs = lights.filter((light) => {
    return light.nodeName.startsWith("Misc");
  });

  extras.forEach((extra) => {
    vcf.configuration.lightables.push({
      id: parseInt(extra.nodeName.match(/([0-9]|[1-9][0-9])$/g)[0]),
      type: 'extra',
      enabled: extra.getAttribute("IsElsControlled") === "true",
      allowEnv: extra.getAttribute("AllowEnvLight") === "true",
      color: extra.getAttribute("Color") as Color ?? null,
    });
  });

  miscs.forEach((misc) => {
    vcf.configuration.lightables.push({
      id: misc.nodeName.match(/([A-Z])$/g)[0].toLowerCase(),
      type: 'misc',
      enabled: misc.getAttribute("IsElsControlled") === "true",
      allowEnv: misc.getAttribute("AllowEnvLight") === "true",
      color: misc.getAttribute("Color") as Color ?? null,
    });
  });

  // STATICS section
  const staticsObject = parsedVCF.querySelector("STATIC");
  const statics = Array.from(staticsObject.querySelectorAll("*"));

  const staticExtras = statics.filter((s) => {
    return s.nodeName.startsWith("Extra");
  });

  const staticMiscs = statics.filter((s) => {
    return s.nodeName.startsWith("Misc");
  });

  staticExtras.forEach((staticExtra) => {
    vcf.configuration.statics.push({
      id: parseInt(staticExtra.nodeName.match(/([0-9]|[1-9][0-9])$/g)[0]) as numericalLightableId,
      type: 'extra',
      name: staticExtra.getAttribute("Name") ?? staticExtra.nodeName,
    });
  });

  staticMiscs.forEach((staticMisc) => {
    vcf.configuration.statics.push({
      id: staticMisc.nodeName.match(/([A-Z])$/g)[0].toLowerCase() as letterLightableId,
      type: 'misc',
      name: staticMisc.getAttribute("Name") ?? staticMisc.nodeName,
    });
  });

  // SOUNDS section
  const soundsObject = parsedVCF.querySelector("SOUNDS");
  const sounds = soundsObject?.querySelectorAll("*");

  sounds?.forEach((sound) => {
    const isNineMode = sound.nodeName === "NineMode";

    let fields: Partial<soundType> = {
      name: sound.nodeName,
      allowUse: sound.getAttribute("AllowUse") === "true",
    }

    if (!isNineMode) {
      fields.audioString = sound.getAttribute("AudioString")
      fields.soundSet = sound.getAttribute("SoundSet")
    }

    vcf.configuration.sounds.push(fields as soundType);
  });

  // determine whether a SoundSet is present
  sounds?.forEach((sound) => {
    if (sound.getAttribute("SoundSet") !== null) {
      vcf.configuration.useServerSirens = true;
    }
  });

  // PATTERN section
  const patternsObject = parsedVCF.querySelector("PATTERN");

  for (const pattern of patternsObject.children) {
    vcf.configuration.patterns.push({
      name: pattern.nodeName,
      isEmergency: pattern.getAttribute("IsEmergency") === "true",
      flashHighBeam: pattern.getAttribute("FlashHighBeam") === "true",
      enableWarningBeep: pattern.getAttribute("EnableWarningBeep") === "true",
      loopPreview: true,
      isPlayingPreview: false,
    });

    for (const flash of pattern.children) {
      const enabledExtras = flash.getAttribute("Extras")?.split(",") ?? [];
      const enabledMiscs: letterLightableId[] = flash.getAttribute("Miscs")?.split(",") as letterLightableId[] ?? [];

      vcf.configuration.flashes.push({
        id: vcf.flashID++,
        duration: parseInt(flash.getAttribute("Duration") || '') ?? 100,
        extras: enabledExtras.map((extra) => parseInt(extra) as numericalLightableId) ?? [],
        miscs: enabledMiscs ?? [],
        pattern: pattern.nodeName,
      });
    }
  }

  return vcf;
};
