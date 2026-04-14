local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local fullbrightEnabled = false
local speedEnabled = false
local speedValue = 32

-- CẤU HÌNH GIAO DIỆN HIỆN ĐẠI
local COLORS = {
    Background = Color3.fromRGB(15, 15, 20),
    AccentOn = Color3.fromRGB(0, 200, 100),
    AccentOff = Color3.fromRGB(50, 50, 60),
    Text = Color3.fromRGB(240, 240, 240),
    Title = Color3.fromRGB(255, 255, 255)
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernHorrorUtility"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- KHUNG CHÍNH LÀM MỜ (GLASSMORPHISM)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 260)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
mainFrame.BackgroundColor3 = COLORS.Background
mainFrame.BackgroundTransparency = 0.25 -- Trong suốt một phần
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
corner.CornerRadius = UDim.new(0, 12) -- Bo góc vừa phải
corner.Parent = mainFrame

-- BÓNG ĐỔ (DROP SHADOW)
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0.5, 0, 0.5, 5)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = -1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.4
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "H O R R O R"
title.TextColor3 = COLORS.Title
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack -- Font chữ đẹp, dày
title.TextSize = 20
title.Parent = mainFrame

-- HÀM TẠO NÚT BẤM CÓ HIỆU ỨNG TWEEN (MƯỢT)
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
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    -- Hiệu ứng Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        -- Hiệu ứng Click
        btn.Size = UDim2.new(1, -44, 0, 41)
        btn.Position = UDim2.new(0, 22, 0, yPos + 2)
        task.wait(0.1)
        btn.Size = UDim2.new(1, -40, 0, 45)
        btn.Position = UDim2.new(0, 20, 0, yPos)
        callback(btn)
    end)
    
    return btn
end

-- TẠO CÁC NÚT TÍNH NĂNG
local brightBtn
brightBtn = CreateButton("Sáng: Tắt", 60, function()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        TweenService:Create(brightBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOn}):Play()
        brightBtn.Text = "Sáng: Bật"
    else
        TweenService:Create(brightBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOff}):Play()
        brightBtn.Text = "Sáng: Tắt"
    end
end)

local speedBtn
speedBtn = CreateButton("Chạy Nhanh: Tắt", 115, function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        TweenService:Create(speedBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOn}):Play()
        speedBtn.Text = "Chạy Nhanh: Bật"
    else
        TweenService:Create(speedBtn, TweenInfo.new(0.3), {BackgroundColor3 = COLORS.AccentOff}):Play()
        speedBtn.Text = "Chạy Nhanh: Tắt"
    end
end)

local closeBtn = CreateButton("Ẩn Menu", 185, function()
    mainFrame.Visible = false
end)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Màu đỏ cho nút ẩn

-- NÚT MỞ LẠI MENU
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 45, 0, 45)
openBtn.Position = UDim2.new(0, 15, 0, 15)
openBtn.BackgroundColor3 = COLORS.Background
openBtn.BackgroundTransparency = 0.25
openBtn.Text = "👁"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
openBtn.Parent = screenGui
openBtn.Visible = false

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(255, 255, 255)
openStroke.Transparency = 0.8
openStroke.Thickness = 1
openStroke.Parent = openBtn

closeBtn.MouseButton1Click:Connect(function() openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openBtn.Visible = false
end)

-- LOGIC XỬ LÝ (Tối ưu bằng RunService)
RunService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    if speedEnabled then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speedValue
        end
    else
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
    end
end)
