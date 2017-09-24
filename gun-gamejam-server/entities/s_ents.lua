local encoder = require('utils.s_encoder')

local ents = {
  entMap = {},
  clients = {}, -- 'ip:port' -> {ip = ip, port = port}
}

function ents:add(ent_id, ent)
  self.entMap[ent_id] = ent
end

function ents:add_many(ents)
  for k, e in pairs(ents) do
    self:add(k, e)
  end
end

function ents:remove(ent_id)
  print(string.format('Removing ent with id=%d', ent_id))
  self.entMap[ent_id] = nil
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

function ents:move(ent_id, x, y, dt)
  self.entMap[ent_id]:move(x, y, dt)
end

function ents:add_client(ip, port)
  local key = make_key(ip, port)
  if not self.clients[key] then
    self.clients[key] = {ip = ip, port = port}
  end
end

function ents:remove_client(ip, port)
  print(string.format('Removing client with ip=%s, port=%s', ip, port))
  self.clients[make_key(ip, port)] = nil
end

-- ===== Networking methods =====
function ents:send_at_info()
  for _, client in pairs(self.clients) do
    for _, e in pairs(self.entMap) do
      e:send_at_info(client.ip, client.port)
    end
  end
end

function ents:send_remove_info(ent_id, udp)
  print(string.format('Sending remove command for id=%d to all clients', ent_id))
  for _, client in pairs(self.clients) do
    udp:sendto(encoder:encode_remove(ent_id), client.ip, client.port)
  end
end

-- ===== Helper functions =====
function make_key(ip, port)
  return ip .. port
end

return ents
