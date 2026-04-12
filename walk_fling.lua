local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if _G.FlingActive then
    _G.FlingActive = false
    if _G.FlingConnection then _G.FlingConnection:Disconnect() end
    return
end

_G.FlingActive = true

_G.FlingConnection = RunService.Stepped:Connect(function()
    if not _G.FlingActive then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        -- Lưu vận tốc di chuyển thực tế từ bàn phím/Humanoid
        local moveVelocity = hum.MoveDirection * hum.WalkSpeed
        local currentY = hrp.AssemblyLinearVelocity.Y
        
        -- Gán vận tốc cực đại để gây sát thương vật lý (Fling)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 50000, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(50000, 50000, 50000)
        
        -- Ngay lập tức trả lại vận tốc di chuyển bình thường trong cùng frame
        RunService.Heartbeat:Wait()
        
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(moveVelocity.X, currentY, moveVelocity.Z)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)
