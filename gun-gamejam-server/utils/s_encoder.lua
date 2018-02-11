-- TODO: make a separate library, so client and server don't repeat
local json = require('libs.json.json')
local utils = require('utils.s_utils')

local encoder = {}

-- Note: all data is encoded into a table with the following shape:
-- {
--   ent_id: ...,
--   cmd: ...,
--   params: ...,
-- }
-- We don't really need to send the ent_id back to the client (except maybe
-- for assertions), but we do it for consistency.

-- ===== LOCAL FUNCTIONS =====
-- input: an ent
-- output: a table representing the ent's information
local function getEntTable(ent, cmd)
  return {
    ent_id = ent.id,
    cmd = cmd,
    params = {
      x = ent.x,
      y = ent.y,
      w = ent.w,
      h = ent.h,
      id = ent.id,
      type = ent.type,
      kb = ent.kb
    },
  }
end

-- input: an ent
-- output: serialized ent
local function encodeEnt(ent, cmd)
  return json.encode(getEntTable(ent, cmd))
end

local function encodeEnts(ent_map, cmd)
  local batched_info = {}
  for ent_id, ent in pairs(ent_map) do
    batched_info[tostring(ent_id)] = getEntTable(ent, cmd)
  end
  return json.encode({
    ent_id = -1,
    cmd = 'batched_info',
    params = {},
    payload = batched_info,
  })
end

-- ===== MODULE FUNCTIONS =====
-- input: an ent
-- output: ent's spawn info
function encoder:encodeSpawn(ent)
  return encodeEnt(ent, 'spawn')
end

-- input: an ent
-- output: ent's info (location, velocity, etc.)
function encoder:encodeEntInfo(ent)
  return encodeEnt(ent, 'ent_info')
end

function encoder:encodeEntInfoBatched(ents)
  return encodeEnts(ents, 'ent_info')
end

-- input: an ent id
-- output: removal info
function encoder:encodeRemove(ent_id)
  return json.encode({ent_id = ent_id, cmd = 'remove', params = {}})
end

return encoder
