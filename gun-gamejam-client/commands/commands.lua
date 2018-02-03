local encoder = require('utils.encoder')
local Ent = require('entities.ent')
local Player = require('entities.player')
local utils = require('utils.utils')

local commands = {}

-- ===== LOCAL FUNCTIONS =====
local function handleAt(p)
  if p.ents:hasEnt(p.ent_id) then
    p.ents:updateState(p.ent_id, p.cmd, p.params)
  else
    -- Send request for new ent
    print(string.format('Sending request for new ent with id=%d', p.ent_id))
    udp:send(encoder:encodeNewEnt(p.ent_id))
  end
end

local function handleNewEnt(p)
  -- TODO: should Ent be abstract?
  local new_ent = p.ents.factory(p.params.type, p.params)
  p.ents:add(new_ent)
end

local function handleRemove(p)
  p.ents:remove(p.ent_id)
end

local function handleSpawn(p)
	local x, y, w, h = p.params.x, p.params.y, p.params.w, p.params.h
  print(string.format('Spawning player with id=%d at x=%d, y=%d', p.ent_id, x, y))
  assert(x and y and w and h)
  return Player{x=x, y=y, w=w, h=h, id=p.ent_id}
end

local command_bindings = {
  at = handleAt,
  new_ent = handleNewEnt,
  remove = handleRemove,
  spawn = handleSpawn,
}

-- ===== PUBLIC FUNCTIONS =====
-- The only function this module exposes
function commands:handle(p)
  if command_bindings[p.cmd] == nil then
    print('Unsupported command!', p.cmd)
    assert(false)
  end
  return command_bindings[p.cmd](p)
end

return commands
