local obstacle_factory = {

}

-- L shape
function obstacle_factory.constructL(x,y)
    local L = { frame = {}, x = x, y = y, dx = 1, dy = 1 }
    local N, M = 4, 4
    for i=1, N do
        for j=1, M do
            if (i == 1) then
                L.frame[i*M + j] = 1
            elseif ((i == 2) and (j == 4)) then
                L.frame[i*M + j] = 1
            else
                L.frame[i*M + j] = 0
            end
        end
    end
    return L
end

---- U shape
function obstacle_factory.constructU(x,y)
    local U = { frame = {}, x = x, y = y, dx = 1, dy = 1 }
    local N, M = 4, 4
    for i=1,N do
      for j=1,M do
        if(i==1) or (i==4) or (((i==2) or (i==3)) and (j==4)) then
            U.frame[i*M+j] = 1
        else
            U.frame[i*M+j] = 0
        end
      end
    end
    return U
end

-- I shape
function obstacle_factory.constructI(x,y)
    local I = { frame = {}, x = x, y = y, dx = 1, dy = 1 }
    local N, M = 4, 4
    for i=1, N do
        for j=1, M do
            if (j == 2) then
                I.frame[i*M + j] = 1
            else
                I.frame[i*M + j] = 0
            end
        end
    end
    return I
end

return obstacle_factory



-- default
