local Class  = require("libs.hump.class")
local Ent = require("entities.s_ent")
local vector = require("libs.hump.vector")

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

function Player:init(x, y, w, h, udp, ip, port, id)
  Ent.init(self, x, y, w, h, udp, id)
  self.ip = ip
  self.port = port
  self.kb = vector(0, 0)
  self.baseVelocity = 300
end

function Player:move(x, y, dt)
  self.kb = vector(x, y)
  self.kb = self.kb * self.baseVelocity * dt
  self.kb:trimInplace(self.baseVelocity * dt)

  -- TODO: no boundaries
  self.x, self.y = self.x + self.kb.x, self.y + self.kb.y
end

function Player:draw()
  love.graphics.rectangle("fill", self:getRect())
end

return Player
