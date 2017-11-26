local socket = require('socket')
local ents = require('entities.s_ents')
local decoder = require('utils.s_decoder')
local commands = require('commands.s_commands')

-- ===== Timing/game-loop stuff =====
local data, c_ip, c_port, cmd, params, dt, current_time
local broadcast_interval = 0.05
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

-- ===== Main loop =====
print 'Beginning server loop.'
while true do
  -- Do time calculations at beginning
  current_time = socket.gettime()
  dt = current_time - previous_time

  -- Accept new clients
  client = tcp:accept()
  if client then
    ents:addTcp(client)
  end

  -- Check for disconnects
  ents:checkForDisconnects(udp)

  -- Get data and client location
  data, c_ip, c_port = udp:receivefrom()
  is_connected = data and c_ip and c_port

  if is_connected then
    ents:addClient(c_ip, c_port)

    ent_id, cmd, params = decoder:decodeData(data)

    if cmd == 'spawn' then
      commands:handleSpawn(ents, udp, c_ip, c_port)
  	elseif cmd == 'move' then
      commands:handleMove(ents, ent_id, params, dt)
    elseif cmd == 'new_ent' then
      commands:handleNewEnt(ents, params, udp, c_ip, c_port)
    elseif cmd == 'quit' then
      commands:handleQuit(ents, ent_id, udp, c_ip, c_port)
    else
      print('unrecognised command:', cmd)
    end
  elseif c_ip ~= 'timeout' then
    error('Unknown network error: '..tostring(msg))
  end

  if current_time - previous_broadcast > broadcast_interval then
    ents:sendAtInfo()
    previous_broadcast = current_time
  end

  previous_time = current_time
  socket.sleep(0.01)
end

print 'Finished server loop.'
