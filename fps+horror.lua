-- LocalScript (đặt trong ScreenGui của bạn)
local Players           = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris            = game:GetService("Debris")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

-- Tạo UI (nếu bạn đã có sẵn thì skip phần này và bind vào các nút có trong GUI của bạn)
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "SelfFlingGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,200,0,140)
frame.Position = UDim2.new(0.8,0,0.3,0)
frame.BackgroundTransparency = 0.5

local btnMove = Instance.new("TextButton", frame)
btnMove.Text = "Move"; btnMove.Size = UDim2.new(0,80,0,25)
btnMove.Position = UDim2.new(0.05,0,0,5)

local btnClose = Instance.new("TextButton", frame)
btnClose.Text = "Close"; btnClose.Size = UDim2.new(0,80,0,25)
btnClose.Position = UDim2.new(0.55,0,0,5)

local btnFling = Instance.new("TextButton", frame)
btnFling.Text = "Fling!"; btnFling.Size = UDim2.new(1,-10,0,40)
btnFling.Position = UDim2.new(0,5,0,40)

local txtStrength = Instance.new("TextBox", frame)
txtStrength.PlaceholderText = "Strength"
txtStrength.Text = "200"
txtStrength.Size = UDim2.new(1,-10,0,25)
txtStrength.Position = UDim2.new(0,5,0,90)
txtStrength.ClearTextOnFocus = false

-- Cho phép kéo Frame
btnMove.MouseButton1Down:Connect(function()
    local startMouse = UserInputService:GetMouseLocation()
    local startPos   = frame.Position
    local conn
    conn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - startMouse
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Wait()
    conn:Disconnect()
end)

-- Close GUI
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Self‑fling khi bấm nút
btnFling.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Lấy strength từ textbox, fallback = 200
    local strength = tonumber(txtStrength.Text) or 200
    local upForce   = strength * 0.5      -- lực nâng thêm
    local duration  = 0.2                 -- duy trì BodyVelocity (giây)

    -- Tính vector đẩy theo hướng camera + nâng lên
    local dir   = camera.CFrame.LookVector
    local force = dir * strength + Vector3.new(0, upForce, 0)

    -- Gắn BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = force
    bv.Parent   = hrp

    -- Tự hủy sau duration
    Debris:AddItem(bv, duration)
end)
