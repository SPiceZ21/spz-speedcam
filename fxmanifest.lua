fx_version 'cerulean'
game 'gta5'

name 'spz-speedcam'
description 'SPiceZ-Core — Speed camera network with records'
version '1.4.1'
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
    '@spz-hud/shim.lua',   -- NUI goes through spz-hud
  'config.lua',
  'client/main.lua',
  'client/blips.lua',
}

-- ui_page 'ui/index.html'  -- drawn by spz-hud now (web/public/apps/spz-speedcam); uncomment + drop the shim to roll back

-- UI files are not shipped from here: spz-hud serves this resource's page
-- (synced from ui/ by spz-hud/tools/sync-apps.mjs).

dependencies {
    'spz-hud',
  'ox_lib',
  'spz-core',
  'spz-identity',
  'oxmysql',
}

