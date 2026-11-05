local module = {}

local RunService = game:GetService("RunService")

local fovModule = require(script.Parent.Fov)

local Camera = workspace.CurrentCamera

local lastCameraPos = Vector3.zero
local CameraPos = lastCameraPos

function module.main()
    RunService.RenderStepped:Connect(function(dt)
        CameraPos = if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position
        else
            workspace.CurrentCamera.CFrame.Position
        local speed = (CameraPos - lastCameraPos).Magnitude / dt
        lastCameraPos = CameraPos
        fovModule.SetFov("MovementFov", speed)
    end)
end

return module