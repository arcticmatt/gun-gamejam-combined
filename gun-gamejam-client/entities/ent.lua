local Class = require("libs.hump.class")

local Ent = Class{}

-- Superclass of all entities
function Ent:init(p)
  self.x = p.x
  self.y = p.y
  self.w = p.w
  self.h = p.h
  self.id = p.id
end

function Ent:getRect()
  return self.x, self.y, self.w, self.h
end

function Ent:draw()
  -- TODO: this should probably do nothing. subclasses should contain drawing logic
  -- Draw a rectangle by default
  love.graphics.rectangle("fill", self:getRect())
end

function Ent:update(dt)
  -- Do nothing by default
end

function Ent:update_state(cmd, params)
  -- TODO: again, this should be abstract. for now, just want to test with hacky shit
  if cmd == 'at' then
    self.x, self.y = params.x, params.y
  end
end

return Ent
