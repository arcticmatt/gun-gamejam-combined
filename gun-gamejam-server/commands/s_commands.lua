local Player = require('entities.s_player')
local encoder = require('utils.s_encoder')
local utils = require('utils.s_utils')
local input = require('commands.s_input')

local commands = {}

-- ===== LOCAL FUNCTIONS =====
local function handleBinding(p)
	ent = p.ents:getEnt(p.ent_id)
	if ent == nil then return end
	input:handle(p.params.binding, ent)
end

local function handleNewEnt(p)
  if p.ents:hasEnt(p.params.ent_id) then
    print(string.format('Sending back new ent with id=%d', p.params.ent_id))
    local e = p.ents:getEnt(p.params.ent_id)
    p.udp:sendto(encoder:encodeEnt(e), p.ip, p.port)
  else
    print(string.format('Error! New ent was requested, but id=%d does not exist', p.params.ent_id))
  end
end

local function handleQuit(p)
  p.ents:handleQuit(p.ent_id, p.udp, p.ip, p.port)
end

local function handleSpawn(p)
  local id = utils.getUnusedID(p.ents)
  local new_player = Player{x=200, y=200, w=64, h=64, udp=p.udp, id=id}
  p.ents:addPlayer(new_player, p.ip, p.port)
  new_player:sendSpawnInfo(p.ip, p.port)
end

local command_bindings = {
  binding = handleBinding,
  move = handleMove,
  new_ent = handleNewEnt,
  quit = handleQuit,
  spawn = handleSpawn,
}

-- ===== PUBLIC FUNCTIONS =====
-- The only function this module exposes
function commands:handle(p)
  if command_bindings[p.cmd] == nil then
    print('Unsuppported command!', p.cmd)
    assert(false)
  end
  return command_bindings[p.cmd](p)
end

return commands
