local module = {}

local RunService = game:GetService("RunService")

local Fov = {}
local PrevFov = {}

local Target = 0

local function UpdateFov(dt)
    local Number = 0
    for i,v in Fov do
        if not PrevFov[i] then
            Number += v
            PrevFov[i] = v
        else
            Number += v - PrevFov[i]
            PrevFov[i] = v
        end
    end
    Target = Target + Number
    
    workspace.CurrentCamera.FieldOfView = math.lerp(workspace.CurrentCamera.FieldOfView,70+Target,dt*10)

end

function module.GetFov(name)
    return Fov[name]
end

function module.SetFov(name, value)
    Fov[name] = value
end

function module.main()
    RunService.RenderStepped:Connect(UpdateFov)
end

return module