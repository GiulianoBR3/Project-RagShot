local module = {}

local RunService = game:GetService("RunService")

-- Lower STIFFNESS = lazier turning toward the camera.
local STIFFNESS = 400
local DAMPING = 50

-- Gains are tuned for this frame time and scaled down on slower frames, so the
-- stale per-frame torque cannot overshoot (softer instead of unstable).
local REF_DT = 1 / 60

local function straightenCF(cf)
    local _, yaw, _ = cf:ToOrientation()
    return CFrame.fromOrientation(0, yaw, 0)
end

function module.main(character)
    local Root = character:WaitForChild("HumanoidRootPart")
    local Torque = Root:WaitForChild("Torque") -- created in manageBalance.luau

    RunService.RenderStepped:Connect(function(dt)
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        local kScale = math.min(1, (REF_DT / dt) ^ 2)
        local dScale = math.min(1, REF_DT / dt)

        local cf = straightenCF(Root.CFrame)
        local camCF = straightenCF(camera.CFrame)

        local lookVector = cf.LookVector
        local camLookVector = camCF.LookVector

        local cross = lookVector:Cross(camLookVector)
        local dot = lookVector:Dot(camLookVector)
        local angle = math.atan2(cross.Y, dot)

        local angVelY = Root.AssemblyAngularVelocity.Y
        local final = (angle * (STIFFNESS * kScale) - angVelY * (DAMPING * dScale)) * Root.AssemblyMass

        Torque.Torque = Vector3.new(Torque.Torque.X, final, Torque.Torque.Z)
    end)
end

return module
