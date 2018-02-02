local Class  = require('libs.hump.class')
local Ent = require('entities.s_ent')
local utils = require('utils.s_utils')

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

function Player:init(p)
  Ent.init(self, p)
  self.type = utils.types.player -- OVERRIDE
  self.baseVelocity = 250
end

function Player:update(dt, world)
  kb = self.kb * self.baseVelocity * dt
  kb:trimInplace(self.baseVelocity * dt)

  -- TODO: no boundaries
  local x, y = self.x + kb.x, self.y + kb.y
  self.x, self.y = world:move(self, x, y,
    function(item, other)
        if other.type == utils.types.player then
          return false
        end
        return 'slide'
    end
  )
end

return Player
