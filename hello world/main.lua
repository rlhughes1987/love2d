

-- bring data as game starts
function love.load()
    MAX_SPEED = 6
    debug_message = ""
    --imports
    anim8 = require 'libraries/anim8'
    bump = require 'libraries/bump'
    obstacle_factory = require './obstacle_factory'
    animated_object_factory = require './animated_object_factory'
    camera = require 'libraries/camera'
    cam = camera()

    sti = require 'libraries/sti'
    gameMap = sti('maps/industrial_area.lua')
    love.graphics.setDefaultFilter("nearest", "nearest") --removes blur from scaling

    WIDTH = gameMap.width * gameMap.tilewidth
    HEIGHT = gameMap.height * gameMap.tileheight

    obstacle_L_1 = obstacle_factory.constructL(150,50)
    obstacle_I_1 = obstacle_factory.constructI(250,100)
    obstacle_U_1 = obstacle_factory.constructU(150,150)
    
    
    cloud = animated_object_factory.constructCloud("player_cloud",10,10)
    pipe_cloud = animated_object_factory.constructCloud("pipe_cloud",768,224)
    hammer_1 = animated_object_factory.constructHammer("hammer1",384,512)
    hammer_1.animations.turned_on:gotoFrame(2)
    hammer_2 = animated_object_factory.constructHammer("hammer2",416,512)
    hammer_2.animations.turned_on:gotoFrame(3)
    hammer_3 = animated_object_factory.constructHammer("hammer3",448,512)
    hammer_3.animations.turned_on:gotoFrame(4)
    hammer_4 = animated_object_factory.constructHammer("hammer4",480,512)
    hammer_4.animations.turned_on:gotoFrame(5)
    hammer_5 = animated_object_factory.constructHammer("hammer5",512,512)

    --collision stuff
    world = bump.newWorld(32)

    world:add(cloud, 0, cloud.x, cloud.y, 32, 32)
    world:add(pipe_cloud,0,pipe_cloud.x,pipe_cloud.y, 32, 32)
end

-- runs every 60 frames, dt delta time between this frame and last
function love.update(dt)
    
    local x_key_pressed = false
    local y_key_pressed = false
    if(love.keyboard.isDown("d")) then
        if (MAX_SPEED > cloud.dx) then
            cloud.dx = cloud.dx + 1
        end
        x_key_pressed = true
    end
    if(love.keyboard.isDown("a")) then
        if (-MAX_SPEED < cloud.dx) then
            cloud.dx = cloud.dx - 1
        end
        x_key_pressed = true
    end
    if(love.keyboard.isDown("w")) then
        if (-MAX_SPEED < cloud.dy) then
            cloud.dy = cloud.dy - 1
        end
        y_key_pressed = true
    end
    if(love.keyboard.isDown("s")) then
        if (MAX_SPEED > cloud.dy) then
            cloud.dy = cloud.dy + 1
        end
        y_key_pressed = true
    end
    if not x_key_pressed then
        reduce_x_speed(cloud)
    end
    if not y_key_pressed then
        reduce_y_speed(cloud)
    end

    move_a_thing_bounded(cloud)
    cloud.animations.weak:update(dt)


    direct_a_thing_up(pipe_cloud)
    move_a_thing_bounded_reset(pipe_cloud)
    pipe_cloud.animations.weak:update(dt)

    hammer_1.animations.turned_on:update(dt)
    hammer_2.animations.turned_on:update(dt)
    hammer_3.animations.turned_on:update(dt)
    hammer_4.animations.turned_on:update(dt)
    hammer_5.animations.turned_on:update(dt)

    move_a_thing_bounded(obstacle_L_1)
    bounce_a_thing(obstacle_L_1)

    move_a_thing_warp(obstacle_I_1)

    move_a_thing_bounded(obstacle_U_1)
    bounce_a_thing(obstacle_U_1)

    cam:lookAt(cloud.x, cloud.y)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    --bound camera to left scene edge
    if cam.x < w/2 then
        cam.x = w/2
    end
    --top edge
    if cam.y < h/2 then
        cam.y = h/2
    end
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight
    --right edge
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end
    -- bottom edge
    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end

    -- collision world
    world:update(cloud, cloud.x, cloud.y, 32, 32)
    world:update(pipe_cloud, pipe_cloud.x, pipe_cloud.y, 32, 32)

end

function reduce_x_speed(thing)
    if(thing.dx == 0) then
        return
    end
    if(thing.dx < 0) then
        thing.dx = thing.dx + 1
    elseif(thing.dx > 0) then
        thing.dx = thing.dx - 1
    end
end

function reduce_y_speed(thing)
    if(thing.dy == 0) then
        return
    end
    if(thing.dy < 0) then
        thing.dy = thing.dy + 1
    elseif(thing.dy > 0) then
        thing.dy = thing.dy - 1
    end
end

function direct_a_thing_up(thing)
    thing.dx = 0
    thing.dy = -1
end

function move_a_thing_bounded(thing)
    -- x
    if (thing.x + thing.dx) > WIDTH then
        thing.x = WIDTH
    elseif(thing.x + thing.dx) < 0 then
        thing.x = 0
    else
        thing.x = thing.x + thing.dx
    end
    -- y
    if (thing.y + thing.dy) > HEIGHT then
        thing.y = HEIGHT
    elseif(thing.y + thing.dy) < 0 then
        thing.y = 0
    else
        thing.y = thing.y + thing.dy
    end
end

function move_a_thing_bounded_reset(thing)
    --world:add(thing,0,thing.x,thing.y, 32, 32)
    if not world:hasItem(thing) then
        world:add(thing,0,thing.x,thing.y, 32, 32)
    end
    -- x
    if (thing.x + thing.dx) > (WIDTH + 64) then --make sure object goes off screen first
        thing.x = thing.init_x
    elseif(thing.x + thing.dx) < -64 then --make sure object goes off screen first
        thing.x = thing.init_x
    else
        --thing.x = thing.x + thing.dx
        local actualX, actualY, cols, len = world:move(thing,(thing.x+thing.dx),thing.y)
        if len > 0 then
            debug_message = "Collision"
        else
            debug_message = "Freedom"
            thing.x = thing.x + thing.dx
        end
    end
    -- y
    if (thing.y + thing.dy) > (HEIGHT + 64) then
        thing.y = thing.init_y
    elseif(thing.y + thing.dy) < -64 then
        thing.y = thing.init_y
    else
        --thing.y = thing.y + thing.dy
        local actualX, actualY, cols, len = world:move(thing, thing.x,(thing.y+thing.dy))
        if len > 0 then
            debug_message = "Collision"
        else
            debug_message = "Freedom"
            thing.y = thing.y + thing.dy
        end
    end
end

function move_a_thing_warp(thing)
    -- x
    if (thing.x + thing.dx) > (WIDTH+thing.dx) then
        thing.x = 0
    elseif(thing.x + thing.dx) < (0-thing.dx) then
        thing.x = WIDTH
    else
        thing.x = thing.x + thing.dx
    end
    -- y
    if (thing.y + thing.dy) > (HEIGHT+thing.dy) then
        thing.y = 0
    elseif(thing.y + thing.dy) < (0-thing.dy) then
        thing.y = HEIGHT
    else
        thing.y = thing.y + thing.dy
    end
end

--
function love.draw()
    cam:attach()
    --love.graphics.print(number, 400, 300)
    --love.graphics.rectangle("fill", 50, rectangle_y, 50, 50)
        gameMap:drawLayer(gameMap.layers["Background"])
        gameMap:drawLayer(gameMap.layers["Underground darkness"])
        gameMap:drawLayer(gameMap.layers["Inner 1"])
        gameMap:drawLayer(gameMap.layers["Middle"])
        gameMap:drawLayer(gameMap.layers["Inner 2"])
        hammer_1.animations.turned_on:draw(hammer_1.spriteSheet, hammer_1.x, hammer_1.y, 0)
        hammer_2.animations.turned_on:draw(hammer_2.spriteSheet, hammer_2.x, hammer_2.y, 0)
        hammer_3.animations.turned_on:draw(hammer_3.spriteSheet, hammer_3.x, hammer_3.y, 0)
        hammer_4.animations.turned_on:draw(hammer_4.spriteSheet, hammer_4.x, hammer_4.y, 0)
        hammer_5.animations.turned_on:draw(hammer_5.spriteSheet, hammer_5.x, hammer_5.y, 0)
        cloud.animations.weak:draw(cloud.spriteSheet, cloud.x, cloud.y, 0.1, 1, 1, 32, 32)
        pipe_cloud.animations.weak:draw(pipe_cloud.spriteSheet, pipe_cloud.x, pipe_cloud.y, 0.1, 1, 1, 32, 32)
        gameMap:drawLayer(gameMap.layers["Front"])
    cam:detach()
    love.graphics.print("HP: ", 10, 10)
    love.graphics.print("Debug: " .. debug_message, 10, 30)
    
    --drawobstacle(obstacle_L_1)
    --drawobstacle(obstacle_I_1)
    --drawobstacle(obstacle_U_1)
    --love.graphics.rectangle("fill", )

end

function drawobstacle(obstac)
    local x, y = obstac.x, obstac.y
    local frame = obstac.frame
    local M, N = 4, 4
    local start_pos_x = x
    local start_pos_y = y
    for i=1, N do
        for j=1, M do
            if(frame[i*M + j] == 1) then
                --render rectangle 50x50
                local new_x = start_pos_x + ((i-1)*50)
                local new_y = start_pos_y + ((j-1)*50)
                love.graphics.rectangle("line", new_x, new_y, 50, 50)
            end
        end
    end

    love.graphics.print("x: " .. obstac.x .. " y: " .. obstac.y, obstac.x, obstac.y)
end

function bounce_a_thing(thing)
    local new_dx = thing.dx
    local new_dy = thing.dy
    if (thing.y >= (HEIGHT)) or (thing.y <= 0) then
        new_dy = -new_dy
    end
    if (thing.x >= (WIDTH)) or (thing.x <= 0) then
        new_dx = -new_dx
    end
    thing.dx = new_dx
    thing.dy = new_dy
end
