---@class NetFrame
NetFrame = {}

function NetFrame._frame_callback()
    local frame = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    print("puk puk")
end

function NetFrame.set_mouse_center()
    local x = math.floor(BlzGetLocalClientWidth()/2)
    local y = math.floor(BlzGetLocalClientHeight()/2)
    BlzSetMousePos(x, y)
end

function NetFrame.create(cls, x ,y)
    local parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    local obj = {}
    obj.frame = BlzCreateFrameByType("SCROLLBAR", "FrameGridBoss", parent,"",0)
    BlzFrameSetAbsPoint(obj.frame, FRAMEPOINT_CENTER, 0.4 + cls.frame_width/2 + x, 0.3 + cls.frame_height/2 + y)
    BlzFrameSetSize(obj.frame, cls.frame_width, cls.frame_height)
    BlzTriggerRegisterFrameEvent(cls.frame_trig, obj.frame, FRAMEEVENT_MOUSE_ENTER)
    return obj
end

---@param frame_handle framehandle
function NetFrame:get(frame_handle)
    return self.link:get(frame_handle)
end

---@param cls NetFrame
function NetFrame.init(cls)
    cls.frame_width = 0.005
    cls.frame_height = 0.005
    cls.timer_mouse_center = CreateTimer()
    cls.frame_trig = CreateTrigger()
    cls.link = dict()
    TriggerAddAction( cls.frame_trig, cls._frame_callback)
    -- TimerStart(cls.timer_mouse_center, 0.1, true, cls.set_mouse_center)

    for i = 1, 10 do
        for j = 1, 10 do
            cls:create((i-1)*cls.frame_height, (j-1)*cls.frame_width)
        end
    end
end