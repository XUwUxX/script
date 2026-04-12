--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

--// Player
local player = Players.LocalPlayer

--// Toggle
if _G.FlingActive then
    _G.FlingActive = false
    if _G.FlingConnection then
        _G.FlingConnection:Disconnect()
        _G.FlingConnection = nil
    end
    
    StarterGui:SetCore("SendNotification", {
        Title = "Walk Fling",
        Text = "Đã dừng",
        Duration = 2
    })
    return
end

_G.FlingActive = true

StarterGui:SetCore("SendNotification", {
    Title = "Walk Fling",
    Text = "Đã kích hoạt - Movement ổn định",
    Duration = 2
})

--// Main
_G.FlingConnection = RunService.PreSimulation:Connect(function()
    if not _G.FlingActive then return end
    
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end
    
    -- chỉ hoạt động khi đang di chuyển
    if hum.MoveDirection.Magnitude <= 0 then return end
    
    -- lưu velocity gốc
    local currentVel = hrp.AssemblyLinearVelocity
    
    -- lực fling (đã tối ưu)
    local flingForce = Vector3.new(0, 3000, 0)
    
    -- áp lực nhẹ, không phá control
    hrp.AssemblyLinearVelocity = currentVel + flingForce
    
    -- trả lại velocity ở frame sau (non-blocking)
    task.defer(function()
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = currentVel
        end
    end)
end)
