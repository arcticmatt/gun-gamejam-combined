local encoder = require('utils.s_encoder')

local ents = {
  entMap = {},
  -- Clients stores all information relevant to specific clients. This includes
  -- the ip, port, tcp connection, and ent_id of the client's player.
  clients = {}, -- 'ip:port' -> { ip = ip, port = port, tcp = tcp, player_id = ent_id }
}

-- ===== Ent methods =====
function ents:add(ent_id, ent)
  self.entMap[ent_id] = ent
end

function ents:add_many(ents)
  for k, e in pairs(ents) do
    self:add(k, e)
  end
end

function ents:remove(ent_id)
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

-- ===== Client methods =====
function ents:add_client(ip, port)
  local key = make_key(ip, port)
  local entry = self.clients[key]
  if entry and (not entry.ip or not entry.port) then
    print(string.format('Adding ip and port to existing client=%s', key))
    entry.ip = ip
    entry.port = port
  elseif not entry then
    print(string.format('Adding ip and port to new client=%s', key))
    self.clients[key] = {ip = ip, port = port}
  end
end

-- Add player to entMap and update corresponding client.
function ents:add_player(player_id, ent, ip, port)
  self:add(player_id, ent)
  local key = make_key(ip, port)
  if self.clients[key] then
    print(string.format('Adding player to existing client=%s', key))
    self.clients[key].player_id = player_id
  else
    assert(false)
  end
end

function ents:add_tcp(tcp)
  tcp:settimeout(0)
  ci, cp = tcp:getpeername()
  local key = make_key(ci, cp)
  if self.clients[key] then
    print(string.format('Adding tcp to existing client=%s', key))
    self.clients[key].tcp = tcp
  else
    print(string.format('Adding tcp with new client=%s', key))
    self.clients[key] = {ip = ip, port = port, tcp = tcp}
  end
end

function ents:remove_client(ip, port)
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
  for _, client in pairs(self.clients) do
    udp:sendto(encoder:encode_remove(ent_id), client.ip, client.port)
  end
end

function ents:check_for_disconnects(udp)
  for _, client in pairs(self.clients) do
    if client.tcp then
      l, e = client.tcp:receive()
      if e == 'closed' then
        self:handle_quit(client.player_id, udp, client.ip, client.port)
      end
    end
  end
end

-- ===== Misc =====
function ents:handle_quit(player_id, udp, ip, port)
  print(string.format('Client with player=%d at %s:%d is quitting', player_id, ip, port))
  self:remove(player_id)
  self:remove_client(ip, port)
  self:send_remove_info(player_id, udp)
end

-- ===== Helper functions =====
function make_key(ip, port)
  return ip .. port
end

return ents
