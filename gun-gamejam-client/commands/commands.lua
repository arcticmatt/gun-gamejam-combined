local encoder = require('utils.encoder')
local Ent = require('entities.ent')
local Player = require('entities.player')
local commands = {}

function commands:handle_at(ents, ent_id, cmd, params, udp)
  if ents:has_ent(ent_id) then
    ents:update_state(ent_id, cmd, params)
  else
    -- Send request for new ent
    print(string.format('Sending request for new ent with id=%d', ent_id))
    udp:send(encoder:encode_new_ent(ent_id))
  end
end

function commands:handle_new_ent(ents, params)
  -- TODO: refactor to use subclasses? should Ent be abstract?
  -- e.g. for new players, we should make a new Player object, not a new Ent
  local new_ent = ents.factory(params.type, params)
  ents:add(new_ent.id, new_ent)
end

function commands:handle_remove(ents, ent_id)
  ents:remove(ent_id)
end

function commands:handle_spawn(ent_id, params)
	local x, y, w, h = params.x, params.y, params.w, params.h
  print(string.format('Spawning player with id=%d at x=%d, y=%d', ent_id, x, y))
  assert(x and y and w and h)
  return Player{x=x, y=y, w=w, h=h, id=ent_id}
end

return commands
