local module = {}

local GetdesiredMoveDirection = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("utils")).getDesiredMoveDirection
local runService = game:GetService("RunService")

local ACCELERATION = 400 -- studs/s^2
local BRAKE_RATE = 16 -- 1/s: fraction of horizontal speed removed per second when no input
local MAX_DT = 1 / 20 -- clamp so a lag spike can't turn into one huge impulse

function module.jump(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Changed:Connect(function(property)
        if property == "Jump" and humanoid.Jump then
            if not character:GetAttribute("OnGround") then
                return
            end
            character.HumanoidRootPart:ApplyImpulse(Vector3.new(0, 500, 0))
        end
    end)
end

function module.Movement(character)
    -- PreSimulation: runs right before each physics step, so the impulse is applied
    -- with the same dt that the physics is about to simulate.
    runService.PreSimulation:Connect(function(dt)
        dt = math.min(dt, MAX_DT)

        local Torso = character.Torso
        local mass = Torso.AssemblyMass
        local MoveDir = GetdesiredMoveDirection()
        local force = MoveDir * ACCELERATION * mass * dt
        local MaxSpeed = character.Humanoid.WalkSpeed
        local currentVelocity = Torso.AssemblyLinearVelocity * Vector3.new(1, 0, 1)

        if currentVelocity.Magnitude > MaxSpeed then
            force -= currentVelocity.Unit * math.max(force:Dot(currentVelocity.Unit), 0)
        end

        if MoveDir.Magnitude == 0 then
            -- Frame-rate independent braking: remove a fixed fraction of the speed per
            -- second (scaled by dt and mass), never more than the full velocity.
            force = currentVelocity * -math.min(BRAKE_RATE * dt, 1) * mass
        end

        Torso:ApplyImpulse(force)
    end)
end


function module.main(character)
    module.jump(character)
    module.Movement(character)
end

return module
