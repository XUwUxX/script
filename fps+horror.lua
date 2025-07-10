-- 📌 LocalScript: đặt vào StarterPlayerScripts
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local charAddedConn

local function makeGUI()
    -- Xoá GUI cũ nếu có
    local old = player.PlayerGui:FindFirstChild("SelfFlingGUI")
    if old then old:Destroy() end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SelfFlingGUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 160)
    frame.Position = UDim2.new(0.7, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    -- Giao diện liquid glass
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Transparency = 0.3

    -- Hiệu ứng mờ nền
    if not Lighting:FindFirstChild("UI_Blur") then
        local blur = Instance.new("BlurEffect")
        blur.Name = "UI_Blur"
        blur.Size = 2
        blur.Parent = Lighting
    end

    -- Tiêu đề
    local title = Instance.new("TextLabel")
    title.Text = "🚀 Self‑Fling"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    -- Nút X
    local btnClose = Instance.new("TextButton")
    btnClose.Text = "X"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 18
    btnClose.TextColor3 = Color3.fromRGB(180, 180, 180)
    btnClose.BackgroundTransparency = 1
    btnClose.Size = UDim2.new(0, 30, 0, 30)
    btnClose.Position = UDim2.new(1, -34, 0, 4)
    btnClose.Parent = frame

    btnClose.MouseEnter:Connect(function()
        btnClose.TextColor3 = Color3.fromRGB(255,255,255)
    end)
    btnClose.MouseLeave:Connect(function()
        btnClose.TextColor3 = Color3.fromRGB(180,180,180)
    end)
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if charAddedConn then charAddedConn:Disconnect() end
    end)

    -- Content Frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -24, 1, -50)
    content.Position = UDim2.new(0, 12, 0, 42)
    content.BackgroundTransparency = 1
    content.Parent = frame

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Strength input
    local txtStrength = Instance.new("TextBox")
    txtStrength.PlaceholderText = "160"
    txtStrength.Text = "160"
    txtStrength.Font = Enum.Font.Gotham
    txtStrength.TextSize = 14
    txtStrength.TextColor3 = Color3.fromRGB(230,230,230)
    txtStrength.BackgroundColor3 = Color3.fromRGB(40,40,40)
    txtStrength.Size = UDim2.new(1, 0, 0, 28)
    txtStrength.ClearTextOnFocus = false
    Instance.new("UICorner", txtStrength).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", txtStrength).Thickness = 1
    txtStrength.Parent = content

    -- Fling Button
    local btnFling = Instance.new("TextButton")
    btnFling.Text = "FLING!"
    btnFling.Font = Enum.Font.GothamBold
    btnFling.TextSize = 16
    btnFling.TextColor3 = Color3.fromRGB(255,255,255)
    btnFling.BackgroundColor3 = Color3.fromRGB(180,30,30)
    btnFling.Size = UDim2.new(1, 0, 0, 36)
    btnFling.AutoButtonColor = false
    btnFling.Parent = content

    Instance.new("UICorner", btnFling).CornerRadius = UDim.new(0, 8)
    local strokeBtn = Instance.new("UIStroke", btnFling)
    strokeBtn.Color = Color3.fromRGB(120,0,0)
    local grad = Instance.new("UIGradient", btnFling)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200,50,50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150,20,20)),
    }

    local defaultText = btnFling.Text
    local defaultColor = btnFling.BackgroundColor3

    btnFling.MouseButton1Click:Connect(function()
        grad:Destroy()
        btnFling.Text = "🚀"
        btnFling.BackgroundColor3 = Color3.fromRGB(50,200,50)

        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        local strength = tonumber(txtStrength.Text) or 160

        -- Xoay nghiêng
        local gyro = Instance.new("BodyGyro")
        gyro.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90))
        gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        gyro.P = 1e5
        gyro.Parent = hrp
        Debris:AddItem(gyro, 0.05) -- phục hồi nhanh

        -- Đẩy lên
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0, 1e5, 0)
        bv.Velocity = Vector3.new(0, strength, 0)
        bv.Parent = hrp
        Debris:AddItem(bv, 0.2)

        -- Reset UI
        delay(0.2, function()
            btnFling.Text = defaultText
            btnFling.BackgroundColor3 = defaultColor
            local newGrad = Instance.new("UIGradient", btnFling)
            newGrad.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(200,50,50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150,20,20)),
            }
            strokeBtn.Color = Color3.fromRGB(120,0,0)
        end)
    end)
end

-- Hiển thị lại sau khi chết
charAddedConn = player.CharacterAdded:Connect(makeGUI)
if player.Character then makeGUI() end
