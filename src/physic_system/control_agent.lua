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
        PhysicSystem:add_physic_agent(obj)
        return obj
    end

    function ControlAgent:physic_process()
        local unit_handle = self.unit_handle
        local x = GetUnitX(unit_handle)
        local y = GetUnitY(unit_handle)
        SetUnitX(unit_handle, x + 0.1)
        SetUnitY(unit_handle, y + 0.1)
    end

    function ControlAgent.init(cls)

    end

    setmetatable(ControlAgent, {
        __call = function(cls,...) return cls:init(...) end
    })
end