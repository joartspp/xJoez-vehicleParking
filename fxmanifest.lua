fx_version 'cerulean'
game 'gta5'
lua54 'yes'

developer 'xJoez <github.com/joartspp>'
version '1.0.5'

shared_script {
    '@ox_lib/init.lua',
}

client_scripts {
    'data/client/*.lua',
    'client/modules/*.lua',
    'client/command.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'data/server/*.lua',
    'server/main.lua'
}

files {
    'data/shared/*.lua'
}

dependency {
    'ox_lib',
    'oxmysql',
    'qbx_core', -- if using QBox Core
    --'qb_core' -- if using QB Core
}