local ents = {
  entMap = {},
  clients = {}, -- 'ip:port' -> {ip = ip, port = port}
}

function ents:add(key, ent)
  self.entMap[key] = ent
end

function ents:add_many(ents)
  for k, e in pairs(ents) do
    self:add(k, e)
  end
end

function ents:has_ent(id)
  return self.entMap[id] ~= nil
end

function ents:get_ent(id)
  return self.entMap[id]
end

function ents:clear()
  self.entMap = {}
end

function ents:draw()
  for k, e in pairs(self.entMap) do
    e:draw(k)
  end
end

function ents:move(ent_id, x, y, dt)
  self.entMap[ent_id]:move(x, y, dt)
end

function ents:send_at_info()
  for _, client in pairs(self.clients) do
    for _, e in pairs(self.entMap) do
      e:send_at_info(client.ip, client.port)
    end
  end
end

function ents:add_client(ip, port)
  local key = ip .. port
  if not self.clients[key] then
    self.clients[key] = {ip = ip, port = port}
  end
end

return ents
