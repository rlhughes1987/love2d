local animated_object_factory = {
    anim8 = require 'libraries/anim8'
}

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
    hammer.animations.turned_on = anim8.newAnimation(hammer.grid('1-8',1), 0.18)
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

return animated_object_factory

