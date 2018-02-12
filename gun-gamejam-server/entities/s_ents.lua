local encoder = require('utils.s_encoder')
local utils = require('utils.s_utils')

local ents = {
  entMap = {},
  -- Clients stores all information relevant to specific clients. This includes
  -- the ip, port, tcp connection, and ent_id of the client's player.
  clients = {}, -- 'ip:port' -> { ip = ip, port = port, tcp = tcp, player_id = ent_id }
  world = nil,
  nextID = 0,
}

-- ===== Local functions =====
local function makeKey(ip, port)
  return ip .. port
end

-- ===== Ent methods =====
function ents:update(dt)
  for _, e in pairs(self.entMap) do
    e:update(dt, self.world)
  end
end

function ents:shoot(dt)
  should_send = false
  for _, e in pairs(self.entMap) do
    if e.type ~= utils.types.player then goto continue end

    new_bullet = e:shoot(dt, self.nextID)
    if new_bullet == nil then goto continue end
    self:getNextID()
    self:add(new_bullet)
    should_send = true
    ::continue::
  end
  return should_send
end

function ents:setWorld(world)
  self.world = world
end

function ents:add(ent)
  assert(self.world ~= nil)
  assert(self.entMap[ent.id] == nil, "you cannot override an existing ent")
  self.entMap[ent.id] = ent
  self.world:add(ent, ent:getRect())
end

function ents:addMany(ents_to_add)
  for _, e in pairs(ents_to_add) do
    self:add(e)
  end
end

function ents:remove(ent_id)
  assert(self.world ~= nil)
  self.world:remove(self.entMap[ent_id])
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

function ents:getNextID()
  id = self.nextID
  self.nextID = id + 1
  print('got id', id)
  return id
end

-- ===== Client methods =====
function ents:addClient(ip, port)
  local key = makeKey(ip, port)
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
function ents:addPlayer(player, ip, port)
  self:add(player)
  local key = makeKey(ip, port)
  if self.clients[key] then
    print(string.format('Adding player to existing client=%s', key))
    self.clients[key].player_id = player.id
  else
    assert(false)
  end
end

function ents:addTcp(tcp)
  tcp:settimeout(0)
  ci, cp = tcp:getpeername()
  local key = makeKey(ci, cp)
  if self.clients[key] then
    print(string.format('Adding tcp to existing client=%s', key))
    self.clients[key].tcp = tcp
  else
    print(string.format('Adding tcp with new client=%s', key))
    self.clients[key] = {ip = ip, port = port, tcp = tcp}
  end
end

function ents:removeClient(ip, port)
  self.clients[makeKey(ip, port)] = nil
end

-- ===== Networking methods =====
function ents:sendRemoveInfo(ent_id, udp)
  for _, client in pairs(self.clients) do
    udp:sendto(encoder:encodeRemove(ent_id), client.ip, client.port)
  end
end

function ents:checkForDisconnects(udp)
  for _, client in pairs(self.clients) do
    if client.tcp then
      l, e = client.tcp:receive()
      if e == 'closed' then
        self:handleQuit(client.player_id, udp, client.ip, client.port)
      end
    end
  end
end

-- ===== Handling =====
function ents:handleQuit(player_id, udp, ip, port)
  print(string.format('Client with player=%d at %s:%d is quitting', player_id, ip, port))
  self:remove(player_id)
  self:removeClient(ip, port)
  self:sendRemoveInfo(player_id, udp)
end

function ents:sendEntInfo(udp)
	for _, client in pairs(self.clients) do
		local ent_info_batched = encoder:encodeEntInfoBatched(self.entMap)
		udp:sendto(ent_info_batched, client.ip, client.port)
	end
end

return ents
