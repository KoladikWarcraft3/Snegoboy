---@class NetFrame
NetFrame = {}

function NetFrame._frame_callback()
    local frame_handle = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    local net_frame = NetFrame:get(frame_handle)
    NetFrame.input_x[GetPlayerId(player) + 1] = net_frame.x
    NetFrame.input_y[GetPlayerId(player) + 1] = net_frame.y
    --- BlzEnableCursor(false)
end

---@param cls NetFrame
function NetFrame.create(cls, x ,y)
    local obj = {}
    local parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    obj.frame = BlzCreateFrameByType("SCROLLBAR", "FrameGridBoss", parent,"",0)
    obj.x = x
    obj.y = y
    BlzFrameSetAbsPoint(obj.frame, FRAMEPOINT_CENTER, 0.4 + x, 0.3 + y)
    BlzFrameSetSize(obj.frame, cls.frame_width, cls.frame_height)
    BlzTriggerRegisterFrameEvent(cls.frame_trig, obj.frame, FRAMEEVENT_MOUSE_ENTER)
    cls.link:set(obj.frame, obj)
    return obj
end

---@param cls NetFrame
---@param frame_handle framehandle
function NetFrame.get(cls, frame_handle)
    return cls.link:get(frame_handle)
end

---@param cls NetFrame
function NetFrame.create_grid(cls)
    for i = -5, 5 do
        for j = -5, 5 do
            if not (i == 0 and j == 0) then
                local frame = cls:create(i * cls.frame_height, j * cls.frame_width)
                table.insert(cls.net, frame)
            end
        end
    end
end

function NetFrame.disable(cls)
    for _, frame in ipairs(cls.net) do
        BlzFrameSetEnable(frame.frame, false)
    end
end

---@param cls NetFrame
function NetFrame.init(cls)
    cls.init = function(_cls) return _cls end
    cls.frame_width = 0.05
    cls.frame_height = 0.05
    cls.frame_trig = CreateTrigger()
    cls.link = dict()
    cls.input_x = {}
    cls.input_y = {}
    cls.net = {}
    cls:create_grid()
    TriggerAddAction( cls.frame_trig, cls._frame_callback)
    return cls
end