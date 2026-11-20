local module = {}

local CAS = game:GetService("ContextActionService")

module.tags = {
    run = {
        Keycodes = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift,Enum.KeyCode.ButtonL3}
    },
    cameraDir = {
        Keycodes = {Enum.KeyCode.E,Enum.KeyCode.Q,Enum.KeyCode.ButtonLeft, Enum.KeyCode.ButtonRight}
    },
    lockUnlockMouse = {
        Keycodes = {Enum.KeyCode.LeftControl,Enum.KeyCode.RightControl}
    }
}
module.ActiveButtons = {}

function module.CreateButton(tag,Func)


    if module.ActiveButtons[tag] then
        module.ActiveButtons[tag]:Destroy()
        module.ActiveButtons[tag] = nil
        CAS:UnbindAction(tag)
    end
    CAS:BindAction(tag,Func,false,table.unpack(module.tags[tag].Keycodes))
end

return module