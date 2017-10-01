local utils = {}

local MAX_IDS = 10

-- ===== Helper functions =====
function utils:get_unused_id(ents)
  local id
  repeat
    math.randomseed(os.time())
    id = math.random(MAX_IDS)
  until id ~= 0 and not ents:get_ent(id)
  return id
end

return utils
