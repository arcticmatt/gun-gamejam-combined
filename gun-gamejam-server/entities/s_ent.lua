local Class = require('libs.hump.class')
local encoder = require('utils.s_encoder')
local vector = require('libs.hump.vector')
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
  if p.kb ~= nil then
    self.kb = p.kb
  else
    self.kb = vector(0,0)
  end
end

function Ent:getRect()
  return self.x, self.y, self.w, self.h
end

function Ent:update(dt, world)
  print('need to override move method!')
  assert(false)
end

function Ent:sendSpawnInfo(ip, port)
  print(string.format('Sending spawn info for id=%d to ip=%s, port=%s', self.id, ip, port))
  self.udp:sendto(encoder:encodeSpawn(self), ip, port)
end

function Ent:sendEntInfo(ip, port)
  self.udp:sendto(encoder:encodeEntInfo(self), ip, port)
end

return Ent
