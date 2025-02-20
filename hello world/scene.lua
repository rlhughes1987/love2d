scene = {}
scene.__index = scene

function scene:create(name, entry_x, entry_y)
    local s = {}
    setmetatable(s, scene)
    s.name = name
    s.entry_x = entry_x
    s.entry_y = entry_y
    s.exit_boundary = "base"
    s.floors = {}
    s.ladders = {}
    s.lights = {}
    s.focal_points = {}
    s.current_focal_point = {entry_x, entry_y}
    local map_path = 'maps/'..name..'.lua'
    print(map_path)
    s.map = sti(map_path)
    return s
end

function scene:getName()
    return self.name
end

function scene:getExit()
    return self.player_exit_boundary
end

function scene:getWidth()
    return self.map.width * self.map.tilewidth
end

function scene:getHeight()
    return self.map.height * self.map.tileheight
end

function scene:getEntryX()
    return self.entry_x
end

function scene:getEntryY()
    return self.entry_y
end

function scene:load(world, lighting, player)
    player:updateRootPosition(self.entry_x,self.entry_y)
    --reset collision world
    world = bump.newWorld(32)
    -- put player in scene
    self:generateCollideablesFromMap(world)
    -- add collideables
    -- reset and add lighting
    lighting.reset()
    self:generateLightingFromMap(lighting)
    world:add(player, player.x+player.hitbox.xoff, player.y+player.hitbox.yoff, player.hitbox.width, player.hitbox.height)
    -- update focal points for camera
    self:generateFocalPointsFromMap()
end

function scene:setFocalPoint(index)
    if index <= #self.focal_points then
        self.current_focal_point = self.focal_points[index]
    end
end

function scene:generateCollideablesFromMap(world)
    local obj_factory = require './animated_object_factory'
    --floors from tiled
    self.floors = {}
    local floor_type = "floor"
    if self.map.layers["Floors"] then
        for i, obj in pairs(self.map.layers["Floors"].objects) do
            local some_floor = obj_factory.constructAnimatedTerrain(floor_type, obj.x,obj.y,obj.width,obj.height, world)
            table.insert(self.floors,some_floor)
        end
    end
    --ladders from tiled
    self.ladders = {}
    local ladder_type = "ladder"
    if self.map.layers["Ladders"] then
        for i,obj in pairs(self.map.layers["Ladders"].objects) do
            local some_floor = obj_factory.constructAnimatedTerrain(ladder_type, obj.x,obj.y,obj.width,obj.height, world)
            table.insert(self.ladders,some_floor)
        end
    end
end

function scene:generateLightingFromMap(lighting)
    --blue distance lights
    self.lights = {}
    local blue_light_type = "blue_distance_light"
    if self.map.layers["BlueDistanceLights"] then
        for i,obj in pairs(self.map.layers["BlueDistanceLights"].objects) do
            local some_light = { enabled = true, x = obj.x+obj.width/2, y = obj.y+obj.height/2}
            table.insert(self.lights,some_light)
            lighting.addDistanceLight(some_light, 300, 0.8, 0.8, 1)
        end
    end
    local white_light_type = "white_distance_light"
    if self.map.layers["WhiteDistanceLights"] then
        for i,obj in pairs(self.map.layers["WhiteDistanceLights"].objects) do
            local some_light = { enabled = true, x = obj.x+obj.width/2, y = obj.y+obj.height/2}
            table.insert(self.lights,some_light)
            lighting.addDistanceLight(some_light, 200, 1.0, 1.0, 1.0)
        end
    end
end

function scene:generateFocalPointsFromMap() -- for camera to move to at start of scene
    --blue distance lights
    self.focal_points = {}
    local focal_type = "Boss"
    if self.map.layers["FocalPoints"] then
        for i,obj in pairs(self.map.layers["FocalPoints"].objects) do
            local some_focal_point = { x = obj.x+obj.width/2, y = obj.y+obj.height/2}
            table.insert(self.focal_points,some_focal_point)
        end
    end
end
