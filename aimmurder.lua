local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local bulletSpeed = 250

StarterGui:SetCore("SendNotification", {
    Title = "MM2 Silent Aim v2",
    Text = "Hệ thống Bù trừ Nhảy đã kích hoạt",
    Duration = 3
})

local function GetTarget()
    local bestTarget = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local char = p.Character
            if char then
                local isMurd = char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if isMurd and hrp and hum and hum.Health > 0 then
                    bestTarget = hrp
                    break
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool and tool.Name == "Gun" then
        local target = GetTarget()
        local myHrp = char:FindFirstChild("HumanoidRootPart")
        if target and myHrp then
            local dist = (target.Position - myHrp.Position).Magnitude
            local timeToHit = dist / bulletSpeed
            
            local targetVel = target.AssemblyLinearVelocity
            local myVel = myHrp.AssemblyLinearVelocity
            
            local prediction = targetVel * timeToHit
            local jumpComp = Vector3.new(0, 0, 0)
            
            if myHrp.AssemblyLinearVelocity.Y > 5 or myHrp.AssemblyLinearVelocity.Y < -5 then
                jumpComp = Vector3.new(0, myVel.Y * timeToHit * 0.5, 0)
            end
            
            local finalPos = target.Position + prediction - jumpComp
            camera.CFrame = CFrame.new(camera.CFrame.Position, finalPos)
        end
    end
end)
