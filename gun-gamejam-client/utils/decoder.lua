local json = require('libs.json.json')
local Ent = require('entities.ent')

local decoder = {}

-- Note: all data is decoded from a table (encoded as a stirng) with the following shape:
-- {
--   ent_id: ...,
--   cmd: ...,
--   params: ...,
--   payload: ...,
-- }

-- input: data encoded by json library
function decoder:decodeData(data)
  if data == nil then return {} end
  t = json.decode(data)
  return {
    ent_id=t.ent_id,
    cmd=t.cmd,
    params=t.params,
    payload=t.payload
  }
end

return decoder
