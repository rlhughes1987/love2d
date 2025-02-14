-- t is passed in for us by api contains info
function love.conf(t)
    -- allow us to use a save file
    t.identity = "data/saves"
    -- version
    --t.version = "0.0.1"
    -- dev console (windows only)
    t.console = true
    -- external drive save (android only)
    t.externalstorage = true
    -- gamma correct
    t.gammacorrect = true
    -- hotkey voice
    t.audio.mic = true
    -- window title
    t.window.title = "Systopia"
    -- image icon
    t.window.icon = "icon/icon2.png"

end