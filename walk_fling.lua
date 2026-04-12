local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Khởi tạo biến toàn cục để quản lý trạng thái
if _G.FlingActive then
    _G.FlingActive = false
    if _G.FlingConnection then _G.FlingConnection:Disconnect() end
    StarterGui:SetCore("SendNotification", {Title = "Walk Fling", Text = "Đã dừng", Duration = 2})
    return
end

_G.FlingActive = true
StarterGui:SetCore("SendNotification", {Title = "Walk Fling", Text = "Đã kích hoạt - Di chuyển bình thường", Duration = 2})

-- Tối ưu hóa va chạm
_G.FlingConnection = RunService.PreSimulation:Connect(function()
    if not _G.FlingActive then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        -- Lưu trữ vận tốc di chuyển hiện tại của người chơi
        local currentVel = hrp.AssemblyLinearVelocity
        
        -- Áp dụng xung lực cực đại (Fling) nhưng thu hồi ngay trong frame sau
        -- Sử dụng trục Y cao để phá vỡ floor bounciness của đối thủ
        hrp.AssemblyLinearVelocity = currentVel + Vector3.new(0, 10000, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(10000, 10000, 10000)
        
        -- Chờ engine tính toán va chạm xong
        RunService.PostSimulation:Wait()
        
        -- Trả lại vận tốc gốc để có thể đi lại bình thường
        if hrp then
            hrp.AssemblyLinearVelocity = currentVel
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)
