# Installation

Please follow these steps to intall the EmergencyLS resource into your FiveM server:

1. Download the [latest release](https://github.com/matsn0w/MISS-ELS/releases)
2. Extract the zip archive somewhere
3. Copy `config.example.lua` to `config.lua`
4. Edit the configuration to fit to your needs
5. Place the folder **IIS-EmergencyLS-ELS-FiveM** into your resources directory
6. Enable the resource in your `server.cfg` file: `ensure IIS-EmergencyLS-ELS-FiveM` or start it manually
7. Make sure your server meets all [requirements](../README.md#Requirements)
8. Enjoy!

## Upgrading

If you currently use an older version of this resource, you can update it as follows:

1. **Make a full backup of the resource**
2. Delete all files from the resource, except your `config.lua` and your `xmlFiles/` folder
3. Rename your `config.lua` to `config.backup.lua`
4. Download the [latest release](https://github.com/matsn0w/MISS-ELS/releases)
5. Extract the zip archive somewhere
6. Place the contents from the archive into your resource folder, alongside with the files from step 2
7. Copy `config.example.lua` to `config.lua`
8. Update `config.lua` to fit to your needs (compare it to your old configuration, but do not copy-paste it as the structure might have changed!)
9. Walk through your VCF's to see if they still comply to the standards. Any breaking change will be announced in this readme.
