local module = {}

function module.main(char)
    char.Humanoid.RequiresNeck = false
    for _,v in char.Torso:GetDescendants() do
        if v:IsA("Motor6D") then
            local Constraint = Instance.new("AnimationConstraint")
            local Attachment0 = Instance.new("Attachment")
            local Attachment1 = Instance.new("Attachment")

            Attachment0.Name = v.Name .. "RigAttachment"
            Attachment1.Name = v.Name .. "RigAttachment"
            Attachment0.Parent = v.Part0
            Attachment1.Parent = v.Part1

            Attachment0.CFrame = v.C0
            Attachment1.CFrame = v.C1

            Constraint.Name = v.Name
            Constraint.Attachment0 = Attachment0
            Constraint.Attachment1 = Attachment1
            Constraint.IsKinematic = false
            Constraint.MaxTorque = 150
            Constraint.Parent = v.Parent
            v.Enabled = false
        end
    end
    for _,v in char:GetDescendants() do
        if v:IsA("BasePart") then
            v.Massless = true
        end
    end
end

return module
