-- LocalScript (đặt trong StarterPlayerScripts)
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local Debris            = game:GetService("Debris")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

-- === Tạo GUI ===
-- Tạo ScreenGui vào PlayerGui (chạy mỗi respawn vì script nằm trong StarterPlayerScripts)
local screenGui = Instance.new("ScreenGui")
screenGui.Name   = "SelfFlingGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", screenGui)
frame.Size              = UDim2.new(0, 200, 0, 140)
frame.Position          = UDim2.new(0.8, 0, 0.3, 0)
frame.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel   = 0

-- Move Button (drag)
local btnMove = Instance.new("TextButton", frame)
btnMove.Name            = "MoveButton"
btnMove.Text            = "Move"
btnMove.Size            = UDim2.new(0, 80, 0, 25)
btnMove.Position        = UDim2.new(0.05, 0, 0, 5)
btnMove.BackgroundColor3= Color3.fromRGB(50, 50, 50)
btnMove.TextColor3      = Color3.new(1,1,1)
btnMove.BorderSizePixel = 0

-- Close Button
local btnClose = Instance.new("TextButton", frame)
btnClose.Name           = "CloseButton"
btnClose.Text           = "Close"
btnClose.Size           = UDim2.new(0, 80, 0, 25)
btnClose.Position       = UDim2.new(0.55, 0, 0, 5)
btnClose.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnClose.TextColor3       = Color3.new(1,1,1)
btnClose.BorderSizePixel  = 0

-- Fling Button
local btnFling = Instance.new("TextButton", frame)
btnFling.Name            = "FlingButton"
btnFling.Text            = "Fling!"
btnFling.Size            = UDim2.new(1, -10, 0, 40)
btnFling.Position        = UDim2.new(0, 5, 0, 40)
btnFling.BackgroundColor3= Color3.fromRGB(100, 0, 0)
btnFling.TextColor3      = Color3.new(1,1,1)
btnFling.BorderSizePixel = 0

-- Strength TextBox
local txtStrength = Instance.new("TextBox", frame)
txtStrength.Name            = "StrengthBox"
txtStrength.PlaceholderText = "Strength"
txtStrength.Text            = "200"
txtStrength.Size            = UDim2.new(1, -10, 0, 25)
txtStrength.Position        = UDim2.new(0, 5, 0, 90)
txtStrength.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
txtStrength.TextColor3       = Color3.new(1,1,1)
txtStrength.BorderSizePixel  = 0
txtStrength.ClearTextOnFocus = false

-- === Drag logic ===
local dragging = false
local dragStart, startPos

btnMove.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

btnMove.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = UserInputService:GetMouseLocation() - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close GUI
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- === Self‑Fling logic ===
btnFling.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local strength = tonumber(txtStrength.Text) or 200
    local horizFactor = 0.3       -- tỉ lệ lực ngang so với strength
    local upForce     = strength  -- lực thẳng đứng

    local duration    = 0.2       -- thời gian giữ lực (giây)

    -- Tạo hướng ngang theo chính hướng camera
    local horizontalDir = camera.CFrame.LookVector * strength * horizFactor
    local verticalDir   = Vector3.new(0, upForce, 0)
    local flingVector   = horizontalDir + verticalDir

    -- Gắn BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = flingVector
    bv.Parent   = hrp

    -- Tự hủy sau duration
    Debris:AddItem(bv, duration)
end)
