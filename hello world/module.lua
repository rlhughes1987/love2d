module = {}
module.__index = module

function module:create(name)
    local m = {}
    setmetatable(m, module)
    m.name = name
    m.size = 1   -- number of slots it occupies
    m.active = false
    m.timer = {}
    m.cooling = false
    m.type = name
    return m
end

function module:activate(console, duration)
    if self.active == true or self.cooling == true then
        return
    end
    self.active = true
    -- on activation effects
    -- start timer
    self.timer.duration = duration
    self.timer.count = 0
end

function module:passive(console)
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
    
    self.timer.count = self.timer.count + 1

    if(self.active) then
        proj_debug_message = " module active. timer: "..self.timer.count.." duration: "..self.timer.duration
    end

    if(self.cooling) then
        proj_debug_message = " module cooling. timer: "..self.timer.count.." duration: "..self.timer.duration
    end

end

function module:deactivate()
    self.active = false
    -- deactivation effects
    self.cooling = true
    self.timer.duration = 30
    self.timer.count = 0
end