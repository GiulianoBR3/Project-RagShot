local module = {}

function module.main(character)
    task.wait(2)
    local tabl = {}
    for _,v in character.Torso:GetChildren() do
        if v:IsA("AnimationConstraint") then
            tabl[v.Name] = v
        end
    end
    while task.wait(.1) do
        local val = character:GetAttribute("State") == "Running"
        tabl["Left Hip"].MaxTorque = if val then 2000 else 200
        tabl["Right Hip"].MaxTorque = if val then 2000 else 200
        
    end
end

return module