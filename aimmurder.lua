local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- THÔNG BÁO DUY NHẤT KHI EXECUTE
StarterGui:SetCore("SendNotification", {
    Title = "MM2 Silent Aim",
    Text = "Hệ thống đã sẵn sàng. Cầm súng để kích hoạt.",
    Duration = 3
})

-- LOGIC TÌM MỤC TIÊU (TƯ DUY NGƯỢC: CHỈ QUÉT KHI CẦM SÚNG)
local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        if char then
            -- Chỉ khóa mục tiêu có thực thể "Knife"
            local hasKnife = char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hasKnife and hrp and hum and hum.Health > 0 then
                return hrp
            end
        end
    end
    return nil
end

-- VÒNG LẶP XỬ LÝ VẬT LÝ CAMERA
RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    -- Điều kiện: Đang cầm Gun
    if tool and tool.Name == "Gun" then
        local target = GetMurderer()
        if target then
            -- Prediction: Dự đoán vị trí dựa trên vận tốc để bắn không trượt
            local predictedPos = target.Position + (target.AssemblyLinearVelocity * 0.18)
            camera.CFrame = CFrame.new(camera.CFrame.Position, predictedPos)
        end
    end
end)
