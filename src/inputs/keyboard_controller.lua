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