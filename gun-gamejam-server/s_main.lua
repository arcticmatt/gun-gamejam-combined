local socket = require("socket")
local ents = require("entities.s_ents")
local Player = require("entities.s_player")
local decoder = require("utils.s_decoder")
local encoder = require("utils.s_encoder")
local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('192.168.0.10', 12345)

local data, ip, port, cmd, params, dt, current_time
local broadcast_interval = 0.1
local previous_time = socket.gettime()
local previous_broadcast = socket.gettime()

local MAX_IDS = 10

-- ===== Helper functions =====
function get_unused_id()
  local id
  repeat
    math.randomseed(os.time())
    id = math.random(MAX_IDS)
  until id ~= 0 and not ents:get_ent(id)
  return id
end

-- ===== Main loop =====
print "Beginning server loop."
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

    if cmd == 'move' then
      -- TODO: validation of inputs
  		local x, y = params.x, params.y
  		assert(x and y) -- validation is better, but asserts will serve.
      ents:move(ent_id, x, y, dt)
  	elseif cmd == 'spawn' then
      -- Get unused player id
      local id = get_unused_id()
      local new_player = Player(50, 50, 32, 32, udp, ip, port, id)
      ents:add(id, new_player)
      new_player:send_spawn_info(ip, port)
    elseif cmd == 'new_ent' then
      if ents:has_ent(params.ent_id) then
        print(string.format('Sending back new ent with id=%d', params.ent_id))
        local e = ents:get_ent(params.ent_id)
        udp:sendto(encoder:encode_ent(e), ip, port)
      else
        print(string.format('Error! New ent was requested, but id=%d does not exist', params.ent_id))
      end
    else
      print("unrecognised command:", cmd)
    end
  elseif ip ~= 'timeout' then
    error("Unknown network error: "..tostring(msg))
  end

  if current_time - previous_broadcast > broadcast_interval then
    ents:send_at_info()
    previous_broadcast = current_time
  end

  previous_time = current_time
  socket.sleep(0.01)
end

print "Finished server loop."
