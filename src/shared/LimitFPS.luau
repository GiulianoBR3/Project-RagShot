task.wait(5)

local RunService = game:GetService("RunService")
local MaxFPS = 15 -- Set your desired frame cap here

while true do
    local t0 = tick()
    RunService.Heartbeat:Wait()
    repeat until (t0 + 1 / MaxFPS) < tick()
end
