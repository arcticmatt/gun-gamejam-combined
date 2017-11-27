local Class  = require('libs.hump.class')
local Ent = require('entities.s_ent')
local vector = require('libs.hump.vector')
local utils = require('utils.s_utils')

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

function Player:init(p)
  Ent.init(self, p)
  self.type = utils.types.player -- OVERRIDE
  self.kb = vector(0, 0)
  self.baseVelocity = 1000
end

function Player:move(x, y, dt)
  self.kb = vector(x, y)
  self.kb = self.kb * self.baseVelocity * dt
  self.kb:trimInplace(self.baseVelocity * dt)

  -- TODO: no boundaries
  self.x, self.y = self.x + self.kb.x, self.y + self.kb.y
end

function Player:draw()
  love.graphics.rectangle('fill', self:getRect())
end

return Player
