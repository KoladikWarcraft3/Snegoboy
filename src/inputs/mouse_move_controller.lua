---@class MouseMoveController
MouseMoveController = {}

function MouseMoveController.get_input_x(cls, player)
    return cls.input_x[GetPlayerId(player) + 1] or 0
end

function MouseMoveController.get_input_y(cls, player)
    return cls.input_y[GetPlayerId(player) + 1] or 0
end

function MouseMoveController.set_mouse_center()
    local x = math.floor(BlzGetLocalClientWidth()/2)
    local y = math.floor(BlzGetLocalClientHeight()/2)
    BlzSetMousePos(x, y)
end

---@param cls MouseMoveController
function MouseMoveController.init(cls)
    cls.init = function(_cls) return _cls end
    print(1)
    cls.net_frame = NetFrame:init()
    cls.input_x = cls.net_frame.input_x
    cls.input_y = cls.net_frame.input_y
    --TimerStart(CreateTimer(), 0.02, true, MouseMoveController.set_mouse_center)
    return cls
end