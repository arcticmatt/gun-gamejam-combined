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

-- ===== LOCAL VARIABLES =====
-- TODO add config changing for this
-- the address and port of the server
local address, port = 'localhost', 12345

local updaterate = 0.1 -- how long to wait, in seconds, before requesting an update

local t

local level = {}
local player = nil

local map
local PLAYER_LAYER = 'players'

-- ===== INPUT STUFF =====
local keysDown = {
  up = "shootUp",
  down = "shootDown",
  left = "shootLeft",
  right = "shootRight",
  w = "moveUp",
  s = "moveDown",
  a = "moveLeft",
  d = "moveRight",
}

local keysReleased = {
  up = "stopShootUp",
  down = "stopShootDown",
  left = "stopShootLeft",
  right = "stopShootRight",
  w = "stopUp",
  s = "stopDown",
  a = "stopLeft",
  d = "stopRight",
}

function love.keypressed(k)
  local binding = keysDown[k]
  if udp == nil or binding == nil or player == nil then return end
  udp:send(encoder:encodeBinding(player, binding))
end
function love.keyreleased(k)
  local binding = keysReleased[k]
  if udp == nil or binding == nil or player == nil then return end
  udp:send(encoder:encodeBinding(player, binding))
end

-- ===== LOCAL FUNCTIONS =====
local function receiveFromServer()
  t = socket.gettime()
  repeat
    data, msg = udp:receive()

    if data then
      commands:handle{ents=ents, udp=udp, data=data}
    elseif msg ~= 'timeout' then
			error('Network error: '..tostring(msg))
    end
    -- print(string.format("loop took %f seconds", socket.gettime() - t))
	until not data
  -- print(string.format("receiveFromServer ran for %f seconds", socket.gettime() - t))
end

local function receiveSpawn()
  local data, msg = udp:receive()

  if data then
    return commands:handle{data=data}
  end
end

local function sendSpawn()
  udp:send(encoder:encodeSpawn())
end

local function sendQuit()
  udp:send(encoder:encodeQuit(player.id))
end

-- ===== GAMESTATE METHODS =====
function level:enter()
  -- Get map!
  map = sti('map/dungeon_small.lua')
  map.layers['Wall-Objects'].visible = false

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

  sendSpawn()
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

    player = receiveSpawn()

    if player then
      ents:add(player)
    end

    return
  end

  -- Update player. Needed for animation
  player:update(dt)

  receiveFromServer()
end

-- NOTE: drawing order matters
-- the map should be first, as everything else is draw on top
-- we always want the client's player to be draw OVER all the other players,
-- which explains the remaining order
function level:draw()
  map:draw()

  ents:draw()

  if player then
    player:draw()
  end
end

function level:keypressed(key)
  if key == 'escape' or key == 'q' then
    print('Quitting the game\n')
    sendQuit()
    Gamestate.pop()
  end
end

return level
