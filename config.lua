Config = {}

-- Each time you add a new .xml file, you MUST include it below!
Config.ELSFiles = {
    'Example.xml',
    'Example_ServerSideSIrens.xml'
}

-- Allows passengers to control the sirens
Config.AllowPassengers = false

-- Whether indicators should be enabled or not. (Controlled with Left & Right arrows by default)
Config.Indicators = true

-- If you are using server-sided sirens, uncomment below...
Config.AudioBanks = {
    "DLC_WMSIRENS\\SIRENPACK_ONE"
}

-- Enables the horn beeps on siren activation
Config.HornBlip = true

-- Enables/Disables ELS beeps
Config.Beeps = false

-- Whether controllers are supported for controlling ELS.
Config.ControllerSupport = true

-- Keybinds for each command. Key codes can be found at https://docs.fivem.net/docs/game-references/controls/
Config.KeyBinds = {
    PrimaryLights = 85,
    SecondaryLights = 311,
    MiscLights = 182,
    ActivateSiren = 19,
    NextSiren = 45,
    Siren1 = 157,
    Siren2 = 158,
    Siren3 = 160,
    Siren4 = 164
}
