local module = {}

local RepStorage = game:GetService("ReplicatedStorage")

local GetDesiredMoveDirection = require(RepStorage.Modules.utils).getDesiredMoveDirection

function module.loadAnimations(hum)
    local AnimationOBJs = RepStorage:WaitForChild("Animations"):WaitForChild("Player"):GetChildren()

    local Animations = {}

    for _,v in AnimationOBJs do
        Animations[v.Name] = hum:LoadAnimation(v)
    end

    return Animations

end

function module.DisableOld(char,hum)
    char:WaitForChild("Animate"):Destroy()
    for _,v in hum:GetPlayingAnimationTracks() do
        v:Stop()
    end
end

function module.manageAnimations(char,hum,Anims)
    local states = {
        Falling = false,
        Running = false,
        Walking = false,
        Idle = false,
    }
    while task.wait() do
        if GetDesiredMoveDirection().Magnitude > 0 then
            states.Walking = true
        else
            states.Walking = false
        end
        if not char:GetAttribute("OnGround") then
            states.Falling = true
        else
            states.Falling = false
        end

        states.Running = states.Walking and hum.WalkSpeed > 16

        local found = false
        for i,v in states do
            if v and not found then
                found = true
                char:SetAttribute("State",i)
                if not Anims[i].IsPlaying then
                    Anims[i]:Play()
                end
            else
                if i == "Idle" and not found then
                    states[i] = true
                elseif i == "Idle" and found then
                    states[i] = false
                end
                if Anims[i].IsPlaying then
                    Anims[i]:Stop()
                end
            end
        end
        local found = char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").RequiresHandle
        if found and not Anims["Toolnone"].IsPlaying then
            Anims["Toolnone"]:Play()
        elseif not found and Anims["Toolnone"].IsPlaying then
            Anims["Toolnone"]:Stop()
        end
    end
end

function module.main(character)
    local Humanoid = character:WaitForChild("Humanoid")
    
    module.DisableOld(character,Humanoid)
    local Animations = module.loadAnimations(Humanoid)

    module.manageAnimations(character,Humanoid, Animations)

end

return module