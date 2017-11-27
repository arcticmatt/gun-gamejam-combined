local Player = require('entities.s_player')
local encoder = require('utils.s_encoder')
local utils = require('utils.s_utils')

local commands = {}

function commands:handleSpawn(ents, udp, ip, port, id)
  local id = utils:get_unused_id(ents)
  local new_player = Player{x=200, y=200, w=64, h=64, udp=udp, id=id}
  ents:addPlayer(id, new_player, ip, port)
  new_player:sendSpawnInfo(ip, port)
end

function commands:handleMove(ents, ent_id, params, dt)
	local x, y = params.x, params.y
	assert(x and y)
  ents:move(ent_id, x, y, dt)
end

function commands:handleNewEnt(ents, params, udp, ip, port)
  if ents:hasEnt(params.ent_id) then
    print(string.format('Sending back new ent with id=%d', params.ent_id))
    local e = ents:getEnt(params.ent_id)
    udp:sendto(encoder:encodeEnt(e), ip, port)
  else
    print(string.format('Error! New ent was requested, but id=%d does not exist', params.ent_id))
  end
end

function commands:handleQuit(ents, ent_id, udp, ip, port)
  ents:handleQuit(ent_id, udp, ip, port)
end

return commands
