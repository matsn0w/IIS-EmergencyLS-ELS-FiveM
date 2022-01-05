# EmergencyLS - Emergency Lighting System for FiveM

EmergencyLS is an all-in-one configurable Emergency Lighting System (ELS) for the popular Grand Theft Auto V (GTA V) multiplayer client called FiveM.

The server-side element restricts controls to the driver and allows the driver to activate primary, secondary & warning lighting each with individually configurable key-bindings. Welcome to the best server-sided Emergency Lighting System for FiveM!

## Key Features

* Sirens and lights synced across the entire server
* Easy configuration per vehicle
* Create your own light patterns
* Use native game sirens or use your own with [WMServerSirens](https://github.com/Walsheyy/WMServerSirens)
* A simple yet comprehensive configuration
* Support for 3 different light stages
* Support for up to 4 different sirens per vehicle

...and more!

## Installation

1. Download the latest release
2. Extract the zip archive somewhere
3. Copy `config.example.lua` and name it `config.lua`
4. Edit the configuration to fit to your needs
5. Place the folder **IIS-EmergencyLS-ELS-FiveM** into your resources directory
6. Enable the resource in your `server.cfg` file: `ensure IIS-EmergencyLS-ELS-FiveM` or start it manually
7. Make sure the `baseevents` resource from FiveM is started **before** this resource is started
8. Enjoy!

## Video Demonstration (+ Installation)

*Note that this video was made for version 1.x of this resource.*

<https://www.youtube.com/watch?v=MZnO9eIjFWA&t=54s>

## Changelog

### v2.0.0

* Added configuration option to allow passengers to control the sirens
* Added configuration option to customize indicator controls
* VCF: Added `AllowUse` flag to enable or disable the main horn
* VCF: Added `SoundSet` flag to specify a custom sound for the main horn
* Added `/extra <extra>` command to quickly toggle a vehicle extra
* Fixed `AllowEnvLight` setting not doing anything
* Fixed `AudioString` on MainHorn not doing anything
* Updated SLAXML parser to version 0.8
* Lots of code improvements and optimizations

### v1.2.0 - v1.3.0

Original releases from [Infinite Impact Solutions](https://github.com/InfImpSolutions)
