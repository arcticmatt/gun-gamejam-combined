local Class = require('libs.hump.class')
local Ent = require('entities.ent')
local vector = require('libs.hump.vector')
local sprite_loader = require('utils.sprite_loader')
local anim8 = require('libs.anim8.anim8')
local utils = require('utils.utils')

local Player = Class{
  __includes = Ent -- Player class inherits our Ent class
}

local dw, dh
local facingLeft = false
local spr, idle_anim, run_anim
local input = {up='up', down='down', left='left', right='right'}
local state
local states = {idle=0, run=1}

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
end

-- Love function
function Player:update(dt)
  self:getInputs()
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
    if facingLeft and self.kb.x > 0 then
      self:flip()
      facingLeft = false
    elseif not facingLeft and self.kb.x < 0 then
      self:flip()
      facingLeft = true
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
function Player:update_state(cmd, params)
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

function Player:getDrawPosition()
  return self.x - self.dw / 2, self.y - self.dh / 2
end

function Player:draw()
  if state == states.run then
    run_anim:draw(spr, self:getDrawPosition())
  elseif state == states.idle then
    idle_anim:draw(spr, self:getDrawPosition())
  end
end

-- Populates the input array with the keys that the player is pressing down
function Player:getInputs()
  -- Reset velocity input vector
  self.kb = vector(0, 0)
  if love.keyboard.isDown(input.up) then self.kb.y = self.kb.y - 1; end
  if love.keyboard.isDown(input.down) then self.kb.y = self.kb.y + 1; end
  if love.keyboard.isDown(input.left) then self.kb.x = self.kb.x - 1; end
  if love.keyboard.isDown(input.right) then self.kb.x = self.kb.x + 1; end

  return self.kb
end

return Player
