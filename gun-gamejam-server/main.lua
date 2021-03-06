local bump = require('libs.bump.bump')
local socket = require('socket')
local ents = require('entities.s_ents')
local decoder = require('utils.s_decoder')
local commands = require('commands.s_commands')
local sti = require('libs.sti.sti.init')

-- ===== Timing/game-loop stuff =====
local data, c_ip, c_port, cmd, params, dt
local time_since_last_update = 10
local broadcast_interval = 0.01
local previous_time = socket.gettime()
local previous_broadcast = socket.gettime()

-- ===== Networking variables =====
local address, port = '*', 12345

-- ===== Setup TCP stuff =====
local tcp = socket.tcp()
tcp:settimeout(0)
print(string.format('Binding tcp to %s:%d...', address, port))
tcp:bind(address, port)
tcp:listen()

-- ===== Setup UDP stuff =====
local udp = socket.udp()
udp:settimeout(0)
print(string.format('Binding udp to %s:%d...', address, port))
udp:setsockname(address, port)

-- ===== World stuff =====
local world

-- ===== Map stuff =====
local map

function love.load()
  -- Get map!
  map = sti('map/dungeon_small.lua')

  -- We need collisions
  world = bump.newWorld(16)

  for k, v in pairs(map.layers['Wall-Objects'].objects) do
    world:add(v, v.x, v.y, v.width, v.height)
    print(string.format('Adding object #%d with x=%d, y=%d, w=%d, h=%d', k, v.x, v.y, v.width, v.height))
  end

  ents:setWorld(world)
end

-- ===== Main loop =====
print 'Beginning server loop.'
function love.update(dt)
  -- Do time calculations at beginning
  time_since_last_update = time_since_last_update + dt

  -- Accept new clients
  client = tcp:accept()
  if client then
    ents:addTcp(client)
  end

  -- Check for disconnects
  ents:checkForDisconnects(udp)

  -- Update everything
  ents:update(dt)

  -- Shoot
  should_send = ents:shoot(dt)

  -- Get data and client location
  data, c_ip, c_port = udp:receivefrom()
  is_connected = data and c_ip and c_port

  if is_connected then
    ents:addClient(c_ip, c_port)

    ent_id, cmd, params = decoder:decodeData(data)
    commands:handle{
      ent_id=ent_id,
      cmd=cmd,
      params=params,
      ents=ents,
      udp=udp,
      ip=c_ip,
      port=c_port,
      dt=dt
    }
  elseif c_ip ~= 'timeout' then
    error('Unknown network error: '..tostring(msg))
  end

  if time_since_last_update > broadcast_interval or should_send then
    commands:send{ents=ents, cmd='ent_info', udp=udp}
    time_since_last_update = 0
  end

  socket.sleep(0.01)
end

-- print 'Finished server loop.'
