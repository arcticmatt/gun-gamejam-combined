local Class = require('libs.hump.class')
local encoder = require('utils.s_encoder')
local utils = require('utils.s_utils')

local Ent = Class{}

-- Superclass of all ents
-- TODO: refactor argument passing
function Ent:init(p)
  self.x = p.x
  self.y = p.y
  self.w = p.w
  self.h = p.h
  self.udp = p.udp
  self.id = p.id
  self.type = utils.types.ent
end

function Ent:getRect()
  return self.x, self.y, self.w, self.h
end

function Ent:draw()
  -- Do nothing by default
end

function Ent:move(x, y, dt, world)
  self.x = x
  self.y = y
end

function Ent:sendSpawnInfo(ip, port)
  print(string.format('Sending spawn info for id=%d to ip=%s, port=%s', self.id, ip, port))
  self.udp:sendto(encoder:encodeSpawn(self), ip, port)
end

function Ent:sendAtInfo(ip, port)
  self.udp:sendto(encoder:encodeAt(self), ip, port)
end

return Ent
