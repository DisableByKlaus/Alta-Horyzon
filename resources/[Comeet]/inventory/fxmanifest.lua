fx_version 'adamant'

game 'gta5'
author 'Lucca.#1294'
description 'https://discord.gg/4YDS7mW6UE'
version '1.1.0'

server_scripts {
	'@vrp/lib/utils.lua',
	"server/*.lua",
	'config.lua',
	'usables.lua',
}
client_scripts {
	'@vrp/lib/utils.lua',
	"client/*.lua",
	'config.lua',
	'usables_client.lua'
}
ui_page {
	'ui/index.html'
}
files {
	'ui/index.html',
	'ui/*.css',
	'ui/recipes.js',
	'ui/assets/js/*.js',
	'ui/assets/images/items/*.png',
	'ui/assets/images/items/*.jpg',
	'ui/assets/images/geral/*.png',
	'ui/assets/images/geral/*.svg',
	'ui/assets/cloth/*.png',
	'ui/assets/font/*ttf'
}