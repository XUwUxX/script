local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- State Management
local State = {
    FullBright = false,
    NoShadow = false,
    SpeedHack = false,
    WalkSpeed = 16,
    OriginalLighting = {}
}

-- Backup Original Lighting
for _, prop in ipairs({"Brightness", "ClockTime", "FogEnd", "GlobalShadows", "Ambient", "OutdoorAmbient"}) do
    State.OriginalLighting[prop] = Lighting[prop]
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HorrorUtility"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Acrylic Blur Effect (Background)
local BlurFrame = Instance.new("Frame")
BlurFrame.Name = "BlurFrame"
BlurFrame.Size = UDim2.new(0, 230, 0, 240)
BlurFrame.Position = UDim2.new(0.5, -115, 0.5, -120)
BlurFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
BlurFrame.BackgroundTransparency = 0.15
BlurFrame.BorderSizePixel = 0
BlurFrame.Active = true
BlurFrame.Draggable = true
BlurFrame.ClipsDescendants = true
BlurFrame.Parent = ScreenGui

local BlurCorner = Instance.new("UICorner")
BlurCorner.CornerRadius = UDim.new(0, 12)
BlurCorner.Parent = BlurFrame

-- Hiệu ứng viền Gradient
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = BlurFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
}
UIGradient.Parent = UIStroke

-- Animation cho viền xoay
task.spawn(function()
    while true do
        UIGradient.Rotation = UIGradient.Rotation + 1
        task.wait(0.02)
    end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = BlurFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "HORROR UTILITY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Nút đóng Menu (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -35, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 45, 85)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    local fade = TweenService:Create(BlurFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
    fade:Play()
    fade.Completed:Connect(function() ScreenGui.Enabled = false end)
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -24, 1, -60)
Container.Position = UDim2.new(0, 12, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ScrollBarThickness = 0
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Container

local function CreateToggle(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Button.BackgroundTransparency = 0.5
    Button.Text = "   " .. text
    Button.TextColor3 = Color3.fromRGB(180, 180, 180)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 12
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.BorderSizePixel = 0
    Button.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Button
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator

    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        local targetColor = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        local targetIndSize = active and UDim2.new(0, 3, 0.6, 0) or UDim2.new(0, 2, 0, 0)
        local targetIndPos = active and UDim2.new(0, 0, 0.2, 0) or UDim2.new(0, 0, 0.5, 0)

        TweenService:Create(Button, TweenInfo.new(0.2), {TextColor3 = targetColor}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Size = targetIndSize, Position = targetIndPos}):Play()
        
        callback(active)
    end)

    -- Hover effect
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)

    return Button
end

-- FullBright Logic
RunService.RenderStepped:Connect(function()
    if State.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = not State.NoShadow and Lighting.GlobalShadows or false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    end
    
    if State.SpeedHack and humanoid then
        humanoid.WalkSpeed = State.WalkSpeed
    end
end)

-- Toggles Implementation
CreateToggle("HACK SÁNG (FULLBRIGHT)", function(val)
    State.FullBright = val
    if not val then
        for prop, value in pairs(State.OriginalLighting) do
            Lighting[prop] = value
        end
    end
end)

CreateToggle("XÓA BÓNG ĐỔ (NO SHADOW)", function(val)
    State.NoShadow = val
    Lighting.GlobalShadows = not val
end)

CreateToggle("TĂNG TỐC CHẠY (SPEED)", function(val)
    State.SpeedHack = val
    State.WalkSpeed = val and 25 or 16
    if humanoid then humanoid.WalkSpeed = State.WalkSpeed end
end)

CreateToggle("NHẢY VÔ HẠN (INF JUMP)", function(val)
    State.InfJump = val
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Toggle GUI Visibility (RightControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            BlurFrame.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(BlurFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 230, 0, 240)}):Play()
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
end)
