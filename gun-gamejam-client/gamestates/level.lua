-- TODO: clean up imports
local bump = require('libs.bump.bump')
local Gamestate = require('libs.hump.gamestate')
local ents = require('entities.ents') -- from server
local decoder = require('utils.decoder')
local encoder = require('utils.encoder')
local sprite_loader = require('utils.sprite_loader')
local commands = require('commands.commands')
local socket = require('socket')
local sti = require('libs.sti.sti')

-- TODO add config changing for this
-- the address and port of the server
local address, port = 'localhost', 12345

local updaterate = 0.1 -- how long to wait, in seconds, before requesting an update

local t

-- ===== Game stuff =====
local level = {}
local player = nil

function level:enter()
  print('Entering level')
  -- Set up sprites
  love.graphics.setDefaultFilter('nearest', 'nearest')
  sprite_loader:loadSprites()

  -- Setting up networking
  -- TCP stuff
  print(string.format('Connecting to %s:%d...', address, port))
  tcp = assert(socket.tcp())
  tcp:settimeout(60) -- TODO: change this?
  tcp:connect(address, port)
  i, p = tcp:getsockname()
  -- UDP stuff
  udp = assert(socket.udp())
  udp:setsockname(i, p)
  iu, pu = udp:getsockname()
  assert(i == iu and p == pu) -- tcp and udp sockets have the same location
  udp:settimeout(0)
  udp:setpeername(address, port)
  math.randomseed(os.time())
  print(string.format('Connected to TCP & UDP! Client is located at %s:%d', i, p))

  send_spawn()
  player = nil

  -- t is a variable we use to help us with the update rate in love.update.
  t = 0

  -- Clear all existing ents
  ents:clear()
end

function level:update(dt)
  -- Spawn player
  if not player then
    -- print('Waiting to spawn...')

    player = receive_spawn()

    if player then
      ents:add(player.id, player)
    end

    return
  end

  -- Update player
  -- Note: this is the only ent that updates on the client (where updating means
  -- changing some variables). All other ents update entirely based on the server.
  local mouse_x, mouse_y = love.mouse.getPosition()
  player:update(dt, mouse_x, mouse_y)

  -- Increase t by the dt
	t = t + dt

  -- Send player info to server
	if t > updaterate then
    udp:send(encoder:encode_move(player))

		t = t - updaterate -- set t for the next round
	end

  repeat
    data, msg = udp:receive()

    if data then
      ent_id, cmd, params = decoder:decode_data(data)
      if cmd == 'at' then
        commands:handle_at(ents, ent_id, cmd, params, udp)
      elseif cmd == 'new_ent' then
        commands:handle_new_ent(ents, params)
      elseif cmd == 'remove' then
        commands:handle_remove(ents, ent_id)
      else
        print('unrecognised command:', cmd)
      end
    elseif msg ~= 'timeout' then
			error('Network error: '..tostring(msg))
    end
	until not data

  -- TODO: update ents
end

function level:draw()
  if player then
    player:draw()
  end

  ents:draw()
end

function level:keypressed(key)
  if key == 'escape' or key == 'q' then
    print('Quitting the game\n')
    send_quit()
    Gamestate.pop()
  end
end

-- ===== Helper functions =====
function send_spawn()
  udp:send(encoder:encode_spawn())
end

function receive_spawn()
  local data, msg = udp:receive()

  if data then
    ent_id, cmd, params = decoder:decode_data(data)
    if cmd == 'spawn' then
      return commands:handle_spawn(ent_id, params)
    end
  end
end

function send_quit()
  udp:send(encoder:encode_quit(player.id))
end

return level
