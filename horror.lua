local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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
BlurFrame.Size = UDim2.new(0, 220, 0, 220)
BlurFrame.Position = UDim2.new(0.5, -110, 0.5, -110)
BlurFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
BlurFrame.BackgroundTransparency = 0.2
BlurFrame.BorderSizePixel = 0
BlurFrame.Active = true
BlurFrame.Draggable = true
BlurFrame.Parent = ScreenGui

local BlurCorner = Instance.new("UICorner")
BlurCorner.CornerRadius = UDim.new(0, 10)
BlurCorner.Parent = BlurFrame

-- Thêm hiệu ứng phát sáng nhẹ (UI Stroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.8
UIStroke.Thickness = 1
UIStroke.Parent = BlurFrame

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = BlurFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "HORROR UTILITY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Nút đóng Menu (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -33, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -24, 1, -55)
Container.Position = UDim2.new(0, 12, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ScrollBarThickness = 0
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.Parent = Container

local function CreateToggle(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 34)
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundTransparency = 0.92
    Button.Text = "  " .. text
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 12
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.BorderSizePixel = 0
    Button.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Status = Instance.new("Frame")
    Status.Size = UDim2.new(0, 4, 1, -12)
    Status.Position = UDim2.new(1, -10, 0, 6)
    Status.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Status.BorderSizePixel = 0
    Status.Parent = Button
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = Status

    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        Status.BackgroundColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(100, 100, 100)
        Button.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(active)
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
CreateToggle("FullBright", function(val)
    State.FullBright = val
    if not val then
        for prop, value in pairs(State.OriginalLighting) do
            Lighting[prop] = value
        end
    end
end)

CreateToggle("No Shadows", function(val)
    State.NoShadow = val
    Lighting.GlobalShadows = not val
end)

CreateToggle("Speed Hack (25)", function(val)
    State.SpeedHack = val
    State.WalkSpeed = val and 25 or 16
    if humanoid then humanoid.WalkSpeed = State.WalkSpeed end
end)

CreateToggle("Infinite Jump", function(val)
    State.InfJump = val
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Toggle GUI Visibility (Phím RightControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Keep settings after death
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
end)
