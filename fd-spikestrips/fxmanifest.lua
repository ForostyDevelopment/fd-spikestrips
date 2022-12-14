fx_version 'cerulean'
game 'gta5'

author "forosty#1472"
description 'Spikestrips'
version '1.0.0'


client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
    'client/*.lua'
}

server_script 'server/*.lua'

shared_script {'config.lua'
}

dependency 'qb-target'

lua54 'yes'