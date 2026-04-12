local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

StarterGui:SetCore("SendNotification", {
    Title = "Aimbot",
    Text = "Active",
    Duration = 3
})

local function GetTarget()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        if char then
            local hitbox = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            local roleValue = p:FindFirstChild("Role") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Role"))
            local isMurderer = false
            
            if roleValue and roleValue.Value == "Murderer" then isMurderer = true end
            if char:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then isMurderer = true end
            
            if isMurderer and hitbox and hum and hum.Health > 0 then
                return hitbox
            end
        end
    end
    return nil
end

RunService:BindToRenderStep("SystemAim", 201, function()
    local char = localPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if tool and tool.Name == "Gun" then
        local target = GetTarget()
        if target and char:FindFirstChild("HumanoidRootPart") then
            local distance = (char.HumanoidRootPart.Position - target.Position).Magnitude
            local predictionTime = distance / 150
            local predictedPos = target.Position + (target.AssemblyLinearVelocity * predictionTime)
            
            camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        end
    end
end)
