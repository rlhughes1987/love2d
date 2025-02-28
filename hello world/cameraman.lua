
cameraman = {}
cameraman.__index = cameraman

function cameraman:create(cam, init_x, init_y, target_x, target_y, type, velocity)
    local mc = {}
    setmetatable(mc, cameraman)
    mc.cam = cam
    mc.init = {x=init_x, y=init_y}
    mc.current = {x=init_x, y=init_y}
    mc.target = {x=target_x, y=target_y}
    mc.type = type -- some type of transition/motion
    mc.velocity = {x = 0, y = 0}
    mc.speed = 80
    return mc
end

function cameraman:lookAt(x, y)
    self.cam:lookAt(x, y)
end

function cameraman:updateCameraFollowingPlayer()
    self.cam:lookAt(player.x, player.y)
    --print("follow player lookat : x:"..self.cam.x.." y:"..self.cam.y)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    --bound camera to left scene edge
    if self.cam.x < w/2 then
        self.cam.x = w/2
    end
    --top edge
    if self.cam.y < h/2 then
        self.cam.y = h/2
    end
    --local mapW = gameMap.width * gameMap.tilewidth
    --local mapH = gameMap.height * gameMap.tileheight
    --right edge
    if self.cam.x > (SCENE_WIDTH - w/2) then
        self.cam.x = (SCENE_WIDTH - w/2)
    end
    -- bottom edge
    if self.cam.y > (SCENE_HEIGHT - h/2) then
        self.cam.y = (SCENE_HEIGHT - h/2)
    end

end

function cameraman:updatePosition(x, y)
    self.cam.x = x
    self.current.x = x
    self.cam.y = y
    self.current.y = y
end

function cameraman:updateTargetPosition(x, y)
    self.target.x = x
    self.target.y = y
end

function cameraman:updateTween(dt)
    --normalise diagonal to determine x and y magnitudes toward target
    local x_axis = (self.target.x-self.current.x)
    local y_axis = (self.target.y-self.current.y)
    local diag_vec_mag = math.sqrt((x_axis*x_axis) + (y_axis*y_axis))
    if(diag_vec_mag > 0) then
        x_axis = x_axis / diag_vec_mag
        y_axis = y_axis / diag_vec_mag
    end
    
    self.velocity.x = x_axis
    self.velocity.y = y_axis
    
    if self.target.x > self.current.x then
        self.current.x = self.current.x + self.velocity.x * dt * self.speed
        self.cam.x = self.cam.x + self.velocity.x * dt * self.speed
    end
    if self.target.y > self.current.y then
        self.current.y = self.current.y + self.velocity.y * dt * self.speed
        self.cam.y = self.cam.y + self.velocity.y * dt * self.speed
    end
    self.cam:lookAt(self.cam.x, self.cam.y)
    --print(" update tween lookat : x:"..self.cam.x.." y:"..self.cam.y.. " vel.x:"..self.velocity.x.." vel.y:"..self.velocity.y)
end