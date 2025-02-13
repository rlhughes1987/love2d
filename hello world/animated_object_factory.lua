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
    player.dx = 0
    player.dy = 0
    player.spriteSheets = {}
    player.animations = {}
    player.grids = {}
    player.spriteSheets.walking = love.graphics.newImage('sprites/walking.png')
    player.grids.walking = anim8.newGrid(96,84,player.spriteSheets.walking:getWidth(), player.spriteSheets.walking:getHeight())
    player.animations.walking = anim8.newAnimation(player.grids.walking('1-8',1),0.15)
    player.spriteSheets.jump = love.graphics.newImage('sprites/jump.png')
    player.grids.jump = anim8.newGrid(96,84,player.spriteSheets.jump:getWidth(), player.spriteSheets.walking:getHeight())
    player.animations.jump = anim8.newAnimation(player.grids.jump('1-3',1),0.15)
    player.current_animation = player.animations.walking -- change to stationary
    player.current_spritesheet = player.spriteSheets.walking
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
    hammer.dx = 0
    hammer.dy = 0
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
    cloud.dx = 0
    cloud.dy = 0
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
    light.dx = 0
    light.dy = 0
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

