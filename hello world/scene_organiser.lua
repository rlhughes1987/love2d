require './scene'

scene_organiser = {}
scene_organiser.__index = scene_organiser

function scene_organiser:create()
    local sg = {}
    setmetatable(sg, scene_organiser)

    --local scene1 = scene:create("rainy cyberpunk street")
    --local scene2 = scene:create("rainy cyberpunk street")
    --local scene3 = scene:create("rainy cyberpunk street")
    --local scene4 = scene:create("rainy cyberpunk street")
    sg.scenes = {
        scene:create("industrial_area"),
        scene:create("chasm"),
        scene:create("pit")
    }
    sg.current_scene_index = 1
    return sg
end

function scene_organiser:getScene()
    print("scene: ".. self.scenes[self.current_scene_index].name.. " at index: ".. self.current_scene_index)
    return self.scenes[self.current_scene_index]
end

function scene_organiser:getNextScene()

    if self.current_scene_index == #self.scenes then -- reset if at end
        self.current_scene_index = 1
    else
        self.current_scene_index = self.current_scene_index + 1 --otherwise increment
    end

    return self:getScene()
end