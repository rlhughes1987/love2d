message = {}
message.__index = message

function message:create(brute_force, disruption, psionic)
    local m = {}
    setmetatable(m, message)
    m.brute_force = brute_force
    m.disruption = disruption
    m.psionic = psionic
    return m
end