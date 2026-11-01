task.wait(1)
for _,v in script:GetChildren() do
    if v:IsA("ModuleScript") then
        print(v.Name.." loading")
        task.spawn(require(v).main,script.Parent.Parent)
        print(v.Name.." loaded")
    end
end