local module = {}


local StarterPlayer = game:GetService("StarterPlayer")

local pm = StarterPlayer:FindFirstChild("PlayerModule")
local moveAction = pm and pm:FindFirstChild("InputContexts")
	and pm.InputContexts:FindFirstChild("CharacterContext")
	and pm.InputContexts.CharacterContext:FindFirstChild("MoveAction")

function module.getDesiredMoveDirection()
	local move = moveAction and moveAction:GetState() or Vector2.zero
	if move.Magnitude < 0.01 then
		return Vector3.zero
	end

	local cf = workspace.CurrentCamera.CFrame
	local look = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
	local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit

	-- move.X = direita, move.Y = frente (confirme com print)
	return (right * move.X + look * move.Y).Unit
end


return module