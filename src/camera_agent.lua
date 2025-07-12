---@class CameraAgent
CameraAgent = {}
CameraAgent.__meta = { __index = CameraAgent }
CameraAgent.debug = false

function CameraAgent:apply()
    if (GetLocalPlayer() == self.player) then
        CameraSetupApplyForceDuration(self.camera, false, 0)
    end
end

---@param cls CameraAgent
---@param unit Unit
function CameraAgent.create(cls, unit, player)
    local obj = setmetatable({}, cls.__meta)
    obj.unit_handle = unit.unit_handle
    obj.camera = CreateCameraSetup()
    obj.player = player
    CameraSetupSetField(obj.camera, CAMERA_FIELD_ANGLE_OF_ATTACK, 355, 0)
    CameraSetupSetField(obj.camera, CAMERA_FIELD_LOCAL_PITCH, 0, 0)
    CameraSetupSetField(obj.camera, CAMERA_FIELD_TARGET_DISTANCE, 1000, 0)
    SetCameraTargetController(obj.unit_handle, 0, 0, false)
    TimerStart(CreateTimer(), 0.02, true, function()
        local facing = GetUnitFacing(obj.unit_handle)
        CameraSetupSetField(obj.camera, CAMERA_FIELD_ROTATION, facing, 0)
        obj:apply()
    end)

    return obj
end

---@param cls CameraAgent
function CameraAgent.init(cls)

end