local Player = require('entities.s_player')
local encoder = require('utils.s_encoder')
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
  local id = utils.getUnusedID(p.ents)
  local new_player = Player{x=200, y=200, w=64, h=64, udp=p.udp, id=id}
  p.ents:addPlayer(new_player, p.ip, p.port)
  new_player:sendSpawnInfo(p.ip, p.port)
end

local command_bindings = {
  binding = handleBinding,
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
