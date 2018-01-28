local utils = {}

local MAX_IDS = 10

-- ===== Helper functions =====
function utils:get_unused_id(ents)
  local id
  repeat
    math.randomseed(os.time())
    id = math.random(MAX_IDS)
  until id ~= 0 and not ents:getEnt(id)
  return id
end

function utils:printTable(t)
  for k, v in pairs(t) do
    print(k, v)
  end
end

utils.types = { ent="ENT", player="PLAYER" } -- sync with client

return utils
