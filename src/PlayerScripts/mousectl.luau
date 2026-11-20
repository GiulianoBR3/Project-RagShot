local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local keycodes = require(ReplicatedStorage.Modules.handeKeycodes)

local locked = true
local ActionType = "defaultLock"
local icons = {
    defaultLock = "rbxasset://textures/MouseLockedCursor.png"
}


function module.SetMouseAction(actionType)
    ActionType = actionType
end

function mouseLockManagement(boolean:boolean)
    locked = boolean
end
local mouse = Players.LocalPlayer:GetMouse()

function module.main()
    keycodes.CreateButton("lockUnlockMouse",function(_,state)
        if state ~= Enum.UserInputState.Begin then return end
        mouseLockManagement(not locked)
    end)
    while task.wait(.1) do
        mouse.Icon = if icons[ActionType] and locked then icons[ActionType] else ""
        UserInputService.MouseBehavior = 
        if locked then 
            Enum.MouseBehavior.LockCenter 
        else
            Enum.MouseBehavior.Default
    end
end

return module