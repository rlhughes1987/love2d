

-- bring data as game starts
function love.load()
    MAX_SPEED = 6

    anim8 = require 'libraries/anim8'
    obstacle_factory = require './obstacle_factory'
    love.graphics.setDefaultFilter("nearest", "nearest") --removes blur from scaling
    
    obstacle_L_1 = {
        frame = obstacle_factory.constructL(),
        x = 100,
        y = 100,
        dx = 1,
        dy = 1
    }
    --local obstacle_I_1 = obstacle_factory.constructI()

    
    going_down = true

    
    cloud = {}
    cloud.x = 300
    cloud.y = 10
    cloud.dx = 1
    cloud.dy = 1
    cloud.spriteSheet = love.graphics.newImage('sprites/vapor_cloud.png')
    cloud.grid = anim8.newGrid(64,64, cloud.spriteSheet:getWidth(), cloud.spriteSheet:getHeight())

    cloud.animations = {}
    cloud.animations.weak = anim8.newAnimation(cloud.grid('3-2',3, '3-2',2 , 1,'3-2', '3-1', 1), 0.18)

    HEIGHT, WIDTH = 500, 500
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
        cloud.dx = 0
    end
    if not y_key_pressed then
        cloud.dy = 0
    end
    

    move_a_thing(cloud)
    cloud.animations.weak:update(dt)
    bounce_a_thing(cloud)

    move_a_thing(obstacle_L_1)
    bounce_a_thing(obstacle_L_1)

end

function move_a_thing(thing)
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

--
function love.draw()
    --love.graphics.print(number, 400, 300)
    --love.graphics.rectangle("fill", 50, rectangle_y, 50, 50)
    cloud.animations.weak:draw(cloud.spriteSheet, cloud.x, cloud.y, 0.1, 1)
    drawobstacle(obstacle_L_1.frame, obstacle_L_1.x, obstacle_L_1.y)

    --love.graphics.rectangle("fill", )

end

function drawobstacle(obstac, x, y)
    local obst = obstac
    local M, N = 4, 4
    local start_pos_x = x
    local start_pos_y = y
    for i=1, N do
        for j=1, M do
            if(obst[i*M + j] == 1) then
                --render rectangle 50x50
                local new_x = start_pos_x + ((i-1)*50)
                local new_y = start_pos_y + ((j-1)*50)
                love.graphics.rectangle("line", new_x, new_y, 50, 50)
            end
        end
    end

    love.graphics.print("x: " .. cloud.x .. " y: " .. cloud.y .. " cloud.dx " .. cloud.dx .. " cloud.dy " .. cloud.dy)
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

