local module = {}

function module.Raycast(origin, direction, params)
    local ray = workspace:Raycast(origin, direction, params)

    if game:GetService("RunService"):IsStudio() then
        local FullCoursePart = Instance.new("Part")
        FullCoursePart.Anchored = true
        FullCoursePart.CanCollide = false
        FullCoursePart.CanTouch = false
        FullCoursePart.CanQuery = false
        FullCoursePart.CastShadow = false
        FullCoursePart.Material = Enum.Material.Neon
        FullCoursePart.Color = Color3.fromRGB(255, 0, 0)
        FullCoursePart.Size = Vector3.new(0.1, 0.1, 0.1)
    

        FullCoursePart.CFrame = CFrame.new(origin + direction / 2, origin + direction)
        FullCoursePart.Size = Vector3.new(0.1, 0.1, direction.Magnitude)

        game:GetService("Debris"):AddItem(FullCoursePart, 0.1)
    end
    if ray then
        return ray
    end
end


return module