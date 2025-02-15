-- bring data as game starts
function love.load()
    MAX_SPEED = 16
    MAX_CLIMB_SPEED = 0.8
    GRAVITY = 12
    LADDER_TERRAIN_TYPE = "ladder"
    FLOOR_TERRAIN_TYPE = "floor"
    debug_message = ""
    --imports
    anim8 = require 'libraries/anim8'
    bump = require 'libraries/bump'
    obstacle_factory = require './obstacle_factory'
    animated_object_factory = require './animated_object_factory'
    lighting = require './lighting'
    camera = require 'libraries/camera'
    cam = camera()
    sti = require 'libraries/sti'  -- includes box2d and bump
    gameMap = sti('maps/industrial_area.lua')

    love.graphics.setDefaultFilter("nearest", "nearest") --removes blur from scaling

    WIDTH = gameMap.width * gameMap.tilewidth
    HEIGHT = gameMap.height * gameMap.tileheight

    --collision world
    world = bump.newWorld(32)

    player = animated_object_factory.constructPlayer("Richard", 30, 236, world)
    enemy = animated_object_factory.constructPlayer("Enemy", 300, 524, world)
    enemy2 = animated_object_factory.constructPlayer("Enemy2", 200, 524, world)
    pipe_cloud = animated_object_factory.constructCloud("pipe_cloud",752,224, world)

    --try build collideables from map properties
    floors = {}
    local floor_type = "floor"
    if gameMap.layers["Floors"] then
        for i, obj in pairs(gameMap.layers["Floors"].objects) do
            local some_floor = animated_object_factory.constructAnimatedTerrain(floor_type, obj.x,obj.y,obj.width,obj.height, world)
            table.insert(floors,some_floor)
        end
    end
    
    ladders = {}
    local ladder_type = "ladder"
    if gameMap.layers["Ladders"] then
        for i,obj in pairs(gameMap.layers["Ladders"].objects) do
            local some_floor = animated_object_factory.constructAnimatedTerrain(ladder_type, obj.x,obj.y,obj.width,obj.height, world)
            table.insert(floors,some_floor)
        end
    end

    --lighting
    light_1 = animated_object_factory.constructLight(175,490, lighting, "distance") --not sure need to animate light turning on or off
    light_2 = animated_object_factory.constructLight(0.1,0.1, lighting, "godray")

    --scene decoration -- TODO: Make hammers hitboxes dynamic and therefore collideable
    hammer_1 = animated_object_factory.constructHammer("hammer1",384,512)
    hammer_1.animations.turned_on:gotoFrame(2)
    hammer_2 = animated_object_factory.constructHammer("hammer2",416,512)
    hammer_2.animations.turned_on:gotoFrame(3)
    hammer_3 = animated_object_factory.constructHammer("hammer3",448,512)
    hammer_3.animations.turned_on:gotoFrame(4)
    hammer_4 = animated_object_factory.constructHammer("hammer4",480,512)
    hammer_4.animations.turned_on:gotoFrame(5)
    hammer_5 = animated_object_factory.constructHammer("hammer5",512,512)
    

end

-- runs every 60 frames, dt delta time between this frame and last
function love.update(dt)
    -- player movement
    --update velocity based on inputs
    --right or left direction
    if(love.keyboard.isDown("d")) and (math.abs(player.velocity.x) < MAX_SPEED) then
        player.x_dir = 1
        player.velocity.x = player.velocity.x + (MAX_SPEED * dt)
    end
    if(love.keyboard.isDown("a") and (math.abs(player.velocity.x) < MAX_SPEED)) then
        player.x_dir = -1
        player.velocity.x = player.velocity.x - (MAX_SPEED * dt)
    end
    --up or down
    --jump/fall
    if((love.keyboard.isDown("space") and (not player.jumping))) then --if starting a jump or in the middle of a jump
        player.velocity.y = -player.leg_power
        player.jumping = true
        player.climbing = false
    end
    --climb
    if(love.keyboard.isDown("s") and can_climb(player) and player.velocity.y < MAX_CLIMB_SPEED) then
        player.velocity.y = player.velocity.y + 1
    elseif(love.keyboard.isDown("w") and can_climb(player) and player.velocity.y > -MAX_CLIMB_SPEED) then
        player.velocity.y = player.velocity.y - 1
    end
    --update velocity based on lack of inputs
    --if not x_key_pressed then
    --    reduce_x_speed(player)
    --end
    --if not y_key_pressed then
    --    reduce_y_speed(player)
    --end

    --add gravity
    if player.climbing then
        ladder_physics(player,dt)
    else
        physics(player,dt)
    end

    move_a_thing_bounded(player,dt)
    
    
    

    --update animations based on velocity
    --jumping
    if(player.velocity.y ~= 0) then
        if player.x_dir > 0 then
            player.current_animation = player.animations.jump_right
            player.current_spritesheet = player.spriteSheets.jump_right
        elseif player.x_dir < 0 then
            player.current_animation = player.animations.jump_left
            player.current_spritesheet = player.spriteSheets.jump_left
        end
    end
    --walking
    if(player.velocity.y == 0) then
        if player.x_dir > 0 then
            player.current_animation = player.animations.walking_right
            player.current_spritesheet = player.spriteSheets.walking_right
        elseif player.x_dir < 0 then
            player.current_animation = player.animations.walking_left
            player.current_spritesheet = player.spriteSheets.walking_left
        end
    end
    --idle
    if (player.velocity.x ==0 and player.velocity.y == 0) then
        if(player.x_dir < 0) then
            player.current_animation = player.animations.idle_left
            player.current_spritesheet = player.spriteSheets.idle_left
        else
            player.current_animation = player.animations.idle_right
            player.current_spritesheet = player.spriteSheets.idle_right
        end
    end
    --climbing
    if (player.climbing) then
        if (player.velocity.y ~= 0) then
            player.current_animation = player.animations.climbing
            player.current_spritesheet = player.spriteSheets.climbing
        else
            player.current_animation = player.animations.idle_climbing
            player.current_spritesheet = player.spriteSheets.idle_climbing
        end
    end

    player.current_animation:update(dt)


    -- TO DO: Generate automatic movement of enemy
    move_a_thing_bounded(enemy)
    enemy.current_animation:update(dt)

    move_a_thing_bounded(enemy2)
    enemy2.current_animation:update(dt)


    
    

    -- Scene animations
    --pipe cloud
    direct_a_thing_up(pipe_cloud,1)
    move_a_thing_bounded_reset(pipe_cloud)
    pipe_cloud.animations.weak:update(dt)

    hammer_1.animations.turned_on:update(dt)
    hammer_2.animations.turned_on:update(dt)
    hammer_3.animations.turned_on:update(dt)
    hammer_4.animations.turned_on:update(dt)
    hammer_5.animations.turned_on:update(dt)

    --toggle lights
    if(love.keyboard.isDown("l") ) then
        light_1.enabled = true
    end
    if(love.keyboard.isDown("g")) then
        light_2.enabled = true
    end
    if(love.keyboard.isDown("o") ) then -- off
        light_1.enabled = false
        light_2.enabled = false
    end
   

    --flicker lights
    evaluate_flicker(light_1, dt)
    --check lights on or off
    if(light_1.enabled == true) then
        light_1.animations.switch:gotoFrame(2)
    else
        light_1.animations.switch:gotoFrame(1)
    end

    cam:lookAt(player.x, player.y)
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
    world:update(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
    world:update(enemy, enemy.x+enemy.hitbox.xoff, enemy.y+enemy.hitbox.yoff, enemy.hitbox.width, enemy.hitbox.height)
    world:update(enemy2, enemy2.x+enemy2.hitbox.xoff, enemy2.y+enemy2.hitbox.yoff, enemy.hitbox.width, enemy.hitbox.height)
    world:update(pipe_cloud, pipe_cloud.x+pipe_cloud.hitbox.xoff, pipe_cloud.y+pipe_cloud.hitbox.yoff, pipe_cloud.hitbox.width, pipe_cloud.hitbox.height)

end

function can_climb(thing)
    local hit_x = thing.x + thing.hitbox.xoff
    local hit_y = thing.y + thing.hitbox.yoff

    local x = hit_x + (thing.hitbox.width / 2)
    local y = hit_y + (thing.hitbox.height / 2)

    local function is_ladder(item)
        return item.type == LADDER_TERRAIN_TYPE
    end

    local items, len = world:queryPoint(x,y, is_ladder)

    return len > 0
end

function physics(thing, dt)
    -- move done outside
    --debug_message = "x= " .. thing.x .. " y=" .. thing.y .. " velocity.x= " .. thing.velocity.x .. " velocity.y=" .. thing.velocity.y .. " -MAX_SPEED=" .. -MAX_SPEED
    thing.velocity.y = thing.velocity.y + GRAVITY * dt
	thing.velocity.x = thing.velocity.x * (1 - math.min(dt*thing.friction, 1))
    -- adjust velocity based on factors
end

function ladder_physics(thing, dt)
    thing.velocity.y = thing.velocity.y * (1 - math.min(dt*thing.friction, 1))
	thing.velocity.x = thing.velocity.x * (1 - math.min(dt*thing.friction, 1))
end


function reduce_x_speed(thing)
    
    if(thing.velocity.x == 0) then
        return
    end
    if(thing.velocity.x < 0) then
        thing.x_dir = thing.velocity.x
        thing.velocity.x = thing.velocity.x + 1
    elseif(thing.velocity.x > 0) then
        thing.x_dir = thing.velocity.x
        thing.velocity.x = thing.velocity.x - 1
    end
end

function reduce_y_speed(thing)
    if(thing.velocity.y == 0) then
        return
    end
    if(thing.velocity.y < 0) then
        thing.velocity.y = thing.velocity.y + 1
    elseif(thing.velocity.y > 0) then
        thing.velocity.y = thing.velocity.y - 1
    end
end

function direct_a_thing_up(thing, speed)
    thing.velocity.x = 0
    thing.velocity.y = -speed
end

function move_a_thing_bounded(thing, dt)

    local initial_x = thing.x
    local initial_xvel = thing.velocity.x
    local initial_y = thing.y
    local initial_yvel = thing.velocity.y

    local desired_x = initial_x + initial_xvel
    local desired_y = initial_y + initial_yvel

    local result_x = desired_x
    local result_y = desired_y
    local result_xvel = initial_xvel
    local result_yvel = initial_yvel


    if not world:hasItem(thing) then
        world:add(thing,thing.x+thing.hitbox.xoff,thing.y+thing.hitbox.yoff, thing.hitbox.width, thing.hitbox.height)
    end
    -- x

    if((thing.x+thing.velocity.x+thing.hitbox.xoff+thing.hitbox.width) > WIDTH) then --dont touch
        thing.x = WIDTH - thing.hitbox.xoff - thing.hitbox.width
        thing.velocity.x = 0
    elseif((thing.x+thing.velocity.x+thing.hitbox.xoff) < 0) then --dont touch
        thing.x = 0 - thing.hitbox.xoff
        thing.velocity.x = 0
    else
        -- test x direction
        local actualX, actualY, cols, len = world:move(thing,(desired_x+thing.hitbox.xoff),(initial_y+thing.hitbox.yoff)) -- sim move
        if not (len > 0) then --if no collision
            result_x = desired_x --if none confirm move
        else
            local floors_collided = 0
            local ladders_collided = 0
            for i=1, len do
                if cols[i].other.type == LADDER_TERRAIN_TYPE then
                    --dont block but dont set as climbing necessarily
                    ladders_collided = ladders_collided + 1
                elseif cols[i].other.type == FLOOR_TERRAIN_TYPE then
                    --print("xdir - floor collided x: " .. cols[i].other.x .. " y: ".. cols[i].other.y .. " w: " .. cols[i].other.w .. " h: " .. cols[i].other.h)
                    --print("xdir - item  x: " .. cols[i].item.x .. " y: ".. cols[i].item.y .. " w: " .. cols[i].item.w .. " h: " .. cols[i].item.h)
                    --print("xdir - person.climbing=" .. tostring(thing.climbing))
                    floors_collided = floors_collided + 1
                end
            end
            if(floors_collided > 0) then
                print("x - floors_collided: " .. floors_collided .. " ladders collided: " .. ladders_collided)
                result_xvel = 0
            end
            result_x = initial_x + result_xvel
        end

    end
    -- y
    if (thing.y+thing.hitbox.yoff+thing.hitbox.height > HEIGHT) then
        --thing.y = HEIGHT-thing.h+thing.hitbox.height
        --thing.velocity.y = 0
        result_y = HEIGHT-thing.h+thing.hitbox.height
        result_yvel = 0
    elseif ((thing.y+thing.hitbox.yoff < 0) ) then
        --thing.y = 0
        --thing.velocity.y = 0
        result_y = 0
        result_yvel = 0
    else
        local actualX, actualY, cols, len = world:move(thing,(initial_x+thing.hitbox.xoff),(desired_y+thing.hitbox.yoff)) -- sim move, TO DO: Remove seperate horizontal and vertical collision checks
        if not (len > 0) then --check any collision
            --thing.y = thing.y + thing.velocity.y --if none confirm move
            result_y = desired_y
        else
            local floors_collided = 0
            local ladders_collided = 0
            for i=1, len do
                if cols[i].other.type == LADDER_TERRAIN_TYPE then
                    --dont block
                    ladders_collided = ladders_collided + 1
                elseif cols[i].other.type == FLOOR_TERRAIN_TYPE then
                    --print("ydir - floor collided x: " .. cols[i].other.x .. " y: ".. cols[i].other.y .. " w: " .. cols[i].other.w .. " h: " .. cols[i].other.h)
                    --print("ydir - item  x: " .. cols[i].item.x .. " y: ".. cols[i].item.y .. " w: " .. cols[i].item.w .. " h: " .. cols[i].item.h)
                    --print("ydir - person.climbing=" .. tostring(thing.climbing))
                    floors_collided = floors_collided + 1
                end
            end
            if(floors_collided > 0) then
                print("y - floors_collided: " .. floors_collided .. " ladders collided: " .. ladders_collided)
                --thing.velocity.y = 0
                result_yvel = 0
                thing.climbing = false
                thing.jumping = false
            end
            --thing.y = thing.y + thing.velocity.y
            result_y = initial_y + result_yvel
        end
    end
    -- result
    thing.x = result_x
    thing.velocity.x = result_xvel
    thing.y = result_y
    thing.velocity.y = result_yvel

    -- floor velocity
    if math.abs(thing.velocity.x) < 0.1 then -- check for tiny floats to prevent sliding
        thing.velocity.x = 0
    end
    if math.abs(thing.velocity.y) < 0.1 then -- check for tiny floats to prevent sliding
        thing.velocity.y = 0
    end
end

    
function move_with_cursor_bounded(thing)
    local mx, my = love.mouse.getPosition()

    if (mx) > WIDTH then
        thing.x = WIDTH
    elseif(mx) < 0 then
        thing.x = 0
    else
        thing.x = mx
    end
    -- y
    if (my) > HEIGHT then
        thing.y = HEIGHT
    elseif(my) < 0 then
        thing.y = 0
    else
        thing.y = my
    end
end


function move_a_thing_bounded_reset(thing)
    --world:add(thing,0,thing.x,thing.y, 32, 32)
    if not world:hasItem(thing) then
        world:add(thing,thing.x+thing.hitbox.xoff,thing.y+thing.hitbox.yoff, thing.hitbox.width, thing.hitbox.height)
    end
    -- x
    if (thing.x + thing.velocity.x) > (WIDTH + 64) then --make sure object goes off screen first
        thing.x = thing.init_x
    elseif(thing.x + thing.velocity.x) < -64 then --make sure object goes off screen first
        thing.x = thing.init_x
    else
        local actualX, actualY, cols, len = world:move(thing,(thing.x+thing.velocity.x+thing.hitbox.xoff),thing.y+thing.hitbox.yoff)
        if not (len > 0) then
            thing.x = thing.x + thing.velocity.x
        end
    end
    -- y
    if (thing.y + thing.velocity.y) > (HEIGHT + 64) then
        thing.y = thing.init_y
    elseif(thing.y + thing.velocity.y) < -64 then
        thing.y = thing.init_y
    else
        local actualX, actualY, cols, len = world:move(thing, thing.x+thing.hitbox.xoff,(thing.y+thing.velocity.y+thing.hitbox.yoff))
        if not (len > 0) then
            thing.y = thing.y + thing.velocity.y
        end
    end
end

function move_a_thing_warp(thing)
    -- x
    if (thing.x + thing.velocity.x) > (WIDTH+thing.velocity.x) then
        thing.x = 0
    elseif(thing.x + thing.velocity.x) < (0-thing.velocity.x) then
        thing.x = WIDTH
    else
        thing.x = thing.x + thing.velocity.x
    end
    -- y
    if (thing.y + thing.velocity.y) > (HEIGHT+thing.velocity.y) then
        thing.y = 0
    elseif(thing.y + thing.velocity.y) < (0-thing.velocity.y) then
        thing.y = HEIGHT
    else
        thing.y = thing.y + thing.velocity.y
    end
end

--

local ofs = {0, 0}

function love.draw()



    cam:attach()

        --shading
        gameMap:drawLayer(gameMap.layers["Background"])
        

        -- distance light
        lighting.startDistanceShading()
        gameMap:drawLayer(gameMap.layers["Underbackground"])    
        hammer_1.animations.turned_on:draw(hammer_1.spriteSheet, hammer_1.x, hammer_1.y, 0)
        hammer_2.animations.turned_on:draw(hammer_2.spriteSheet, hammer_2.x, hammer_2.y, 0)
        hammer_3.animations.turned_on:draw(hammer_3.spriteSheet, hammer_3.x, hammer_3.y, 0)
        hammer_4.animations.turned_on:draw(hammer_4.spriteSheet, hammer_4.x, hammer_4.y, 0)
        hammer_5.animations.turned_on:draw(hammer_5.spriteSheet, hammer_5.x, hammer_5.y, 0)
        lighting.endShading()
        lighting.startGodrayShading()
        light_1.animations.switch:draw(light_1.spriteSheet, light_1.x, light_1.y)
        gameMap:drawLayer(gameMap.layers["Inner 1"])
        gameMap:drawLayer(gameMap.layers["Middle"])
        gameMap:drawLayer(gameMap.layers["Inner 2"])
        
        player.current_animation:draw(player.current_spritesheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
        love.graphics.rectangle("line",player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
        enemy.current_animation:draw(enemy.current_spritesheet, enemy.x, enemy.y, 0, enemy.scale, enemy.scale, 0, 0)
        enemy2.current_animation:draw(enemy2.current_spritesheet, enemy2.x, enemy2.y, 0, enemy2.scale, enemy2.scale, 0, 0)
        pipe_cloud.animations.weak:draw(pipe_cloud.spriteSheet, pipe_cloud.x, pipe_cloud.y, 0.1, 1, 1, 0, 0)
        love.graphics.rectangle("line", pipe_cloud.x+pipe_cloud.hitbox.xoff, pipe_cloud.y+pipe_cloud.hitbox.yoff, pipe_cloud.hitbox.width, pipe_cloud.hitbox.height)

       
        gameMap:drawLayer(gameMap.layers["Front"])
        lighting:endShading()

        for i=1, #floors do
            love.graphics.rectangle("line",floors[i].x, floors[i].y, floors[i].w, floors[i].h)
        end

    cam:detach()

    love.graphics.print("HP: ", 10, 10)
    debug_message = "player.jumping: " .. tostring(player.jumping) .. " player.climbing: " .. tostring(player.climbing) .. " player base (y): " .. player.y+player.hitbox.yoff+player.hitbox.height
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
        thing.velocity.y = -1 * thing.velocity.y
    end
    if (thing.x >= (WIDTH)) or (thing.x <= 0) then
        new_dx = -new_dx
        thing.velocity.x = -1 * thing.velocity.x
    end
    thing.dx = new_dx
    thing.dy = new_dy
end

function evaluate_flicker(light, dt)
    light.flickercount = light.flickercount + dt
    --check if we should start a flicker
    if ((not light.flicking) and (light.flickercount > light.flickerpoint) and light.enabled) then
        light.flicking = true
        light.enabled = false
        light.flickercount = 0
    end
    --check if flicker finished
    if((light.flicking) and (light.flickercount > light.flickerdepth)) then
        light.flicking = false
        light.enabled = true
        light.flickercount = 0
        light.flickerpoint = math.random(0.1,10.0)
    end
end