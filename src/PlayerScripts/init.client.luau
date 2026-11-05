for _,v in script:GetChildren() do
    if v:IsA("ModuleScript") then
        print(v)
        task.spawn(require(v).main)
    end
end