local anim8 = require('libs.anim8.anim8')

-- A class meant to unify calls for sprite loading
-- Extend for each different sprite class
local sprite_loader = {}

local player_spr, player_g

function sprite_loader:loadSprites()
  player_spr = love.graphics.newImage('sprites/robot.png')
  player_g = anim8.newGrid(96, 96, player_spr:getWidth(), player_spr:getHeight())
end

function sprite_loader:getPlayerData()
  return player_spr, player_g
end

return sprite_loader
