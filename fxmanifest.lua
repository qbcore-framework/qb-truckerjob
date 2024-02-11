fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Allows players to restock stores for money'
version '1.2.0'

shared_scripts {
	'@qb-core/shared/locale.lua',
	'config.lua',
	'locales/en.lua',
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}
