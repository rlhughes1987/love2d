function love.load()

    lighting = require './lighting'
    moonshine = require './libraries/moonshine'

    

    sti = require 'libraries/sti'

    love.graphics.setDefaultFilter("nearest", "nearest") --removes blur from scaling

    require './console'
    require './module'
    require './nic'

    cons1 = console:create(7,192,416,"assets/rwt-dnx500.png")
    lighting.addCRTShading(cons1.screen)
    mod_def_1 = module:create("Defender",10,50,"assets/turtle-module.png")
    mod_def_2 = module:create("Defender",10,90,"assets/turtle-module.png")
    mod_def_3 = module:create("Defender",10,130,"assets/turtle-module.png")
    mod_def_4 = module:create("Defender",10,170,"assets/turtle-module.png")
    mod_def_5 = module:create("Defender",10,210,"assets/turtle-module.png")
    mod_def_6 = module:create("Defender",10,250,"assets/turtle-module.png")
    --mod_def_6 = module:create("Defender")
    --mod_def_7 = module:create("Defender")
    --mod_def_8 = module:create("Defender")

    cons2 = console:create(7,192,0,"assets/rwt-dnx500.png")
    
    mod_atk_1 = module:create("Attacker",10,50,"assets/tiger-module.png")
    mod_atk_2 = module:create("Attacker",10,90,"assets/tiger-module.png")
    mod_atk_3 = module:create("Attacker",10,130,"assets/tiger-module.png")
    mod_atk_4 = module:create("Attacker",10,170,"assets/tiger-module.png")
    
    counter = 0
    
    cons1:insert(mod_atk_1)
    cons1:insert(mod_atk_2)
    cons1:insert(mod_atk_3)
    cons1:insert(mod_def_1)
    cons1:insert(mod_def_2)
    cons1:insert(mod_def_3)

    cons2:insert(mod_def_4)
    cons2:insert(mod_def_5)
    cons2:insert(mod_atk_4)
    cons2:insert(mod_def_6)

    cons1.nic = nic:create(cons1)
    cons2.nic = nic:create(cons2)

    start_session(cons1, cons2)

    screen_effect = moonshine(1024, 768, moonshine.effects.glow)
                        .chain(moonshine.effects.filmgrain)
                        .chain(moonshine.effects.vignette)
    --screen_effect.chromasep.angle = 1
    --screen_effect.chromasep.radius = 1
    FILMGRAINSIZE = 1
    GLOWSTRENGTH = 1
    MINLUMA = 0.1

    screen_effect.filmgrain.size = FILMGRAINSIZE
    screen_effect.glow.strength = GLOWSTRENGTH
    screen_effect.glow.min_luma = MINLUMA


    -- scene control
    require './scene_organiser'
    so = scene_organiser:create()
    current_scene = so:getScene()
    gameMap = current_scene.map
    candidate_scene = nil -- if not nil then we should start drawing next scene and updating world objects (in love.update)

end

function love.keypressed(key, scancode, isrepeat)
    if key == "1" then
        FILMGRAINSIZE = FILMGRAINSIZE + 1
        screen_effect.filmgrain.size = FILMGRAINSIZE
    end
    if key == "2" then
        GLOWSTRENGTH = GLOWSTRENGTH + 1
        screen_effect.glow.strength = GLOWSTRENGTH
    end
    if key == "3" then
        MINLUMA = MINLUMA + 0.1
        screen_effect.glow.min_luma = MINLUMA
    end
    if key == "r" then
        screen_effect.filmgrain.size = 1
        screen_effect.glow.strength = 1
        screen_effect.glow.min_luma = 0.1
    end
end

function start_session(console_aggressor, console_passive)
    console_aggressor:connect(console_passive)
    console_passive:connect(console_aggressor)
    console_aggressor:activate()
    console_passive:activate()
end

function love.update(dt)

    counter = counter + dt
    if counter > 0.3 then
        counter = 0
        cons1:passive()
        cons2:passive()
    end
end


function love.draw()

    local cons1_state_message = "C: " .. cons1.state_message
    local cons2_state_message = "C: " .. cons2.state_message
    for m=1, #cons1.modules do
        cons1_state_message = cons1_state_message .. " M:" .. cons1.modules[m].state_message
    end
    for m=1, #cons2.modules do
        cons2_state_message = cons2_state_message .. " M:" .. cons2.modules[m].state_message
    end

    --love.graphics.print("CONS1 state: " .. cons1_state_message, 10, 10)
    --love.graphics.print("CONS2 state: " .. cons2_state_message, 10, 30)
    
    --love.graphics.print("CONS2 barrier: " .. CONS2HP, 10, 70)

    if(current_scene:getName() == "protobattle") then
        
        --lighting.StartCRTShading()
        screen_effect(function()
            gameMap:drawLayer(gameMap.layers["Screens"])
            cons1:drawScreenData()
            cons2:drawScreenData()
        end)

        
       
        --lighting.endShading()
        --gameMap:drawLayer(gameMap.layers["Consoles"])
        gameMap:drawLayer(gameMap.layers["Consoles"])
        cons1:draw()
        cons2:draw()
        
        
    end

end