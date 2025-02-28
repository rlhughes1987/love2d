loot = {}
loot.__index = loot

function loot:create(tier)
    local l = {}
    setmetatable(l, loot)

    if tier == 1 then
        l.items = {
            { computer = { 
                programs = { leech = { value=1, rarity = 0.8 },
                             buzzsaw = { value=2, rarity = 0.2 }
                },
                hardware = { console_t1 = { value=10, rarity=0.5},
                             console_t2 = { value=5, rarity=0.25}
                }
            }, rarity = 0.33},
            { fabric = {
                basic_hat = { value = 1, rarity = 0.33},
                basic_top = { value = 2, rarity = 0.34},
                basic_pants = { value = 2.5, rarity = 0.33}
            }, rarity = 0.34},
            { schematic = {
                map = { level_1 = { value = 1, rarity = 0.1 },
                        level_2 = { value = 1, rarity = 0.1 }
                },
                blueprint = {
                    console_t1_uncommon = { value = 1, rarity = 0.05},
                    console_t1_common = { value = 1, rarity = 0.2}
                }
            }, rarity = 0.33}
        }
    elseif tier == 2 then
        l.items = {
            { computer = { 
                programs = { leech = { value=1, rarity = 0.8 },
                             buzzsaw = { value=2, rarity = 0.2 }
                },
                hardware = { console_t1 = { value=10, rarity=0.5},
                             console_t2 = { value=5, rarity=0.25}
                }
            }, rarity = 0.33},
            { fabric = {
                basic_hat = { value = 1, rarity = 0.33},
                basic_top = { value = 2, rarity = 0.34},
                basic_pants = { value = 2.5, rarity = 0.33}
            }, rarity = 0.34},
            { schematic = {
                map = { level_3 = { value = 1, rarity = 0.1 },
                        level_4 = { value = 1, rarity = 0.1 }
                },
                blueprint = {
                    console_t2_uncommon = { value = 1, rarity = 0.05},
                    console_t2_common = { value = 1, rarity = 0.2}
                }
            }, rarity = 0.33}
        }
    end
   
    

    return l
end

function loot:metadata(item)
    local value, rarity = 0

end