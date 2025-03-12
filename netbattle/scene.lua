scene = {}
scene.__index = scene

function scene:create(name, entry_x, entry_y, song)
    local s = {}
    setmetatable(s, scene)
    s.name = name
    s.entry_x = entry_x
    s.entry_y = entry_y
    s.exit_boundary = "base"
    s.lights = {}
    s.focal_points = {}

    s.current_focal_point = nil
    local map_path = 'assets/'..name..'.lua'
    local music_path = 'audio/'..song..'.ogg'
    print(map_path)
    s.map = sti(map_path)
    s.background_music = music_path
    --s.animation = {}
    --s.animation.sprite_sheet = love.graphics.newImage(animation_file) --change
    --s.animation.grid = anim8.newGrid(32,32,s.animation.sprite_sheet:getWidth(),s.animation.sprite_sheet:getHeight())
    --s.animation.run = anim8.newAnimation(s.animation.grid('1-96',1),0.1) --start slow

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

function scene:load()
    projectiles = {}
    for p=1, #projectiles do
        world:remove(projectile[p])
    end
    --current_focal_point
    self.current_focal_point = self.focal_points[1]

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
    -- audio
    audio = love.audio.newSource(self.background_music, "stream")
    audio:setVolume(0.8)
    audio:play()
end

function scene:setFocalPoint(index)
    for i=1,#self.focal_points do
        if i == index then
            self.current_focal_point = self.focal_points[index]
        end
    end
end

