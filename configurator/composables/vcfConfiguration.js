export const useVcfConfiguration = () => {
  return useState("vcfConfiguration", () => ({
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
        { id: 12, enabled: false, allowEnv: false, color: null },
      ],
      statics: [],
      useServerSirens: false,
      sounds: [
        {
          name: "MainHorn",
          allowUse: true,
          audioString: "SIRENS_AIRHORN",
          soundSet: null,
        },
        { name: "NineMode", allowUse: true },
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
        },
        {
          name: "SECONDARY",
          isEmergency: true,
          flashHighBeam: false,
          enableWarningBeep: false,
        },
        {
          name: "REARREDS",
          isEmergency: true,
          flashHighBeam: false,
          enableWarningBeep: false,
        },
      ],
      flashes: [],
    },
  }));
};

const getFlashIndex = (flash) => {
  const VCF = useVcfConfiguration();

  return VCF.value.configuration.flashes.map((f) => f.id).indexOf(flash.id);
};

export const useAddStatic = (value) => {
  const VCF = useVcfConfiguration();

  VCF.value.configuration.statics.push(value);
};

export const useRemoveStatic = (value) => {
  const VCF = useVcfConfiguration();

  const index = VCF.value.configuration.statics
    .map((item) => item.extra)
    .indexOf(value.extra);

  VCF.value.configuration.statics.splice(index, 1);
};

export const useAddFlash = (value) => {
  const VCF = useVcfConfiguration();

  const flash = {
    id: state.flashID++,
    pattern: value.pattern.name,
    duration: 100,
    extras: [],
  };

  VCF.value.configuration.flashes.push(flash);
};

export const useRemoveFlash = (value) => {
  const VCF = useVcfConfiguration();

  const flashIndex = getFlashIndex(value.flash);

  if (flashIndex !== -1) {
    VCF.value.configuration.flashes.splice(flashIndex, 1);
  }
};

export const useToggleExtra = (value) => {
  const VCF = useVcfConfiguration();

  const flashIndex = getFlashIndex(value.flash);
  const extras = VCF.value.configuration.flashes[flashIndex].extras;

  if (extras.includes(value.extra.id)) {
    extras.splice(extras.indexOf(value.extra.id), 1);
  } else {
    extras.push(value.extra.id);
  }
};

export const useImportExistingConfiguration = (value) => {
  const VCF = useVcfConfiguration();

  VCF.value.flashID = value.flashID;
  delete value.flashID;

  VCF.value.configuration = value;
};
