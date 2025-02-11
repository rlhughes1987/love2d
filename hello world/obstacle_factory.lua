local obstacle_factory = {
    x = 50,
    y = 50
}

-- L shape
function obstacle_factory.constructL()
    local L = {}
    local N, M = 4, 4
    for i=1, N do
        for j=1, M do
            if (i == 1) then
                L[i*M + j] = 1
            elseif ((i == 2) and (j == 4)) then
                L[i*M + j] = 1
            else
                L[i*M + j] = 0
            end
        end
    end
    return L
end

-- I shape
function obstacle_factory.constructI()
    local I = {}
    local N, M = 4, 4
    for i=1, N do
        for j=1, M do
            if (j == 2) then
                I[i*M + j] = 1
            else
                I[i*M + j] = 0
            end
        end
    end
    return I
end

return obstacle_factory



-- default
