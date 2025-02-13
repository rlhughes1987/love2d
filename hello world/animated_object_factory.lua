local animated_object_factory = {
    anim8 = require 'libraries/anim8',
    lighting = require 'lighting'
}

function animated_object_factory.constructPlayer(name,x,y)
    local player = {}
    player.name = name
    player.init_x = x
    player.init_y = y
    player.x = x
    player.y = y
    player.w = 32
    player.h = 32
    player.velocity = {x=0,y=0}
    player.spriteSheets = {}
    player.animations = {}
    player.grids = {}

    player.spriteSheets.walking_left = love.graphics.newImage('sprites/walk-left.png')
    player.grids.walking_left = anim8.newGrid(96,84,player.spriteSheets.walking_left:getWidth(), player.spriteSheets.walking_left:getHeight())
    player.animations.walking_left = anim8.newAnimation(player.grids.walking_left('1-8',1),0.15)

    player.spriteSheets.walking_right = love.graphics.newImage('sprites/walk-right.png')
    player.grids.walking_right = anim8.newGrid(96,84,player.spriteSheets.walking_right:getWidth(), player.spriteSheets.walking_right:getHeight())
    player.animations.walking_right = anim8.newAnimation(player.grids.walking_right('1-8',1),0.15)

    player.spriteSheets.jump = love.graphics.newImage('sprites/jump.png')
    player.grids.jump = anim8.newGrid(96,84,player.spriteSheets.jump:getWidth(), player.spriteSheets.jump:getHeight())
    player.animations.jump = anim8.newAnimation(player.grids.jump('1-3',1),0.15)

    player.spriteSheets.idle = love.graphics.newImage('sprites/idle.png')
    player.grids.idle = anim8.newGrid(96,84,player.spriteSheets.idle:getWidth(), player.spriteSheets.idle:getHeight())
    player.animations.idle = anim8.newAnimation(player.grids.idle('1-3',1),0.15)

    player.current_animation = player.animations.idle -- change to stationary
    player.current_spritesheet = player.spriteSheets.idle

    player.scale = 1
    
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
function animated_object_factory.constructCloud(name, x, y)
    local cloud = {}
    cloud.name = name
    cloud.init_x = x
    cloud.init_y = y
    cloud.x = x
    cloud.y = y
    cloud.w = 32
    cloud.h = 32
    cloud.velocity = {x=0,y=0}
    cloud.spriteSheet = love.graphics.newImage('sprites/vapor_cloud.png')
    cloud.grid = anim8.newGrid(64,64, cloud.spriteSheet:getWidth(), cloud.spriteSheet:getHeight())
    cloud.animations = {}
    cloud.animations.weak = anim8.newAnimation(cloud.grid('3-2',3, '3-2',2 , 1,'3-2', '3-1', 1), 0.18)
    return cloud
end

--light
function animated_object_factory.constructLight(x, y)
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
    return light
end

return animated_object_factory

