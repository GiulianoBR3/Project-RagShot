local module = {}

local RunService = game:GetService("RunService")
local RaycastingService = require(game:GetService("ReplicatedStorage").Modules.raycastingService)

function module.DisableStates(Humanoid)
    for _, v in Enum.HumanoidStateType:GetEnumItems() do
        if v ~= Enum.HumanoidStateType.Physics and v ~= Enum.HumanoidStateType.Dead and v ~= Enum.HumanoidStateType.None then
            Humanoid:SetStateEnabled(v, false)
        end
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

function module.Balance(char, Humanoid)
    local RootPart = char:WaitForChild("HumanoidRootPart")
    local Torso = char:WaitForChild("Torso")

    local Torque = Instance.new("Torque")
    Torque.Attachment0 = RootPart:WaitForChild("RootAttachment")
    Torque.RelativeTo = Enum.ActuatorRelativeTo.World
    Torque.Parent = RootPart

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {char}

    local Hover_Height = 3.8
    local Stiffness = 1000
    local Damping = 2 * math.sqrt(Stiffness)

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if not RootPart:IsDescendantOf(workspace) then
            conn:Disconnect()
            return
        end

        local ray = RaycastingService.Raycast(Torso.Position, Vector3.new(0, -Hover_Height, 0), Params)
        local final = Vector3.zero
        if ray then

            local cf = RootPart.CFrame
            local angVel = RootPart.AssemblyAngularVelocity

            local _, yaw, _ = cf:ToOrientation()
            local straight = CFrame.fromOrientation(0, yaw, 0)

            local toCorrect = straight * cf.Rotation:Inverse()
            local axis, angle = toCorrect:ToAxisAngle()

            local P = axis * angle * 5000
            local D = angVel * 500
            final = P - D

            local distance = (Torso.Position - ray.Position).Magnitude
            local err = Hover_Height - distance
            local velY = Torso.AssemblyLinearVelocity.Y

            local force = (Stiffness * err) - (Damping * velY)
            Torso:ApplyImpulse(Vector3.new(0, force * Torso.AssemblyMass * dt, 0))
        end
        Torque.Torque = Vector3.new(final.X, Torque.Torque.Y, final.Z)
        char:SetAttribute("OnGround", ray ~= nil)
    end)
end

function module.main(character)
    local humanoid = character:WaitForChild("Humanoid")
    module.DisableStates(humanoid)
    module.Balance(character, humanoid)
end

return module
