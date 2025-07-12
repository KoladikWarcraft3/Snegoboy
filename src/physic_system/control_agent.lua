do
    ---@class ControlAgent
    ControlAgent = {}
    ControlAgent.__meta = { __index = ControlAgent }
    ControlAgent.debug = false

    ---@param cls ControlAgent
    ---@param unit Unit
    function ControlAgent.create(cls, unit, player)
        local obj = setmetatable({}, cls.__meta)
        obj.unit_handle = unit.unit_handle
        obj.player = player
        PhysicSystem:add_physic_agent(obj)
        return obj
    end

    function ControlAgent:physic_process()
        local unit_handle = self.unit_handle
        local x = GetUnitX(unit_handle)
        local y = GetUnitY(unit_handle)
        local face_angle = GetUnitFacing(unit_handle)/180*math.pi
        local input_x, input_y = InputServer:get_movement_vector(self.player)
        local speed = 2
        local dx = speed * input_y * math.cos(face_angle) + speed * input_x * math.sin(face_angle)
        local dy = speed * input_y * math.sin(face_angle) - speed * input_x * math.cos(face_angle)
        SetUnitPosition(unit_handle, x + dx, y + dy)
    end

    function ControlAgent.init(cls)

    end

    setmetatable(ControlAgent, {
        __call = function(cls,...) return cls:init(...) end
    })
end