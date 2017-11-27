local Class = require('libs.hump.class')
local Ent = require('entities.ent')
local vector = require('libs.hump.vector')
local sprite_loader = require('utils.sprite_loader')
local anim8 = require('libs.anim8.anim8')
local utils = require('utils.utils')

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

-- ===== LOCAL VARS =====
local dw, dh
local facing_left = false
local spr, idle_anim, run_anim
local input = {up='up', down='down', left='left', right='right'}
-- 8 direction "sections". I.e. player can face 8 possible directions. Direction
-- is just for looks/animation, at least for now. In the future, we might
-- add interactions (e.g. table flip) that are direction based.
local direction = {
  up='up',
  up_right='up_right',
  right='right',
  down_right='down_right',
  down ='down',
  down_left ='down_left',
  left ='left',
  up_left ='up_left',
}
local quadrant = {
  first='first',    -- upper right
  second='second',  -- upper left
  third='third',    -- lower left
  fourth='fourth',  -- lower right
}
local state
local states = {idle=0, run=1}

-- ===== LOCAL FUNCTIONS =====
local function getDirection(angle)
  -- Hardcoded is kinda ugly, but easy to read
  if angle >= 337.5 or angle < 22.5 then
    return direction.right
  elseif angle >= 22.5 and angle < 67.5 then
    return direction.up_right
  elseif angle >= 67.5 and angle < 112.5 then
    return direction.up
  elseif angle >= 112.5 and angle < 157.5 then
    return direction.up_left
  elseif angle >= 157.5 and angle < 202.5 then
    return direction.left
  elseif angle >= 202.5 and angle < 247.5 then
    return direction.down_left
  elseif angle >= 247.5 and angle < 292.5 then
    return direction.down
  elseif angle >= 292.5 and angle < 337.5 then
    return direction.down_right
  end

  assert(false)
end

local function getQuadrant(mouse_x, mouse_y, player_x, player_y)
  if mouse_x == player_x and mouse_y == player_y then
    assert(false)
  end

  local dx = mouse_x > player_x
  local dy = mouse_y < player_y  -- coordinate system is top right

  if dx and dy then return quadrant.first
  elseif dy then return quadrant.second
  elseif dx then return quadrant.fourth
  else return quadrant.third
  end
end

local function getAngle(mouse_x, mouse_y, player_x, player_y)
  if mouse_x == player_x and mouse_y == player_y then
    assert(false)
  end

  local dx, dy = math.abs(mouse_x - player_x), math.abs(mouse_y - player_y)
  local y_over_x = math.deg(math.atan(dy / dx))
  local x_over_y = math.deg(math.atan(dx / dy))
  quad = getQuadrant(mouse_x, mouse_y, player_x, player_y)

  if quad == quadrant.first then
    return y_over_x
  elseif quad == quadrant.second then
    return 90 + x_over_y
  elseif quad == quadrant.third then
    return 180 + y_over_x
  else
    return 270 + x_over_y
  end
end

-- ===== PLAYER METHODS =====
function Player:init(p)
  local g

  Ent.init(self, p)
  -- All we need is input. Everything else on server
  self.kb = vector(0, 0)

  self.type = utils.types.player

  spr, g = sprite_loader:getPlayerData()
  self.dw, self.dh = g.frameWidth, g.frameHeight
  idle_anim = anim8.newAnimation(g('1-5', 1), 0.1)
  run_anim = anim8.newAnimation(g('6-9', 1), 0.1)

  state = states.idle
  self.direction = direction.right  -- TODO: change?
end

-- Love function
function Player:update(dt, mouse_x, mouse_y)
  self:updateDirection(mouse_x, mouse_y)
  self:resolveState(dt)
end

function Player:resolveState(dt)
  -- Determine state switches and update proper animations
  if state == states.run then
    if self.kb.x == 0 and self.kb.y == 0 then
      state = states.idle
      idle_anim:gotoFrame(1)
    end

    -- Handle facing direction
    if facing_left and self.kb.x > 0 then
      self:flip()
      facing_left = false
    elseif not facing_left and self.kb.x < 0 then
      self:flip()
      facing_left = true
    end

    run_anim:update(dt)
  elseif state == states.idle then
    if self.kb.x ~= 0 or self.kb.y ~= 0 then
      state = states.run
      run_anim:gotoFrame(1)
    end

    idle_anim:update(dt)
  end
end

-- Our function
function Player:updateState(cmd, params)
  if cmd == 'at' then
    self.x, self.y = params.x, params.y
  end
end

-- Make sure you add new animations here. Flips all of them depending on the
-- player facing direction
function Player:flip()
  run_anim:flipH()
  idle_anim:flipH()
end

-- TODO: if we change sprites we'll probably need to change this
function Player:getPosition()
  return self.x - self.w / 4, self.y - self.h / 4
end

function Player:draw()
  if state == states.run then
    run_anim:draw(spr, self:getPosition())
  elseif state == states.idle then
    idle_anim:draw(spr, self:getPosition())
  end
end

function Player:updateDirection(mouse_x, mouse_y)
  -- TODO: finish
  if mouse_x == self.x and mouse_y == self.y then
    return  -- don't change direction
  end
  local angle = getAngle(mouse_x, mouse_y, self.x, self.y)
  self.direction = getDirection(angle)
end

return Player
