function InitGlobals()
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hfoo"), -569.0, 110.6, 110.987, FourCC("hfoo"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreatePlayerBuildings()
CreatePlayerUnits()
end

--CUSTOM_CODE
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
    print("CameraAgent.create(cls, unit, player)")
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
map = {
    debug = true
}


function map:main()
    print("Initializing map...")
    -- InputServer:init()
    Unit:init()
    PhysicSystem:init()
    local unit = Unit:create(Player(0),FourCC("H000"),0,0)
    InputServer:init()
    local camera_agent = CameraAgent:create(unit, Player(0))
    local agent = ControlAgent:create(unit, Player(0), function()
        return camera_agent.rotation
    end)
    print("Initializing complite.")
end

local oldInitGlobals = InitGlobals

-- Теперь переопределяем InitGlobals своей функцией
function InitGlobals()
    oldInitGlobals()
    local initTimer = CreateTimer()
    TimerStart(initTimer, 0.0, false, function()
        DestroyTimer(initTimer)
        map:main() -- вызываем свою основную инициализацию
    end)
end
do
    ---@class dict
    ---@field create fun(self:dict)
    ---@field set fun(self:dict, key:number|string, item:any):void
    ---@field remove fun(self:dict, key:number|string):void
    ---@field has fun(self:dict, key:number|string):boolean
    ---@field get fun(self:dict, key:number|string):any
    ---@field each fun(self:dict, callback:fun(key:number|string, value:any)): void
    ---@field keys fun(self:dict): table
    ---@field values fun(self:dict): table
    ---@field size fun(self:dict): number
    ---@field clear fun(self:dict): void
    dict = dict or {}


    ---set
    ---@param key number|string
    ---@param item any
    function dict:set(key, item)
        self.data[key] = item
    end

    ---remove
    ---@param key number|string
    function dict:remove(key)
        self.data[key] = nil
    end

    ---has
    ---@param key number|string
    function dict:has(key)
        return self.data[key] ~= nil
    end

    ---get
    ---@param key number|string
    ---@return any
    function dict:get(key)
        return self.data[key]
    end

    -- Итератор
    ---@param callback fun(key:number|string, value:any)
    function dict:each(callback)
        for key, value in pairs(self.data) do
            callback(key, value)
        end
    end

    -- Получение ключей
    ---@return table
    function dict:keys()
        local keys = {}
        for key in pairs(self.data) do
            table.insert(keys, key)
        end
        return keys
    end


    -- Получение значений
    ---@return table
    function dict:values()
        local values = {}
        for _, value in pairs(self.data) do
            table.insert(values, value)
        end
        return values
    end


    -- Размер словаря
    ---@return number
    function dict:size()
        local count = 0
        for _ in pairs(self.data) do
            count = count + 1
        end
        return count
    end

    -- Очистка словаря
    function dict:clear()
        for key, _ in pairs(self.data) do
            self.data[key] = nil
        end
    end

    dict.__meta = {
        __index = dict
    }

    ---create
    ---@param tbl table|nil
    ---@return dict
    function dict:create(tbl)
        local obj = {
            data = tbl or {}
        } ---@type dict
        return setmetatable(obj, self.__meta)
    end

    local dict_meta = {
        __call = dict.create
    }
    setmetatable(dict, dict_meta)
end

do
    Grid = {}

    function Grid:get_indices(x, y)
        local j = math.floor((y - self.ymin) / self.cell_height) + 1
        local i = math.floor((x - self.xmin) / self.cell_width) + 1
        return i, j
    end

    function Grid:get_center(i, j)
        local x_c = self.xmin + (i - 0.5) * self.cell_width
        local y_c = self.ymin + (j - 0.5) * self.cell_height
        return x_c, y_c
    end

    function Grid:get_cells_within_circle(x_0, y_0, r)
        -- Определяем границы прямоугольника, охватывающего окружность
        -- Получаем индексы ячеек, охватывающих прямоугольник
        local i_min, j_min = self:get_indices(x_0 - r, y_0 - r)
        local i_max, j_max = self:get_indices(x_0 + r, y_0 + r)
        local r2 = r*r
        local cells = {}

        -- Проходим по всем ячейкам в пределах прямоугольника
        for i = i_min, i_max do
            for j = j_min, j_max do
                local cell = self.cells[i][j]
                local x_c, y_c = self:get_center(i, j)
                -- Получаем координаты границ текущей ячейки
                local cell_xmin = x_c - self.cell_width * 0.5
                local cell_xmax = x_c + self.cell_width * 0.5
                local cell_ymin = y_c - self.cell_height * 0.5
                local cell_ymax = y_c + self.cell_height * 0.5

                -- Находим ближайшую точку ячейки к центру окружности
                local dx_closest = math.max(cell_xmin, math.min(x_0, cell_xmax)) - x_0
                local dy_closest = math.max(cell_ymin, math.min(y_0, cell_ymax)) - y_0

                -- Если расстояние меньше или равно квадрату радиуса, ячейка пересекает окружность
                if dx_closest*dx_closest + dy_closest*dy_closest <= r2 then
                    table.insert(cells, cell)
                end
            end
        end

        return cells
    end

    function Grid:get_cells_within_box(xmin, xmax, ymin, ymax)
        local i_min, j_min = self:get_indices(xmin, ymin)
        local i_max, j_max = self:get_indices(xmax, ymax)
        local cells = table.empty()
        for i = i_min, i_max do
            for j = j_min, j_max do
                table.insert(cells, self.cells[i][j])
            end
        end
        return cells
    end

    function Grid:get_cell(x, y)
        local i, j = self:get_indices(x, y)
        if not self:is_in_bounds(i, j) then
            print("Grid error: попытка получить ячейку за границами сетки")
            return nil
        end
        return self.cells[i][j]
    end

    function Grid:insert(x, y, item)
        local cell = self:get_cell(x, y)
        table.insert(cell, item)
    end

    function Grid:get_neighbors(x, y)
        local neighbors = {}
        local i, j = self:get_indices(x, y)
        for di = -1, 1 do
            for dj = -1, 1 do
                local ni = i + di
                local nj = j + dj
                if (not (di == 0 and dj == 0)) and self:is_in_bounds(ni, nj) then --  and
                    local cell = self.cells[ni][nj]
                    if cell then
                        table.insert(neighbors, cell)
                    end
                end
            end
        end
        return neighbors
    end

    function Grid:is_in_bounds(i, j)
        return (j > 0 and j <= self.shape[1]) and (i >  0 and i <= self.shape[2])
    end

    function Grid:tostring()
        return self.cells:tostring()
    end



    local meta = {
        __index = Grid,
        __tostring = Grid.tostring
    }


    Grid = {}
    function Grid.create(cls, xmin, xmax, ymin, ymax, cell_width, cell_height)
        print("Grid deprecated use Grid2D")
        local grid = setmetatable({}, meta)
        grid.xmax = xmax
        grid.xmin = xmin
        grid.ymin = ymin
        grid.ymax = ymax
        grid.width  = xmax - xmin
        grid.height = ymax - ymin
        grid.cell_width  = cell_width
        grid.cell_height = cell_height
        grid.shape = {
            math.floor(grid.height / grid.cell_height + 1),
            math.floor(grid.width  / grid.cell_width  + 1)
        }
        grid.cells = NDArray(grid.shape):fill(table.empty)
        return grid
    end

    setmetatable(Grid,{__call = Grid.create})
end
do
    table = table or {}
    table.tools = table.tools or {}


    ---@class Grid2D
    table.tools.Grid2D = table.tools.Grid2D or {}
    local Grid2D = table.tools.Grid2D

    function Grid2D:get_indices(x, y)
        local j = math.floor((y - self.ymin) / self.cell_height) + 1
        local i = math.floor((x - self.xmin) / self.cell_width) + 1
        return i, j
    end

    function Grid2D:get_center(i, j)
        local x_c = self.xmin + (i - 0.5) * self.cell_width
        local y_c = self.ymin + (j - 0.5) * self.cell_height
        return x_c, y_c
    end

    function Grid2D:get_cells_within_circle(x_0, y_0, r)
        -- Определяем границы прямоугольника, охватывающего окружность
        -- Получаем индексы ячеек, охватывающих прямоугольник
        local i_min, j_min = self:get_indices(x_0 - r, y_0 - r)
        local i_max, j_max = self:get_indices(x_0 + r, y_0 + r)
        local r2 = r*r
        local cells = {}

        -- Проходим по всем ячейкам в пределах прямоугольника
        for i = i_min, i_max do
            for j = j_min, j_max do
                local cell = self.cells[i][j]
                local x_c, y_c = self:get_center(i, j)
                -- Получаем координаты границ текущей ячейки
                local cell_xmin = x_c - self.cell_width * 0.5
                local cell_xmax = x_c + self.cell_width * 0.5
                local cell_ymin = y_c - self.cell_height * 0.5
                local cell_ymax = y_c + self.cell_height * 0.5

                -- Находим ближайшую точку ячейки к центру окружности
                local dx_closest = math.max(cell_xmin, math.min(x_0, cell_xmax)) - x_0
                local dy_closest = math.max(cell_ymin, math.min(y_0, cell_ymax)) - y_0

                -- Если расстояние меньше или равно квадрату радиуса, ячейка пересекает окружность
                if dx_closest*dx_closest + dy_closest*dy_closest <= r2 then
                    table.insert(cells, cell)
                end
            end
        end

        return cells
    end

    function Grid2D:get_cells_within_box(xmin, xmax, ymin, ymax)
        local i_min, j_min = self:get_indices(xmin, ymin)
        local i_max, j_max = self:get_indices(xmax, ymax)
        local cells = table.empty()
        for i = i_min, i_max do
            for j = j_min, j_max do
                table.insert(cells, self.cells[i][j])
            end
        end
        return cells
    end

    function Grid2D:get_cell(x, y)
        local i, j = self:get_indices(x, y)
        if not self:is_in_bounds(i, j) then
            print("Grid error: попытка получить ячейку за границами сетки")
            return nil
        end
        return self.cells[i][j]
    end

    function Grid2D:insert(x, y, item)
        local cell = self:get_cell(x, y)
        table.insert(cell, item)
    end

    function Grid2D:get_neighbors(x, y)
        local neighbors = {}
        local i, j = self:get_indices(x, y)
        for di = -1, 1 do
            for dj = -1, 1 do
                local ni = i + di
                local nj = j + dj
                if (not (di == 0 and dj == 0)) and self:is_in_bounds(ni, nj) then --  and
                    local cell = self.cells[ni][nj]
                    if cell then
                        table.insert(neighbors, cell)
                    end
                end
            end
        end
        return neighbors
    end

    function Grid2D:is_in_bounds(i, j)
        return (j > 0 and j <= self.shape[1]) and (i >  0 and i <= self.shape[2])
    end

    function Grid2D:tostring()
        return self.cells:tostring()
    end



    Grid2D.__meta = {
        __index = Grid2D,
        __tostring = Grid2D.tostring
    }


    ---@return Grid2D
    function Grid2D.create(cls, shape, xmin, xmax, ymin, ymax)
        local grid = setmetatable({}, cls.__meta)
        grid.xmax = xmax
        grid.xmin = xmin
        grid.ymin = ymin
        grid.ymax = ymax
        grid.width  = xmax - xmin
        grid.height = ymax - ymin
        grid.cell_width  = grid.width/shape[1]
        grid.cell_height = grid.height/shape[2]
        grid.shape = shape
        grid.cells = NDArray(grid.shape):fill(table.empty)
        return grid
    end

    setmetatable(Grid2D,{ __call = Grid2D.create})
end

do
    table = table or {}

    table.meta = {
        __index = table,
        __tostring = table.tostring,
        __add = nil,             -- сложение
        __sub = nil,             -- вычитание
        __mul = table.multiply,  -- умножение
        __div = table.divide     -- деление
    }

    function table:setmetatable(tbl)
        return setmetatable(tbl, self.meta)
    end

    setmetatable(table, {
        __call = table.setmetatable
    })

end

do -- require "table"

    --- генератор нулей
    local empty = math.empty or function()
        return nil
    end

    local function tostring2d(ndarray)
        local _str = "{"
        for i = 1, #ndarray do
            _str = _str .. table.tostring(ndarray[i])
            if i < #ndarray then
                _str = _str .. ",\n "
            else
                _str = _str .. "}"
            end
        end
        return _str
    end

    ---------------- Class NDArray API ----------------------------
    ---@type NDArrayClass
    ---@overload fun(shape:table): NDArray
    NDArray = NDArray or {}

    ---@class NDArray
    ---@field fill fun(self:NDArray, value:any):table
    ---@field tostring fun(self:NDArray):string
    ---@field shape table
    ---@field ndim number
    local object = {}

    ---@class NDArrayClass
    ---@field emptify fun(self:NDArrayClass, ndarray:NDArray):NDArray
    ---@field create fun(self:NDArrayClass, shape:table):NDArray
    local class = {}
    ---------------- object methods ---------------------------------
    ---fill
    ---@param value table
    ---@return NDArray
    function object:fill(value)
        NDArray:fill_nda(self, self.shape, value)
        return self
    end


    function object:tostring()
        if self.ndim == 1 then
            return table.tostring(self)
        end
        if self.ndim == 2 then
            return tostring2d(self)
        end
        if self.ndim == 3 then
            local str = "{\n\n"
            for i = 1, #self do
                str = str .. tostring2d(self[i]) .. ",\n\n"
            end
            return str
        end
    end

    local object_meta = {
        __index = object,
        __tostring = object.tostring
    }

    ---create
    ---@param shape table
    ---@return NDArray
    function class:create(shape)
        local obj = {} ---@type NDArray
        obj.shape = shape
        obj.ndim = #obj.shape
        self:emptify(obj)
        return setmetatable(obj, object_meta)
    end

    ---------------- class methods ------------------------
    ---emptify
    ---@param ndarray NDArray
    ---@return NDArray
    function class:emptify(ndarray)
        local shape = ndarray.shape

        if #shape == n then
            return table.fill(ndarray, empty, shape[n])
        end

        local old_stack = {}
        local new_stack = {}
        table.insert(old_stack, ndarray)
        --
        for n = 1, #shape - 1 do
            for _, _ndarray in ipairs(old_stack) do
                table.fill(_ndarray, table.empty, shape[n])
                for _, item in ipairs(_ndarray) do
                    table.insert(new_stack, item)
                end
            end
            old_stack = new_stack
            new_stack = {}
        end
    end

    function class:fill_nda(array, shape, value, n)
        n = n or 1
        if #shape == n then table.fill(array, value, shape[n]) return end
        for i = 1, shape[n] do
            self:fill_nda(array[i], shape, value, n + 1)
        end
    end


    setmetatable(NDArray, {
        __index = class,
        __call = class.create
    })
end
do
    table = table or {}
    table.tools = table.tools or {}

    ---@class Observer
    ---@field subscribe fun(obj: Observer, subscriber: function)
    ---@field unsubscribe fun(obj: Observer, subscriber: function)
    ---@field publish fun(obj: Observer,...)
    ---@field notify fun(obj: Observer)
    ---@overload fun():Observer
    table.tools.Observer = table.tools.Observer or {}
    

    local Observer = table.tools.Observer or {} ---@type Observer
    -- метатаблица для экземпляров
    Observer.__meta = {}
    Observer.__meta.__index = Observer

    ------------------ статические методы -----------------------

    ---@param cls Observer
    function Observer.init(cls)
        cls.publish_callback = function(sub,...) sub(...) end
        cls.notify_callback  = function(sub) sub() end
        return cls
    end

    ---@param cls Observer
    function Observer.__create(cls)
        local obj = setmetatable({}, cls.__meta)
        obj.subscribers = set()
        return obj
    end

    ---@param cls Observer
    function Observer.create(cls)
        cls.create = cls.__create
        cls:init()
        return cls.__create(cls)
    end

    ------------------ методы класса -----------------------
    -- подписка на наблюдателя
    ---@param subscriber function
    function Observer:subscribe(subscriber)
        return self.subscribers:insert(subscriber)
    end

    -- отписка от наблюдателя
    ---@param subscriber function
    function Observer:unsubscribe(subscriber)
        self.subscribers:remove(subscriber)
    end

    -- публикация подписчикам
    function Observer:publish(...)
        self.subscribers:each(self.publish_callback,...)
    end
    
    -- раздача копий подписчикам
    ---@param obj Observer
    Observer.distribute = function(obj,...)
        local data = {...}
        obj.subscribers:each(
            function(sub, data)
                local data_copy = table.deepcopy(data)                
                sub(table.unpack(data_copy)) 
            end,
            data
        )
    end
    
    -- уведомление подписчиков
    function Observer:notify()
        self.subscribers:each(self.notify_callback)
    end

    -- установка метатаблицы для класса
    setmetatable(Observer,{
                __call = Observer.create
            })

end


do
    table = table or {}
    table.tools = table.tools or {}
    local tools = table.tools
    tools.Searcher2d = tools.Searcher2d or {}
    
    ---@class Searcher2d
    ---@overload fun(xmin:number, xmax:number, ymin:number, ymax:number):Searcher2d
    local Searcher2d = tools.Searcher2d or {}

    Searcher2d.__meta = {
        __index = Searcher2d
    }

    Searcher2d.create = function(cls, xmin, xmax, ymin, ymax)
        local obj = setmetatable({}, cls.__meta)
        local cell_height = 1
        local cell_width = 1
        obj.grid = Grid(xmin, xmax, ymin, ymax, cell_width, cell_height)
        -- for _, item in ipairs(locations) do obj:insert(item) end
        return obj
    end

    function Searcher2d:insert(item)
        self.grid:insert(item.x, item.y, item)
    end

    function Searcher2d:insert_list(list_items)
        for _, item in ipairs(list_items) do
            self:insert(item)
        end
    end

    function Searcher2d:insert(item)
        self.grid:insert(item.x, item.y, item)
    end

    function Searcher2d:is_in_box(item, xmin, xmax, ymin, ymax)
        local x, y = item.x, item.y
        return x > xmin and x <= xmax and
               y > ymin and y <= ymax
    end

    function Searcher2d:is_in_range(item, x_0, y_0, r)
        local dx, dy = item.x - x_0, item.y - y_0
        return dx*dx + dy*dy <= r*r
    end

    function Searcher2d:get_cells_within_box(xmin, xmax, ymin, ymax)
        return self.grid:get_cells_within_box(xmin, xmax, ymin, ymax)
    end

    function Searcher2d:find_in_box(xmin, xmax, ymin, ymax)
        local cells = self:get_cells_within_box(xmin, xmax, ymin, ymax)
        local items = table.empty()
        for _, cell in ipairs(cells) do
            for _, item in ipairs(cell) do
                if self:is_in_box(item, xmin, xmax, ymin, ymax) then
                    table.insert(items, item)
                end
            end
        end
        return items
    end

    setmetatable(Searcher2d,{ __call = Searcher2d.create})
end


do
    ---@class set
    ---@field remove fun(self:set, item:any): boolean
    ---@field insert fun(self:set, item:any): boolean
    ---@field add fun(self:set, item:any): boolean
    ---@field has fun(self:set, item:any): boolean
    ---@field get_random fun(self:set): any
    ---@field remove_random fun(self:set)
    ---@field create fun(self:set, tbl:table): set
    ---@field __index_dict dict
    ---@overload fun(tbl:table): set
    set = set or {}

    ---@param obj set
    ---@param item any
    ---@return boolean
    set.insert = function(obj, item)
        if obj.__index_dict:has(item) then
            return false
        end
        table.insert(obj, item)
        obj.__index_dict:set(item, #obj)
        return true
    end

    ---@param item any
    ---@return boolean
    set.add = function(obj, item)
        if obj:insert(item) then
            return true
        end
        print("Ошибка: элемент уже существовал")
        return false
    end

    ---@param item any
    ---@return boolean
    function set:has(item)
        return self.__index_dict:has(item)
    end

    --- Removes an item from the set.
    ---@param item any The item to remove.
    ---@return boolean Returns `true` if the item was successfully removed, `false` otherwise.
    function set:remove(item)
        local idx = self.__index_dict:get(item)
        if not idx then
            print("Ошибка: элемент не существовал")
            return false
        end
        table.remove_swap(self, idx)
        if self[idx] ~= nil then
            self.__index_dict:remove(item)
            self.__index_dict:set(self[idx], idx)
            return true
        else
            self.__index_dict:remove(item)
        end
        return true
    end

    function set:get_last()
        if #self == 0 then return nil end
        return self[#self]
    end

    function set:get_random()
        return table.get_random(self)
    end

    function set:remove_random()
        local item = self:get_random()
        if item == nil then return nil end
        return self:remove(self:get_random())
    end

    ---@param _set set Второе множество.
    ---@return set Новое объединённое множество.
    function set:union(_set)
        for _, item in ipairs(_set) do
            self:insert(item)  -- Добавляем элементы из второго множества
        end
        return self
    end

    set.each = function(obj, callback,...)
        for _, item in ipairs(obj) do
            callback(item,...)    
        end
    end
    
    --- Возвращает новое множество, являющееся пересечением текущего множества и второго.
    ---@param _set set Второе множество.
    ---@return set Пересечённое множество.
    function set:intersection(_set)
        local i = 1
        while i <= #self do
            local item = self[i]
            if _set:has(item) then
                i = i + 1
            else
                self:remove(item)
            end
        end
        return self
    end


    ---@param _set set Второе множество.
    ---@return set Новое множество-разность.
    function set:difference(_set)
        local i = 1
        while i <= #self do
            local item = self[i]
            if _set:has(item) then
                self:remove(item)
            else
                i = i + 1
            end
        end
        return self
    end


    function set:clear()
        local len = #self
        for i = 1, len do
            local item = self[i]
            self[i] = nil
            self.__index_dict:remove(item)
        end
    end


    set.object_meta = {
        __index = set,
        __tostring = table.tostring,
        __add = function(set1, set2) return set.union(set(table.copy(set1)), set2)  end,
        __mul = function(set1, set2) return set.intersection(set(table.copy(set1)), set2)  end,
        __sub = function(set1, set2) return set.difference(set(table.copy(set1)), set2)  end
    }


    --- Создаёт новое множество.
    ---@param tbl table|set Начальная таблица элементов (опционально).
    ---@return set Новое множество.
    function set:create(tbl)
        tbl = tbl or {} ---@type set
        tbl, tbl.__index_dict = table.unique(tbl)
        return setmetatable(tbl, self.object_meta)
    end

    setmetatable(set, {__call = set.create})
end

do
    table = table or {}
    ---@field stooge fun(array:table):table
    ---@field shell fun(array:table):table
    ---@field pigeonhole fun(array:table):table -- integer only
    ---@field pancake fun(array:table):table
    ---@field merge fun(array:table):table
    ---@field heap fun(array:table):table
    ---@field gnome fun(array:table):table
    ---@field cycle fun(array:table):table
    ---@field comb fun(array:table):table
    ---@field cocktail fun(array:table):table
    ---@field circle fun(array:table):table
    ---@field insertion fun(array:table):table
    ---@field quick fun(array:table):table
    ---@field bucket fun(array:table):table
    ---@field bubble fun(array:table):table
    table.sorts = table.sorts or {}
    local sorts = table.sorts

    -- gravity -- полезная сортировка

    -- excluded
    --[[bogo, radix]]--

    -- not stable
    -- [[bucket]] --


    ---bubble
    ---@param array table
    function sorts.bubble(array)
        for i = 1, #array do
            for j = 1, #array - i do
                if array[j] > array[j + 1] then
                    array[j], array[j + 1] = array[j + 1], array[j]
                end
            end
        end
        return array
    end

    ---bucket
    ---@param array table
    ---@param slots number|nil
    function sorts.bucket(array, slots)
        local buckets = {}
        slots = 10 or slots

        -- Создаем пустые корзины
        for _ = 1, slots do
            table.insert(buckets, {})
        end

        -- Находим максимальное значение, чтобы правильно распределить элементы по корзинам
        local maxValue = table.max(array)

        -- Распределяем элементы по корзинам
        for _, value in ipairs(array) do
            local index = math.ceil((value / maxValue) * (slots - 1)) + 1
            table.insert(buckets[index], value)
        end

        -- Сортируем каждую корзину
        for i = 1, slots do
            buckets[i] = table.sorts.insertion(buckets[i])
        end

        -- Собираем обратно элементы из корзин
        local k = 1
        for i = 1, slots do
            for j = 1, #buckets[i] do
                array[k] = buckets[i][j]
                k = k + 1
            end
        end

        return array
    end

    ---quick
    ---@param array table
    ---@return table
    function sorts.quick(array)
        local function partition(low, high)
            local pivot = array[high]
            local i = low - 1
            for j = low, high - 1 do
                if array[j] <= pivot then
                    i = i + 1
                    array[i], array[j] = array[j], array[i]
                end
            end
            array[i + 1], array[high] = array[high], array[i + 1]
            return i + 1
        end
        local function sort(low, high)
            if low < high then
                local pivot = partition(low, high)
                sort(low, pivot - 1)
                sort(pivot + 1, high)
            end
            return array
        end
        return sort(1, #array)
    end

    ---insertion
    ---@param array table
    ---@return table
    function sorts.insertion(array)
        for i = 2, #array do
            local key = array[i]
            local j = i - 1
            while j > 0 and key < array[j] do
                array[j + 1] = array[j]
                j = j - 1
            end
            array[j + 1] = key
        end
        return array
    end

    ---circle
    ---@param array table
    ---@return table
    function sorts.circle(array)
        local function inner_circle(list, low, high, swaps)
            if low >= high then
                return swaps
            end
            local sub_high, sub_low = high, low
            --[[цикл, начинает с условно граничных значений,
            постепенно сужает границу и переставляет значения на границе
            --]]
            while low < high do
                if list[low] > list[high] then
                    list[low], list[high] = list[high], list[low]
                    swaps = swaps + 1
                end
                low = low + 1
                high = high - 1
            end
            --разделение массива на два подмассива
            swaps = inner_circle(list, sub_low, high, swaps)
            swaps = inner_circle(list, low, sub_high, swaps)
            return swaps
        end

        while inner_circle(array, 1, #array, 0) > 0 do end
        return array
    end

    ---cocktail
    ---@param array table
    ---@return table
    function sorts.cocktail(array)
        local swapped

        repeat
            swapped = false

            for i = 1, #array - 1 do
                if array[i] > array[i + 1] then
                    array[i], array[i + 1] = array[i + 1], array[i]
                    swapped = true
                end
            end

            if not swapped then
                break
            end

            for i = #array - 1, 1, -1 do
                if array[i] > array[i + 1] then
                    array[i], array[i + 1] = array[i + 1], array[i]
                    swapped = true
                end
            end
        until swapped == false

        return array
    end

    ---comb
    ---@param array table
    ---@return table
    function sorts.comb(array)
        local function get_next_gap(gap)
            gap = math.floor((gap * 10) / 13)
            if gap < 1 then
                return 1
            end
            return gap
        end
        local gap = #array
        local swapped = true
        while gap ~= 1 or swapped do
            gap = get_next_gap(gap)
            swapped = false
            for i = 1, #array - gap do
                if array[i] > array[i + gap] then
                    array[i], array[i + gap] = array[i + gap], array[i]
                    swapped = true
                end
            end
        end
        return array
    end

    ---cycle
    ---@param array table
    ---@return table
    function sorts.cycle(array)
        local start = 0

        while start < #array - 1 do
            local value = array[start + 1]

            local position = start
            local i = start + 1

            while i < #array do
                if array[i + 1] < value then
                    position = position + 1
                end

                i = i + 1
            end

            if position ~= start then
                while value == array[position + 1] do
                    position = position + 1
                end

                array[position + 1], value = value, array[position + 1]

                while position ~= start do
                    position = start
                    i = start + 1

                    while i < #array do
                        if array[i + 1] < value then
                            position = position + 1
                        end

                        i = i + 1
                    end

                    while value == array[position + 1] do
                        position = position + 1
                    end

                    array[position + 1], value = value, array[position + 1]
                end
            end

            start = start + 1
        end

        return array
    end

    ---gnome
    ---@param array table
    ---@return table
    function sorts.gnome(array)
        local i, j = 2, 3

        while i <= #array do
            if array[i-1] <= array[i] then
                i = j
                j = j + 1
            else
                array[i - 1], array[i] = array[i], array[i - 1]
                i = i - 1

                if i == 1 then
                    i = j
                    j = j + 1
                end
            end
        end

        return array
    end

    ---heap
    ---@param array table
    ---@return table
    function sorts.heap(array)
        local function heapify(size, i)
            local left = 2 * i
            local right = 2 * i + 1
            local largest
            if left <= size and array[left] > array[i] then
                largest = left
            else
                largest = i
            end
            if right <= size and array[right] > array[largest] then
                largest = right
            end
            if largest ~= i then
                array[i], array[largest] = array[largest], array[i]
                heapify(size, largest)
            end
        end
        local size = #array
        for i = math.floor(size / 2), 1, -1 do
            heapify(size, i)
        end
        for i = #array, 2, -1 do
            array[i], array[1] = array[1], array[i]
            size = size - 1
            heapify(size, 1)
        end
        return array
    end

    ---merge
    ---@param array table
    ---@return table
    function sorts.merge(array)
        local function mergeSort(low, mid, high)
            local n1 = mid - low + 1
            local n2 = high - mid
            local left = {}
            local right = {}

            for i = 1, n1 do
                left[i] = array[low + i - 1]
            end
            left[n1 + 1] = math.huge

            for j = 1, n2 do
                right[j] = array[mid + j]
            end
            right[n2 + 1] = math.huge

            local i = 1
            local j = 1

            for k = low, high do
                if left[i] <= right[j] then
                    array[k] = left[i]
                    i = i + 1
                else
                    array[k] = right[j]
                    j = j + 1
                end
            end
        end

        local function sort(low, high)
            if low < high then
                local mid = math.floor((low + high) / 2)
                sort(low, mid)
                sort(mid + 1, high)
                mergeSort(low, mid, high)
            end

            return array
        end

        return sort(1, #array)
    end

    ---pancake
    ---@param array table
    ---@return table
    function sorts.pancake(array)

        local function flip(array, i)
            local start = 1
            while start < i do
                array[i], array[start] = array[start], array[i]
                start = start + 1
                i = i - 1
            end
        end

        local function find_argmax(array, n)
            local max = 1

            for i = 1, n do
                if array[i] > array[max] then
                    max = i
                end
            end
            return max
        end

        local size = #array

        while size > 1 do
            local max = find_argmax(array, size)

            if max ~= size then
                flip(array, max)
                flip(array, size)
            end

            size = size - 1
        end

        return array
    end

    ---pigeonhole
    ---@param array table
    ---@return table
    function sorts.pigeonhole(array)
        local holes = {}

        for i = 1, #array do
            holes[i] = 0
        end

        for v,_ in ipairs(array) do
            holes[v] = holes[v] + 1
        end

        local i = 1
        for count = 1, #array do
            while holes[count] > 0 do
                holes[count] = holes[count] - 1
                array[i] = count
                i = i + 1
            end
        end
        return array
    end

    ---selection
    ---@param array table
    ---@return table
    function sorts.selection(array)
        for i = 1, #array do
            local min = i

            for j = i + 1, #array do
                if array[min] > array[j] then
                    min = j
                end
            end

            array[i], array[min] = array[min], array[i]
        end

        return array
    end

    ---shell
    ---@param array table
    ---@return table
    function sorts.shell(array)
        local gap = math.floor(#array / 2)

        while gap > 0 do
            local j = gap

            while j < #array do
                local i = j - gap

                while i >= 0 do
                    if array[i + gap + 1] > array[i + 1] then
                        break
                    else
                        array[i + gap + 1], array[i + 1] = array[i + 1], array[i + gap + 1]
                    end

                    i = i - gap
                end

                j = j + 1
            end

            gap = math.floor(gap / 2)
        end

        return array
    end

    ---stooge
    ---@param array table
    ---@return table
    function sorts.stooge(array)
        local function sort(low, high)
            if low >= high then
                return
            end

            if array[low] > array[high] then
                array[low], array[high] = array[high], array[low]
            end

            if high - low > 1 then
                local part = math.floor((high - low + 1) / 3)
                sort(low, high - part)
                sort(low + part, high)
                sort(low, high - part)
            end

            return array
        end

        return sort(1, #array)
    end
end
do
    --[[war3-lua-table (27.09.2024)]]--
    ---@class table
    ---@field unique fun(tbl: table): table, table
    ---@field find fun(tbl: table, value: any): table
    ---@field find_first fun(tbl: table, value: any, pos_start: number): table|nil
    ---@field get_meta_compatible fun(tbl:table,...):table
    ---@field merge fun(tbl:table,...):table
    ---@field get_random fun(tbl:table):any
    ---@field get fun(tbl:table, idx:number):any
    ---@field empty fun():table
    ---@field fill fun(tbl:table, value:number, pos_start:number, pos_end:number):table
    ---@field move fun(tbl:table, pos_start:number, pos_end:number, tbl_to:number, pos_to:number):table
    ---@field is_sorted fun(tbl:table):boolean
    ---@field copy fun(tbl:table):table
    ---@field slice fun(tbl:table, pos_start:number, pos_end:number):table
    ---@field multiply fun(tbl:table, value:number):table
    ---@field divide fun(tbl:table, value:number):table
    ---@field subtract fun(tbl:table, value:number):table
    ---@field add fun(tbl:table, value:number):table
    ---@field argmin fun(tbl:table):number
    ---@field argmax fun(tbl:table):number
    ---@field min fun(tbl:table):number
    ---@field max fun(tbl:table):number
    ---@field cumsum fun(tbl:table):table
    ---@field sum fun(tbl:table):number
    ---@field reverse fun(tbl:table):table
    ---@field shuffle fun(tbl:table):table
    ---@field remove_swap fun(tbl:table, idx:number):any
    ---@field remove fun(tbl:table, idx:number):any
    ---@field tostring fun(tbl:table):string
    ---@field pack fun(...):table
    ---@field unpack fun(tbl:table, start_pos:number, end_pos:number)
    ---@field insert fun(tbl:table, pos:number, value:number):table
    table = table or {}

    ---@return table
    table.empty = function()
        return {}
    end
    
    ---insert
    ---@param tbl table
    ---@param pos number
    ---@param value number
    ---@return table
    table.insert = table.insert or
    function(tbl, pos, value)
        -- Определяем, передано ли значение или только позиция
        if value == nil then
            pos, value = #tbl + 1, pos
        end
        -- Если pos выходит за границы текущей длины таблицы, добавляем в конец
        if pos > #tbl + 1 then
            pos = #tbl + 1
        end

        -- Сдвигаем элементы вправо, начиная с позиции pos
        for i = #tbl, pos, -1 do
            tbl[i + 1] = tbl[i]
        end
        -- Вставляем значение на позицию pos
        tbl[pos] = value
        return tbl
    end

    ---unpack
    ---@param tbl table
    ---@param start_pos number
    ---@param end_pos number
    ---@return table
    table.unpack = table.unpack or
    function(tbl, start_pos, end_pos)
        start_pos = start_pos or 1
        end_pos = end_pos or #tbl
        if start_pos <= end_pos then
            return tbl[start_pos], table.unpack(tbl, start_pos + 1, end_pos)
        end
    end

    ---pack
    ---@return table
    table.pack = table.pack or
    function(...)
        return { ... }
    end

    ---tostring
    ---@param tbl table
    ---@return table
    table.tostring = table.tostring or
    function(tbl)
        if getmetatable(tbl) and getmetatable(tbl).__tostring then return tostring(tbl) end
        if tbl == nil then return tostring(nil) end
        if type(tbl) ~= "table" then return tostring(tbl) end
        local str = "{"
        if #tbl == 0 then return str .. "}" end
        if #tbl == 1 then return str .. table.tostring(tbl[1]) .. "}" end
        str = str .. table.tostring(tbl[1])
        for i=2, #tbl do
            str = str .. "," .. table.tostring(tbl[i])
        end
        str = str .. "}"
        return str
    end

    ---remove
    ---@param tbl table
    ---@param tbl number|nil
    ---@return any
    table.remove = table.remove or function(tbl, idx)
        idx = idx or #tbl
        local item = tbl[idx]
        for i = idx, #tbl - 1 do
            tbl[i] = tbl[i + 1]
        end
        tbl[#tbl] = nil
        return item
    end


    ---remove_swap
    ---@param tbl table
    ---@param idx number
    ---@return any
    table.remove_swap = table.remove_swap or
    function(tbl, idx)
        idx = idx or #tbl
        local item = tbl[idx]
        tbl[idx]  = tbl[#tbl]
        tbl[#tbl] = nil
        return item
    end


    ---shuffle
    ---@param tbl table
    ---@return table
    table.shuffle = table.shuffle or
    function(tbl)
        -- алгоритм случайного тасования Дурштенфельда
        for i = #tbl, 2, -1 do
            local j = math.random(1, i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
    end

    ---reverse
    ---@param tbl table
    ---@return table
    table.reverse = table.reverse or
    function(tbl)
        if #tbl <= 1 then return end
        local n = math.floor(#tbl/2)
        for i=1, n do
            tbl[i], tbl[#tbl-i+1] = tbl[#tbl-i+1], tbl[i]
        end
    end

    ---sum
    ---@param tbl table
    ---@return number
    table.sum = table.sum or
    function(tbl)
        local sum = 0
        for i=1, #tbl do
            sum = sum + tbl[i]
        end
        return sum
    end

    ---cumsum
    ---@param tbl table
    ---@return table
    table.cumsum =
    function(tbl)
        local cs = table.empty()
        local sum = 0
        for i=1, #tbl do
            sum = sum + tbl[i]
            cs[i] = sum
        end
        return cs
    end

    ---max
    ---@param tbl table
    ---@return table
    table.max =
    function(tbl)
        local len = #tbl
        if len == 0 then return nil end
        if len == 1 then return tbl[1] end
        local max = tbl[1]
        for i=2, #tbl do
            if tbl[i] > max then max = tbl[i] end
        end
        return max
    end

    ---min
    ---@param tbl table
    ---@return table
    table.min =
    function(tbl)
        local len = #tbl
        if len == 0 then return nil end
        if len == 1 then return tbl[1] end
        local min = tbl[1]
        for i=2, #tbl do
            if tbl[i] < min then min = tbl[i] end
        end
        return min
    end

    ---argmax
    ---@param tbl table
    ---@return table
    table.argmax =
    function(tbl)
        local len = #tbl
        if len == 0 then return nil end
        if len == 1 then return 1 end
        local idx = 1
        for i=2, #tbl do
            if tbl[i] > tbl[idx] then idx = i end
        end
        return idx
    end

    ---argmin
    ---@param tbl table
    ---@return table
    table.argmin =
    function(tbl)
        local len = #tbl
        if len == 0 then return nil end
        if len == 1 then return 1 end
        local idx = 1
        for i=2, #tbl do
            if tbl[i] < tbl[idx] then idx = i end
        end
        return idx
    end

    
    ---add
    ---@param tbl table
    ---@param value number
    ---@return table
    table.add =
    function(tbl, value)
          for i=1, #tbl do
            tbl[i] = tbl[i] + value
          end
        return tbl
    end

    
    ---subtract
    ---@param tbl table
    ---@param val number
    ---@return table
    table.subtract =
    function(tbl, val)
        for i=1, #tbl do
            tbl[i] = tbl[i] - val
        end
        return tbl
    end

    
    ---multiply
    ---@param tbl table
    ---@param val number
    ---@return table
    table.multiply =
    function(tbl, val)
        for i=1, #tbl do
            tbl[i] = tbl[i] * val
        end
        return tbl
    end
    

    ---divide
    ---@param tbl table
    ---@param val number
    ---@return table
    table.divide =
    function(tbl, val)
        for i=1, #tbl do
            tbl[i] = tbl[i] / val
        end
        return tbl
    end

    ---slice
    ---@param tbl table
    ---@param pos_start number
    ---@param pos_end number
    table.slice =
    function(tbl, pos_start, pos_end)
        local slice = {}
        local length = pos_end - pos_start + 1
        local _pos_start = pos_start - 1
        for i = 1, length do
            slice[i] = tbl[_pos_start + i]
        end
        return slice
    end
    
    --------------- fuctional utils ------------
    table.each = function(tbl, callback,...)
        for key, value in pairs(tbl) do
            callback(key, value,...)
        end
    end
    
    table.ieach = function(tbl, callback,...)
        for i, value in ipairs(tbl) do
            callback(i, value,...)
        end
    end
    
    table.map = function(tbl, callback,...)
        local map = table.empty()
        for i, value in ipairs(tbl) do
            map[i] = callback(value,...)
        end
        return map
    end
    --------------------------------------------

    ---copy
    ---@param tbl table
    ---@return table
    table.copy = table.copy or
    function(tbl, callback)
        callback = callback or function(value) return value end
        local tbl_copy = table.map(tbl, callback)
        return setmetatable(tbl_copy, getmetatable(tbl))
    end
    
    
    ---deepcopy
    ---@param tbl table
    ---@return table
    table.deepcopy = table.deepcopy or
    function(tbl)
        return table.copy(tbl, function(value)
            if type(value) == "table" then
                local meta = getmetatable(tbl)
                local deepcopy = meta and meta.__deepcopy or table.deepcopy
                return deepcopy(value)
            else
                return value
            end
        end)
    end


    ---is_sorted
    ---@param tbl table
    ---@return boolean
    table.is_sorted =
    function(tbl)
        for i = 2, #tbl do
            if tbl[i - 1] >= tbl[i] then
                return false
            end
        end
        return true
    end

    ---move
    ---@param tbl table
    ---@param pos_start number
    ---@param pos_end number
    ---@param pos_to number
    ---@param tbl_to table
    ---@return table
    table.move =
    function(tbl, pos_start, pos_end,  pos_to, tbl_to)
        tbl_to = tbl_to or tbl
        pos_to = pos_to or 1
        
        local offset = pos_to - pos_start -- перекрытие регионов
        if offset > 0 then
            for i = pos_end, pos_start, -1 do
                tbl_to[i + offset] = tbl[i]
            end
        else
            for i = pos_start, pos_end do
                tbl_to[i + offset] = tbl[i]
            end
        end
        return tbl_to
    end

    ---fill
    ---@param tbl table
    ---@param value number|function
    ---@param pos_start number|nil
    ---@param pos_end number|nil
    table.fill =
    function(tbl, value, pos_start, pos_end)
        pos_start = pos_start or 1
        if pos_end == nil then pos_start, pos_end = 1, pos_start or #tbl end
        if type(value) == "number" then
            for i = pos_start, pos_end do
                tbl[i] = value
            end
        else
            for i = pos_start, pos_end do
                tbl[i] = value(i)
            end
        end
    end
    
    ---get
    ---@param tbl table
    ---@param idx number
    ---@return any
    table.get =
    function(tbl, idx)
        return tbl[idx]
    end


    ---rawget
    ---@param tbl table
    ---@param idx number
    ---@return any
    table.rawget =
    function(tbl, idx)
        return rawget(tbl, idx)
    end


    ---get_random
    ---@param tbl table
    ---@return any
    table.get_random =
    function(tbl)
        if #tbl == 0 then return nil end
        return tbl[math.random(1, #tbl)]
    end


    table.get_meta_compatible =
    function(tbl,...)
        local tbls = {tbl, ...}
        if #tbls == 1 then tbls = {table.unpack(tbl)} end
        
        local meta = getmetatable(tbls[1])
        for i = 1, #tbls do
            meta = meta or getmetatable(tbls[i])
            local compare_meta = getmetatable(tbls[i]) or meta
            if meta ~= compare_meta then
                print("Ошибка: метатаблицы не совместимы")
                return false
            end
        end
        return meta or getmetatable(tbl)
    end


    table.merge = function(tbl, ...)
        if tbl == nil then return nil end
        -- try to set common metatable
        local meta = table.get_meta_compatible(tbl,...)
        if meta == false then return nil end
        local merge = setmetatable({}, meta)
        --
        local tbls = {tbl, ...}
        if #tbls == 1 then tbls = tbl end
        --
        local k = 1
        for i = 1, #tbls do
            local _tbl = tbls[i]
            if type(_tbl) == "table" then
                table.move(_tbl, 1, #_tbl, k, merge)
                k = k + #_tbl
            elseif tbl then
                merge[k] = tbl
                k = k + 1
            end
        end
        
        return merge
    end

    ---unique
    ---@param tbl table
    ---@return table, dict
    table.unique =
    function(tbl)
        local index_dict = dict()
        local i = 1
        while i <= #tbl do
            local item = tbl[i]
            if not (index_dict:has(item)) then
                index_dict:set(item, i)
                i = i + 1
            else
                table.remove_swap(tbl, i)
            end
        end
        return tbl, index_dict
    end


    ---find_first
    ---@overload fun(tbl:table, item:any):number|nil
    ---@param tbl table
    ---@param item any
    ---@param pos_start|nil
    ---@return number|nil
    table.find_first = table.find_first or
    function(tbl, item, pos_start)
        pos_start = pos_start or 1
        for i =  pos_start, #tbl do
            if tbl[i] == item then
                return i
            end
        end
        return nil
    end

    ---find
    ---@param tbl table
    ---@param item any
    ---@return number[]
    table.find = table.find or
    function(tbl, item)
        local indices  = {}
        for i = 1, #tbl do
            if tbl[i] == item then
                table.insert(indices , i)
            end
        end
        return indices
    end

end

InputServer = {}

function InputServer:get_mouse_x(player)
    return self.mouse_move_control:get_input_x(player)
end

function InputServer:get_mouse_y(player)
    return self.mouse_move_control:get_input_y(player)
end

-- Получить вектор движения игрока
function InputServer:get_movement_vector(player)

    local x = 0
    local y = 0

    -- Ось X (горизонтальное движение)
    if self.keyboard_control:is_player_button_pressed(player, OSKEY_A) then
        x = x - 1  -- Движение влево
    end
    if self.keyboard_control:is_player_button_pressed(player, OSKEY_D) then
        x = x + 1  -- Движение вправо
    end

    -- Ось Y (вертикальное движение)
    if self.keyboard_control:is_player_button_pressed(player, OSKEY_W) then
        y = y + 1  -- Движение вперёд
    end
    if self.keyboard_control:is_player_button_pressed(player, OSKEY_S) then
        y = y - 1  -- Движение назад
    end

    return x, y
end



function InputServer.init(cls)
    cls.init = function(_cls) return _cls end
    cls.keyboard_control = KeyboardController:init()
    cls.mouse_move_control = MouseMoveController:init()
    ControlAgent:init()
    cls.keyboard_control:add_key(OSKEY_W)
    cls.keyboard_control:add_key(OSKEY_A)
    cls.keyboard_control:add_key(OSKEY_S)
    cls.keyboard_control:add_key(OSKEY_D)
    return cls
end

---@class KeyboardController
KeyboardController = {}


function KeyboardController.get_config()
    local config = {}
    config.hearing_keys = {
        OSKEY_Q, OSKEY_W, OSKEY_E,
        OSKEY_A, OSKEY_S, OSKEY_D
    }
    return config
end


---@param cls KeyboardController
function KeyboardController.is_player_button_pressed(cls, player, os_key)
    return cls.player_key[player][os_key]
end


function KeyboardController._on_keyboard_event()
    local key_status = BlzGetTriggerPlayerIsKeyDown()
    local os_key = BlzGetTriggerPlayerKey()
    local player = GetTriggerPlayer()
    KeyboardController.player_key[player][os_key] = key_status
end

---@param cls KeyboardController
---@param os_key_type oskeytype
function KeyboardController.add_key(cls, os_key_type)
    for i = 1, bj_MAX_PLAYER_SLOTS do
        local player = Player(i-1)
        cls.player_key[player] = {}
        BlzTriggerRegisterPlayerKeyEvent(cls.trigger_keypress, player, os_key_type, 0, true  )
        BlzTriggerRegisterPlayerKeyEvent(cls.trigger_keypress, player, os_key_type, 0, false )
    end
end

---@param cls KeyboardController
---@return KeyboardController
function KeyboardController.init(cls)
    cls.init = function(_cls) return _cls end
    cls.player_key = {}
    cls.trigger_keypress = CreateTrigger()
    TriggerAddAction(cls.trigger_keypress, cls._on_keyboard_event)
    return cls
end


setmetatable(KeyboardController, {
    __call = function(cls,...) return cls:init(...) end
})
---@class MouseMoveController
MouseMoveController = {}

function MouseMoveController.get_input_x(cls, player)
    return cls.input_x[GetPlayerId(player) + 1] or 0
end

function MouseMoveController.get_input_y(cls, player)
    return cls.input_y[GetPlayerId(player) + 1] or 0
end

function MouseMoveController.set_mouse_center()
    local x = math.floor(BlzGetLocalClientWidth()/2)
    local y = math.floor(BlzGetLocalClientHeight()/2)
    BlzSetMousePos(x, y)
end

---@param cls MouseMoveController
function MouseMoveController.init(cls)
    cls.init = function(_cls) return _cls end
    cls.net_frame = NetFrame:init()
    cls.input_x = cls.net_frame.input_x
    cls.input_y = cls.net_frame.input_y
    --TimerStart(CreateTimer(), 0.02, true, MouseMoveController.set_mouse_center)
    return cls
end
---@class NetFrame
NetFrame = {}

function NetFrame._frame_callback()
    local frame_handle = BlzGetTriggerFrame()
    local player = GetTriggerPlayer()
    local net_frame = NetFrame:get(frame_handle)
    NetFrame.input_x[GetPlayerId(player) + 1] = net_frame.x
    NetFrame.input_y[GetPlayerId(player) + 1] = net_frame.y
end

---@param cls NetFrame
function NetFrame.create(cls, x ,y)
    local obj = {}
    local parent = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    obj.frame = BlzCreateFrameByType("SCROLLBAR", "FrameGridBoss", parent,"",0)
    obj.x = x
    obj.y = y
    BlzFrameSetAbsPoint(obj.frame, FRAMEPOINT_CENTER, 0.4 + x, 0.3 + y)
    BlzFrameSetSize(obj.frame, cls.frame_width, cls.frame_height)
    BlzTriggerRegisterFrameEvent(cls.frame_trig, obj.frame, FRAMEEVENT_MOUSE_ENTER)
    cls.link:set(obj.frame, obj)
    return obj
end

---@param cls NetFrame
---@param frame_handle framehandle
function NetFrame.get(cls, frame_handle)
    return cls.link:get(frame_handle)
end

---@param cls NetFrame
function NetFrame.create_grid(cls)
    for i = -5, 5 do
        for j = -5, 5 do
            if not (i == 0 and j == 0) then
                cls:create(i * cls.frame_height, j * cls.frame_width)
            end
        end
    end
end

---@param cls NetFrame
function NetFrame.init(cls)
    cls.init = function(_cls) return _cls end
    cls.frame_width = 0.05
    cls.frame_height = 0.05
    cls.frame_trig = CreateTrigger()
    cls.link = dict()
    cls.input_x = {}
    cls.input_y = {}
    cls:create_grid()
    TriggerAddAction( cls.frame_trig, cls._frame_callback)
    return cls
end
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
        local speed = 5
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
--CUSTOM_CODE
function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(1)
SetTeams(1)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -960.0, 64.0)
InitCustomPlayerSlots()
SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
InitGenericPlayerSlots()
end

