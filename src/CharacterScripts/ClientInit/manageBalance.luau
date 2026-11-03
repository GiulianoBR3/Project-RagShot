local module = {}

local RunService = game:GetService("RunService")
local RaycastingService = require(game:GetService("ReplicatedStorage").Modules.raycastingService)

-- Tunables. Rough starting values: tune them in Studio.
local HOVER_HEIGHT = 3.6
local HOVER_GAIN = 15 -- 1/s: target vertical speed per stud of hover error
local MAX_HOVER_SPEED = 20 -- studs/s: cap for the hover correction speed
local HOVER_FORCE_MULT = 4 -- hover MaxForce, as a multiple of the character's weight

local ALIGN_RESPONSIVENESS = 60
local GROUND_TORQUE = 1e5
local AIR_TORQUE = 1e4

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
    local RootAttachment = RootPart:WaitForChild("RootAttachment")

    -- Why constraints instead of per-frame impulses/torques:
    -- the physics engine solves constraints on every physics substep, so they stay
    -- stable no matter how low the client FPS gets. The script only updates the
    -- *targets* once per frame. A hand-written spring that applies an impulse once
    -- per frame (force * dt) becomes unstable when dt is large.

    -- Keeps the character upright. lookAtCamera.luau sets its CFrame (yaw = camera yaw).
    local Align = Instance.new("AlignOrientation")
    Align.Name = "UprightAlign"
    Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    Align.Attachment0 = RootAttachment
    Align.CFrame = CFrame.new()
    Align.RigidityEnabled = false
    Align.Responsiveness = ALIGN_RESPONSIVENESS
    Align.MaxAngularVelocity = math.huge
    Align.MaxTorque = AIR_TORQUE
    Align.Parent = RootPart

    -- Hover: drives only the vertical velocity toward a target proportional to the
    -- hover error (a first-order response, so it cannot oscillate).
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
    conn = RunService.PreSimulation:Connect(function()
        if not RootPart:IsDescendantOf(workspace) then
            conn:Disconnect()
            return
        end

        local ray = RaycastingService.Raycast(RootPart.Position, Vector3.new(0, -HOVER_HEIGHT-.3, 0), Params)
        local grounded = ray ~= nil

        if grounded then
            local distance = (RootPart.Position - ray.Position).Magnitude
            local err = HOVER_HEIGHT - distance
            local targetVelY = math.clamp(err * HOVER_GAIN, -MAX_HOVER_SPEED, MAX_HOVER_SPEED)
            local velY = RootPart.AssemblyLinearVelocity.Y

            Hover.LineVelocity = targetVelY
            -- Never fight upward motion that is already faster than the target (jumping).
            if velY > targetVelY then
                Hover.MaxForce = 0
            else
                Hover.MaxForce = RootPart.AssemblyMass * workspace.Gravity * HOVER_FORCE_MULT
            end
        else
            Hover.MaxForce = 0
        end

        Align.MaxTorque = if grounded then GROUND_TORQUE else AIR_TORQUE
        char:SetAttribute("OnGround", grounded)
    end)
end

function module.main(character)
    local humanoid = character:WaitForChild("Humanoid")
    module.DisableStates(humanoid)
    module.Balance(character, humanoid)
end

return module
