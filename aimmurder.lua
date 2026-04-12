local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local camera = workspace.CurrentCamera

local aimActive = true -- Mặc định bật

-- LOGIC TƯ DUY NGƯỢC: CHỈ QUÉT KHI CẦN THIẾT
local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        
        -- Kiểm tra dao trong Backpack hoặc Character
        local char = p.Character
        local hasKnife = (char and char:FindFirstChild("Knife")) or (p.Backpack:FindFirstChild("Knife"))
        
        if hasKnife and char and char:FindFirstChild("HumanoidRootPart") then
            -- Kiểm tra nếu Murderer còn sống
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return char.HumanoidRootPart
            end
        end
    end
    return nil
end

-- XỬ LÝ AIM (SMOOTH & OPTIMIZED)
RunService.RenderStepped:Connect(function()
    if not aimActive then return end
    
    -- Tư duy ngược: Chỉ chạy logic Aim khi cầm "Gun" trên tay
    local char = lp.Character
    if char and char:FindFirstChild("Gun") then
        local target = GetMurderer()
        
        if target then
            -- Dự đoán vị trí (Prediction logic đơn giản để bắn trúng khi đối thủ chạy)
            local targetPos = target.Position + (target.AssemblyLinearVelocity * 0.15)
            
            -- Chế độ Aim thẳng vào mục tiêu (Smooth Camera)
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
        end
    end
end)

-- Nút bấm bật/tắt nhanh (Phím L)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.L then
        aimActive = not aimActive
        print("Aimlock Status: " .. tostring(aimActive))
    end
end)
