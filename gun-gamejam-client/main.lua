Gamestate      = require("libs.hump.gamestate")
local menu     = require("gamestates.menu")

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end

function love.keypressed(key)
  if key == "escape" or key == "q" then
    love.event.push("quit")
  end
end
