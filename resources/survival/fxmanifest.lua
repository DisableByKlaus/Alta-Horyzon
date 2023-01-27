fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'web/index.html'

client_scripts {
	'@vrp/lib/utils.lua',
	'config/*',
	'client/*'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'config/*',
	'server/*'
}

files {
    'web/*',
	'web/**/*'
}

escrow_ignore {
	'config/*',
}