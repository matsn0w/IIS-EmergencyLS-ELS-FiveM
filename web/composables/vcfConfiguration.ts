import type {
  letterLightableId,
  Lightable,
  numericalLightableId,
} from "~/types/lights";
import type { vcfConfig } from "~/types/vcfConfig";
import type { flashType } from "~/types/flash";
import type { staticType } from "~/types/static";
import type { patternType } from "~/types/patterns";
import type { Ref } from "vue";
import { DateTime } from "luxon";
const config = useRuntimeConfig();

export const defaultVcfConfig = () => {
  return {
    flashID: 1,
    configuration: {
      author: null,
      description: null,
      version: config.public.version,
      lightables: [],
      statics: [],
      useServerSirens: false,
      sounds: [
        {
          name: "MainHorn",
          allowUse: true,
          audioString: "SIRENS_AIRHORN",
          soundSet: null,
        },
        {
          name: "NineMode",
          allowUse: false,
        },
        {
          name: "SrnTone1",
          allowUse: true,
          audioString: "VEHICLES_HORNS_SIREN_1",
          soundSet: "DLC_WMSIRENS_SOUNDSET",
        },
        {
          name: "SrnTone2",
          allowUse: true,
          audioString: "VEHICLES_HORNS_SIREN_2",
          soundSet: "DLC_WMSIRENS_SOUNDSET",
        },
        {
          name: "SrnTone3",
          allowUse: true,
          audioString: "VEHICLES_HORNS_POLICE_WARNING",
          soundSet: "DLC_WMSIRENS_SOUNDSET",
        },
        {
          name: "SrnTone4",
          allowUse: true,
          audioString: "VEHICLES_HORNS_AMBULANCE_WARNING",
          soundSet: "DLC_WMSIRENS_SOUNDSET",
        },
      ],
      patterns: [
        {
          name: "PRIMARY",
          isEmergency: true,
          flashHighBeam: false,
          enableWarningBeep: false,
          loopPreview: true,
          isPlayingPreview: false,
        },
        {
          name: "SECONDARY",
          isEmergency: true,
          flashHighBeam: false,
          enableWarningBeep: false,
          loopPreview: true,
          isPlayingPreview: false,
        },
        {
          name: "REARREDS",
          isEmergency: true,
          flashHighBeam: false,
          enableWarningBeep: false,
          loopPreview: true,
          isPlayingPreview: false,
        },
      ],
      flashes: [],
    },
  }
};
const luxon = DateTime;

export const useVcfConfiguration = (): Ref<vcfConfig> => {
  return useState("vcfConfiguration", () => (getVcfConfig() as vcfConfig));
};

const getVcfConfig = (): vcfConfig => {
  if (
    localStorage.getItem("vcfConfiguration") !== null &&
    localStorage.getItem("saveVcfLocal") === "1"
  ) {
    return JSON.parse(
      localStorage.getItem("vcfConfiguration") as string
    ) as vcfConfig;
  } else {
    return defaultVcfConfig()
  }
};

watch(useVcfConfiguration().value, (value) => {
  localStorage.setItem("vcfUpdate", String(luxon.now().toUnixInteger()));
  localStorage.setItem("vcfConfiguration", JSON.stringify(value));
});

export const resetVcfConfiguration = () => {
  // To make sure we trigger the watch
  useVcfConfiguration().value.flashID = defaultVcfConfig().flashID;
  useVcfConfiguration().value.configuration = defaultVcfConfig().configuration;
};

const getFlashIndex = (flash: flashType) => {
  const VCF = useVcfConfiguration();

  return VCF.value.configuration.flashes.map((f) => f.id).indexOf(flash.id);
};

export const lightableIsNotInUseAsStatic = (
  lightableId: numericalLightableId | letterLightableId
) =>
  !useVcfConfiguration()
    .value.configuration.statics.map(
      (staticElement: staticType) => staticElement.id
    )
    .includes(lightableId);

export const miscIds: letterLightableId[] = [
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
];
export const extraIds: numericalLightableId[] = [
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
];

export const isLightableIdInUse = (
  id: letterLightableId | numericalLightableId
) =>
  useVcfConfiguration()
    .value.configuration.lightables.map((lightable: Lightable) => lightable.id)
    .includes(id);
export const availableMiscIds = computed(() =>
  miscIds.filter((miscId) => !isLightableIdInUse(miscId))
);
export const availableExtraIds = computed(() =>
  extraIds.filter((extraId) => !isLightableIdInUse(extraId))
);

export const useAddStatic = (value: staticType) => {
  const VCF = useVcfConfiguration();

  VCF.value.configuration.statics.push(value);
};

export const useRemoveStatic = (value: staticType) => {
  const VCF = useVcfConfiguration();

  const index = VCF.value.configuration.statics
    .map((item) => item.id)
    .indexOf(value.id);

  VCF.value.configuration.statics.splice(index, 1);
};

export const useAddFlash = (pattern: patternType) => {
  const VCF = useVcfConfiguration();

  const flash: flashType = {
    id: VCF.value.flashID++,
    pattern: pattern.name,
    duration: 100,
    extras: [],
    miscs: [],
  };

  VCF.value.configuration.flashes.push(flash);
};

export const useRemoveFlash = (pattern: patternType, flash: flashType) => {
  const VCF = useVcfConfiguration();

  const flashIndex = getFlashIndex(flash);

  if (flashIndex !== -1) {
    VCF.value.configuration.flashes.splice(flashIndex, 1);
  }
};

export const useToggleLight = (
  pattern: patternType,
  flash: flashType,
  lightable: Lightable
) => {
  const VCF = useVcfConfiguration();

  const flashIndex: number = getFlashIndex(flash);
  const extras = VCF.value.configuration.flashes[flashIndex].extras;
  const miscs = VCF.value.configuration.flashes[flashIndex].miscs;

  if (typeof lightable.id === "number") {
    if (extras.includes(lightable.id)) {
      extras.splice(extras.indexOf(lightable.id), 1);
    } else {
      extras.push(lightable.id);
    }
  } else {
    if (miscs.includes(lightable.id)) {
      miscs.splice(miscs.indexOf(lightable.id), 1);
    } else if (typeof lightable.id === "string") {
      miscs.push(lightable.id);
    }
  }
};

export const useImportExistingConfiguration = (value: vcfConfig) => {
  const VCF = useVcfConfiguration();

  VCF.value.flashID = value.flashID;
  VCF.value.configuration = value.configuration;
};
