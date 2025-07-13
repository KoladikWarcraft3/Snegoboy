---@class MouseMoveController
MouseMoveController = {}

function MouseMoveController._on_mouse_caged(player, x, y)
    MouseMoveController.input_x[GetPlayerId(player) + 1] = x*20
    MouseMoveController.input_y[GetPlayerId(player) + 1] = y*20
end

function MouseMoveController.get_input_x(cls, player)
    return cls.input_x[GetPlayerId(player) + 1] or 0
end

function MouseMoveController.get_input_y(cls, player)
    return cls.input_y[GetPlayerId(player) + 1] or 0
end

function MouseMoveController.set_mouse_center()
    local x = math.floor(BlzGetLocalClientWidth()/2)
    local y = math.floor(BlzGetLocalClientHeight()/2)
    -- BlzEnableCursor(false)
    for i = 1, bj_MAX_PLAYERS do
         MouseMoveController.input_x[i] = (MouseMoveController.input_x[i] or 0)/2
         MouseMoveController.input_y[i] = (MouseMoveController.input_y[i] or 0)/2
    end
    BlzSetMousePos(x, y)
end

---@param cls MouseMoveController
function MouseMoveController.init(cls)
    cls.init = function(_cls) return _cls end
    cls.net_frame = MouseCage:init()
    cls.net_frame.signal_mouse_cage:subscribe(cls._on_mouse_caged)
    cls.players_changed = {}
    cls.input_x = {}
    cls.input_y = {}
    TimerStart(CreateTimer(), 0.02, true, cls.set_mouse_center)
    return cls
end
