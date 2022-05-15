fx_version 'cerulean'
game 'gta5'

description 'QB-TruckerJob'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua', -- Change client/server language
    'locales/en.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua'
}

server_script 'server/main.lua'

lua54 'yes'
