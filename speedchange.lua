local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local defaultSpeed = humanoid.WalkSpeed
local defaultJump = humanoid.JumpPower
local defaultGravity = workspace.Gravity

-- Blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

-- Lấy GUI từ model đã load sẵn trong StarterGui
local guiAsset = player:WaitForChild("PlayerGui"):WaitForChild("SiriusUI")

-- Lấy thư viện từ Gui nếu chứa ModuleScript
local Sirius = require(guiAsset:WaitForChild("Library"))

-- Tạo window
local window = Sirius:NewWindow({
    Title = "Kevinz Hub",
    Size = UDim2.new(0,360,0,380),
    Position = UDim2.new(0,20,0.25,0)
})

-- User header
local header = window:AddSection("User")
header:AddAvatar(player.UserId)
header:AddLabel(player.DisplayName)

-- Speed toggle & slider
window:AddToggle("Enable Speed", false, function(val)
    humanoid.WalkSpeed = val and window:Get("Speed Value") or defaultSpeed
end)
window:AddSlider("Speed Value", defaultSpeed, 0, 100, function(val)
    if window:Get("Enable Speed") then humanoid.WalkSpeed = val end
end)

-- JumpPower & Gravity
window:AddSlider("Jump Power", defaultJump, 10, 200, function(val)
    humanoid.JumpPower = val
end)
window:AddSlider("Gravity", defaultGravity, 0, 300, function(val)
    workspace.Gravity = val
end)

-- Sound & tween toggle button
local clickSound = Instance.new("Sound", SoundService)
clickSound.SoundId = "rbxassetid://138090133"
clickSound.Volume = 0.5

local toggleBtn = guiAsset:WaitForChild("ToggleButton")
toggleBtn.MouseButton1Click:Connect(function()
    clickSound:Play()
    local visible = not window.Frame.Visible
    window.Frame.Visible = true
    TweenService:Create(window.Frame, TweenInfo.new(0.3), {
        Position = visible and window.InitialPosition or UDim2.new(-1,0,window.InitialPosition.Y.Scale,0),
        BackgroundTransparency = visible and 0 or 1
    }):Play()
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = visible and 24 or 0}):Play()
end)

-- Kích hoạt ripple trên các button có sẵn
Sirius:EnableRipples()

window:Init()
