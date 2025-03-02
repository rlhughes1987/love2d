humanoid = {}
humanoid.__index = humanoid

function humanoid:create(name, x, y, hitbox_xoff, hitbox_yoff, hitbox_w, hitbox_h)
    local h = {}
    setmetatable(h, humanoid)
    h.type = "humanoid"
    h.init_x = x
    h.name = name
    h.init_y = y
    h.x = x
    h.y = y
    h.hitbox = {xoff=hitbox_xoff,yoff=hitbox_yoff,width=hitbox_w,height=hitbox_h,init_xoff=hitbox_xoff,init_yoff=hitbox_yoff} --offset from image coord
    h.x_dir = 1 -- use to face character
    h.velocity = {x=0,y=0}
    h.animation_rate = 1 -- use to speed up animation
    h.scale = 1
    h.leg_power = 300 --jump velocity
    h.jumping = false
    h.climbing = false
    h.falling = false
    h.sliding = false
    h.knocked_down = false
    --animations
    h.animations = {
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
        wall_slide_right = {},
        knock_back = {}
    }
    h.current_animation = nil -- randomize starting facing

    h.powers = {}
    h.powers.shield = {}
    h.powers.shield.image = love.graphics.newImage('sprites/4 Proto/shield.png')
    h.powers.shield.enabled = false
    h.powers.shield.x = x + hitbox_xoff + hitbox_w/2
    h.powers.shield.y = y + hitbox_yoff + hitbox_h/2

    h.survival = {}
    h.survival.hp = 100
    h.survival.recently_damaged = false
    h.survival.recent_damage_timer = 0.0
    h.survival.recent_damage_timer_threshold = 0.15 -- duration can be used to hold animations in view
    return h
end

function humanoid:load()
    -- animation data
    self.animations.walking_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/walk-left.png')
    self.animations.walking_left.grid = anim8.newGrid(96,84,self.animations.walking_left.sprite_sheet:getWidth(),self.animations.walking_left.sprite_sheet:getHeight())
    self.animations.walking_left.animation = anim8.newAnimation(self.animations.walking_left.grid('1-8',1),0.1) --start slow
    self.animations.walking_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/walk-right.png')
    self.animations.walking_right.grid = anim8.newGrid(96,84,self.animations.walking_right.sprite_sheet:getWidth(),self.animations.walking_right.sprite_sheet:getHeight())
    self.animations.walking_right.animation = anim8.newAnimation(self.animations.walking_right.grid('1-8',1),0.1) --start slow      
    self.animations.jump_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/jump-left.png')
    self.animations.jump_left.grid = anim8.newGrid(96,84,self.animations.jump_left.sprite_sheet:getWidth(),self.animations.jump_left.sprite_sheet:getHeight())
    self.animations.jump_left.animation = anim8.newAnimation(self.animations.jump_left.grid('1-3',1),0.5) --start slow
    self.animations.jump_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/jump-right.png')
    self.animations.jump_right.grid = anim8.newGrid(96,84,self.animations.jump_right.sprite_sheet:getWidth(),self.animations.jump_right.sprite_sheet:getHeight())
    self.animations.jump_right.animation = anim8.newAnimation(self.animations.jump_right.grid('1-3',1),0.5) --start slow
    self.animations.idle_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/idle-left.png')
    self.animations.idle_left.grid = anim8.newGrid(96,84,self.animations.idle_left.sprite_sheet:getWidth(),self.animations.idle_left.sprite_sheet:getHeight())
    self.animations.idle_left.animation = anim8.newAnimation(self.animations.idle_left.grid('1-7',1),0.15) --start slow
    self.animations.idle_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/idle-right.png')
    self.animations.idle_right.grid = anim8.newGrid(96,84,self.animations.idle_right.sprite_sheet:getWidth(),self.animations.idle_right.sprite_sheet:getHeight())
    self.animations.idle_right.animation = anim8.newAnimation(self.animations.idle_right.grid('1-7',1),0.15) --start slow
    self.animations.climbing.sprite_sheet = love.graphics.newImage('sprites/4 Proto/climbing.png')
    self.animations.climbing.grid = anim8.newGrid(96,84,self.animations.climbing.sprite_sheet:getWidth(),self.animations.climbing.sprite_sheet:getHeight())
    self.animations.climbing.animation = anim8.newAnimation(self.animations.climbing.grid('1-8',1),0.15) --start slow
    self.animations.idle_climbing.sprite_sheet = love.graphics.newImage('sprites/4 Proto/idle-climbing.png')
    self.animations.idle_climbing.grid = anim8.newGrid(96,84,self.animations.idle_climbing.sprite_sheet:getWidth(),self.animations.idle_climbing.sprite_sheet:getHeight())
    self.animations.idle_climbing.animation = anim8.newAnimation(self.animations.idle_climbing.grid('1-7',1),0.15) --start slow
    self.animations.roll_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/roll-left.png')
    self.animations.roll_left.grid = anim8.newGrid(96,84,self.animations.roll_left.sprite_sheet:getWidth(),self.animations.roll_left.sprite_sheet:getHeight())
    self.animations.roll_left.animation = anim8.newAnimation(self.animations.roll_left.grid('2-9',1),0.1)
    self.animations.roll_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/roll-right.png')
    self.animations.roll_right.grid = anim8.newGrid(96,84,self.animations.roll_right.sprite_sheet:getWidth(),self.animations.roll_right.sprite_sheet:getHeight())
    self.animations.roll_right.animation = anim8.newAnimation(self.animations.roll_right.grid('2-9',1),0.1)
    self.animations.wall_slide_left.sprite_sheet = love.graphics.newImage('sprites/4 Proto/wall-slide-left.png')
    self.animations.wall_slide_left.grid = anim8.newGrid(96,84,self.animations.wall_slide_left.sprite_sheet:getWidth(),self.animations.wall_slide_left.sprite_sheet:getHeight())
    self.animations.wall_slide_left.animation = anim8.newAnimation(self.animations.wall_slide_left.grid('1-6',1),0.05)
    self.animations.wall_slide_right.sprite_sheet = love.graphics.newImage('sprites/4 Proto/wall-slide-right.png')
    self.animations.wall_slide_right.grid = anim8.newGrid(96,84,self.animations.wall_slide_right.sprite_sheet:getWidth(),self.animations.wall_slide_right.sprite_sheet:getHeight())
    self.animations.wall_slide_right.animation = anim8.newAnimation(self.animations.wall_slide_right.grid('1-6',1),0.05)
    self.animations.knock_back.sprite_sheet = love.graphics.newImage('sprites/4 Proto/knockback.png')
    self.animations.knock_back.grid = anim8.newGrid(96,84,self.animations.knock_back.sprite_sheet:getWidth(),self.animations.knock_back.sprite_sheet:getHeight())
    self.animations.knock_back.animation = anim8.newAnimation(self.animations.knock_back.grid('1-6',1),0.05)
    self.current_animation = self.animations.idle_right
    -- add to collision world
    world:add(self, self.x+self.hitbox.xoff, self.y+self.hitbox.yoff, self.hitbox.width, self.hitbox.height)
    -- lighting elements
    if self.powers.shield.enabled == true then
        lighting.addDistanceLight(self.shield, 30, 1.0, 1.0, 1.0)
    end
end

function humanoid:updateAnimationBasedOnVelocity(dt, world)
    --update animation rate
    if math.abs(player.velocity.x) > 250 then
        self.animation_rate = 3
    else
       self.animation_rate = 1
    end
    --jumping
    if(self.velocity.y ~= 0 and self.jumping) then
        if self.x_dir > 0 then
            self.current_animation = self.animations.jump_right
        elseif self.x_dir < 0 then
            self.current_animation = self.animations.jump_left
        end
    end
    debug_message = "hitbox.x: " .. self.hitbox.xoff + self.x.." falling: " ..tostring(self.falling).." jumping: "..tostring(self.jumping).." sliding: "..tostring(self.sliding)
    --walking
    if(self.velocity.y == 0 and (not self.falling) and (not self.jumping)) then
        if self.x_dir > 0 then
            self.current_animation = self.animations.walking_right
        elseif self.x_dir < 0 then
            self.current_animation = self.animations.walking_left
        end
    end
    --idle
    if (self.velocity.x ==0 and self.velocity.y == 0) then
        if(self.x_dir < 0) then
            self.current_animation = self.animations.idle_left
        else
            self.current_animation = self.animations.idle_right
        end
    end
    --climbing
    if (self.climbing) then
        if (self.velocity.y ~= 0) then
            self.current_animation = self.animations.climbing
        else
            self.current_animation = self.animations.idle_climbing
        end
    end
    --falling / sliding
    if(self.velocity.y > 0 and self.falling) then
        --print("sliding: "..tostring(self.sliding))
        if(self.sliding) then -- sliding
            if(self.x_dir < 0) then
                self.current_animation = self.animations.wall_slide_left -- no falling animation with protoype
            else
                self.current_animation = self.animations.wall_slide_right
            end
        else -- falling
            if(self.x_dir < 0) then
                self.current_animation = self.animations.roll_left -- no falling animation with protoype
            else
                self.current_animation = self.animations.roll_right
            end
        end
    end
    self.current_animation.animation:update(dt * self.animation_rate)
end

function humanoid:calculate_knockdown(collider) -- if hit form right we want to do a knockback animation to the left.
    self.knocked_down = true
    -- determine net trajectory of player after receiving collision
    self.velocity.x = self.velocity.x - collider.velocity.x
    self.velocity.y = self.velocity.y - collider.velocity.y

    if(self.velocity.x < 0) then
        self.x_dir = -1
    else 
        self.x_dir = 1
    end
end

function humanoid:check_wall_slide(world)
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
        --print("checking xl:"..xl.." yl:"..yl)

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
        --print("checking xr:"..xr.." yr:"..yr)

        local itemsr, lenr = world:queryPoint(xr,yr, is_floor)
        if(lenr > 0) then
            return "right"
        end
    end
    return "none"
end

function humanoid:can_climb(world)
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


function humanoid:updateRootPosition(x,y)
    self.x = x
    self.y = y
    -- now update things anchored to the player e.g. shield
    self.powers.shield.x = self.x + self.hitbox.xoff + self.hitbox.width/2
    self.powers.shield.y = self.y + self.hitbox.yoff + self.hitbox.height/2
    -- extend
end

