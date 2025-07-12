---@class CameraAgent
CameraAgent = {}
CameraAgent.__meta = { __index = CameraAgent }
CameraAgent.debug = false

function CameraAgent:apply()
    if (GetLocalPlayer() == self.player) then
        CameraSetupApplyForceDuration(self.camera, false, 0)
    end
end

function CameraAgent.correct_angle(angle)
    if angle < 0 then
        return 360 - angle
    elseif angle > 360 then
        return angle - 360
    end
    return angle
end

---@param angle number
function CameraAgent:add_rotation(angle)
    self.rotation = CameraAgent.correct_angle(self.rotation - angle)
    CameraSetupSetField(self.camera, CAMERA_FIELD_ROTATION, self.rotation, 0)
end

---@param angle number
function CameraAgent:add_angle_of_attack(angle)
    self.angle_of_attack = CameraAgent.correct_angle(self.angle_of_attack + angle)
    CameraSetupSetField(self.camera, CAMERA_FIELD_ANGLE_OF_ATTACK, self.angle_of_attack, 0)
end

---@param angle number
function CameraAgent:add_yangle(angle)
    self.yangle = CameraAgent.correct_angle(self.yangle + angle)
    CameraSetupSetField(self.camera, CAMERA_FIELD_ANGLE_OF_ATTACK, self.yangle, 0)
end

---@param cls CameraAgent
---@param unit Unit
function CameraAgent.create(cls, unit, player)
    local obj = setmetatable({}, cls.__meta)
    obj.unit_handle = unit.unit_handle
    obj.camera = CreateCameraSetup()
    obj.player = player
    obj.rotation = 0
    obj.angle_of_attack = 355
    obj.yangle = 0
    obj.sens_x = 10
    obj.sens_y = 10
    CameraSetupSetField(obj.camera, CAMERA_FIELD_ANGLE_OF_ATTACK, obj.angle_of_attack, 0)
    CameraSetupSetField(obj.camera, CAMERA_FIELD_LOCAL_PITCH, 0, 0)
    CameraSetupSetField(obj.camera, CAMERA_FIELD_TARGET_DISTANCE, 400, 0)
    CameraSetupSetField(obj.camera, CAMERA_FIELD_ZOFFSET,150, 0)
    SetCameraTargetController(obj.unit_handle, 0, 0, false)
    TimerStart(CreateTimer(), 0.02, true, function()
        local dx = obj.sens_x * InputServer:get_mouse_x(obj.player)
        local dy = obj.sens_y * InputServer:get_mouse_y(obj.player)
        obj:add_rotation(dx)
        obj:add_angle_of_attack(dy)
        obj:apply()
    end)
    return obj
end

---@param cls CameraAgent
function CameraAgent.init(cls)
    cls.init = function(_cls) return _cls end
    return cls
end