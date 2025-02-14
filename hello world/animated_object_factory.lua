local animated_object_factory = {
    anim8 = require 'libraries/anim8',
    lighting = require 'lighting',
    bump = require 'libraries/bump'
}

function animated_object_factory.constructPlayer(name,x,y, world)
    local player = {}
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
    player.spriteSheets = {}
    player.animations = {}
    player.grids = {}

    player.spriteSheets.walking_left = love.graphics.newImage('sprites/walk-left.png')
    player.grids.walking_left = anim8.newGrid(96,84,player.spriteSheets.walking_left:getWidth(), player.spriteSheets.walking_left:getHeight())
    player.animations.walking_left = anim8.newAnimation(player.grids.walking_left('1-8',1),0.05)

    player.spriteSheets.walking_right = love.graphics.newImage('sprites/walk-right.png')
    player.grids.walking_right = anim8.newGrid(96,84,player.spriteSheets.walking_right:getWidth(), player.spriteSheets.walking_right:getHeight())
    player.animations.walking_right = anim8.newAnimation(player.grids.walking_right('1-8',1),0.05)

    player.spriteSheets.jump_left = love.graphics.newImage('sprites/jump-left.png')
    player.grids.jump_left = anim8.newGrid(96,84,player.spriteSheets.jump_left:getWidth(), player.spriteSheets.jump_left:getHeight())
    player.animations.jump_left = anim8.newAnimation(player.grids.jump_left('1-3',1),0.15)

    player.spriteSheets.jump_right = love.graphics.newImage('sprites/jump-right.png')
    player.grids.jump_right = anim8.newGrid(96,84,player.spriteSheets.jump_right:getWidth(), player.spriteSheets.jump_right:getHeight())
    player.animations.jump_right = anim8.newAnimation(player.grids.jump_right('1-3',1),0.15)

    player.spriteSheets.idle_left = love.graphics.newImage('sprites/idle-left.png')
    player.grids.idle_left = anim8.newGrid(96,84,player.spriteSheets.idle_left:getWidth(), player.spriteSheets.idle_left:getHeight())
    player.animations.idle_left = anim8.newAnimation(player.grids.idle_left('1-7',1),0.15)

    player.spriteSheets.idle_right = love.graphics.newImage('sprites/idle-right.png')
    player.grids.idle_right = anim8.newGrid(96,84,player.spriteSheets.idle_right:getWidth(), player.spriteSheets.idle_right:getHeight())
    player.animations.idle_right = anim8.newAnimation(player.grids.idle_right('1-7',1),0.15)

    player.spriteSheets.climbing = love.graphics.newImage('sprites/climbing.png')
    player.grids.climbing = anim8.newGrid(96,84,player.spriteSheets.climbing:getWidth(), player.spriteSheets.climbing:getHeight())
    player.animations.climbing = anim8.newAnimation(player.grids.climbing('1-8',1),0.15)

    player.spriteSheets.idle_climbing = love.graphics.newImage('sprites/idle-climbing.png')
    player.grids.idle_climbing = anim8.newGrid(96,84,player.spriteSheets.idle_climbing:getWidth(), player.spriteSheets.idle_climbing:getHeight())
    player.animations.idle_climbing = anim8.newAnimation(player.grids.idle_climbing('1-7',1),0.15)

    player.current_animation = (math.random(0,1)==0) and player.animations.idle_left or player.animations.idle_right -- randomize starting facing
    player.current_spritesheet = (math.random(0,1)==0) and player.spriteSheets.idle_left or player.spriteSheets.idle_right 

    player.scale = 1
    player.leg_power = 4 --jump velocity
    player.jumping = false
    player.climbing = false
    player.friction = 7

    --add to collideable world
    world:add(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
    
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
    hammer.spriteSheet = love.graphics.newImage('sprites/Hammer.png')
    hammer.grid = anim8.newGrid(32,64, hammer.spriteSheet:getWidth(), hammer.spriteSheet:getHeight())
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
    cloud.spriteSheet = love.graphics.newImage('sprites/vapor_cloud.png')
    cloud.grid = anim8.newGrid(64,64, cloud.spriteSheet:getWidth(), cloud.spriteSheet:getHeight())
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
    light.spriteSheet = love.graphics.newImage('sprites/lamp-Sheet.png')
    light.grid = anim8.newGrid(32,32, light.spriteSheet:getWidth(), light.spriteSheet:getHeight())
    light.animations = {}
    light.animations.switch = anim8.newAnimation(light.grid('1-2',1), 2.5)
    light.flickerpoint = math.random(0.1,10.0)
    light.flickercount = 0
    light.flickerdepth = 0.23 --length the light goes off in dt
    light.flicking = false
    if type == "distance" then
        lighting.addDistanceLight(light, 300, 1.0, 1.0, 1.0)
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
    terrain.spriteSheets = {}
    terrain.grids = {}
    terrain.animations = {}
    --terrain.current_animation
    --terrain.current_spritesheet
    world:add(terrain, terrain.x+terrain.hitbox.xoff, terrain.y+terrain.hitbox.yoff, terrain.hitbox.width, terrain.hitbox.height)
    return terrain
end

return animated_object_factory

