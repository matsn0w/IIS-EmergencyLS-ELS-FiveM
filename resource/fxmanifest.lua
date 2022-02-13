fx_version 'cerulean'
game 'gta5'

author 'matsn0w'
description 'Server-Sided Emergency Lighting System for FiveM.'
version '2.0.1'

dependencies {
    'baseevents',
    'NativeUI'
}

ui_page 'html/index.html'

files {
    'html/**.*'
}

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_script '@NativeUI/NativeUI.lua'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'lib/*.lua',
    'server/*.lua'
}
