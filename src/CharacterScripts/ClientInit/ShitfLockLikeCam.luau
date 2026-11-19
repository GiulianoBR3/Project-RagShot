local module = {}

local RunService = game:GetService("RunService")
local GetdesiredMoveDirection = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("utils")).getDesiredMoveDirection
local keycodes = require(game:GetService("ReplicatedStorage").Modules.handeKeycodes)

local right = true
local defcd = 0
local Offset = Vector3.new()
local OldOffset = Vector3.new()

function module.main(char)
    local Hum = char:WaitForChild("Humanoid")
    local RootPart = char:WaitForChild("HumanoidRootPart")

    keycodes.CreateButton("cameraDir",function(_,state, obj)
        if state == Enum.UserInputState.Begin then
            if obj.KeyCode == Enum.KeyCode.Q or obj.KeyCode == Enum.KeyCode.ButtonLeft then
                right = false
            elseif obj.KeyCode == Enum.KeyCode.E or obj.KeyCode == Enum.KeyCode.ButtonRight then
                right = true
            end
            defcd = 3
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if defcd > 0 then
            defcd -= dt
        else
            local dir = GetdesiredMoveDirection()
            if dir.Magnitude > 0 then
                right = if RootPart.CFrame.RightVector:Dot(dir) > 0.8 then 
                    true 
                elseif RootPart.CFrame.RightVector:Dot(dir) < -0.8 then 
                    false 
                else 
                    right
            end
        end
        Offset = Offset:Lerp(Vector3.new(if right then 1 else -1,0,0),dt*5)
        Hum.CameraOffset += Offset - OldOffset
        OldOffset = Offset
    end)
end

return module