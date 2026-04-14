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

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220) -- Đã thu ngắn chiều cao (từ 300 xuống 220)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
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
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 200) -- Đã thu nhỏ CanvasSize để hợp với cửa sổ ngắn
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Container

local function CreateToggle(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 32) -- Thu nhỏ nhẹ chiều cao nút
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.BorderSizePixel = 0
    Button.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Button

    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        Button.Text = text .. (active and ": ON" or ": OFF")
        Button.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
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
