local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local fullbrightEnabled = false
local speedEnabled = false
local speedValue = 32

-- CẤU HÌNH MÀU SẮC
local COLORS = {
    Background = Color3.fromRGB(15, 15, 20),
    AccentOn = Color3.fromRGB(0, 200, 100),
    AccentOff = Color3.fromRGB(50, 50, 60),
    Text = Color3.fromRGB(240, 240, 240),
    Title = Color3.fromRGB(255, 255, 255)
}

-- Xóa UI cũ nếu đã tồn tại để tránh trùng lặp
if CoreGui:FindFirstChild("ModernHorrorUtility") then
    CoreGui:FindFirstChild("ModernHorrorUtility"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernHorrorUtility"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 260)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
mainFrame.BackgroundColor3 = COLORS.Background
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Transparency = 0.8
uiStroke.Thickness = 1
uiStroke.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "H O R R O R"
title.TextColor3 = COLORS.Title
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -40, 0, 45)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = COLORS.AccentOff
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = COLORS.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    
    return btn
end

local brightBtn
brightBtn = CreateButton("SANG: TAT", 60, function()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        TweenService:Create(brightBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOn}):Play()
        brightBtn.Text = "SANG: BAT"
    else
        TweenService:Create(brightBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOff}):Play()
        brightBtn.Text = "SANG: TAT"
    end
end)

local speedBtn
speedBtn = CreateButton("SPEED: TAT", 115, function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        TweenService:Create(speedBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOn}):Play()
        speedBtn.Text = "SPEED: BAT"
    else
        TweenService:Create(speedBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOff}):Play()
        speedBtn.Text = "SPEED: TAT"
    end
end)

local closeBtn = CreateButton("AN MENU", 185, function()
    mainFrame.Visible = false
end)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 60, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.BackgroundColor3 = COLORS.Background
openBtn.Text = "OPEN"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 12
openBtn.Parent = screenGui
openBtn.Visible = false

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 6)
openCorner.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function() openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openBtn.Visible = false
end)

RunService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speedEnabled and speedValue or 16
    end
end)
