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
