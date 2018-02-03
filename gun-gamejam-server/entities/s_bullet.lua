local Class  = require('libs.hump.class')
local Ent = require('entities.s_ent')
local utils = require('utils.s_utils')

local Bullet = Class{
  __includes = Ent -- Bullet class inherits our Ent class
}

function Bullet:init(p)
  Ent.init(self, p)
  self.type = utils.types.bullet -- OVERRIDE
  self.baseVelocity = 300
  self.owner = p.owner -- Player that shot the bullet
  assert(self.owner ~= nil)
end

function Bullet:update(dt, world)
  kb = self.kb * self.baseVelocity * dt
  kb:trimInplace(self.baseVelocity * dt)

  -- TODO: refine? this is just a placeholder
  local x, y = self.x + kb.x, self.y + kb.y
  self.x, self.y = world:move(self, x, y,
    function(item, other)
        if other.type == utils.types.bullet or other.id == self.owner.id then
          return false
        end
        return 'slide'
    end
  )
end

return Bullet
