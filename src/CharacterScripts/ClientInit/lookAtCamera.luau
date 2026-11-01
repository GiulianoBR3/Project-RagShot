local module = {}

local RunService = game:GetService("RunService")

local function straightenCF(cf)
    local _, yaw, _ = cf:ToOrientation()
	return CFrame.fromOrientation(0, yaw, 0)
end

function module.main(character)
    local Root = character:WaitForChild("HumanoidRootPart")
    local Torque = Root:WaitForChild("Torque")
    local STIFFNESS = 400
    local DAMPING   = 50
    RunService.RenderStepped:Connect(function(dt)
        
        local cf = straightenCF(Root.CFrame)
        local camCF = straightenCF(workspace.CurrentCamera.CFrame)

        local lookVector = cf.LookVector
        local camLookVector = camCF.LookVector

        local cross = lookVector:Cross(camLookVector)
        local dot = lookVector:Dot(camLookVector)
        local angle = math.atan2(cross.Y, dot)

        local angVelY = Root.AssemblyAngularVelocity.Y
        local final = (angle * STIFFNESS - angVelY * DAMPING) * Root.AssemblyMass




        Torque.Torque = Vector3.new(Torque.Torque.X, final, Torque.Torque.Z)
    end)
end

return module