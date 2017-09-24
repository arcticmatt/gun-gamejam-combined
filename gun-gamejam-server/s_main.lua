local socket = require('socket')
local ents = require('entities.s_ents')
local decoder = require('utils.s_decoder')
local commands = require('commands.commands')
local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('*', 12345)

local data, ip, port, cmd, params, dt, current_time
local broadcast_interval = 0.1
local previous_time = socket.gettime()
local previous_broadcast = socket.gettime()

-- ===== Main loop =====
print 'Beginning server loop.'
while true do
  -- Do time calculations at beginning
  current_time = socket.gettime()
  dt = current_time - previous_time

  -- Get data and client location
  data, ip, port = udp:receivefrom()
  is_connected = data and ip and port

  if is_connected then
    ents:add_client(ip, port)

    ent_id, cmd, params = decoder:decode_data(data)

    if cmd == 'spawn' then
      commands:handle_spawn(ents, udp, ip, port)
  	elseif cmd == 'move' then
      commands:handle_move(ents, ent_id, params, dt)
    elseif cmd == 'new_ent' then
      commands:handle_new_ent(ents, params, udp, ip, port)
    elseif cmd == 'quit' then
      commands:handle_quit(ents, ent_id, udp, ip, port)
    else
      print('unrecognised command:', cmd)
    end
  elseif ip ~= 'timeout' then
    error('Unknown network error: '..tostring(msg))
  end

  if current_time - previous_broadcast > broadcast_interval then
    ents:send_at_info()
    previous_broadcast = current_time
  end

  previous_time = current_time
  socket.sleep(0.01)
end

print 'Finished server loop.'
