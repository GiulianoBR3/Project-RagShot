for _,v in script:GetChildren() do
    if v:IsA("ModuleScript") then
        task.spawn(require(v).main,script.Parent.Parent)
    end
end