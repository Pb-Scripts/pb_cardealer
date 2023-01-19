fx_version 'cerulean'
game 'gta5'

description 'Pbtm Car Dealer'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}

client_scripts {
    'config.lua',
    'client/client.lua',
    'client/utils.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_script '@packmaps/src/c_00.lua'