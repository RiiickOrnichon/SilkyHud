fx_version "cerulean"
game "gta5"

ui_page 'html/Silky.html'

files {
	'html/Silky.html',
	'html/main.js',
	'html/style.css',
	'html/logo.png',
}

shared_script {
	'shared/*.lua',
}

client_scripts {
	"client/*.lua",
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"server/*.lua",
}
