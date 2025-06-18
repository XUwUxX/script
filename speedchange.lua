-- LocalScript để chạy qua Delta --
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local start = os.clock()

-- Load Sirius UI core
local Sirius = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/request/source.lua"))()
local win = Sirius:CreateWindow({Title="Speed & Jump"})
-- Chỉ sử dụng switch theme có sẵn
local speedSwitch = win:AddSwitch("Fast Walk", false, function(on)
    if on then hum.WalkSpeed = 100 else hum.WalkSpeed = 16 end
end)
local jumpSwitch = win:AddSwitch("High Jump", false, function(on)
    if on then hum.JumpPower = 100 else hum.JumpPower = 50 end
end)
win:Open()

-- Thông báo thành công
local ms = math.floor((os.clock() - start)*1000)
StarterGui:SetCore("SendNotification", {
    Title = "✅ Executed",
    Text = "Xong trong " .. ms .. "ms",
    Duration = 4
})
