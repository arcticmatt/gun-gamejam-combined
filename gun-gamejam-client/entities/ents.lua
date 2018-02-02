local utils = require('utils.utils')

-- Ents go here
local Ent = require('entities.ent')
local Player = require('entities.player')

local ents = {
  entMap = {},
}

function ents:add(ent)
  self.entMap[ent.id] = ent
end

function ents:addMany(ents)
  for _, e in pairs(ents) do
    self:add(e.id, e)
  end
end

function ents:remove(ent_id)
  print(string.format('Removing ent with id=%d', ent_id))
  self.entMap[ent_id] = nil
end

function ents:hasEnt(ent_id)
  return self.entMap[ent_id] ~= nil
end

function ents:getEnt(ent_id)
  return self.entMap[ent_id]
end

function ents:clear()
  self.entMap = {}
end

function ents:draw()
  for k, e in pairs(self.entMap) do
    e:draw(k)
  end
end

function ents:updateState(ent_id, cmd, params)
  assert(self.entMap[ent_id])
  self.entMap[ent_id]:updateState(cmd, params)
end

function ents.factory(type, params)
  if type == utils.types.ent then
    return Ent(params)
  elseif type == utils.types.player then
    return Player(params)
  end
end

return ents
