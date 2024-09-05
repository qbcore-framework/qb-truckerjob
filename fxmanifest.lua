fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'qwerty1Verified'
description 'Trucking job to haul cargo for money with an integrated skill system'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    'client/client.lua',
    'client/target.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/app.js',
    'html/style.css',
    'html/images/**/*.webp',
}

this_is_a_map 'yes'