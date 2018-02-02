local input = {}

local input_bindings = {
  moveUp = function(player) player.kb.y = -1 end,
  moveDown = function(player) player.kb.y = 1 end,
  moveLeft = function(player) player.kb.x = -1 end,
  moveRight = function(player) player.kb.x = 1 end,
  stopUp = function(player) if player.kb.y == -1 then player.kb.y = 0 end end,
  stopDown = function(player) if player.kb.y == 1 then player.kb.y = 0 end end,
  stopLeft = function(player) if player.kb.x == -1 then player.kb.x = 0 end end,
  stopRight = function(player) if player.kb.x == 1 then player.kb.x = 0 end end,
}

-- ===== PUBLIC FUNCTIONS =====
-- The only function this module exposes
function input:handle(binding, player)
  if input_bindings[binding] == nil then
    print('Unsupported binding!', binding)
    return
    -- assert(false)
  end
  input_bindings[binding](player)
end

return input
