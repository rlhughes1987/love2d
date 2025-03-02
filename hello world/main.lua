-- bring data as game starts
function love.load()
    --environment variables
    PAUSED = false
    MAX_SPEED = 2000
    MAX_CLIMB_SPEED = 800
    GRAVITY = 500
    FRICTION = 7
    LADDER_TERRAIN_TYPE = "ladder"
    FLOOR_TERRAIN_TYPE = "floor"
    HUMANOID_TYPE = "humanoid"
    PROJECTILE_TYPE = "projectile"
    debug_message = ""
    proj_debug_message = ""
    --imports
    sti = require 'libraries/sti'
    anim8 = require 'libraries/anim8'
    bump = require 'libraries/bump'
    animated_object_factory = require './animated_object_factory'
    lighting = require './lighting'
    camera = require 'libraries/camera'
    cam = camera()
    

    --gameMap = sti('maps/industrial_area.lua')
    love.graphics.setDefaultFilter("nearest", "nearest") --removes blur from scaling

    --collision world
    world = bump.newWorld(32)

    -- scene control
    require './scene_organiser'
    sg = scene_organiser:create()
    current_scene = sg:getScene()
    gameMap = current_scene.map
    candidate_scene = nil -- if not nil then we should start drawing next scene and updating world objects (in love.update)
    
    -- create player
    require './humanoid'
    --player = spawn_pool.constructPlayer("Richard", current_scene.entry_x, current_scene.entry_y, world, lighting)
    player = humanoid:create("Dicky",0, 0, 32, 42, 32, 42)
    player:load()

    --projectiles
    projectiles = {}

    require './cameraman'
    mc = cameraman:create(cam, player.x, player.y, player.x, player.y, "smooth", 150)

    current_scene:load()
    --player = spawn_pool:create(player.hitbox = {xoff=32,yoff=42,width=32,height=42, init_xoff=32, init_yoff=42} )
    
    
    -- get collideables from scene map
    --current_scene:generateCollideablesFromMap(world)
    -- get lighting from scene map
    --current_scene:generateLightingFromMap(lighting)

    --game dimensions
    SCENE_WIDTH = current_scene:getWidth()
    SCENE_HEIGHT = current_scene:getHeight()

    
    

    -- create enemies
    --enemy = spawn_pool.constructPlayer("Enemy", 300, 524, world, lighting)
    --enemy2 = spawn_pool.constructPlayer("Enemy2", 200, 524, world, lighting)

    -- create collideable objects and/or scene decoration
    --pipe_cloud = animated_object_factory.constructCloud("pipe_cloud",752,224, world)

    --animated physical lights
    --light_1 = animated_object_factory.constructLight(175,490, lighting, "distance") --not sure need to animate light turning on or off
    --light_1.enabled = true
    --light_2 = animated_object_factory.constructLight(0.1,0.1, lighting, "godray")

    --backgriound hammers -- TODO: Make hammers foreground and hitboxes dynamic and collideable and hurt player
   -- hammer_1 = animated_object_factory.constructHammer("hammer1",384,512)
    --hammer_1.animations.turned_on:gotoFrame(2)
    --hammer_2 = animated_object_factory.constructHammer("hammer2",416,512)
    --hammer_2.animations.turned_on:gotoFrame(3)
    --hammer_3 = animated_object_factory.constructHammer("hammer3",448,512)
    --hammer_3.animations.turned_on:gotoFrame(4)
    --hammer_4 = animated_object_factory.constructHammer("hammer4",480,512)
    --hammer_4.animations.turned_on:gotoFrame(5)
    --hammer_5 = animated_object_factory.constructHammer("hammer5",512,512)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "t" then
        sg:getNextScene()
    end

    if key == "l" then
        for l=1,#lighting.distance_shading.distance_lights do
            local current_power = lighting.distance_shading.distance_lights[l].power
            local new_power = math.max(0,current_power - 50)
            
            lighting.distance_shading.distance_lights[l].power = new_power
        end
    end
    if key == "o" then
        for l=1,#lighting.distance_shading.distance_lights do
            local current_power = lighting.distance_shading.distance_lights[l].power
            local new_power = math.min(600,current_power + 50)

            lighting.distance_shading.distance_lights[l].power = new_power
        end
    end
    if key == "r" then --reset
        love.load()
    end

    if key == "c" then
        current_scene:setFocalPoint(1)
        --cam.move(current_scene.current_focal.x, current_scene.current_focal.y)
        for i=1, #current_scene.focal_points do
            local focx = current_scene.focal_points[i].x
            local focy = current_scene.focal_points[i].y
            local w = love.graphics.getWidth()
            local h = love.graphics.getHeight()
            print("focus: "..focx.." "..focy)
            mc.target.x = focx - w/2
            mc.target.y = focy - h/2
        end
    end

    if key == "p" then
        toggle_pause()
    end

    if key == "k" then
        shoot_player_from_mouse()
    end
end

function toggle_pause()
    PAUSED = not PAUSED
end

function shoot_player_from_mouse()
    -- get mouse
    local mx, my = love.mouse.getPosition()
    -- x
    if (mx) > SCENE_WIDTH then
        mx = SCENE_WIDTH
    elseif(mx) < 0 then
        mx = 0
    end
    -- y
    if (my) > SCENE_HEIGHT then
        my = SCENE_HEIGHT
    elseif(my) < 0 then
        my = 0
    end 

    -- move projectile to player
    local projectile = {}
    projectile.active = true
    projectile.type = PROJECTILE_TYPE
    projectile.x = mx
    projectile.y = my
    projectile.w = 5
    projectile.h = 5
    projectile.target = {}
    projectile.target.x = player.x+player.hitbox.xoff+player.hitbox.width/2
    projectile.target.y = player.y+player.hitbox.yoff+player.hitbox.height/2
    projectile.speed = 500
    projectile.velocity = {}
    projectile.velocity.x, projectile.velocity.y = calculateDiagonal(projectile, projectile.target)
    proj_debug_message = "x: ".. projectile.velocity.x.." y: "..projectile.velocity.y
    world:add(projectile, projectile.x, projectile.y, projectile.w, projectile.h)
    table.insert(projectiles,projectile)
end

function calculateDiagonal(source, destination)
    local x_axis = (destination.x-source.x)
    local y_axis = (destination.y-source.y)
    local diag_vec_mag = math.sqrt((x_axis*x_axis) + (y_axis*y_axis))
    if(diag_vec_mag > 0) then
        x_axis = x_axis / diag_vec_mag
        y_axis = y_axis / diag_vec_mag
    end
    return x_axis, y_axis
end

function outOfBounds(thing)
    if thing.x < 0 or thing.x > SCENE_WIDTH or thing.y > SCENE_HEIGHT or thing.y < 0 then
        return true
    end

    return false
end

function updateProjectiles(dt)
    local function collision_control(item, other)
        if other.type == FLOOR_TERRAIN_TYPE then
            return "cross"
        elseif other.type == HUMANOID_TYPE then
            return "cross"
        elseif other.type == PROJECTILE_TYPE then
            return "cross"
        else
            return false
        end
    end

    for p=1,#projectiles do
        if projectiles[p].active == false then
            world:remove(projectiles[p])
            table.remove(projectiles,p)
            break
        else
            --projectiles[p].x = projectiles[p].x + projectiles[p].velocity.x * dt * projectiles[p].speed 
            --projectiles[p].y = projectiles[p].y + projectiles[p].velocity.y * dt * projectiles[p].speed
            local target_x = projectiles[p].x + projectiles[p].velocity.x * dt * projectiles[p].speed
            local target_y = projectiles[p].y + projectiles[p].velocity.y * dt * projectiles[p].speed
            local actualX, actualY, cols, len = world:move(projectiles[p],target_x,target_y,collision_control)
            if len > 0 then
                projectiles[p].active = false
                for i=1, #cols do
                    if cols[i].other.type == HUMANOID_TYPE then
                        cols[i].other.survival.hp = cols[i].other.survival.hp - projectiles[p].speed * 0.1
                    end
                end
            end
            projectiles[p].x = target_x
            projectiles[p].y = target_y
            
            world:update(projectiles[p], projectiles[p].x, projectiles[p].y, projectiles[p].w, projectiles[p].h)
        end
    end
end

function evaluate_player_state(humanoid, dt)
    --landed on something, including landing as gravity pulls us while stood on ground
    if(humanoid.velocity.y == 0 and humanoid.falling) then
        humanoid.jumping = false
        humanoid.falling = false
        --print("setting sliding false 1")
        humanoid.sliding = false
    end
    
    if(humanoid.falling) then 
        local check = humanoid:check_wall_slide(world)
        if check == "left" then
            --print("left")
            --debug_message = "left"
            humanoid.x_dir = -1
            if (not humanoid.sliding) then
                humanoid.hitbox.xoff = humanoid.hitbox.init_xoff + 5 --once only adjust image a bit for slide
                humanoid.sliding = true
            end
        elseif check == "right" then
            --print("right")
            --debug_message = "right"
            humanoid.x_dir = 1
            if (not humanoid.sliding) then
                humanoid.hitbox.xoff = humanoid.hitbox.init_xoff - 5 --once only adjust image a bit for slide
                humanoid.sliding = true
            end
        else 
            --print("falling")
            --debug_message = "falling"
            --print("setting sliding false 2")
            humanoid.sliding = false
            humanoid.hitbox.xoff = humanoid.hitbox.init_xoff
            humanoid.hitbox.yoff = humanoid.hitbox.init_yoff
        end
    end

    if(humanoid.velocity.y > 0) then
        humanoid.falling = true
    end

    --to do move: show shield while recently damaged
    humanoid.powers.shield.x = humanoid.x + humanoid.hitbox.xoff + humanoid.hitbox.width/2
    humanoid.powers.shield.y = humanoid.y + humanoid.hitbox.yoff + humanoid.hitbox.height/2
    if(humanoid.survival.recently_damaged == true) then
        humanoid.powers.shield.enabled = true
        humanoid.survival.recent_damage_timer = humanoid.survival.recent_damage_timer + dt
        if(humanoid.survival.recent_damage_timer > humanoid.survival.recent_damage_timer_threshold) then
            humanoid.survival.recently_damaged = false
            humanoid.survival.recent_damage_timer = 0
        end
    else
        humanoid.powers.shield.enabled = false
    end

end

-- runs every 60 frames, dt delta time between this frame and last
function love.update(dt)

    if PAUSED then return end

    --debug_message = "num distance lights: "..(#lighting.distance_shading.distance_lights)
    -- check for scene change
    evaluate_should_change_scene()

    -- keep at top in order
    evaluate_player_state(player, dt)

    --inputs
    --right or left direction
    if(love.keyboard.isDown("d")) and (math.abs(player.velocity.x) < MAX_SPEED) then
        player.x_dir = 1
        player.velocity.x = player.velocity.x + (MAX_SPEED * dt)
    end
    if(love.keyboard.isDown("a") and (math.abs(player.velocity.x) < MAX_SPEED)) then
        player.x_dir = -1
        player.velocity.x = player.velocity.x - (MAX_SPEED * dt)
    end
    --jump/fall
    if((love.keyboard.isDown("space") and (not player.jumping))) then --if starting a jump or in the middle of a jump
        player.velocity.y = player.velocity.y - (player.leg_power)
        player.jumping = true
        player.climbing = false
        player.falling = false
    end
    --climb
    if(love.keyboard.isDown("s") and player:can_climb(world) and player.velocity.y < MAX_CLIMB_SPEED) then
        player.velocity.y = player.velocity.y + (MAX_CLIMB_SPEED * dt)
        player.climbing = true
        player.falling = false
        player.jumping = false
    elseif(love.keyboard.isDown("w") and player:can_climb(world) and player.velocity.y > -MAX_CLIMB_SPEED) then
        player.velocity.y = player.velocity.y - (MAX_CLIMB_SPEED * dt)
        player.climbing = true
        player.jumping = false
        player.falling = false
    end

 
    --add gravity and friction
    if player.climbing then
        ladder_physics(player,dt)
    else
        physics(player,dt)
    end
    
    --move scene objects
    move_a_humanoid_bounded(player, dt)
    --update animations based on velocity
    player:updateAnimationBasedOnVelocity(dt, world)

    -- TO DO: Generate automatic movement of enemy
    --move_a_humanoid_bounded(enemy, dt)
    --enemy.current_animation.animation:update(dt)

    --move_a_humanoid_bounded(enemy2, dt)
    --enemy2.current_animation.animation:update(dt)

    -- Scene animations
    --pipe cloud
    --direct_a_thing_up(pipe_cloud,1)
    --move_a_thing_bounded_reset(pipe_cloud)
    --pipe_cloud.animations.weak:update(dt)

    --hammer_1.animations.turned_on:update(dt)
    --hammer_2.animations.turned_on:update(dt)
    --hammer_3.animations.turned_on:update(dt)
    --hammer_4.animations.turned_on:update(dt)
    --hammer_5.animations.turned_on:update(dt)

    --toggle lights
    --if(love.keyboard.isDown("g")) then
    --    light_2.enabled = true
    --end
    
    mc:updateCameraFollowingPlayer()
    --mc:updateTween(dt)

    
    updateProjectiles(dt)
    

    

    -- collision world¬
    world:update(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
    
    --world:update(enemy, enemy.x+enemy.hitbox.xoff, enemy.y+enemy.hitbox.yoff, enemy.hitbox.width, enemy.hitbox.height)
    --world:update(enemy2, enemy2.x+enemy2.hitbox.xoff, enemy2.y+enemy2.hitbox.yoff, enemy.hitbox.width, enemy.hitbox.height)
    --world:update(pipe_cloud, pipe_cloud.x+pipe_cloud.hitbox.xoff, pipe_cloud.y+pipe_cloud.hitbox.yoff, pipe_cloud.hitbox.width, pipe_cloud.hitbox.height)

end



function flickerLights()
 --flicker lights
    --evaluate_flicker(light_1, dt)
    --check lights on or off
    --if(light_1.enabled == true) then
    --    light_1.animations.switch:gotoFrame(2)
    --else
    --    light_1.animations.switch:gotoFrame(1)
    --end
end






function physics(thing, dt)
    -- move done outside
    --debug_message = "x= " .. thing.x .. " y=" .. thing.y .. " velocity.x= " .. thing.velocity.x .. " velocity.y=" .. thing.velocity.y .. " -MAX_SPEED=" .. -MAX_SPEED
    thing.velocity.y = thing.velocity.y + GRAVITY * dt
	thing.velocity.x = thing.velocity.x * (1 - math.min(dt*FRICTION, 1))
    if(math.abs(thing.velocity.x) < 0.01)
    then
        thing.velocity.x = 0
    end
    -- adjust velocity based on factors
end

function ladder_physics(thing, dt)
    thing.velocity.y = thing.velocity.y * (1 - math.min(dt*FRICTION, 1))
	thing.velocity.x = thing.velocity.x * (1 - math.min(dt*FRICTION, 1)) 
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

function move_a_humanoid_bounded(humanoid, dt)
    -- move
    -- lambda so we only check floors for collisions
    local function collision_control(item, other)
        if other.type == FLOOR_TERRAIN_TYPE then
            return "slide"
        elseif other.type == HUMANOID_TYPE then
            return "bounce"
        elseif other.type == PROJECTILE_TYPE then
            return "cross"
        else
            return false
        end
    end

    -- test and do movement in collision world
    local initial_velx = humanoid.velocity.x
    local initial_vely = humanoid.velocity.y
    local hitbox_x = humanoid.x + humanoid.hitbox.xoff
    local hitbox_y = humanoid.y + humanoid.hitbox.yoff
    local target_x = hitbox_x + humanoid.velocity.x * dt
    local target_y = hitbox_y + humanoid.velocity.y * dt
    local actualX, actualY, cols, len = world:move(humanoid,target_x,target_y,collision_control) -- sim move, TO DO: Remove seperate horizontal and vertical collision checks
    local result_x = actualX - humanoid.hitbox.xoff
    local result_y = actualY - humanoid.hitbox.yoff
    humanoid:updateRootPosition(result_x, result_y)

    -- adjust velocities based on collision data
    -- stop on floors
    if(actualX ~= target_x and len > 0) then
        humanoid.velocity.x = 0
    end
    if(actualY ~= target_y and len > 0) then
        humanoid.velocity.y = 0
    end
    -- bounce off humans
    if(len > 0) then
        for i=1, #cols do
            if cols[i].other.type == HUMANOID_TYPE then
                humanoid.survival.recently_damaged = true
                --x
                if ((initial_velx > 0) and (cols[i].bounce.x > cols[i].touch.x)) or ((initial_velx < 0) and (cols[i].bounce.x < cols[i].touch.x)) then
                    humanoid.velocity.x = initial_velx
                else
                    humanoid.velocity.x = -initial_velx
                    humanoid.x_dir = -humanoid.x_dir
                end

                if ((initial_vely < 0) and (cols[i].bounce.y < cols[i].touch.y)) or ((initial_vely > 0) and (cols[i].bounce.y > cols[i].touch.y)) then
                    humanoid.velocity.y = initial_vely
                else
                    humanoid.velocity.y = -initial_vely
                end
            end
            -- projectiles moved to projectiles
            --if cols[i].other.type == PROJECTILE_TYPE then
             --   cols[i].other.active = false
             --   humanoid.survival.hp = humanoid.survival.hp - cols[i].other.speed * 0.1
             --   humanoid.survival.recently_damaged = true
            --end
        end
    end

    -- check movement hasn't put player off screen
    enforce_boundary(humanoid) -- also recommends scene change

end

function enforce_boundary(thing)
    local hitbox_x = thing.x + thing.hitbox.xoff
    local hitbox_y = thing.y + thing.hitbox.yoff
    local hitbox_width = thing.hitbox.width
    local hitbox_height = thing.hitbox.height
    local result_x = thing.x
    local result_y = thing.y

    if((hitbox_x+hitbox_width) > SCENE_WIDTH) then --dont touch
        result_x = SCENE_WIDTH - thing.hitbox.xoff - hitbox_width
        thing.velocity.x = 0
    elseif(hitbox_x < 0) then --dont touch
        result_x = 0 - thing.hitbox.xoff
        thing.velocity.x = 0
    end
    if (hitbox_y+hitbox_height > SCENE_HEIGHT) then -- base boundary
        candidate_scene = sg:getNextScene("base")
        if(candidate_scene == nil) then
            result_y = SCENE_HEIGHT - thing.hitbox.yoff - hitbox_height
            thing.velocity.y = 0
        end
    elseif ((thing.y+thing.hitbox.yoff < 0)) then -- top boundary
        result_y = 0
        thing.velocity.y = 0
    end
    thing:updateRootPosition(result_x,result_y)
end

function evaluate_should_change_scene()
    if candidate_scene ~= nil then -- if not nil then we should start drawing next scene and updating world objects (in love.update)
        --globals
        current_scene = candidate_scene
        candidate_scene = nil
        gameMap = current_scene.map
        SCENE_WIDTH = gameMap.width * gameMap.tilewidth
        SCENE_HEIGHT = gameMap.height * gameMap.tileheight
        
        --reset collideable world
        current_scene:load()
        --current_scene:generateCollideablesFromMap(world)
        --reset lighting
        --current_scene:generateLightingFromMap(lighting)
        --add player
        
    end
end

function move_with_cursor_bounded(thing)
    local mx, my = love.mouse.getPosition()

    if (mx) > SCENE_WIDTH then
        thing.x = SCENE_WIDTH
    elseif(mx) < 0 then
        thing.x = 0
    else
        thing.x = mx
    end
    -- y
    if (my) > SCENE_HEIGHT then
        thing.y = SCENE_HEIGHT
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
    if (thing.x + thing.velocity.x) > (SCENE_WIDTH + 64) then --make sure object goes off screen first
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
    if (thing.y + thing.velocity.y) > (SCENE_HEIGHT + 64) then
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
    if (thing.x + thing.velocity.x) > (SCENE_WIDTH+thing.velocity.x) then
        thing.x = 0
    elseif(thing.x + thing.velocity.x) < (0-thing.velocity.x) then
        thing.x = SCENE_WIDTH
    else
        thing.x = thing.x + thing.velocity.x
    end
    -- y
    if (thing.y + thing.velocity.y) > (SCENE_HEIGHT+thing.velocity.y) then
        thing.y = 0
    elseif(thing.y + thing.velocity.y) < (0-thing.velocity.y) then
        thing.y = SCENE_HEIGHT
    else
        thing.y = thing.y + thing.velocity.y
    end
end

--

local ofs = {0, 0}

function love.draw()

    if PAUSED then
        local paused_message = "PAUSED"
        
        local font       = love.graphics.getFont()
	    local textWidth  = font:getWidth(paused_message)
	    local textHeight = font:getHeight()

	    love.graphics.print(paused_message, (love.graphics.getWidth()/2), (love.graphics.getHeight()/2), 0, 1, 1, textWidth/2, textHeight/2)
        return
    end

    -- when scene 1
    if(current_scene:getName() == "industrial_area") then
    --if(true) then
        cam:attach()
            gameMap:drawLayer(gameMap.layers["Background"])
            --shading
            --lighting.startDistanceShading()
            --gameMap:drawLayer(gameMap.layers["Underbackground"]) 
            -- distance light   
            --hammer_1.animations.turned_on:draw(hammer_1.sprite_sheet, hammer_1.x, hammer_1.y, 0)
            --hammer_2.animations.turned_on:draw(hammer_2.sprite_sheet, hammer_2.x, hammer_2.y, 0)
            --hammer_3.animations.turned_on:draw(hammer_3.sprite_sheet, hammer_3.x, hammer_3.y, 0)
            --hammer_4.animations.turned_on:draw(hammer_4.sprite_sheet, hammer_4.x, hammer_4.y, 0)
            --hammer_5.animations.turned_on:draw(hammer_5.sprite_sheet, hammer_5.x, hammer_5.y, 0)
            --lighting:endShading()
            gameMap:drawLayer(gameMap.layers["Game-1"])
            --lighting.startGodrayShading()
            --light_1.animations.switch:draw(light_1.sprite_sheet, light_1.x, light_1.y)
            gameMap:drawLayer(gameMap.layers["Game"])
            for p=1, #projectiles do
                if projectiles[p].active then
                    love.graphics.rectangle("fill", projectiles[p].x, projectiles[p].y, projectiles[p].w, projectiles[p].h)
                end
            end
            gameMap:drawLayer(gameMap.layers["Game+1"])
            
            love.graphics.rectangle("line",player.x+player.hitbox.xoff-5, player.y+player.hitbox.yoff, player.hitbox.width+5, player.hitbox.height)
            if(player.powers.shield.enabled) then
                lighting.startDistanceShading()
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
                love.graphics.draw(player.powers.shield.image,player.x,player.y + 6)
                lighting.endShading()
            else
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
            end
            
            --love.graphics.rectangle("line",player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
            --enemy.current_animation.animation:draw(enemy.current_animation.sprite_sheet, enemy.x, enemy.y, 0, enemy.scale, enemy.scale, 0, 0)
            --enemy2.current_animation.animation:draw(enemy2.current_animation.sprite_sheet, enemy2.x, enemy2.y, 0, enemy2.scale, enemy2.scale, 0, 0)
            --pipe_cloud.animations.weak:draw(pipe_cloud.sprite_sheet, pipe_cloud.x, pipe_cloud.y, 0.1, 1, 1, 0, 0)
            --love.graphics.rectangle("line", pipe_cloud.x+pipe_cloud.hitbox.xoff, pipe_cloud.y+pipe_cloud.hitbox.yoff, pipe_cloud.hitbox.width, pipe_cloud.hitbox.height)

            if(player.powers.shield.enabled) then
                lighting.startDistanceShading()
                love.graphics.draw(player.powers.shield.image,player.x,player.y + 6)
                lighting.endShading()
            end
        
            gameMap:drawLayer(gameMap.layers["Foreground"])

        cam:detach()

        love.graphics.print("HP: "..player.survival.hp, 10, 10)
        love.graphics.print("Debug: " .. proj_debug_message, 10, 30)
    end
    -- end scene 1
    -- if scene 2
    if(current_scene:getName() == "chasm") then
        cam:attach()
            gameMap:drawLayer(gameMap.layers["Background"])
            gameMap:drawLayer(gameMap.layers["Game"])
            lighting.endShading()
            love.graphics.rectangle("line",player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
            if(player.powers.shield.enabled) then
                lighting.startDistanceShading()
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
                love.graphics.draw(player.powers.shield.image,player.x,player.y + 6)
                lighting.endShading()
            else
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
            end
            gameMap:drawLayer(gameMap.layers["Foreground"])
        cam:detach()

        love.graphics.print("HP: ", 10, 10)
        love.graphics.print("Debug: " .. debug_message, 10, 30)
    end
    -- end scene2
    -- if scene 3
    if(current_scene:getName() == "pit") then
        cam:attach()
            gameMap:drawLayer(gameMap.layers["Background"])
            gameMap:drawLayer(gameMap.layers["Game-1"])
            gameMap:drawLayer(gameMap.layers["Game"])
            gameMap:drawLayer(gameMap.layers["Game+1"])
            gameMap:drawLayer(gameMap.layers["Foreground"])
            if(player.powers.shield.enabled) then
                lighting.startDistanceShading()
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
                love.graphics.draw(player.powers.shield.image,player.x,player.y + 6)
                lighting.endShading()
            else
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
            end
        cam:detach()

        love.graphics.print("HP: ", 10, 10)
        love.graphics.print("Debug: " .. debug_message, 10, 30)
    end
     -- if scene 3
    if(current_scene:getName() == "garbage") then
        cam:attach()
            gameMap:drawLayer(gameMap.layers["Background"])

            gameMap:drawLayer(gameMap.layers["Game-1"])
            gameMap:drawLayer(gameMap.layers["Game"])
            gameMap:drawLayer(gameMap.layers["Game+1"])
            gameMap:drawLayer(gameMap.layers["Foreground"])
            if(player.powers.shield.enabled) then
                lighting.startDistanceShading()
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
                love.graphics.draw(player.powers.shield.image,player.x,player.y + 6)
                lighting.endShading()
            else
                player.current_animation.animation:draw(player.current_animation.sprite_sheet, player.x, player.y, 0, player.scale, player.scale, 0, 0)
            end
        cam:detach()

        love.graphics.print("HP: ", 10, 10)
        love.graphics.print("Debug: " .. debug_message, 10, 30)
    end
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
    if (thing.y >= (SCENE_HEIGHT)) or (thing.y <= 0) then
        new_dy = -new_dy
        thing.velocity.y = -1 * thing.velocity.y
    end
    if (thing.x >= (SCENE_WIDTH)) or (thing.x <= 0) then
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