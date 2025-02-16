local animated_object_factory = {
    anim8 = require 'libraries/anim8',
    lighting = require 'lighting',
    bump = require 'libraries/bump'
}

function animated_object_factory.constructPlayer(name,x,y, world)
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

    -- init animations
    player.animations = {
        walking_left = {},
        walking_right = {},
        jump_left = {},
        jump_right = {},
        idle_left = {},
        idle_right = {},
        climbing = {},
        idle_climbing = {}
    }
    player.animations.walking_left.sprite_sheet = love.graphics.newImage('sprites/walk-left.png')
    player.animations.walking_left.grid = anim8.newGrid(96,84,player.animations.walking_left.sprite_sheet:getWidth(), player.animations.walking_left.sprite_sheet:getHeight())
    player.animations.walking_left.animation = anim8.newAnimation(player.animations.walking_left.grid('1-8',1),0.1) --start slow
    player.animations.walking_right.sprite_sheet = love.graphics.newImage('sprites/walk-right.png')
    player.animations.walking_right.grid = anim8.newGrid(96,84,player.animations.walking_right.sprite_sheet:getWidth(), player.animations.walking_right.sprite_sheet:getHeight())
    player.animations.walking_right.animation = anim8.newAnimation(player.animations.walking_right.grid('1-8',1),0.1) --start slow      
    player.animations.jump_left.sprite_sheet = love.graphics.newImage('sprites/jump-left.png')
    player.animations.jump_left.grid = anim8.newGrid(96,84,player.animations.jump_left.sprite_sheet:getWidth(), player.animations.jump_left.sprite_sheet:getHeight())
    player.animations.jump_left.animation = anim8.newAnimation(player.animations.jump_left.grid('1-3',1),0.15) --start slow
    player.animations.jump_right.sprite_sheet = love.graphics.newImage('sprites/jump-right.png')
    player.animations.jump_right.grid = anim8.newGrid(96,84,player.animations.jump_right.sprite_sheet:getWidth(), player.animations.jump_right.sprite_sheet:getHeight())
    player.animations.jump_right.animation = anim8.newAnimation(player.animations.jump_right.grid('1-3',1),0.15) --start slow
    player.animations.idle_left.sprite_sheet = love.graphics.newImage('sprites/idle-left.png')
    player.animations.idle_left.grid = anim8.newGrid(96,84,player.animations.idle_left.sprite_sheet:getWidth(), player.animations.idle_left.sprite_sheet:getHeight())
    player.animations.idle_left.animation = anim8.newAnimation(player.animations.idle_left.grid('1-7',1),0.15) --start slow
    player.animations.idle_right.sprite_sheet = love.graphics.newImage('sprites/idle-right.png')
    player.animations.idle_right.grid = anim8.newGrid(96,84,player.animations.idle_right.sprite_sheet:getWidth(), player.animations.idle_right.sprite_sheet:getHeight())
    player.animations.idle_right.animation = anim8.newAnimation(player.animations.idle_right.grid('1-7',1),0.15) --start slow
    player.animations.climbing.sprite_sheet = love.graphics.newImage('sprites/climbing.png')
    player.animations.climbing.grid = anim8.newGrid(96,84,player.animations.climbing.sprite_sheet:getWidth(), player.animations.climbing.sprite_sheet:getHeight())
    player.animations.climbing.animation = anim8.newAnimation(player.animations.climbing.grid('1-8',1),0.15) --start slow
    player.animations.idle_climbing.sprite_sheet = love.graphics.newImage('sprites/idle-climbing.png')
    player.animations.idle_climbing.grid = anim8.newGrid(96,84,player.animations.idle_climbing.sprite_sheet:getWidth(), player.animations.idle_climbing.sprite_sheet:getHeight())
    player.animations.idle_climbing.animation = anim8.newAnimation(player.animations.idle_climbing.grid('1-7',1),0.15) --start slow

    player.current_animation = (math.random(0,1)==0) and player.animations.idle_left or player.animations.idle_right -- randomize starting facing
    player.animation_rate = 1 -- use to speed up animation

    player.scale = 1
    player.leg_power = 300 --jump velocity
    player.jumping = false
    player.climbing = false
    player.falling = false

    --shield is a lightobj
    player.powers = {}
    player.powers.shield = {}
    player.powers.shield.image = love.graphics.newImage('sprites/shield.png')
    player.powers.shield.enabled = true
    player.powers.shield.x = player.x + player.hitbox.xoff + player.hitbox.width/2
    player.powers.shield.y = player.y + player.hitbox.yoff + player.hitbox.height/2

    player.survival = {}
    player.survival.recently_damaged = false
    player.survival.recent_damage_timer = 0.0
    player.survival.recent_damage_timer_threshold = 0.15 -- duration can be used to hold animations in view

    --add to collideable world
    world:add(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)

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
                self.current_animation = self.animations.jump_right
            elseif self.x_dir < 0 then
                self.current_animation = self.animations.jump_left
            end
        end
        --walking
        if(self.velocity.y == 0) then
            if self.x_dir > 0 then
                self.current_animation = self.animations.walking_right
            elseif self.x_dir < 0 then
                self.current_animation = self.animations.walking_left
            end
        end
        --idle
        if (self.velocity.x ==0 and self.velocity.y == 0) then
            if(self.x_dir < 0) then
                self.current_animation = self.animations.idle_left
            else
                self.current_animation = self.animations.idle_right
            end
        end
        --climbing
        if (self.climbing) then
            if (self.velocity.y ~= 0) then
                self.current_animation = self.animations.idle_climbing
            else
                self.current_animation = self.animations.idle_climbing
            end
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


function animated_object_factory.constructHammer(name,x, y)
    local hammer = {}
    hammer.name = name
    hammer.init_x = x
    hammer.init_y = y
    hammer.x = x
    hammer.y = y
    hammer.w = 32
    hammer.h = 32
    hammer.velocity = {x=0,y=0}
    hammer.sprite_sheet = love.graphics.newImage('sprites/Hammer.png')
    hammer.grid = anim8.newGrid(32,64, hammer.sprite_sheet:getWidth(), hammer.sprite_sheet:getHeight())
    hammer.animations = {}
    hammer.animations.turned_on = anim8.newAnimation(hammer.grid('1-8',1), 0.15)
    return hammer
end

--cloud
function animated_object_factory.constructCloud(name, x, y, world)
    local cloud = {}
    cloud.name = name
    cloud.init_x = x
    cloud.init_y = y
    cloud.x = x
    cloud.y = y
    cloud.w = 32
    cloud.h = 32
    cloud.hitbox = {xoff=8,yoff=16,width=48,height=48}
    cloud.velocity = {x=0,y=0}
    cloud.sprite_sheet = love.graphics.newImage('sprites/vapor_cloud.png')
    cloud.grid = anim8.newGrid(64,64, cloud.sprite_sheet:getWidth(), cloud.sprite_sheet:getHeight())
    cloud.animations = {}
    cloud.animations.weak = anim8.newAnimation(cloud.grid('3-2',3, '3-2',2 , 1,'3-2', '3-1', 1), 0.18)
    world:add(cloud, cloud.x+cloud.hitbox.xoff, cloud.y+cloud.hitbox.yoff, cloud.hitbox.width, cloud.hitbox.height)
    return cloud
end

--light
function animated_object_factory.constructLight(x, y, lighting, type)
    local light = {}
    light.enabled = false
    light.init_x = x
    light.init_y = y
    light.x = x
    light.y = y
    light.w = 32
    light.h = 32
    light.velocity = {x=0,y=0}
    light.sprite_sheet = love.graphics.newImage('sprites/lamp-Sheet.png')
    light.grid = anim8.newGrid(32,32, light.sprite_sheet:getWidth(), light.sprite_sheet:getHeight())
    light.animations = {}
    light.animations.switch = anim8.newAnimation(light.grid('1-2',1), 2.5)
    light.flickerpoint = math.random(0.1,10.0)
    light.flickercount = 0
    light.flickerdepth = 0.23 --length the light goes off in dt
    light.flicking = false
    if type == "distance" then
        lighting.addDistanceLight(light, 32, 1.0, 1.0, 1.0)
    elseif type == "godray" then
        lighting.addGodRay(light, 0.8, 0.4, 2)
        --decay (~0.5-0.8)
        --density (~0.2-0.4)
        --weight (~0.5-2)
    end
    return light
end

--collideable terrain
function animated_object_factory.constructAnimatedTerrain(type, x, y, w, h, world)
    local terrain = {}
    terrain.type = type --ladder or floor
    terrain.init_x = x
    terrain.init_y = y
    terrain.x = x
    terrain.y = y
    terrain.w = w
    terrain.h = h
    terrain.hitbox = {xoff=0,yoff=0,width=w,height=h}
    terrain.velocity = {x=0,y=0}
    terrain.sprite_sheets = {}
    terrain.grids = {}
    terrain.animations = {}
    --terrain.current_animation
    --terrain.current_sprite_sheet
    world:add(terrain, terrain.x+terrain.hitbox.xoff, terrain.y+terrain.hitbox.yoff, terrain.hitbox.width, terrain.hitbox.height)
    return terrain
end

return animated_object_factory

