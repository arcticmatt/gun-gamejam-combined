local Bullet = require('entities.s_bullet')
local utils = require('utils.s_utils')

local input = {}

local move_bindings = {
  moveUp = function(player) player.kb.y = -1 end,
  moveDown = function(player) player.kb.y = 1 end,
  moveLeft = function(player) player.kb.x = -1 end,
  moveRight = function(player) player.kb.x = 1 end,
  stopUp = function(player) if player.kb.y == -1 then player.kb.y = 0 end end,
  stopDown = function(player) if player.kb.y == 1 then player.kb.y = 0 end end,
  stopLeft = function(player) if player.kb.x == -1 then player.kb.x = 0 end end,
  stopRight = function(player) if player.kb.x == 1 then player.kb.x = 0 end end,
}

local shoot_bindings = {
  shootUp = function(player) player.bullet_kb.y = -1 end,
  shootDown = function(player) player.bullet_kb.y = 1 end,
  shootLeft = function(player) player.bullet_kb.x = -1 end,
  shootRight = function(player) player.bullet_kb.x = 1 end,
  stopShootUp = function(player) if player.bullet_kb.y == -1 then player.bullet_kb.y = 0 end end,
  stopShootDown = function(player) if player.bullet_kb.y == 1 then player.bullet_kb.y = 0 end end,
  stopShootLeft = function(player) if player.bullet_kb.x == -1 then player.bullet_kb.x = 0 end end,
  stopShootRight = function(player) if player.bullet_kb.x == 1 then player.bullet_kb.x = 0 end end,
}

local function handleMove(binding, player)
  if move_bindings[binding] == nil then return end
  move_bindings[binding](player)
end

local function handleShoot(binding, player)
  if shoot_bindings[binding] == nil then return end
  shoot_bindings[binding](player)
end

-- ===== PUBLIC FUNCTIONS =====
-- The only function this module exposes
function input:handle(binding, player)
  handleMove(binding, player)
  handleShoot(binding, player)
  -- TODO: call handleShoot
end

return input
