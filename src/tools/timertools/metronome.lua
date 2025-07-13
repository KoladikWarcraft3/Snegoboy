do
    table = table or {}
    table.tools = table.tools or {}
    local Observer = table.tools.Observer

    --- version 3 ---
    ---@class Metronome
    ---@field tick number
    ---@field tick_per_sec integer
    ---@field _tick_event Observer
    ---@field _timer_handle handle
    ---@field _tick_callback function
    ---@overload fun():Metronome
    Metronome = {}

    ---@public
    ---@param callback function
    --- add callback function to every tick
    function Metronome:add_tick_event(callback)
        self._tick_event:subscribe(callback)
    end

    ---@public
    ---@param callback function
    --- remove function from every tick
    function Metronome:remove_tick_event(callback)
        self._tick_event:unsubscribe(callback)
    end


    ---@private
    ---starts warcraft 3 timer function
    function Metronome._start(cls)
        TimerStart(cls._timer_handle, cls.tick, true, cls._tick_callback)
        return self
    end

    ---@public
    ---@param cls Metronome
    --- initialize Metronome as singletone and returnes self as protect
    function Metronome.init(cls)
        cls._timer_handle = CreateTimer()
        cls._tick_event = Observer() ---@type Observer
        cls.tick = 0.01
        cls.tick_per_sec = 100
        cls._tick_callback = function()
            cls._tick_event:notify()
        end
        cls:_start()
        --This part ensure Metronome as singletone
        cls.init = function(_cls) return _cls end
        getmetatable(cls).__call = cls.init
        return cls
    end

    setmetatable(Metronome, {
        -- Overrides the class call as a function to initialize or self return
        __call = Metronome.init
    })
end