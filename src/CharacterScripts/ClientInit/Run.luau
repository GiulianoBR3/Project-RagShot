local module = {}

local CAS = game:GetService("ContextActionService")

function module.main(char)
    local Humanoid = char:WaitForChild("Humanoid")
    local function Run(_,state)
        if state == Enum.UserInputState.Begin then
            if not char:FindFirstChild("RunBlocked") then
                Humanoid.WalkSpeed = 24
            end
        elseif state == Enum.UserInputState.End then
            Humanoid.WalkSpeed = 16
        end
    end

    CAS:BindAction("Run",Run,false,Enum.KeyCode.LeftShift)
end

return module