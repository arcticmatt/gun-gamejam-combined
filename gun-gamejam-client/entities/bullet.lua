local Class  = require('libs.hump.class')
local Ent = require('entities.ent')
local utils = require('utils.utils')

local Bullet = Class{
  __includes = Ent -- Bullet class inherits our Ent class
}

function Bullet:init(p)
  Ent.init(self, p)
  self.type = utils.types.bullet -- OVERRIDE
end

function Bullet:update(dt, world)
end

return Bullet
