-- LocalScript chạy phía client --
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local startTime = os.clock()

-- Load Modern Sirius UI trực tiếp từ repo SiriusSoftwareLtd
local Sirius = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/request/source.lua"))()
local window = Sirius:CreateWindow({Title = "Speed & Jump Modifier"})

-- Slider điều chỉnh tốc độ và nhảy
local speedSlider = window:AddSlider("Walk Speed", 16, 200, humanoid.WalkSpeed, function(val)
    humanoid.WalkSpeed = val
end)
local jumpSlider = window:AddSlider("Jump Power", 50, 300, humanoid.JumpPower, function(val)
    humanoid.JumpPower = val
end)

-- Header hiển thị headshot avatar và tên người chơi ở góc
local header = window:AddHeader()
header:AddImage("rbxthumb://type=AvatarHeadshot&id=" .. player.UserId .. "&w=150&h=150")
header:AddLabel(player.Name)

-- Mặc định mở giao diện UI khi load script
window:Open()

-- Thông báo thực thi thành công kèm thời gian ms
local elapsed = math.floor((os.clock() - startTime) * 1000)
StarterGui:SetCore("SendNotification", {
    Title = "✅ Script Executed",
    Text = "Script đã execute thành công trong " .. elapsed .. " ms",
    Duration = 5
})
