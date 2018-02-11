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
-- output: int, string, table, table
function decoder:decodeData(data)
  t = json.decode(data)
  return t.ent_id, t.cmd, t.params, t.payload
end

return decoder
