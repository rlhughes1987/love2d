require './scene'

scene_organiser = {}
scene_organiser.__index = scene_organiser

function scene_organiser:create()
    local sg = {}
    setmetatable(sg, scene_organiser)
    sg.scenes = {
        scene:create("industrial_area", 30, 220),
        scene:create("chasm", 416, 0),
        scene:create("pit", 448, 0),
        scene:create("garbage", 448,0)
    }
    sg.current_scene_index = 1
    return sg
end

function scene_organiser:getScene()
    local c_s = self.scenes[self.current_scene_index]
    return c_s
end

function scene_organiser:getNextScene(direction)

    if direction == "base" then
        --pick a specific scene
    end
    --extend for other directions

    -- for now just cycle whatever
    if self.current_scene_index == #self.scenes then -- reset if at end
        --to do: do something
    else
        self.current_scene_index = self.current_scene_index + 1 --otherwise increment
    end

    return self:getScene()
end