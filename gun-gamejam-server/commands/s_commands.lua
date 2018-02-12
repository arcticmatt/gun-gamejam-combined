local Player = require('entities.s_player')
local utils = require('utils.s_utils')
local input = require('commands.s_input')

local commands = {}

-- ===== LOCAL HANDLE FUNCTIONS =====
local function handleBinding(p)
	ent = p.ents:getEnt(p.ent_id)
	if ent == nil then return end
	input:handle(p.params.binding, ent)
end

local function handleQuit(p)
  p.ents:handleQuit(p.ent_id, p.udp, p.ip, p.port)
end

local function handleSpawn(p)
  local id = p.ents:getNextID()
  local new_player = Player{x=200, y=200, w=64, h=64, udp=p.udp, id=id}
  p.ents:addPlayer(new_player, p.ip, p.port)
  new_player:sendSpawnInfo(p.ip, p.port)
end

local handle_bindings = {
  binding = handleBinding,
  quit = handleQuit,
  spawn = handleSpawn,
}

-- ===== LOCAL SEND FUNCTIONS =====
local function sendEntInfo(p)
	p.ents:sendEntInfo(p.udp)
end

local send_bindings = {
  ent_info = sendEntInfo,
}

-- ===== PUBLIC FUNCTIONS =====
function commands:handle(p)
  if handle_bindings[p.cmd] == nil then
    print('Unsuppported handle command!', p.cmd)
    assert(false)
  end
  return handle_bindings[p.cmd](p)
end

function commands:send(p)
  if send_bindings[p.cmd] == nil then
    print('Unsuppported send command!', p.cmd)
    assert(false)
  end
  return send_bindings[p.cmd](p)
end

return commands
