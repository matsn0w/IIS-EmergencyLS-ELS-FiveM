# Frequently Asked Questions

## 1. Why don't other cars pull over?

You have to set a `sirenSetting` in a `carvariations.meta` file. This will make the game think your vehicle has a 'siren'. Also make sure the vehicle has the flag `FLAG_EMERGENCY_SERVICE` or `FLAG_LAW_ENFORCEMENT` in the `vehicles.meta`. The ELS will trigger the emergency state when you toggle the sirens, and BOOM! They move over!

See [#2](#2-why-are-my-tail-lights-flashing)

## 2. Why are my tail lights flashing?

Same issue as question [#1](#1-why-dont-other-cars-pull-over): you'll have to set a `sirenSetting` in your `carvariations.meta` file.

The flashing taillights are a default GTA behaviour. You can get rid of it by changing the `carvariations.meta` entry for the emergency vehicle. I recoommend setting it to 9, but you can try other values too.

```xml
<sirenSettings value="9" />
```

Complete carvariations entry exmaple:

```xml
<Item>
    <modelName>police</modelName>

    <colors>
        <Item>
            <indices content="char_array">
                132
                132
                132
                132
            </indices>

            <liveries>
                <Item value="true" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
            </liveries>
        </Item>

        <Item>
            <indices content="char_array">
                132
                132
                132
                132
            </indices>

            <liveries>
                <Item value="false" />
                <Item value="true" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
            </liveries>
        </Item>

        <Item>
            <indices content="char_array">
                132
                132
                132
                132
            </indices>

            <liveries>
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="true" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
            </liveries>
        </Item>

        <Item>
            <indices content="char_array">
                132
                132
                132
                132
            </indices>

            <liveries>
                <Item value="false" />
                <Item value="false" />
                <Item value="true" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
            </liveries>
        </Item>

        <Item>
            <indices content="char_array">
                132
                132
                132
                132
            </indices>

            <liveries>
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="true" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
                <Item value="false" />
            </liveries>
        </Item>
    </colors>

    <kits>
        <Item>0_default_modkit</Item>
    </kits>

    <windowsWithExposedEdges />

    <plateProbabilities>
        <Probabilities />
    </plateProbabilities>

    <lightSettings value="1" />
    <sirenSettings value="9" />
</Item>
```

You can stream this file by specifiying it in your `fxmanifest.lua`:

```lua
files {
    'vehicles.meta',
    'carvariations.meta', --> load the file
    'handling.meta',
    'carcols.meta',
}

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta' --> mark the file as VEHICLE_VARIATION_FILE
```
