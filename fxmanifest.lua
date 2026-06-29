fx_version 'cerulean'
game 'gta5'

name 'spz-speedcam'
description 'SPiceZ-Core — Speed camera network with records'
version '1.0.0'
author 'SPiceZ-Core'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/cameras.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/main.lua',
}

client_scripts {
  'config.lua',
  'client/main.lua',
}

ui_page 'ui/index.html'

files {
  'ui/index.html',
  'ui/style.css',
  'ui/script.js',
  'ui/fonts/Panchang-Variable.ttf',
}

dependencies {
  'ox_lib',
  'spz-identity',
  'oxmysql',
}

exports {
  'GetCameraRecords',
  'GetTopSpeed',
}
