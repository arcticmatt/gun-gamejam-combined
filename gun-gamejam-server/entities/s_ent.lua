local Class = require("libs.hump.class")
local encoder = require("utils.s_encoder")

local Ent = Class{}

-- Superclass of all ents
-- TODO: refactor argument passing
function Ent:init(x, y, w, h, udp, id)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.udp = udp
  self.id = id
end

function Ent:getRect()
  return self.x, self.y, self.w, self.h
end

function Ent:draw()
  -- Do nothing by default
end

function Ent:move(x, y, dt)
  self.x = x
  self.y = y
end

function Ent:send_spawn_info(ip, port)
  print(string.format("Sending spawn info for id=%d to ip=%s, port=%s", self.id, ip, port))
  self.udp:sendto(encoder:encode_spawn(self), ip, port)
end

function Ent:send_at_info(ip, port)
  self.udp:sendto(encoder:encode_at(self), ip, port)
end

return Ent
