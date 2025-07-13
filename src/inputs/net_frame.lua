---@class NetFrame
---@field signal_mouse_cage Observer
---@field x number
---@field y number
MouseCage = {}

function MouseCage._frame_callback()
    local frame_handle = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    local cage = MouseCage:get(frame_handle)
    MouseCage.signal_mouse_cage:publish(player, cage.x, cage.y)
end

---@param cls NetFrame
function MouseCage.create(cls, x , y)
    local obj = {}
    local parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    obj.frame = BlzCreateFrameByType("SLIDER", "FrameGridBoss", parent,"",0)
    obj.x = x
    obj.y = y
    BlzFrameSetSize(obj.frame, cls.frame_width, cls.frame_height)
    BlzFrameSetAbsPoint(obj.frame, FRAMEPOINT_CENTER, 0.4 + x, 0.3 + y)
    BlzTriggerRegisterFrameEvent(cls.frame_trig, obj.frame, FRAMEEVENT_MOUSE_ENTER)
    cls.link:set(obj.frame, obj)
    return obj
end

---@param cls NetFrame
---@param frame_handle framehandle
function MouseCage.get(cls, frame_handle)
    return cls.link:get(frame_handle)
end

---@param cls NetFrame
function MouseCage.create_grid(cls)
    for i = -50, 50 do
        for j = -50, 50 do
            if not (i == 0 and j == 0) then
                local frame = cls:create(i *cls.frame_width, j * cls.frame_height)
                table.insert(cls.net, frame)
            end
        end
    end
end

function MouseCage.disable(cls)
    for _, frame in ipairs(cls.net) do
        BlzFrameSetEnable(frame.frame, false)
    end
end

---@param cls NetFrame
function MouseCage.init(cls)
    cls.init = function(_cls) return _cls end
    cls.frame_width = 0.002
    cls.frame_height = 0.002
    cls.frame_trig = CreateTrigger()
    cls.link = dict()
    cls.signal_mouse_cage = table.tools.Observer()
    cls.net = {}
    cls:create_grid()
    TriggerAddAction( cls.frame_trig, cls._frame_callback)
    return cls
end