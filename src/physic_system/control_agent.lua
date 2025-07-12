do
    ---@class ControlAgent
    ControlAgent = {}
    ControlAgent.__meta = { __index = ControlAgent }
    ControlAgent.debug = false

    ---@param cls ControlAgent
    ---@param unit Unit
    ---@param get_angle number
    function ControlAgent.create(cls, unit, player, get_angle)
        local obj = setmetatable({}, cls.__meta)
        obj.unit_handle = unit.unit_handle
        obj.player = player
        obj.get_angle = get_angle or GetUnitFacing
        PhysicSystem:add_physic_agent(obj)
        return obj
    end

    function ControlAgent:physic_process()
        local unit_handle = self.unit_handle
        local x = GetUnitX(unit_handle)
        local y = GetUnitY(unit_handle)
        local angle = self.get_angle(unit_handle)/180*math.pi
        local input_x, input_y = InputServer:get_movement_vector(self.player)
        local speed = 2
        local dx = speed * input_y * math.cos(angle) + speed * input_x * math.sin(angle)
        local dy = speed * input_y * math.sin(angle) - speed * input_x * math.cos(angle)
        if dx ~= 0 and dy ~= 0 then
            local angle = math.atan(dy, dx)/math.pi*180
            SetUnitFacing(unit_handle, angle)
            SetUnitAnimation(unit_handle, "walk")
            SetUnitPosition(unit_handle, x + dx, y + dy)
        else
            SetUnitAnimation(unit_handle, "stand")
        end
    end

    ---@param cls ControlAgent
    function ControlAgent.init(cls)

    end

    setmetatable(ControlAgent, {
        __call = function(cls,...) return cls:init(...) end
    })
end