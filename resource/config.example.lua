Config = {}

-- Add your VCF files here
Config.ELSFiles = {
    'police.xml',
    'police2.xml',
    'ambulance.xml',
    'someothervcf.xml',
}

-- If you are using WM Server Sirens, uncomment below
-- See https://github.com/Walsheyy/WMServerSirens
Config.AudioBanks = {
    -- 'DLC_WMSIRENS\\SIRENPACK_ONE',
}

-- Change these values to tweak the light reflections around your vehicle
Config.EnvironmentalLights = {
    Range = 80.0, -- how far the light reaches
    Intensity = 1.0, -- how intense the light source is
}

-- Whether vehicle passengers are allowed to control the lights and sirens
Config.AllowPassengers = false

-- Whether vehicle indicator control should be enabled
-- The indicators are controlled with arrow left, right and down on your keyboard
Config.Indicators = true

-- Enables a short honk when a siren is activated
Config.HornBlip = true

-- Enables a short beep when a light stage or siren is activated
Config.Beeps = false

-- Enables controller support for controlling the primary light stage and the sirens
-- DPAD_LEFT = toggle primary lights
-- DPAD_DOWN = toggle siren 1
-- B = activate next siren
Config.ControllerSupport = true

-- Sets key binds for various actions
-- See https://docs.fivem.net/docs/game-references/controls for a list of codes
Config.KeyBinds = {
    PrimaryLights = 85, -- Q
    SecondaryLights = 311, -- K
    MiscLights = 182, -- L
    ActivateSiren = 19, -- LEFT ALT
    NextSiren = 45, -- R
    Siren1 = 157, -- 1
    Siren2 = 158, -- 2
    Siren3 = 160, -- 3
    Siren4 = 164, -- 4
    IndicatorLeft = 174, -- ARROW LEFT
    IndicatorRight = 175, -- ARROW RIGHT
    IndicatorHazard = 173, -- ARROW DOWN
}
