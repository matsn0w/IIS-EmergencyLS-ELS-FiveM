⚠️ **NOTE**: it is HIGHLY discouraged to directly download or 'clone' the resource, please download it via the *Releases* section!

# Installation

Please follow these steps to intall the EmergencyLS resource into your FiveM server:

1. Make sure your server meets all [requirements](../README.md#Requirements)
2. Download the [latest release](https://github.com/matsn0w/MISS-ELS/releases/latest)
3. Create a folder for the resource somewhere, call it anything you like (suggestion: `MISS-ELS`)
4. Extract the zip archive in that folder
5. Copy `config.example.lua` to `config.lua`
6. Edit the configuration to fit to your needs
7. Place the folder from step 2 and 3 into your resources directory on your server
8. Enable the resource in your `server.cfg` file: `ensure MISS-ELS` (or whatever you called it in step 2) or start it manually
9. Enjoy! You can now start [creating your VCF files](adding_vcfs.md)

## Upgrading

If you currently use an older version of this resource, you can update it as follows:

1. ⚠️ **Make a full backup of your configuration and VCFs!**
2. Delete all files from the resource, **except your `config.lua` and your `xmlFiles/` folder**
3. Rename your `config.lua` to `config.backup.lua`
4. Download the [latest release](https://github.com/matsn0w/MISS-ELS/releases/latest)
5. Extract the zip archive somewhere
6. Place the contents from the archive into your resource folder, alongside with the files from step 2
7. Copy `config.example.lua` to `config.lua`
8. Update `config.lua` to fit to your needs (compare it to your old configuration, but do not copy-paste it as the structure might have changed!)
9. Walk through your VCF's to see if they still comply to the standards. Any breaking change will be announced.
