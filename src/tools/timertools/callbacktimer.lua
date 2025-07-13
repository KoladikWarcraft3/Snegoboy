do
    --- CallbackTimer
    ---@class CallbackTimer
    ---@field callback function
    ---@field metronome Metronome
    ---@field recycler MatrixRecycler
    ---@field duration number
    ---@field num_ticks integer
    ---@field tick_num integer
    ---@field tick_callback function
    ---@overload fun(number, function):CallbackTimer
    --- pseudo timer
    CallbackTimer = {}

    ---@public
    --- starts timer
    function CallbackTimer:start()
        self.metronome:add_tick_event(self.tick_callback)
    end

    ---@public
    ---@param cls CallbackTimer
    ---@param duration number
    ---@param callback function
    ---@return CallbackTimer
    --- create CallbackTimer without hidden initialization
    function CallbackTimer.__create(cls, duration, callback)
        local obj = cls.recycler:take() ---@type CallbackTimer
        if obj then
            obj.duration = duration
            obj.callback = callback
            obj.num_ticks = math.floor((obj.duration + 0.0001) * cls.tick_per_sec)
            obj.tick_num = 0
            return obj
        end
        obj = setmetatable({}, cls.meta)
        obj.callback = callback
        obj.duration = duration
        --[[
        This is trick to evade inaccurate calc specific
        for lua in last number of float calculus.
        0.0001 is the required accuracy]]
        obj.num_ticks = math.floor((obj.duration + 0.0001) * cls.tick_per_sec)
        obj.tick_num = 0
        obj.tick_callback = function()
            obj.tick_num = obj.tick_num + 1
            if obj.tick_num > obj.num_ticks then
                obj.metronome:remove_tick_event(obj.tick_callback)
                obj.callback(obj)
                obj.callback = nil
                obj.recycler:recycle(obj)
            end
        end
        return obj
    end

    ---@public
    ---@param cls CallbackTimer
    ---@param duration number
    ---@param callback function
    ---@return CallbackTimer
    --- create CallbackTimer
    function CallbackTimer.create(cls, duration, callback)
        -- this is pseudo create to evade uninitialized classes
        cls:init()
        cls.create = cls.__create
        getmetatable(cls).__call = cls.__create
        return cls:__create(duration, callback)
    end

    ---@public
    ---@param cls CallbackTimer
    --- class initialization
    function CallbackTimer.init(cls)
        cls.metronome = Metronome:init()
        cls.recycler = MatrixRecycler()
        cls.tick = cls.metronome.tick
        cls.tick_per_sec = cls.metronome.tick_per_sec
        cls.init = function(_cls) return _cls  end
        return cls
    end

    CallbackTimer.meta = {
        -- gives to instances control over class methods
       __index = CallbackTimer
    }

    setmetatable(CallbackTimer, {
        --overload the class call as a function to create instances
        __call = CallbackTimer.create
    })

end