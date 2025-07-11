---@class PhysicSystem
PhysicSystem = {}

---@param cls PhysicSystem
function PhysicSystem.add_physic_agent(cls, agent)
    cls.agency:add(agent)
end

function PhysicSystem.init(cls)
    cls.physic_timer = CreateTimer()
    cls.agency = set()
    TimerStart(cls.physic_timer, 0.02, true, function()
        for _, agent in ipairs(cls.agency) do
            agent:physic_process()
        end
    end)
end

setmetatable(PhysicSystem, {
    __call = function(cls,...) return cls:init(...) end
})