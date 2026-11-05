local module = {}

local RunService = game:GetService("RunService")
local RaycastingService = require(game:GetService("ReplicatedStorage").Modules.raycastingService)

-- Tunables. Rough starting values: tune them in Studio.
local HOVER_HEIGHT = 3.3
local GROUND_CHECK_MARGIN = 0.6 -- the ray reaches past the hover height so the rig never sits on the edge of the ray
local HOVER_GAIN = 15 -- 1/s: target vertical speed per stud of hover error
local MAX_HOVER_SPEED = 20 -- studs/s: cap for the hover correction speed
local HOVER_FORCE_MULT = 4 -- hover MaxForce, as a multiple of the character's weight
local JUMP_TOLERANCE = 3 -- studs/s: only stop hovering when clearly moving up (jumping)

-- Upright torque. Lower UPRIGHT_P = floppier. Keep UPRIGHT_D near 2 * sqrt(P) for
-- critical damping, or lower for more wobble.
local UPRIGHT_P = 5000
local UPRIGHT_D = 500

-- The gains above are tuned for this frame time. On slower frames they are scaled
-- down so the stale per-frame torque cannot overshoot: the rig gets softer instead
-- of exploding.
local REF_DT = 1 / 60

function module.DisableStates(Humanoid)
    for _, v in Enum.HumanoidStateType:GetEnumItems() do
        if v ~= Enum.HumanoidStateType.Ragdoll and v ~= Enum.HumanoidStateType.Dead and v ~= Enum.HumanoidStateType.None and v ~= Enum.HumanoidStateType.Jumping then
            Humanoid:SetStateEnabled(v, false)
        end
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
end

function module.Balance(char, Humanoid)
    local RootPart = char:WaitForChild("HumanoidRootPart")
    local RootAttachment = RootPart:WaitForChild("RootAttachment")

    -- X/Z are written here (upright), Y is written by lookAtCamera.luau (yaw).
    local Torque = Instance.new("Torque")
    Torque.Name = "Torque"
    Torque.Attachment0 = RootAttachment
    Torque.RelativeTo = Enum.ActuatorRelativeTo.World
    Torque.Parent = RootPart

    -- Hover: drives only the vertical velocity toward a target proportional to the
    -- hover error. The physics engine solves it every substep, so it stays stable at
    -- any FPS and cannot oscillate.
    local Hover = Instance.new("LinearVelocity")
    Hover.Name = "HoverVelocity"
    Hover.Attachment0 = RootAttachment
    Hover.RelativeTo = Enum.ActuatorRelativeTo.World
    Hover.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
    Hover.LineDirection = Vector3.yAxis
    Hover.LineVelocity = 0
    Hover.MaxForce = 0
    Hover.Parent = RootPart

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {char}

    local conn
    conn = RunService.PreSimulation:Connect(function(dt)
        if not RootPart:IsDescendantOf(workspace) then
            conn:Disconnect()
            return
        end

        local ray = RaycastingService.Raycast(RootPart.Position, Vector3.new(0, -(HOVER_HEIGHT + GROUND_CHECK_MARGIN), 0), Params)
        local grounded = ray ~= nil
        local final = Vector3.zero

        if grounded then
            -- Upright torque (frame-time scaled gains)
            local kScale = math.min(1, (REF_DT / dt) ^ 2) -- stiffness
            local dScale = math.min(1, REF_DT / dt) -- damping (keeps the damping ratio)

            local cf = RootPart.CFrame
            local angVel = RootPart.AssemblyAngularVelocity

            local _, yaw, _ = cf:ToOrientation()
            local straight = CFrame.fromOrientation(0, yaw, 0)

            local toCorrect = straight * cf.Rotation:Inverse()
            local axis, angle = toCorrect:ToAxisAngle()

            final = axis * angle * (UPRIGHT_P * kScale) - angVel * (UPRIGHT_D * dScale)

            -- Hover target. err can be slightly negative, which pushes the rig back
            -- down smoothly instead of toggling the force on and off.
            local distance = (RootPart.Position - ray.Position).Magnitude
            local err = HOVER_HEIGHT - distance
            local targetVelY = math.clamp(err * HOVER_GAIN, -MAX_HOVER_SPEED, MAX_HOVER_SPEED)
            local velY = RootPart.AssemblyLinearVelocity.Y

            Hover.LineVelocity = targetVelY
            -- Never fight upward motion that is clearly faster than the target (jumping).
            if velY > targetVelY + JUMP_TOLERANCE then
                Hover.MaxForce = 0
            else
                Hover.MaxForce = RootPart.AssemblyMass * workspace.Gravity * HOVER_FORCE_MULT
            end
        else
            Hover.MaxForce = 0
        end

        Torque.Torque = Vector3.new(final.X, Torque.Torque.Y, final.Z)
        char:SetAttribute("OnGround", grounded)
    end)
end

function module.main(character)
    local humanoid = character:WaitForChild("Humanoid")
    module.DisableStates(humanoid)
    module.Balance(character, humanoid)
end

return module
