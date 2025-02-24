
mycamera = {}
mycamera.__index = mycamera

function mycamera:create(cam, init_x, init_y, target_x, target_y, type, velocity)
    local mc = {}
    setmetatable(mc, mycamera)
    mc.cam = cam
    mc.init = {x=init_x, y=init_y}
    mc.current = {x=init_x, y=init_y}
    mc.target = {x=target_x, y=target_y}
    mc.type = type -- some type of transition/motion
    mc.velocity = velocity
    return mc
end

function mycamera:lookAt(x, y)
    self.cam:lookAt(x, y)
end

function mycamera:updateCameraFollowingPlayer()
    self.cam:lookAt(player.x, player.y)
    print("follow player lookat : x:"..self.cam.x.." y:"..self.cam.y)
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

function mycamera:updatePosition(x, y)
    self.cam.x = x
    self.current.x = x
    self.cam.y = y
    self.current.y = y
end

function mycamera:updateTargetPosition(x, y)
    self.target.x = x
    self.target.y = y
end

function mycamera:updateTween(dt)

    if self.target.x > self.current.x then
        self.current.x = self.current.x + self.velocity * dt
        self.cam.x = self.cam.x + self.velocity * dt
    end
    if self.target.y > self.current.y then
        self.current.y = self.current.y + self.velocity * dt
        self.cam.y = self.cam.y + self.velocity * dt
    end
    self.cam:lookAt(self.cam.x, self.cam.y)
    print(" update tween lookat : x:"..self.cam.x.." y:"..self.cam.y)
end