local module = {}

local GetdesiredMoveDirection = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("utils")).getDesiredMoveDirection
local runService = game:GetService("RunService")

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
	runService.RenderStepped:Connect(function(dt)
        local MoveDir = GetdesiredMoveDirection()
		local force = MoveDir * 100 * character.Torso.AssemblyMass * dt
		local MaxSpeed = character.Humanoid.WalkSpeed
		local currentVelocity = character.Torso.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		if currentVelocity.Magnitude > MaxSpeed then
			force -= currentVelocity.Unit * math.max(force:Dot(currentVelocity.Unit), 0)
		end
        if MoveDir.Magnitude == 0 then
            force = currentVelocity * -.5
        end

		character.Torso:ApplyImpulse(force)
	end)
end


function module.main(character)
    module.jump(character)
    module.Movement(character)
end

return module