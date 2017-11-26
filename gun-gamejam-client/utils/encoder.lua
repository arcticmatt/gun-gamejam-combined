local json = require('libs.json.json')

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
-- output: ent's move info
function encoder:encodeMove(player)
  return json.encode({
    ent_id = player.id,
    cmd = 'move',
    params = {x = player.kb.x, y = player.kb.y},
  })
end

-- input: an ent
-- output: request for new ent
function encoder:encodeNewEnt(ent_id)
  return json.encode({
    ent_id = 0,
    cmd = 'new_ent',
    params = {ent_id = ent_id},
  })
end

-- input: ent_id
-- output: quit message
function encoder:encodeQuit(ent_id)
  return json.encode({ent_id = ent_id, cmd = 'quit', params = {}})
end

-- input: an ent
-- output: ent's spawn info
-- Note: server decides ent id and spawn position
function encoder:encodeSpawn(player)
  return json.encode({ent_id = 0, cmd = 'spawn', params = {}})
end

return encoder
