local json = require("libs.json.json")
local Ent = require("entities.ent")

local decoder = {}

-- Note: all data is decoded from a table (encoded as a stirng) with the following shape:
-- {
--   ent_id: ...,
--   cmd: ...,
--   params: ...,
-- }

-- input: data encoded by json library
-- output: int, string, table
function decoder:decode_data(data)
  t = json.decode(data)
  return t.ent_id, t.cmd, t.params
end

return decoder
