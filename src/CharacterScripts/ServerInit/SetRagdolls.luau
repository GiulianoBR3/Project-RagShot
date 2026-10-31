local module = {}

function module.main(char)
    char.Humanoid.RequiresNeck = false
    for _,v in char.Torso:GetChildren() do
        if v:IsA("Motor6D") then
            local Constraint = Instance.new(if v.Name ~= "Neck" then "RopeConstraint" else "BallSocketConstraint")
            local Attachment0 = Instance.new("Attachment")
            local Attachment1 = Instance.new("Attachment")

            Attachment0.Parent = v.Part0
            Attachment1.Parent = v.Part1

            Attachment0.CFrame = v.C0
            Attachment1.CFrame = v.C1

            Constraint.Attachment0 = Attachment0
            Constraint.Attachment1 = Attachment1
            Constraint.Parent = char.Torso
            Constraint.Name = v.Name
            if v.Name ~= "Neck" then
                Constraint.Visible = false
                Constraint.Length = (v.C0.Position - v.C1.Position).Magnitude/4
            else
                Constraint.LimitsEnabled = true
                Constraint.TwistLimitsEnabled = true
            end
            v:Destroy()
        end
    end
end

return module