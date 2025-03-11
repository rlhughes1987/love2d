nic = {}
nic.__index = nic

function nic:create(local_console)
    local n = {}
    setmetatable(n, nic)
    n.width = 10
    n.local_console = local_console
    return n
end

function nic:send(message, remote_console)
    remote_console:getNic():receive(message)
end

function nic:getLatency(remote_console)
    -- distance in x,y space
    local local_x = self.local_console.x
    local local_y = self.local_console.y
    local remote_x = remote_console.x
    local remote_y = remote_console.y
    local x_axis = (local_x-remote_x)
    local y_axis = (local_y-remote_y)
    return math.sqrt((x_axis*x_axis) + (y_axis*y_axis)) * 1 -- some factor
end

function nic:receive(message)
    -- do something external from cpu
    -- give message to cpu
    self.local_console:decodeMessage(message)
end