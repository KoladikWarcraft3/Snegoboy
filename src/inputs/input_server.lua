InputServer = {}

function InputServer:get_mouse_vx(player)
    return NetFrame:get_input_x(player)
end

function InputServer:get_mouse_vy(player)
    return NetFrame:get_input_y(player)
end

function InputServer:init()
    NetFrame:init()
end
