local module = {}

local keycodes = require(game:GetService("ReplicatedStorage").Modules.handeKeycodes)

function module.main(char)
    local Humanoid = char:WaitForChild("Humanoid")
    local function Run(_,state)
        if state == Enum.UserInputState.Begin then
            if not char:FindFirstChild("RunBlocked") then
                Humanoid.WalkSpeed = 32
            end
        elseif state == Enum.UserInputState.End then
            Humanoid.WalkSpeed = 16
        end
    end

    keycodes.CreateButton("run",Run)
end

return module