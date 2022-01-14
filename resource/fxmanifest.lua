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
    'html/**.*'
}

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'lib/*.lua',
    'server/*.lua',
}
