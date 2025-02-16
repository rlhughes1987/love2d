local humanoid = {}

local anim8 = require 'libraries/anim8'
-- init animations
local animations = {
    walking_left = {},
    walking_right = {},
    jump_left = {},
    jump_right = {},
    idle_left = {},
    idle_right = {},
    climbing = {},
    idle_climbing = {},
    roll = {}
}

animations.walking_left.sprite_sheet = love.graphics.newImage('sprites/walk-left.png')
animations.walking_left.grid = anim8.newGrid(96,84,animations.walking_left.sprite_sheet:getWidth(), animations.walking_left.sprite_sheet:getHeight())
animations.walking_left.animation = anim8.newAnimation(animations.walking_left.grid('1-8',1),0.1) --start slow
animations.walking_right.sprite_sheet = love.graphics.newImage('sprites/walk-right.png')
animations.walking_right.grid = anim8.newGrid(96,84,animations.walking_right.sprite_sheet:getWidth(), animations.walking_right.sprite_sheet:getHeight())
animations.walking_right.animation = anim8.newAnimation(animations.walking_right.grid('1-8',1),0.1) --start slow      
animations.jump_left.sprite_sheet = love.graphics.newImage('sprites/jump-left.png')
animations.jump_left.grid = anim8.newGrid(96,84,animations.jump_left.sprite_sheet:getWidth(), animations.jump_left.sprite_sheet:getHeight())
animations.jump_left.animation = anim8.newAnimation(animations.jump_left.grid('1-3',1),0.15) --start slow
animations.jump_right.sprite_sheet = love.graphics.newImage('sprites/jump-right.png')
animations.jump_right.grid = anim8.newGrid(96,84,animations.jump_right.sprite_sheet:getWidth(), animations.jump_right.sprite_sheet:getHeight())
animations.jump_right.animation = anim8.newAnimation(animations.jump_right.grid('1-3',1),0.15) --start slow
animations.idle_left.sprite_sheet = love.graphics.newImage('sprites/idle-left.png')
animations.idle_left.grid = anim8.newGrid(96,84,animations.idle_left.sprite_sheet:getWidth(), animations.idle_left.sprite_sheet:getHeight())
animations.idle_left.animation = anim8.newAnimation(animations.idle_left.grid('1-7',1),0.15) --start slow
animations.idle_right.sprite_sheet = love.graphics.newImage('sprites/idle-right.png')
animations.idle_right.grid = anim8.newGrid(96,84,animations.idle_right.sprite_sheet:getWidth(), animations.idle_right.sprite_sheet:getHeight())
animations.idle_right.animation = anim8.newAnimation(animations.idle_right.grid('1-7',1),0.15) --start slow
animations.climbing.sprite_sheet = love.graphics.newImage('sprites/climbing.png')
animations.climbing.grid = anim8.newGrid(96,84,animations.climbing.sprite_sheet:getWidth(), animations.climbing.sprite_sheet:getHeight())
animations.climbing.animation = anim8.newAnimation(animations.climbing.grid('1-8',1),0.15) --start slow
animations.idle_climbing.sprite_sheet = love.graphics.newImage('sprites/idle-climbing.png')
animations.idle_climbing.grid = anim8.newGrid(96,84,animations.idle_climbing.sprite_sheet:getWidth(), animations.idle_climbing.sprite_sheet:getHeight())
animations.idle_climbing.animation = anim8.newAnimation(animations.idle_climbing.grid('1-7',1),0.15) --start slow
animations.roll.sprite_sheet = love.graphics.newImage('sprites/roll.png')
animations.roll.grid = anim8.newGrid(96,84,animations.roll.sprite_sheet:getWidth(), animations.roll.sprite_sheet:getHeight())
animations.roll.animation = anim8.newAnimation(animations.roll.grid('1-9',1),0.05)

function humanoid.constructPlayer(name,x,y, world, lighting)
    local player = {}
    player.type = "humanoid"
    player.name = name
    player.init_x = x
    player.init_y = y
    player.x = x
    player.y = y
    player.w = 32
    player.h = 32
    player.hitbox = {xoff=32,yoff=42,width=32,height=42} --offset from image coord
    player.lastvelocity = {x=1, y=0} --start aimed to right, generally used to store direction character faces based on recent movements
    player.x_dir = 1 -- use to face character
    player.velocity = {x=0,y=0}
    player.current_animation = (math.random(0,1)==0) and animations.idle_left or animations.idle_right -- randomize starting facing
    player.animation_rate = 1 -- use to speed up animation
    player.scale = 1
    player.leg_power = 300 --jump velocity
    player.jumping = false
    player.climbing = false
    player.falling = false

    player.powers = {}
    player.powers.shield = {}
    player.powers.shield.image = love.graphics.newImage('sprites/shield.png')
    player.powers.shield.enabled = false
    player.powers.shield.x = player.x + player.hitbox.xoff + player.hitbox.width/2
    player.powers.shield.y = player.y + player.hitbox.yoff + player.hitbox.height/2

    player.survival = {}
    player.survival.recently_damaged = false
    player.survival.recent_damage_timer = 0.0
    player.survival.recent_damage_timer_threshold = 0.15 -- duration can be used to hold animations in view

    --add to collideable world
    world:add(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)

    --shield affects lighting
    lighting.addDistanceLight(player.powers.shield, 300, 0.8, 0.8, 1)

    function player:updateAnimationBasedOnVelocity(dt)
        --update animation rate
        if math.abs(player.velocity.x) > 250 then
            self.animation_rate = 3
        else
           self.animation_rate = 1
        end
        --jumping
        if(self.velocity.y ~= 0 and self.jumping) then
            if self.x_dir > 0 then
                self.current_animation = animations.jump_right
            elseif self.x_dir < 0 then
                self.current_animation = animations.jump_left
            end
        end
        --walking
        if(self.velocity.y == 0) then
            if self.x_dir > 0 then
                self.current_animation = animations.walking_right
            elseif self.x_dir < 0 then
                self.current_animation = animations.walking_left
            end
        end
        --idle
        if (self.velocity.x ==0 and self.velocity.y == 0) then
            if(self.x_dir < 0) then
                self.current_animation = animations.idle_left
            else
                self.current_animation = animations.idle_right
            end
        end
        --climbing
        if (self.climbing) then
            if (self.velocity.y ~= 0) then
                self.current_animation = animations.idle_climbing
            else
                self.current_animation = animations.idle_climbing
            end
        end
        --falling
        if(self.velocity.y > 0 and self.falling) then
            self.current_animation = animations.roll -- no falling animation with protoype 
        end
        self.current_animation.animation:update(dt * self.animation_rate)
    end

    function player:updateRootPosition(x,y)
        self.x = x
        self.y = y
        -- now update things anchored to the player e.g. shield
        self.powers.shield.x = self.x + self.hitbox.xoff + self.hitbox.width/2
        self.powers.shield.y = self.y + self.hitbox.yoff + self.hitbox.height/2
        -- extend
    end

    return player
end

return humanoid