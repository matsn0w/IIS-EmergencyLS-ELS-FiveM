Config = {}

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

-- You can make the flashing high beams brighter. Set to 1.0 for GTA default
Config.HighBeamIntensity = 5.0

-- Whether vehicle passengers are allowed to control the lights and sirens
Config.AllowPassengers = false

-- Whether you can toggle the siren, even when the lights are out
Config.SirenAlwaysAllowed = false

-- Whether vehicle indicator control should be enabled
Config.Indicators = true

-- Enables a short honk when a siren is activated
Config.HornBlip = true

-- Enables a short beep when a light stage or siren is activated
Config.Beeps = false

-- Duration for the warning beep (in seconds)
-- Should be equal to the WarningBeep.ogg file
-- Only change this if you replace the audio file with your own
Config.WarningBeepDuration = 2.0

-- Enables controller support for controlling the primary light stage and the sirens
-- DPAD_LEFT = toggle primary lights
-- DPAD_DOWN = toggle siren 1
-- B = activate next siren
Config.ControllerSupport = true
