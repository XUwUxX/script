local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

if _G.FlingActive then
    _G.FlingActive = false
    if _G.FlingConnection then _G.FlingConnection:Disconnect() end
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
    Text = "Đã kích hoạt - Di chuyển bình thường",
    Duration = 2
})

_G.FlingConnection = RunService.Heartbeat:Connect(function()
    if not _G.FlingActive then return end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        -- chỉ fling NGẮN trong 1 frame
        hrp.AssemblyLinearVelocity += Vector3.new(0, 3000, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(5000, 5000, 5000)

        -- reset ngay frame sau (không dùng Wait)
        task.defer(function()
            if hrp then
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
end)
