local Class  = require('libs.hump.class')
local Ent = require('entities.s_ent')
local Bullet = require('entities.s_bullet')
local utils = require('utils.s_utils')
local vector = require('libs.hump.vector')

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

function Player:init(p)
  Ent.init(self, p)
  self.type = utils.types.player -- OVERRIDE
  self.baseVelocity = 250
  self.bullet_kb = vector(0, 0)
  self.timeSinceLastShot = 10
  self.shootingRate = 1
end

function Player:update(dt, world)
  kb = self.kb * self.baseVelocity * dt
  kb:trimInplace(self.baseVelocity * dt)

  -- TODO: no boundaries
  local x, y = self.x + kb.x, self.y + kb.y
  self.x, self.y = world:move(self, x, y,
    function(item, other)
        -- Not every ent has an owner
        if type(other.owner) == "table" then owner_id = other.owner.id else owner_id = nil end
        if other.type == utils.types.player or owner_id == self.id then
          return false
        end
        return 'slide'
    end
  )
end

function Player:shoot(dt, bullet_id)
  self.timeSinceLastShot = self.timeSinceLastShot + dt
  if self.timeSinceLastShot < self.shootingRate then return end
  if self.bullet_kb == vector(0, 0) then return end

  -- Since we're here, shoot!
  -- TODO: mess with bullet size
  self.timeSinceLastShot = 0
  -- Need to manually copy the vector
  bullet_kb = vector(self.bullet_kb.x, self.bullet_kb.y)
  return Bullet{x=self.x, y=self.y, w=10, h=10, kb=bullet_kb, udp=self.udp, id=bullet_id, owner=self}
end

return Player
