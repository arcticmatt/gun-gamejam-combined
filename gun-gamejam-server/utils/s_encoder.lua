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

-- ===== Module functions =====
-- input: an ent
-- output: ent's spawn info
function encoder:encodeSpawn(ent)
  return json.encode({ent_id = ent.id, cmd = 'spawn', params = {x = ent.x, y = ent.y, w = ent.w, h = ent.h}})
end

-- input: an ent
-- output: ent's move info
function encoder:encodeAt(ent)
  return encodePosition(ent, 'at')
end

-- input: an ent
-- output: serialized ent
function encoder:encodeEnt(ent)
  -- pass work off to encoders for specific subclasses. if the type is just ent,
  -- we'll do the encoding here.
  if ent.type == utils.types.player then
    return self:encodePlayer(ent)
  end

  return json.encode({
    ent_id = ent.id,
    cmd = 'new_ent',
    params = {
      x = ent.x,
      y = ent.y,
      w = ent.w,
      h = ent.h,
      id = ent.id,
      type = ent.type,
    },
  })
end

function encoder:encodePlayer(ent)
  return json.encode({
    ent_id = ent.id,
    cmd = 'new_ent',
    params = {
      x = ent.x,
      y = ent.y,
      w = ent.w,
      h = ent.h,
      id = ent.id,
      type = ent.type,

    },
  })
end

-- input: an ent id
-- output: removal info
function encoder:encodeRemove(ent_id)
  return json.encode({ent_id = ent_id, cmd = 'remove', params = {}})
end

-- ===== Helper functions =====
function encodePosition(ent, cmd)
  return json.encode({ent_id = ent.id, cmd = cmd, params = {x = ent.x, y = ent.y}})
end

return encoder
