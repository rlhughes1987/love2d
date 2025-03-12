require './nic'
require './message'

console = {}
console.__index = console

function console:create(slots, x, y, image)
    local c = {}
    setmetatable(c, console)
    c.modules = {}
    c.image = love.graphics.newImage(image)
    c.x = x
    c.y = y
    c.slots = {count=slots, xoff=434, yoff=117, w=67, h=31, padding = 0}
    c.screen = {enabled = true, xoff=103, yoff=130, w=228, h=120, padding = 10}
    c.active_slot_index = 0
    c.nic = nil
    c.fans = {}
    c.rate = 1 -- 1 cycle per second
    c.power = 5
    c.active = false
    c.decay = 1 -- per second
    c.remote = nil
    c.buffer = 30 -- caps stuff
    -- defense attributes
    c.barrier = 0 -- software defense taking damage
    c.armour = 0 -- console taking damage
    c.maxarmour = 0
    c.hull = 0 -- modules taking damage
    c.maxhull = 0
    -- attack attributes
    c.brute_force = 0
    c.disrupt = 0
    c.psionic = 0
    c.state_message = ""
    
    return c
end

function console:activate()
    -- on activation effects
    self.active = true
    self.active_slot_index = 1
end

function console:passive()
    -- console passively ticks other modules
    if self.active then
        for m=1,#self.modules do
            --self.state_message = "m="..m.." active_slot_index="..self.active_slot_index
            self.modules[m]:tick()
        end
        for m=1,#self.modules do
            --self.state_message = "m="..m.." active_slot_index="..self.active_slot_index
            --self.modules[m]:tick()
            if m == self.active_slot_index then
                self.state_message = "slot="..m
                self:applyDecay()
                self.modules[m]:trigger(self, self.power) -- power improves duration of modules
                break
            end
        end
        --
        if self.remote ~= nil and self.active_slot_index == #self.modules then -- message only fires once all module stack parsed
            local msg = message:create(self.brute_force, self.disrupt, self.psionic)
            self.nic:send(msg, self.remote)
            self.active_slot_index = 1
        else
            self.active_slot_index = self.active_slot_index + 1
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

    return self.slots.count - count
end

function console:insert(module)
    if module.size > self:availableSpace() then
        self.state_message = "no space for module "..module.name
        return false
    else
        self.state_message = "inserted module "..module.name
        local next_slot_index = #self.modules + 1
        module.console = self
        module.x = self.x + self.slots.xoff
        module.y = self.y + self.slots.yoff + ((next_slot_index-1) * self.slots.h)
        self.hull = self.hull + module.hull
        self.maxhull = self.maxhull + module.hull
        self.armour = self.armour + module.armour
        self.maxarmour = self.maxarmour + module.armour
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

    self.barrier = math.max(0,self.barrier - brute_force)
    -- to do implement disrupt and psionic effects
end

function console:draw()
    --console
    --love.graphics.draw(self.image,self.x,self.y)
    --modules
    for m=1,#self.modules do
        love.graphics.draw(self.modules[m].image, self.modules[m].x, self.modules[m].y)
    end
    
end

function console:drawScreenData()
    --screen data
    --love.graphics.print("" .. self.barrier, self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+self.screen.padding)
    local hp_bar_height = self.screen.h/10
    --hp
    love.graphics.rectangle("fill", self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+self.screen.padding, self:getCurrentBarrierBarWidth(), hp_bar_height)
    love.graphics.rectangle("line", self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+self.screen.padding, self.screen.w - (2*self.screen.padding), hp_bar_height)
    --console
    love.graphics.rectangle("fill", self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+(2*self.screen.padding)+hp_bar_height, self:getCurrentArmourBarWidth(), hp_bar_height)
    love.graphics.rectangle("line", self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+(2*self.screen.padding)+hp_bar_height, self.screen.w - (2*self.screen.padding), hp_bar_height)
    --modules
    love.graphics.rectangle("fill", self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+(3*self.screen.padding)+(2*hp_bar_height), self:getCurrentStructureBarWidth(), hp_bar_height)
    love.graphics.rectangle("line", self.x+self.screen.xoff+self.screen.padding, self.y+self.screen.yoff+(3*self.screen.padding)+(2*hp_bar_height), self.screen.w - (2*self.screen.padding), hp_bar_height)
end

function console:getCurrentBarrierBarWidth()
    local max_hp_bar_width = self.screen.w - (2*self.screen.padding)
    local current_hp_bar_width = (self.barrier/self.buffer) * max_hp_bar_width
    return current_hp_bar_width
end
function console:getCurrentArmourBarWidth()
    local max_hp_bar_width = self.screen.w - (2*self.screen.padding)
    local current_hp_bar_width = (self.armour/self.maxarmour) * max_hp_bar_width
    return current_hp_bar_width
end
function console:getCurrentStructureBarWidth()
    local max_hp_bar_width = self.screen.w - (2*self.screen.padding)
    local current_hp_bar_width = (self.hull/self.maxhull) * max_hp_bar_width
    return current_hp_bar_width
end



