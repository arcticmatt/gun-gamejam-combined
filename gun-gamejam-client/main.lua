local Gamestate = require('libs.hump.gamestate')
local sprite_loader = require('utils.sprite_loader')
local menu = require('gamestates.menu')

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end
