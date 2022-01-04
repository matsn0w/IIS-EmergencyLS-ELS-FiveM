Config = {}

-- Each time you add a new .xml file, you MUST include it below!
Config.ELSFiles = {
--  'Example.xml',
    "AMBULANCE.xml",
    "ert1.xml",
    "ert2.xml",
    "ert3.xml",
    "ert4.xml",
    "ert5.xml",
    "ert6.xml",
    "ert7.xml",
    "ert8.xml",
    "ert9.xml",
    "ert10.xml",
    "astraestate.xml",
    "art10.xml",
    "art9.xml",
    "art8.xml",
    "art7.xml",
    "art6.xml",
    "art5.xml",
    "art4.xml",
    "art3.xml",
    "art2.xml",
    "art1.xml",
    "FBI.xml",
    "FBI2.xml",
    "FIRETRUK.xml",
    "POLICE.xml",
    "POLICE2.xml",
    "POLICE3.xml",
    "POLICET.xml",
    "rbfrs1.xml",
    "rbfrs2.xml",
    "rbfrs3.xml",
    "rbfrs4.xml",
    "rbfrs5.xml",
    "rbfrs6.xml",
    "rbfrs7.xml",
    "rbfrs8.xml",
    "rbfrs9.xml",
    "rbfrs10.xml",
    "rpt1.xml",
    "rpt2.xml",
    "rpt3.xml",
    "rpt4.xml",
    "rpt5.xml",
    "rpt6.xml",
    "rpt7.xml",
    "rpt8.xml",
    "rpt9.xml",
    "rpt10.xml",
    "scas1.xml",
    "scas2.xml",
    "scas3.xml",
    "scas4.xml",
    "scas5.xml",
    "scas6.xml",
    "scas7.xml",
    "scas8.xml",
    "scas9.xml",
    "scas10.xml",
    "SHERIFF2.xml",
    "RIOT.xml",
    "POLICEB.xml",
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