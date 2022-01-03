resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

fx_version 'bodacious'
games { 'gta5' }

author 'KJ Studios'
description 'Server-Sided Emergency Lighting System for FiveM.'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/sounds/999mode.ogg',
    'html/sounds/Beep.ogg'
}

shared_script "config.lua"

client_scripts {
    'client/vehInit.lua',
    'client/main.lua',
    'client/funcs.lua',
    'client/lights.lua',
    'client/initVehicle.lua',
}

server_scripts {
    'server/parseObjSet.lua',
    'server/parseXML.lua',
    'server/serverInit.lua',
    'server/keypress.lua'
}
