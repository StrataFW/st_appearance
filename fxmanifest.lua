fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'st_appearance'
author 'Strata Framework'
description 'Strata appearance editor — clothing, hair, face, tattoos, outfits, presets, wardrobe, uniforms, sharing.'
version '1.0.0'
repository 'https://github.com/StrataFW/st_appearance'

-- Originally based on juddlie/juddlie_appearance (https://github.com/juddlie/juddlie_appearance).
-- Heavily edited — ox_core-only bridge, Strata nui-kit, feature cull, faction uniforms
-- + wardrobe slots added, server-side validation hardened, English-only, full LuaLS
-- annotations, flat layout. Core editor surface and clothing/tattoo data trace to juddlie.
credits 'Originally based on juddlie/juddlie_appearance by juddlie'

ui_page 'web/dist/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/types.lua',
    'shared/logger.lua',
    'shared/locale.lua',
    'shared/security.lua',
    'shared/blacklist.lua',
    'shared/data.lua',
    'shared/tattoos.lua',
    'config.lua',
}

client_scripts {
    'client/framework.lua',
    'client/nui.lua',
    'client/ped.lua',
    'client/camera.lua',
    'client/animation.lua',
    'client/menu.lua',
    'client/zones.lua',
    'client/interaction.lua',
    'client/sharing.lua',
    'client/wardrobe.lua',
    'client/uniforms.lua',
    'client/admin.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@st_log/lib/init.lua',
    'server/framework.lua',
    'server/db.lua',
    'server/cache.lua',
    'server/sharing.lua',
    'server/wardrobe.lua',
    'server/main.lua',
}

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'web/dist/logo/*',
    'client/framework.lua',
    'client/interaction.lua',
    'locales/*.json',
}

dependencies {
    'ox_lib',
    'oxmysql',
}
