local Class = require('libs.hump.class')
local utils = require('utils.utils')
local vector = require('libs.hump.vector')

local Ent = Class{}

-- Superclass of all entities
function Ent:init(p)
  self.x = p.x
  self.y = p.y
  self.w = p.w
  self.h = p.h
  self.id = p.id
  self.type = utils.types.ent
  self.kb = vector(0, 0)
end

function Ent:getPosition()
  return self.x, self.y
end

function Ent:getRect()
  return self.x, self.y, self.w, self.h
end

function Ent:draw()
  -- TODO: this should probably do nothing. subclasses should contain drawing logic
  -- Draw a rectangle by default
  love.graphics.rectangle('fill', self:getRect())
end

function Ent:update(dt)
  -- Do nothing by default
end

function Ent:updateState(cmd, params)
  -- Not sure if I'm ever gonna need more than this command
  if cmd == 'ent_info' then
    self.x, self.y, self.kb = params.x, params.y, params.kb
  end
end

return Ent
