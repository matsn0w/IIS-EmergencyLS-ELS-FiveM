fx_version 'cerulean'
games { 'gta5' }

author 'KJ Studios and matsn0w'
description 'Server-Sided Emergency Lighting System for FiveM.'
version '2.0.0'

dependencies {
    'baseevents'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/sounds/999mode.ogg',
    'html/sounds/Beep.ogg'
}

shared_scripts {
    'config.lua',
    'shared/funcs.lua'
}

client_scripts {
    'client/init.lua',
    'client/main.lua',
    'client/lights.lua',
    'client/commands.lua'
}

server_scripts {
    'lib/SLAXML.lua',

    'server/init.lua',
    'server/keypress.lua',
    'server/parseVCF.lua'
}
