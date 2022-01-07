# Vehicle Configuration File (VCF)

A Vehicle Configuration File, shortly VCF, is an XML file which contains all ELS-related configurations of a specific vehicle. Each ELS-enabled vehicle must have a configuration file set up in order for ELS to know how to handle it.

A VCF consists of 3 main sections:

- extras (`EOVERRIDE`)
- sounds (`SOUNDS`)
- patterns (`PATTERN`)

All these three sections must be present, otherwise the file won't be valid. They live under the main `<vcfroot>` tag. You can use the bare configuration file below to start completely from scratch, or edit one of the configuration examples included in the `xmlFiles` directory.

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- ELS VEHICLE CONFIGURATION FILE -->
<vcfroot Description="Bare bone configuration file" Author="matsn0w" >
    <!-- EXTRAS CONFIGURATION -->
    <EOVERRIDE>
        <Extra01 />
        <Extra02 />
        <Extra03 />
        <Extra04 />
        <Extra05 />
        <Extra06 />
        <Extra07 />
        <Extra08 />
        <Extra09 />
        <Extra10 />
        <Extra11 />
        <Extra12 />
    </EOVERRIDE>

    <!-- SOUNDS & SIREN CONFIG -->
    <SOUNDS>
        <MainHorn />
        <NineMode />
        <SrnTone1 />
        <SrnTone2 />
        <SrnTone3 />
        <SrnTone4 />
    </SOUNDS>

    <!-- CUSTOM PATTERN -->
    <PATTERN>
        <PRIMARY></PRIMARY>
        <SECONDARY></SECONDARY>
        <REARREDS></REARREDS>
    </PATTERN>
</vcfroot>
```

## Extras: `EOVERRIDE`

This section defines the configuration of the extras that live on the vehicle.

These extra parts are a bit like vehicle modifications (you can often change the look of the wheels for example), but with the difference that they can be enabled or disabled. This means that you can choose whether you want to see it on the vehicle. Normally, the extra parts are used for optional parts like the cupholders in the Blista. A clever guy once came up with the idea of using these extras to create more dynamic light bars on emergency vehicles. This gives the player much more options and flexibility compared to the native lightbars. Now, advanced configurations with fancy traffic advisors and takedown lights are possible. Nice!

The only limitation is the amount of extras that can be placed on a vehicle. The game developers limited this to 12 extras, each with a number from 1 to 12. This means you can have a maximum of 12 different lights on your vehicle, but you can sometimes combine multiple light sources into one extra. The configuration depends on the vehicle and needs to be set up correctly by the author of it.

In the `EOVERRIDE` section, you can define each extra on your vehicle and configure some options for each of them. Consult the author of the vehicle if you are unsure about the layout of the vehicle.

As you can see in the example below, you should define each extra as `ExtraXX` where XX is the ID of the extra. ID's lower than 10 must have a leading 0. Most options are optional and will fall back to a default value when not specified. You can omit an option, but it's totally OK to specify them anyway. See the configuration table for an explanation of each option.

Example configuration:

```xml
<EOVERRIDE>
    <Extra01 IsElsControlled="true" AllowEnvLight="true" Color="blue" OffsetX="-3.0" />
    <Extra02 IsElsControlled="false" />
    <Extra03 IsElsControlled="false" />
    <Extra04 IsElsControlled="true" AllowEnvLight="true" Color="blue" OffsetX="3.0" />
    <Extra05 IsElsControlled="true" AllowEnvLight="true" Color="amber" OffsetX="-3.0" OffsetY="-3.0" OffsetZ="3.0" />
    <Extra06 IsElsControlled="true" AllowEnvLight="true" Color="amber" OffsetX="-4.7" OffsetZ="0.0" />
    <Extra07 IsElsControlled="true" AllowEnvLight="false" />
    <Extra08 IsElsControlled="true" />
    <Extra09 IsElsControlled="false" />
    <Extra10 IsElsControlled="false" />
    <Extra11 IsElsControlled="true" AllowEnvLight="true" Color="green" />
    <Extra12 IsElsControlled="true" AllowEnvLight="true" Color="white" OffsetY="5.0" />
</EOVERRIDE>
```

Options:

| Name                      | Type    | Values                                   | Default | Description                                                                                                                                                               |
| ------------------------- | ------- | ---------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| IsElsControlled           | boolean | `true`, `false`                          | `false` | Whether the extra should be controlled by ELS or not. ELS will ignore the extra when this is set to `false`.                                                              |
| AllowEnvLight             | boolean | `true`, `false`                          | `false` | Whether environment lights are enabled or not. This is better known as 'flashing on the walls'.                                                                           |
| Color                     | string  | `red`, `green`, `blue`, `white`, `amber` | `red`   | Specifies the color of environment lights (reflections). Should be set when AllowEnvLight is set to true.                                                                 |
| OffsetX, OffsetY, OffsetZ | float   | a positive or negative decimal number    | `0.0`   | Optionally specifies an offset for the environment light on the x, y or z-axis, relative to the origin of the light source. This will 'move' the reflection of the light. |

## Sounds: `SOUNDS`

This section defines the sound for each siren on your vehicle. You can enable up to 4 different sirens for each vehicle. Also, you can optionally set a custom horn sound for the vehicle. This can be used to enable an airhorn for example. Enabling the NineMode setting will activate a '999 mode actived!' sound effect when you press Q (by default, or DPAD_LEFT on controllers).

If you are using [WMServerSirens](https://github.com/Walsheyy/WMServerSirens), you can specify the sound set too. ELS will use the game's native sound effects otherwise. Make sure to include the sound set under `Config.AudioBanks` in order for it to load.

Now, you might ask yourself: how do I know which sounds I can use? Well... it's complicated. There doesn't seem to be an unequivocal answer to that question. You can read [this forum topic](gtaforums.com/topic/795622-audio-for-mods), especially [this comment](https://gtaforums.com/topic/795622-audio-for-mods/?do=findComment&comment=1068658778) for some guidelines.

*Note that you can use WMServerSirens and native game sounds mixed together (do not specify a SoundSet to use a native game sound).*

Example with WMServerSirens:

```xml
<SOUNDS>
    <MainHorn AllowUse="false" />
    <NineMode AllowUse="false" />
    <SrnTone1 AllowUse="true" AudioString="SIREN_ALPHA" SoundSet="DLC_WMSIRENS_SOUNDSET" />
    <SrnTone2 AllowUse="true" AudioString="SIREN_BRAVO" SoundSet="DLC_WMSIRENS_SOUNDSET" />
    <SrnTone3 AllowUse="true" AudioString="VEHICLES_HORNS_SIREN_1" />
    <SrnTone4 AllowUse="false" />
</SOUNDS>
```

Example with native game sounds:

```xml
<SOUNDS>
    <MainHorn AllowUse="true" AudioString="SIRENS_AIRHORN" />
    <NineMode AllowUse="true" />
    <SrnTone1 AllowUse="true" AudioString="VEHICLES_HORNS_SIREN_1" />
    <SrnTone2 AllowUse="true" AudioString="VEHICLES_HORNS_SIREN_2" />
    <SrnTone3 AllowUse="true" AudioString="VEHICLES_HORNS_POLICE_WARNING" />
    <SrnTone4 AllowUse="true" AudioString="VEHICLES_HORNS_AMBULANCE_WARNING" />
</SOUNDS>
```

Options:

**MainHorn**:
| Name            | Type    | Values                    | Default          | Description                                                                                                                                        |
| --------------- | ------- | ------------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| AllowUse        | boolean | `true`, `false`           | `false`          | Whether the custom horn is enabled or not. The game's horn for the vehicle will be used (different depending on the `vehicles.meta` entry for it). |
| AudioString     | string  | name hash of sound to use | `SIRENS_AIRHORN` | The name of an audio to play. Must be compatible with the [`PLAY_SOUND_FROM_ENTITY`](https://docs.fivem.net/natives/?_0xE65F427EB70AB1ED) native.  |
| SoundSet        | string  | name of sound bank to use | -                | The name of the sound set if using WMServerSirens.                                                                                                 |

**NineMode**:

| Name     | Type    | Values          | Default | Description                                  |
| -------- | ------- | --------------- | ------- | -------------------------------------------- |
| AllowUse | boolean | `true`, `false` | `false` | Enables a '999 mode activated' sound effect. |

**SrnTone1-4**:

| Name        | Type    | Values                    | Default | Description                                                                                                                                       |
| ----------- | ------- | ------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| AllowUse    | boolean | `true`, `false`           | `false` | Whether the siren is enabled or not.                                                                                                              |
| AudioString | string  | name hash of sound to use | -       | The name of an audio to play. Must be compatible with the [`PLAY_SOUND_FROM_ENTITY`](https://docs.fivem.net/natives/?_0xE65F427EB70AB1ED) native. |
| SoundSet    | string  | name of sound bank to use | -       | The name of the sound set if using WMServerSirens.                                                                                                |

## Patterns: `PATTERN`

This section explains how to create a nice lighting pattern for the vehicle. There are three light stages that you can use: primary, secondary and 'rear reds' (also known as 'warning'). Each pattern goes into it's own section as you can see in the example below.

Each pattern consists of one or more 'flashes'. For each flash, you can define how long it will be active and which extras light up. You can specify more than one extra per flash. Omitting or leaving the Extras key empty will be handled as 'waiting time'.

The duration is measured in milliseconds. Flashes will be executed by appearance order and the entire pattern will be looped. Separate multiple extras with a comma.

It's recommended to include an 'empty flash' at the bottom of each pattern to make the transition from last to first flash smooth.

Pattern example:

```xml
<PATTERN>
    <PRIMARY>
        <Flash Duration="50" Extras="1,4" />
        <Flash Duration="50" />
        <Flash Duration="150" Extras="1,4" />
        <Flash Duration="50" />
        <Flash Duration="50" Extras="2,3" />
        <Flash Duration="50" />
        <Flash Duration="150" Extras="2,3" />
        <Flash Duration="50" />
    </PRIMARY>

    <SECONDARY>
        <Flash Duration="50" Extras="5" />
        <Flash Duration="50" Extras="" />
        <Flash Duration="150" Extras="5" />
        <Flash Duration="50" Extras="" />
        <Flash Duration="50" Extras="6" />
        <Flash Duration="50" Extras="" />
        <Flash Duration="150" Extras="6" />
        <Flash Duration="50" Extras="" />
    </SECONDARY>

    <REARREDS>
        <Flash Duration="1000" Extras="8" />
        <Flash Duration="250" />
        <Flash Duration="1000" Extras="7" />
    </REARREDS>
</PATTERN>
```
