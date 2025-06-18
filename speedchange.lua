--[[
    Script GUI cho Executor
    - Tạo một cửa sổ giao diện có thể kéo thả.
    - Nền có hiệu ứng gradient màu đỏ.
    - Bao gồm các nút chức năng mẫu.
    Cách dùng: Sao chép toàn bộ script và dán vào executor của bạn (ví dụ: Delta), sau đó Execute.
]]

-- // BIẾN VÀ THIẾT LẬP BAN ĐẦU
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

-- Tạo đối tượng GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI_ByGemini"
ScreenGui.ResetOnSpawn = false -- Không reset GUI mỗi khi nhân vật chết
ScreenGui.ZIndexBehavior = "Global" -- Luôn hiển thị trên cùng

-- // TẠO GIAO DIỆN
-- Frame chính làm nền cho cửa sổ
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.Size = UDim2.fromOffset(500, 300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 1
MainFrame.ClipsDescendants = true
MainFrame.CornerRadius = UDim.new(0, 12)

-- Hiệu ứng Gradient cho nền
local Gradient = Instance.new("UIGradient")
Gradient.Parent = MainFrame
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
})
Gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.8, 1),
    NumberSequenceKeypoint.new(1, 1)
})

-- Thanh tiêu đề để kéo thả
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BackgroundTransparency = 0.5

-- Tiêu đề
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.fromOffset(10, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "My Script Hub"
TitleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Nút đóng GUI
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.Size = UDim2.fromOffset(35, 35)
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Position = UDim2.new(1, 0, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseButton.TextSize = 18

-- // CÁC NÚT CHỨC NĂNG (VÍ DỤ)
-- Layout để tự động sắp xếp các nút
local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.Parent = MainFrame
ButtonLayout.Padding = UDim.new(0, 10)
ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.StartCorner = "Top"

-- Nút Tăng Tốc
local SpeedButton = Instance.new("TextButton")
SpeedButton.Name = "SpeedButton"
SpeedButton.Parent = MainFrame
SpeedButton.LayoutOrder = 1
SpeedButton.Size = UDim2.new(0.9, 0, 0, 40)
SpeedButton.Position = UDim2.fromOffset(0, 50) -- Vị trí ban đầu, sẽ được layout ghi đè
SpeedButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
SpeedButton.CornerRadius = UDim.new(0, 6)
SpeedButton.Font = Enum.Font.Gotham
SpeedButton.Text = "Speed (100)"
SpeedButton.TextColor3 = Color3.fromRGB(225, 225, 225)
SpeedButton.TextSize = 16

-- Nút Nhảy Cao
local JumpButton = Instance.new("TextButton")
JumpButton.Name = "JumpButton"
JumpButton.Parent = MainFrame
JumpButton.LayoutOrder = 2
JumpButton.Size = UDim2.new(0.9, 0, 0, 40)
JumpButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
JumpButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
JumpButton.CornerRadius = UDim.new(0, 6)
JumpButton.Font = Enum.Font.Gotham
JumpButton.Text = "JumpPower (100)"
JumpButton.TextColor3 = Color3.fromRGB(225, 225, 225)
JumpButton.TextSize = 16

-- // LOGIC VÀ CHỨC NĂNG
-- Logic kéo thả cửa sổ
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
        if dragging then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Chức năng của các nút
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

SpeedButton.MouseButton1Click:Connect(function()
    local Character = Player.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.WalkSpeed = 100
        SpeedButton.Text = "Speed: ON"
        wait(0.5)
        SpeedButton.Text = "Speed (100)" -- Reset text
    end
end)

JumpButton.MouseButton1Click:Connect(function()
    local Character = Player.Character
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.JumpPower = 100
        JumpButton.Text = "Jump: ON"
        wait(0.5)
        JumpButton.Text = "JumpPower (100)"
    end
end)

-- Đưa GUI vào game
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

print("Executor UI Loaded!")
