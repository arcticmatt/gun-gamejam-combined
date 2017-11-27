local encoder = require('utils.encoder')
local Ent = require('entities.ent')
local Player = require('entities.player')
local commands = {}

function commands:handleAt(ents, ent_id, cmd, params, udp)
  if ents:hasEnt(ent_id) then
    ents:updateState(ent_id, cmd, params)
  else
    -- Send request for new ent
    print(string.format('Sending request for new ent with id=%d', ent_id))
    udp:send(encoder:encodeNewEnt(ent_id))
  end
end

function commands:handleNewEnt(ents, params)
  -- TODO: should Ent be abstract?
  local new_ent = ents.factory(params.type, params)
  ents:add(new_ent.id, new_ent)
end

function commands:handleRemove(ents, ent_id)
  ents:remove(ent_id)
end

function commands:handleSpawn(ent_id, params, world)
	local x, y, w, h = params.x, params.y, params.w, params.h
  print(string.format('Spawning player with id=%d at x=%d, y=%d', ent_id, x, y))
  assert(x and y and w and h)
  player = Player{x=x, y=y, w=w, h=h, id=ent_id, world=world}
  world:add(player, player:getRect())
  return player
end

return commands
