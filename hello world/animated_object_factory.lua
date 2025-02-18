local animated_object_factory = {
    anim8 = require 'libraries/anim8',
    lighting = require 'lighting',
    bump = require 'libraries/bump'
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
    hammer.velocity = {x=0,y=0}
    hammer.sprite_sheet = love.graphics.newImage('sprites/4 Proto/Hammer.png')
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
    cloud.sprite_sheet = love.graphics.newImage('sprites/4 Proto/vapor_cloud.png')
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
    light.sprite_sheet = love.graphics.newImage('sprites/4 Proto/lamp-Sheet.png')
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

