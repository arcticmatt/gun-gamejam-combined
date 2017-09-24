local Class  = require("libs.hump.class")
local Ent = require("entities.ent")
local vector = require("libs.hump.vector")

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

local directions = {up="up", down="down", left="left", right="right"}

function Player:init(p)
  Ent.init(self, p)
  -- All we need is input. Everything else on server
  self.kb = vector(0, 0)
end

-- Love function
function Player:update(dt)
  self:getInputs()
end

-- Our function
function Player:update_state(cmd, params)
  if cmd == 'at' then
    self.x, self.y = params.x, params.y
  end
end

function Player:draw()
  love.graphics.rectangle("fill", self:getRect())
end

-- Populates the input array with the keys that the player is pressing down
function Player:getInputs()
  -- Reset velocity input vector
  self.kb = vector(0, 0)
  if love.keyboard.isDown(directions.up) then self.kb.y = self.kb.y - 1; end
  if love.keyboard.isDown(directions.down) then self.kb.y = self.kb.y + 1; end
  if love.keyboard.isDown(directions.left) then self.kb.x = self.kb.x - 1; end
  if love.keyboard.isDown(directions.right) then self.kb.x = self.kb.x + 1; end

  return self.kb
end

return Player
