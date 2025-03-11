require './nic'
require './message'

console = {}
console.__index = console

function console:create(slots)
    local c = {}
    setmetatable(c, console)
    c.modules = {}
    c.slots = slots
    c.nic = nic:create(self)
    c.fans = {}
    c.rate = 1 -- 1 cycle per second
    c.power = 5
    c.active = false
    c.decay = 2 -- per second
    c.remote = nil
    c.buffer = 20 -- caps stuff
    -- defense attributes
    c.barrier = 0 -- software defense taking damage
    c.armour = 0 -- console taking damage
    c.hull = 0 -- modules taking damage
    -- attack attributes
    c.brute_force = 0
    c.disrupt = 0
    c.psionic = 0
    return c
end

function console:activate()
    -- on activation effects
    self.active = true
end

function console:passive()
    -- console passively ticks other modules
    if self.active then
        for m=1,#self.modules do
            self:applyDecay()
            self.modules[m]:activate(self, self.power) -- power improves duration of modules
            self.modules[m]:passive(self)
            if self.remote ~= nil then
                local m = message:create(self.brute_force, self.disrupt, self.psionic)
                self.nic:send(m, self.remote)
            end
        end
    end
end

function console:applyDecay()
    self.barrier = math.max(self.barrier - self.decay, 0)
    self.brute_force = math.max(self.brute_force - self.decay, 0)
end

function console:availableSpace()
    local count = 0
    for i=1, #self.modules do
        count = count + self.modules[i].size
    end

    return self.slots - count
end

function console:insert(module)
    if module.size > self:availableSpace() then
        proj_debug_message = "no space for module "..module.name
        return false
    else
        proj_debug_message = "inserted module "..module.name
        table.insert(self.modules, module)
    end
end

function console:getBarrier()
    return self.barrier
end

function console:connect(remote_console)
    self.remote = remote_console
end

function console:disconnect()
    self.remote = nil
end

function console:initBattle()
    self:activate()
end

function console:getNic()
    return self.nic
end

function console:decodeMessage(message)
    local brute_force = message.brute_force
    local disrupt = message.disrupt
    local psionic = message.psionic

    self.barrier = self.barrier - brute_force
    -- to do implement disrupt and psionic effects
end