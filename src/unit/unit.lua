do
    ---require MatrixRecycler
    ---
    ---@class Unit
    ---@field agency set
    Unit = Unit or {}
    Unit.__meta = { __index = Unit }
    Unit.debug = false

    ----------------------- instance methods -------------------------

    function Unit:add_child(agent)
        self.agency:add(agent)
    end

    function Unit:remove()
        self.link:remove(self.unit_handle)
        self.agency:clear()
        self.agency_recycler:recycle(self.agency)
        self.instance_recycler:recycle(self)
    end

    function Unit:on_unit_death()
        for _, agent in ipairs(self.agency) do
            if agent.on_unit_death then
                agent:on_unit_death()
            end
        end
        self:remove()
    end
    ----------------------- class methods -------------------------
    ---@param cls Unit
    ---@param unit_handle handle
    function Unit.has(cls, unit_handle)
        return cls.link:has(unit_handle) or false
    end

    ---@param cls Unit
    ---@param unit_handle handle
    ---@return Unit
    function Unit.get(cls, unit_handle)
        return cls.link:get(unit_handle)
    end

    ---@param cls Unit
    ---@param player handle
    ---@param unit_type_id number
    ---@param x number
    ---@param y number
    ---@param face number|nil
    ---@return Unit
    function Unit.create(cls, player, unit_type_id, x, y, face)
        local obj = setmetatable(cls.instance_recycler:generate(), cls.__meta) ---@type Unit
        obj.unit_handle = CreateUnit(player, unit_type_id, x, y, face or 0)
        obj.agency = set(cls.agency_recycler:generate())
        cls.link:set(obj.unit_handle, obj)
        return obj
    end

    ---@param cls Unit
    ---@return Unit
    function Unit.init(cls)
        print("function Unit.init(cls)")
        cls.init = function(_cls) return _cls end
        cls.link = dict()
        cls.instance_recycler = MatrixRecycler()
        cls.agency_recycler = MatrixRecycler()
        cls.death_trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(cls.death_trigger, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddCondition(cls.death_trigger, Condition(function()
            return cls:has(GetTriggerUnit())
        end))
        TriggerAddAction(cls.death_trigger, function()
            Unit:get(GetTriggerUnit()):on_unit_death()
        end)
        return cls
    end

    ---------------------- static methods -------------------------

    setmetatable(Unit, {
        __call = function(cls,...) return cls:init(...) end
    })
end