local module = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ActionType = "dot"
local icons = {

}

function module.SetMouseAction(actionType)
    ActionType = actionType
end


local mouse = Players.LocalPlayer:GetMouse()

function module.main()
    while task.wait(.1) do
        mouse.Icon = if icons[ActionType] then icons[ActionType] else nil
    end
end

return module