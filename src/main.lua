map = {
    debug = true
}


function map:main()
    print("Initializing map...")
    NetFrame:init()
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