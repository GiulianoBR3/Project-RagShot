local module = {}

local RunService = game:GetService("RunService")

local function straightenCF(cf)
    local _, yaw, _ = cf:ToOrientation()
    return CFrame.fromOrientation(0, yaw, 0)
end

function module.main(character)
    local Root = character:WaitForChild("HumanoidRootPart")
    local Align = Root:WaitForChild("UprightAlign") -- created in manageBalance.luau

    -- Only the target changes here. The AlignOrientation constraint turns the
    -- character toward the camera yaw on every physics substep, so low FPS only
    -- makes the target update less often instead of destabilizing the character.
    RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        if camera then
            Align.CFrame = straightenCF(camera.CFrame)
        end
    end)
end

return module
