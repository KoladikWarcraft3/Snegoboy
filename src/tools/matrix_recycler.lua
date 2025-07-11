do
    ---@class MatrixRecycler
    MatrixRecycler = {}
    --[[array that have principle of stack,
        one can throw table here and then take
         it for another purpose]]--

    ---@public
    ---@param tab table
    --- add table to array from which one can take old table
    function MatrixRecycler:recycle(tab)
        self[#self + 1] = tab
    end

    ---@public
    ---@param tab table
    function MatrixRecycler:recycle_hard(tab)
        for key, val in pairs(tab) do
            tab[key] = nil
        end
        setmetatable(tab, nil)
        self[#self + 1] = tab
    end

    function MatrixRecycler:take()
        if #self == 0 then
            return nil
        end
        local tab = self[#self]
        self[#self] = nil
        return tab
    end

    function MatrixRecycler:generate()
        local tbl = self:take()
        if tbl then
            return tbl
        end
        return {}
    end

    ---@public
    ---@param cls MatrixRecycler
    ---@return MatrixRecycler
    function MatrixRecycler.create(cls)
        obj = setmetatable({}, cls.__meta)
        return obj
    end

    MatrixRecycler.__meta = {
        __index = MatrixRecycler
    }

    setmetatable(MatrixRecycler, {
        __call = MatrixRecycler.create
    })
end