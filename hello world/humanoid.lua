local humanoid = {}

local animations = {
    walking_left = {},
    walking_right = {},
    jump_left = {},
    jump_right = {},
    idle_left = {},
    idle_right = {},
    climbing = {},
    idle_climbing = {},
    roll_left = {},
    roll_right = {},
    wall_slide_left = {},
    wall_slide_right = {}
}

animations.walking_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/walk-left.png')
animations.walking_left.grid = anim8.newGrid(96,84,animations.walking_left.sprite_sheet:getWidth(), animations.walking_left.sprite_sheet:getHeight())
animations.walking_left.animation = anim8.newAnimation(animations.walking_left.grid('1-8',1),0.1) --start slow
animations.walking_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/walk-right.png')
animations.walking_right.grid = anim8.newGrid(96,84,animations.walking_right.sprite_sheet:getWidth(), animations.walking_right.sprite_sheet:getHeight())
animations.walking_right.animation = anim8.newAnimation(animations.walking_right.grid('1-8',1),0.1) --start slow      
animations.jump_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/jump-left.png')
animations.jump_left.grid = anim8.newGrid(96,84,animations.jump_left.sprite_sheet:getWidth(), animations.jump_left.sprite_sheet:getHeight())
animations.jump_left.animation = anim8.newAnimation(animations.jump_left.grid('1-3',1),0.5) --start slow
animations.jump_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/jump-right.png')
animations.jump_right.grid = anim8.newGrid(96,84,animations.jump_right.sprite_sheet:getWidth(), animations.jump_right.sprite_sheet:getHeight())
animations.jump_right.animation = anim8.newAnimation(animations.jump_right.grid('1-3',1),0.5) --start slow
animations.idle_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/idle-left.png')
animations.idle_left.grid = anim8.newGrid(96,84,animations.idle_left.sprite_sheet:getWidth(), animations.idle_left.sprite_sheet:getHeight())
animations.idle_left.animation = anim8.newAnimation(animations.idle_left.grid('1-7',1),0.15) --start slow
animations.idle_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/idle-right.png')
animations.idle_right.grid = anim8.newGrid(96,84,animations.idle_right.sprite_sheet:getWidth(), animations.idle_right.sprite_sheet:getHeight())
animations.idle_right.animation = anim8.newAnimation(animations.idle_right.grid('1-7',1),0.15) --start slow
animations.climbing.sprite_sheet = love.graphics.newImage('sprites/4 Proto/climbing.png')
animations.climbing.grid = anim8.newGrid(96,84,animations.climbing.sprite_sheet:getWidth(), animations.climbing.sprite_sheet:getHeight())
animations.climbing.animation = anim8.newAnimation(animations.climbing.grid('1-8',1),0.15) --start slow
animations.idle_climbing.sprite_sheet = love.graphics.newImage('sprites/4 Proto/idle-climbing.png')
animations.idle_climbing.grid = anim8.newGrid(96,84,animations.idle_climbing.sprite_sheet:getWidth(), animations.idle_climbing.sprite_sheet:getHeight())
animations.idle_climbing.animation = anim8.newAnimation(animations.idle_climbing.grid('1-7',1),0.15) --start slow
animations.roll_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/roll-left.png')
animations.roll_left.grid = anim8.newGrid(96,84,animations.roll_left.sprite_sheet:getWidth(), animations.roll_left.sprite_sheet:getHeight())
animations.roll_left.animation = anim8.newAnimation(animations.roll_left.grid('2-9',1),0.1)
animations.roll_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/roll-right.png')
animations.roll_right.grid = anim8.newGrid(96,84,animations.roll_right.sprite_sheet:getWidth(), animations.roll_right.sprite_sheet:getHeight())
animations.roll_right.animation = anim8.newAnimation(animations.roll_right.grid('2-9',1),0.1)
animations.wall_slide_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/wall-slide-left.png')
animations.wall_slide_left.grid = anim8.newGrid(96,84,animations.wall_slide_left.sprite_sheet:getWidth(), animations.wall_slide_left.sprite_sheet:getHeight())
animations.wall_slide_left.animation = anim8.newAnimation(animations.wall_slide_left.grid('1-6',1),0.05)
animations.wall_slide_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/wall-slide-right.png')
animations.wall_slide_right.grid = anim8.newGrid(96,84,animations.wall_slide_right.sprite_sheet:getWidth(), animations.wall_slide_right.sprite_sheet:getHeight())
animations.wall_slide_right.animation = anim8.newAnimation(animations.wall_slide_right.grid('1-6',1),0.05)

function humanoid.constructPlayer(name,x,y, world, lighting)
    local player = {}
    player.type = "humanoid"
    player.name = name
    player.init_x = x
    player.init_y = y
    player.x = x
    player.y = y
    player.w = 32
    player.h = 32
    player.hitbox = {xoff=32,yoff=42,width=32,height=42, init_xoff=32, init_yoff=42} --offset from image coord
    player.lastvelocity = {x=1, y=0} --start aimed to right, generally used to store direction character faces based on recent movements
    player.x_dir = 1 -- use to face character
    player.velocity = {x=0,y=0}
    player.current_animation = (math.random(0,1)==0) and animations.idle_left or animations.idle_right -- randomize starting facing
    player.animation_rate = 1 -- use to speed up animation
    player.scale = 1
    player.leg_power = 300 --jump velocity
    player.jumping = false
    player.climbing = false
    player.falling = false
    player.sliding = false

    player.powers = {}
    player.powers.shield = {}
    player.powers.shield.image = love.graphics.newImage('sprites/4 Proto/shield.png')
    player.powers.shield.enabled = false
    player.powers.shield.x = player.x + player.hitbox.xoff + player.hitbox.width/2
    player.powers.shield.y = player.y + player.hitbox.yoff + player.hitbox.height/2

    player.survival = {}
    player.survival.recently_damaged = false
    player.survival.recent_damage_timer = 0.0
    player.survival.recent_damage_timer_threshold = 0.15 -- duration can be used to hold animations in view

    --add to collideable world
    world:add(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)

    --shield affects lighting
    lighting.addDistanceLight(player.powers.shield, 300, 0.8, 0.8, 1)

    function player:updateAnimationBasedOnVelocity(dt, world)
        --update animation rate
        if math.abs(player.velocity.x) > 250 then
            self.animation_rate = 3
        else
           self.animation_rate = 1
        end
        --jumping
        if(self.velocity.y ~= 0 and self.jumping) then
            if self.x_dir > 0 then
                self.current_animation = animations.jump_right
            elseif self.x_dir < 0 then
                self.current_animation = animations.jump_left
            end
        end
        debug_message = "hitbox.x: " .. self.hitbox.xoff + self.x.." falling: " ..tostring(self.falling).." jumping: "..tostring(self.jumping).." sliding: "..tostring(self.sliding)
        --walking
        if(self.velocity.y == 0 and (not self.falling) and (not self.jumping)) then
            if self.x_dir > 0 then
                self.current_animation = animations.walking_right
            elseif self.x_dir < 0 then
                self.current_animation = animations.walking_left
            end
        end
        --idle
        if (self.velocity.x ==0 and self.velocity.y == 0) then
            if(self.x_dir < 0) then
                self.current_animation = animations.idle_left
            else
                self.current_animation = animations.idle_right
            end
        end
        --climbing
        if (self.climbing) then
            if (self.velocity.y ~= 0) then
                self.current_animation = animations.climbing
            else
                self.current_animation = animations.idle_climbing
            end
        end
        --falling / sliding
        if(self.velocity.y > 0 and self.falling) then
            print("sliding: "..tostring(self.sliding))
            if(self.sliding) then -- sliding
                if(self.x_dir < 0) then
                    self.current_animation = animations.wall_slide_left -- no falling animation with protoype
                else
                    self.current_animation = animations.wall_slide_right
                end
            else -- falling
                if(self.x_dir < 0) then
                    self.current_animation = animations.roll_left -- no falling animation with protoype
                else
                    self.current_animation = animations.roll_right
                end
            end
        end
        self.current_animation.animation:update(dt * self.animation_rate)
    end

    function player:check_wall_slide(world)
        if(self.velocity.y > 0) then
            local function is_floor(other)
                return other.type == FLOOR_TERRAIN_TYPE
            end
            --query left
            local hit_x = self.x + self.hitbox.xoff
            local hit_y = self.y + self.hitbox.yoff
            local check_distance = 5
            if(player.sliding) then
                check_distance = check_distance * 2 --only necessary because hitbox moves when sliding
            end
            local xl = hit_x - check_distance
            local yl = hit_y + (self.hitbox.height / 2)
            print("checking xl:"..xl.." yl:"..yl)

            local function is_floor(other)
                return other.type == FLOOR_TERRAIN_TYPE
            end
    
            local items, len = world:queryPoint(xl,yl, is_floor)
            if(len > 0) then
                return "left"
            end
            --query right
            local xr = hit_x + self.hitbox.width + check_distance
            local yr = hit_y + (self.hitbox.height / 2)
            print("checking xr:"..xr.." yr:"..yr)
    
            local itemsr, lenr = world:queryPoint(xr,yr, is_floor)
            if(lenr > 0) then
                return "right"
            end
        end
        return "none"
    end

    function player:can_climb(world)
        local hit_x = self.x + self.hitbox.xoff
        local hit_y = self.y + self.hitbox.yoff
    
        local x = hit_x + (self.hitbox.width / 2)
        local y = hit_y + (self.hitbox.height / 2)
    
        local function is_ladder(other)
            return other.type == LADDER_TERRAIN_TYPE
        end
    
        local items, len = world:queryPoint(x,y, is_ladder)
        return len > 0
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

return humanoid