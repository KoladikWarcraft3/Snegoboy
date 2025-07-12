InputServer = {}

function InputServer:get_mouse_vx(player)
    return NetFrame:get_input_x(player)
end

function InputServer:get_mouse_vy(player)
    return NetFrame:get_input_y(player)
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



function InputServer:init()
    self.keyboard_control = KeyboardController:init()
    ControlAgent:init()
    self.keyboard_control:add_key(OSKEY_W)
    self.keyboard_control:add_key(OSKEY_A)
    self.keyboard_control:add_key(OSKEY_S)
    self.keyboard_control:add_key(OSKEY_D)
    --NetFrame:init()
end
