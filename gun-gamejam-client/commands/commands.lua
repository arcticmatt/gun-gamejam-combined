local decoder = require('utils.decoder')
local encoder = require('utils.encoder')
local Ent = require('entities.ent')
local Player = require('entities.player')
local utils = require('utils.utils')

local commands = {}

-- ===== LOCAL FUNCTIONS =====
local function union(t1, t2)
  new_t = {}
  for k, v in pairs(t1) do new_t[k] = v end
  for k, v in pairs(t2) do new_t[k] = v end
  return new_t
end

local function handleBatchedInfo(p)
  assert(p.payload ~= nil)
  for _, cmd_table in pairs(p.payload) do
    cmd_table.ents = p.ents
    commands:handle(cmd_table)
  end
end

local function handleEntInfo(p)
  if p.ents:hasEnt(p.ent_id) then
    -- Update existing ent
    p.ents:updateState(p.ent_id, p.cmd, p.params)
  else
    -- Add new ent
    local new_ent = p.ents.factory(p.params.type, p.params)
    p.ents:add(new_ent)
  end
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
  batched_info = handleBatchedInfo,
  ent_info = handleEntInfo,
  remove = handleRemove,
  spawn = handleSpawn,
}

-- ===== PUBLIC FUNCTIONS =====
-- The only function this module exposes
function commands:handle(p)
  data_params = decoder:decodeData(p.data)
  p = union(p, data_params)
  p.data = nil

  if command_bindings[p.cmd] == nil then
    print('Unsupported command!', p.cmd)
    assert(false)
  end

  return command_bindings[p.cmd](p)
end

return commands
