




fx_version 'cerulean'
game 'gta5'

ui_page 'nui/index.html'

client_script{
    "@vrp/lib/utils.lua",
    "client.lua",
    "cfg.lua"
}

server_script{
    "@vrp/lib/utils.lua",
    "server.lua"
}

files{
    "nui/**/*",
    "nui/*",
}