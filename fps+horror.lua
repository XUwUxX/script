-- LocalScript (đặt trong StarterGui hoặc trong ScreenGui của bạn)
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local Debris            = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse  = player:GetMouse()

-- Tạo hoặc lấy ScreenGui
local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("SelfFlingGUI")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SelfFlingGUI"
    screenGui.Parent = player.PlayerGui
end

-- Tạo Frame chứa UI
local frame = Instance.new("Frame", screenGui)
frame.Size              = UDim2.new(0, 200, 0, 140)
frame.Position          = UDim2.new(0.8, 0, 0.3, 0)
frame.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel   = 0

-- Nút Move (để kéo GUI)
local btnMove = Instance.new("TextButton", frame)
btnMove.Text            = "Move"
btnMove.Size            = UDim2.new(0, 80, 0, 25)
btnMove.Position        = UDim2.new(0.05, 0, 0, 5)
btnMove.BackgroundColor3= Color3.fromRGB(50, 50, 50)
btnMove.TextColor3      = Color3.new(1,1,1)
btnMove.BorderSizePixel = 0

-- Nút Close
local btnClose = Instance.new("TextButton", frame)
btnClose.Text           = "Close"
btnClose.Size           = UDim2.new(0, 80, 0, 25)
btnClose.Position       = UDim2.new(0.55, 0, 0, 5)
btnClose.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnClose.TextColor3       = Color3.new(1,1,1)
btnClose.BorderSizePixel  = 0

-- Nút Fling!
local btnFling = Instance.new("TextButton", frame)
btnFling.Text            = "Fling!"
btnFling.Size            = UDim2.new(1, -10, 0, 40)
btnFling.Position        = UDim2.new(0, 5, 0, 40)
btnFling.BackgroundColor3= Color3.fromRGB(100, 0, 0)
btnFling.TextColor3      = Color3.new(1,1,1)
btnFling.BorderSizePixel = 0

-- TextBox nhập Strength
local txtStrength = Instance.new("TextBox", frame)
txtStrength.PlaceholderText = "Strength"
txtStrength.Text            = "200"
txtStrength.Size            = UDim2.new(1, -10, 0, 25)
txtStrength.Position        = UDim2.new(0, 5, 0, 90)
txtStrength.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
txtStrength.TextColor3       = Color3.new(1,1,1)
txtStrength.BorderSizePixel  = 0
txtStrength.ClearTextOnFocus = false

-- Cho phép kéo Frame bằng btnMove
btnMove.MouseButton1Down:Connect(function()
    local mouseStart = UserInputService:GetMouseLocation()
    local guiStart   = frame.Position
    local conn
    conn = UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - mouseStart
            frame.Position = UDim2.new(
                guiStart.X.Scale, guiStart.X.Offset + delta.X,
                guiStart.Y.Scale, guiStart.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Wait()
    conn:Disconnect()
end)

-- Đóng GUI
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Xử lý Self‑Fling
btnFling.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Đọc strength từ textbox
    local strength = tonumber(txtStrength.Text) or 200
    local upForce   = strength * 0.5
    local duration  = 0.2

    -- Tính hướng bay: từ HRP tới vị trí chuột trên mặt đất
    local targetPos   = mouse.Hit and mouse.Hit.p or (hrp.Position + camera.CFrame.LookVector * 10)
    local dirVector   = (targetPos - hrp.Position).Unit
    local flingVector = dirVector * strength + Vector3.new(0, upForce, 0)

    -- Gắn BodyVelocity để đẩy
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = flingVector
    bv.Parent   = hrp

    -- Tự hủy sau một thời gian
    Debris:AddItem(bv, duration)
end)
