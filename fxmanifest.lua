fx_version "cerulean"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
game "rdr3"

name "Native Abilities"
author "Senexis <https://github.com/Senexis>"
description "A full implementation of the truly native abilities UI"
version "1.0.0"
repository "https://github.com/Senexis/RedM-Native-Abilities"
license "GNU GPL v3"

client_scripts {
    'client/config.lua',
    'client/utils.lua',
    'client/player-state.lua',
    'client/card-logic.lua',
    'client/ui-databinding.lua',
    'client/card-renderer.lua',
    'client/event-handlers.lua',
    'client/dataview.lua',
    'client/abilities.lua'
}
