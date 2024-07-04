fx_version 'cerulean'
game 'gta5'
lua54 'yes'

developer 'xJoez <github.com/joartspp>'
version '1.0.0'

shared_script {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'data/client/*.lua',
    'client/modules/*.lua',
    'client/command.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'data/server/*.lua',
    'server/modules/*.lua',
    'server/main.lua'
}

files {
    'data/shared/*.lua'
}

dependency {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    --'qb_core'
}