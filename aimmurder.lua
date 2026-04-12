local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local projectileSpeed = 250

StarterGui:SetCore("SendNotification", {
    Title = "MM2 Smart Aim",
    Text = "Hệ thống đã sẵn sàng.",
    Duration = 3
})

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        local backpack = p:FindFirstChild("Backpack")
        if char then
            local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hasKnife and hrp and hum and hum.Health > 0 then
                return hrp, hum
            end
        end
    end
    return nil, nil
end

RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    local localHum = char and char:FindFirstChildOfClass("Humanoid")
    
    if tool and tool.Name == "Gun" then
        local targetHrp, targetHum = GetMurderer()
        if targetHrp and localHum then
            local distance = (targetHrp.Position - char.HumanoidRootPart.Position).Magnitude
            local timeToHit = distance / projectileSpeed
            
            local predictedPos = targetHrp.Position + (targetHrp.AssemblyLinearVelocity * timeToHit)
            
            local state = localHum:GetState()
            if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
                local accuracyDrop = distance / 50
                predictedPos = predictedPos + Vector3.new(
                    math.random(-1, 1) * accuracyDrop,
                    math.random(-1, 1) * accuracyDrop,
                    math.random(-1, 1) * accuracyDrop
                )
            end
            
            camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        end
    end
end)
