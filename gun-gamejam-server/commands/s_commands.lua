local Player = require('entities.s_player')
local encoder = require('utils.s_encoder')
local utils = require('utils.s_utils')

local commands = {}

function commands:handle_spawn(ents, udp, ip, port, id)
  local id = utils:get_unused_id(ents)
  local new_player = Player(400, 200, 64, 64, udp, ip, port, id)
  ents:add_player(id, new_player, ip, port)
  new_player:send_spawn_info(ip, port)
end

function commands:handle_move(ents, ent_id, params, dt)
	local x, y = params.x, params.y
	assert(x and y)
  ents:move(ent_id, x, y, dt)
end

function commands:handle_new_ent(ents, params, udp, ip, port)
  if ents:has_ent(params.ent_id) then
    print(string.format('Sending back new ent with id=%d', params.ent_id))
    local e = ents:get_ent(params.ent_id)
    udp:sendto(encoder:encode_ent(e), ip, port)
  else
    print(string.format('Error! New ent was requested, but id=%d does not exist', params.ent_id))
  end
end

function commands:handle_quit(ents, ent_id, udp, ip, port)
  ents:handle_quit(ent_id, udp, ip, port)
end

return commands
