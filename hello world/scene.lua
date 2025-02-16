scene = {}
scene.__index = scene

function scene:create(name)
    local s = {}
    setmetatable(s, scene)
    s.name = name
    return s
end

function scene:getName()
    return self.name
end

