fx_version 'cerulean'
game 'gta5'

description 'QB Job Garage - Hệ thống quản lý garage cho các nghề nghiệp'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'
