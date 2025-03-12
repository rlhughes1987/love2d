module = {}
module.__index = module

function module:create(name, x, y, image)
    local m = {}
    setmetatable(m, module)
    m.name = name
    m.size = 1   -- number of slots it occupies
    m.active = false
    m.timer = {count = 0, duration = 0}
    m.cooling = false
    m.type = name
    m.console = nil
    m.state_message = ""
    m.x = x
    m.y = y
    m.image = love.graphics.newImage(image)
    return m
end

function module:trigger(console, duration)
    --self.state_message = " active="..tostring(self.active).." cooling="..tostring(self.cooling)
    if not self.active and not self.cooling then
        self:activate(duration)
    end
    self:passive(console)

end

function module:activate(duration)
    
    self.active = true
    -- on activation effects
    -- start timer
    self.timer.duration = duration
    self.timer.count = 0
end

function module:passive(console)
    self.state_message = tostring(self.active).."/CHECK/"..self.timer.count
    if self.active and (self.timer.count < self.timer.duration) then
        --- while active effects
        if self.type == "Defender" then
            console.barrier = math.min(console.buffer, console.barrier + 5) -- ramps up defens
        end
        if self.type == "Attacker" then
            console.brute_force = math.min(console.buffer, console.brute_force + 3) -- ramps up attack
        end
    elseif self.active then
        self:deactivate()
    end

    if self.cooling and (self.timer.count < self.timer.duration) then
        -- do nothing or do some cooling action
    elseif self.cooling then
        self.active = false
        self.cooling = false
    end
end

function module:tick()
    self.timer.count = self.timer.count + 1
    self.state_message = tostring(self.active).."/NOPE/"..self.timer.count
    if(self.active) then
        --self.state_message = "active timer="..self.timer.count.." duration="..self.timer.duration
    end

    if(self.cooling) then
        --self.state_message = "cooling timer="..self.timer.count.." duration="..self.timer.duration
    end
end

function module:deactivate()
    self.active = false
    -- deactivation effects
    self.cooling = true
    self.timer.duration = 20
    self.timer.count = 0
end