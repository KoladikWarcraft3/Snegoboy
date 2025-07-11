map = {
    debug = true
}


function map:main()
    print("Initializing map...")
    -- InputServer:init()
    Unit:init()
    PhysicSystem:init()
    local unit = Unit:create(Player(0),FourCC("hfoo"),0,0)
    local agent = ControlAgent:create(unit, Player(0))
    print("Initializing complite.")
end

local oldInitGlobals = InitGlobals

-- Теперь переопределяем InitGlobals своей функцией
function InitGlobals()
    oldInitGlobals()
    local initTimer = CreateTimer()
    TimerStart(initTimer, 0.0, false, function()
        DestroyTimer(initTimer)
        map:main() -- вызываем свою основную инициализацию
    end)
end