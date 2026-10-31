local module = {}

local RunService = game:GetService("RunService")

function module.main(character)
    local Root = character:WaitForChild("HumanoidRootPart")
    local Torque = Root:WaitForChild("Torque")

    RunService.RenderStepped:Connect(function(dt)
        -- NOTE TO SELF: do this tomorrow.
    end)
end

return module