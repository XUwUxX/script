local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local aiming = false

-- THÔNG BÁO
local function Notify(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "Silent Aim",
        Text = msg,
        Duration = 2
    })
end

-- LOGIC TÌM MURDER (TƯ DUY NGƯỢC)
local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        if char then
            -- Kiểm tra xem có Knife trong túi hoặc trên tay không
            local hasKnife = char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
            if hasKnife and char:FindFirstChild("HumanoidRootPart") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    return char.HumanoidRootPart
                end
            end
        end
    end
    return nil
end

-- VÒNG LẶP AIMBOT
RunService.RenderStepped:Connect(function()
    -- Chỉ chạy khi cầm Gun trên tay
    local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and tool.Name == "Gun" then
        local target = GetMurderer()
        
        if target then
            if not aiming then
                aiming = true
                Notify("Đã khóa mục tiêu: MURDER")
            end
            
            -- Tính toán góc nhìn (Smooth)
            local targetPos = target.Position + (target.AssemblyLinearVelocity * 0.15) -- Dự đoán vị trí di chuyển
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
        else
            if aiming then
                aiming = false
                Notify("Mất dấu Murderer")
            end
        end
    else
        aiming = false
    end
end)
