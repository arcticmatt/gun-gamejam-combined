Gamestate      = require('libs.hump.gamestate')
local menu     = require('gamestates.menu')

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end
