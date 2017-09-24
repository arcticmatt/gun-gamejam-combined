Gamestate = require('libs.hump.gamestate')
level = require('gamestates.level')

-- Create our Gamestate
local menu = {}

function menu:init()
  love.graphics.setFont(love.graphics.newFont(22))
end

function menu:draw()
  love.graphics.printf('Press Enter to continue', 0,
                       love.graphics.getHeight() / 2,
                       love.graphics.getWidth(), 'center')
end

function menu:keyreleased(key, code)
  if key == 'return' then
    Gamestate.push(level)
  end
end

function menu:keypressed(key)
  if key == 'escape' or key == 'q' then
    love.event.push('quit')
  end
end

return menu
