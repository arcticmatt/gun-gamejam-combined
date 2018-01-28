local json = require('libs.json.json')

local encoder = {}

-- Note: all data is encoded into a table with the following shape:
-- {
--   ent_id: ...,
--   cmd: ...,
--   params: ...,
-- }

-- ===== Module functions =====
-- input: a binding that corresponds to a key press or relase
-- output: request to process the binding
function encoder:encodeBinding(player, binding)
  return json.encode({
    ent_id = player.id,
    cmd = 'binding',
    params = {binding = binding},
  })
end

-- TODO: deprecate?
-- input: an ent
-- output: request to move the ent
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
-- output: request to quit
function encoder:encodeQuit(ent_id)
  return json.encode({ent_id = ent_id, cmd = 'quit', params = {}})
end

-- input: an ent
-- output: request to spawn an ent
-- Note: server decides ent id and spawn position
function encoder:encodeSpawn(player)
  return json.encode({ent_id = 0, cmd = 'spawn', params = {}})
end

return encoder
