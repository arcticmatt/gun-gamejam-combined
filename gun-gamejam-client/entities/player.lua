local Class = require('libs.hump.class')
local Ent = require('entities.ent')
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
local state
local states = {idle=0, run=1}

-- ===== PLAYER METHODS =====
function Player:init(p)
  local g

  Ent.init(self, p)
  self.type = utils.types.player

  spr, g = sprite_loader:getPlayerData()
  self.dw, self.dh = g.frameWidth, g.frameHeight
  idle_anim = anim8.newAnimation(g('1-5', 1), 0.1)
  run_anim = anim8.newAnimation(g('6-9', 1), 0.1)

  state = states.idle
end

-- Love function
function Player:update(dt)
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
    self.x, self.y, self.kb = params.x, params.y, params.kb
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

return Player
