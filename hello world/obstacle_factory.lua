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

---- U shape
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

function obstacle_factory.constructU()
    --local U = {{1,0,0,1}, {1,0,0,1}, {1,0,0,1}, {1,1,1,1}}
    local U = {}          -- create the matrix
    local N, M = 4, 4
    for i=1,N do
      for j=1,M do
        if(i==1) or (i==4) or (((i==2) or (i==3)) and (j==4)) then
            U[i*M+j] = 1
        end
      end
    end
    return U
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
