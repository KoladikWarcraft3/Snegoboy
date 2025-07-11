---@class NetFrame
NetFrame = {}

function NetFrame._frame_callback()
    local frame_handle = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    print("puk puk")
    NetFrame.set_mouse_center()
end

function NetFrame.set_mouse_center()
    local x = math.floor(BlzGetLocalClientWidth()/2)
    local y = math.floor(BlzGetLocalClientHeight()/2)
    BlzSetMousePos(x, y)
end

---@param cls NetFrame
function NetFrame.create(cls, x ,y)
    --local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    local parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    local obj = {}
    obj.frame = BlzCreateFrameByType("SCROLLBAR", "FrameGridBoss", parent,"",0)
    obj.x = x
    obj.y = y
    BlzFrameSetAbsPoint(obj.frame, FRAMEPOINT_CENTER, 0.4 + x, 0.3 + y)
    BlzFrameSetSize(obj.frame, cls.frame_width, cls.frame_height)
    BlzTriggerRegisterFrameEvent(cls.frame_trig, obj.frame, FRAMEEVENT_MOUSE_ENTER)
    return obj
end

---@param cls NetFrame
function NetFrame.create_grid(cls)
    for i = -10, 10 do
        for j = -10, 10 do
            if not (i == 0 and j == 0) then
                cls:create(i * cls.frame_height, j * cls.frame_width)
            end
        end
    end
end

---@param cls NetFrame
---@param frame_handle framehandle
function NetFrame.get(cls, frame_handle)
    return self.link:get(frame_handle)
end

---@param cls NetFrame
function NetFrame.init(cls)
    cls.frame_width = 0.05
    cls.frame_height = 0.05
    cls.timer_mouse_center = CreateTimer()
    cls.frame_trig = CreateTrigger()
    cls.link = dict()
    TriggerAddAction( cls.frame_trig, cls._frame_callback)
    cls:create_grid()
    -- TimerStart(cls.timer_mouse_center, 0.1, true, cls.set_mouse_center)
end