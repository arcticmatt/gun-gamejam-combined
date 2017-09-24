local ents = {
  entMap = {},
}

function ents:add(ent_id, entity)
  self.entMap[ent_id] = entity
end

function ents:add_many(ents)
  for k, e in pairs(ents) do
    self:add(k, e)
  end
end

function ents:has_ent(ent_id)
  return self.entMap[ent_id] ~= nil
end

function ents:get_ent(ent_id)
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

function ents:update_state(ent_id, cmd, params)
  assert(self.entMap[ent_id])
  self.entMap[ent_id]:update_state(cmd, params)
end

return ents
