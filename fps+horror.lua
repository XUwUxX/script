-- LocalScript (đặt trong StarterPlayerScripts)
local Players = game:GetService("Players")
local Debris  = game:GetService("Debris")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

local charAddedConn

local function makeGUI()
    local old = player.PlayerGui:FindFirstChild("SelfFlingGUI")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name   = "SelfFlingGUI"
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame", screenGui)
    frame.Size             = UDim2.new(0, 200, 0, 140)
    frame.Position         = UDim2.new(0.8, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.Active           = true
    frame.Draggable        = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", frame).Thickness    = 1

    local title = Instance.new("TextLabel", frame)
    title.Text               = "🚀 Self‑Fling"
    title.Font               = Enum.Font.GothamBold
    title.TextSize           = 16
    title.TextColor3         = Color3.fromRGB(240,240,240)
    title.BackgroundTransparency = 1
    title.Size               = UDim2.new(1,0,0,28)

    local btnClose = Instance.new("TextButton", frame)
    btnClose.Text             = "X"
    btnClose.Font             = Enum.Font.GothamBold
    btnClose.TextSize         = 18
    btnClose.Size             = UDim2.new(0,24,0,24)
    btnClose.Position         = UDim2.new(1,-28,0,2)
    btnClose.BackgroundTransparency = 1
    btnClose.TextColor3       = Color3.fromRGB(200,200,200)
    btnClose.MouseEnter:Connect(function() btnClose.TextColor3 = Color3.fromRGB(255,255,255) end)
    btnClose.MouseLeave:Connect(function() btnClose.TextColor3 = Color3.fromRGB(200,200,200) end)
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    end)

    local content = Instance.new("Frame", frame)
    content.Size               = UDim2.new(1,-16,1,-44)
    content.Position           = UDim2.new(0,8,0,32)
    content.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", content)
    layout.Padding            = UDim.new(0,8)
    layout.SortOrder          = Enum.SortOrder.LayoutOrder

    local txtStrength = Instance.new("TextBox", content)
    txtStrength.PlaceholderText = "160"
    txtStrength.Text            = "160"
    txtStrength.Font            = Enum.Font.Gotham
    txtStrength.TextSize        = 14
    txtStrength.TextColor3      = Color3.fromRGB(230,230,230)
    txtStrength.BackgroundColor3 = Color3.fromRGB(35,35,35)
    txtStrength.Size            = UDim2.new(1,0,0,28)
    txtStrength.ClearTextOnFocus = false
    Instance.new("UICorner", txtStrength).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", txtStrength).Thickness    = 1

    local btnFling = Instance.new("TextButton", content)
    btnFling.Text            = "FLING!"
    btnFling.Font            = Enum.Font.GothamBold
    btnFling.TextSize        = 16
    btnFling.TextColor3      = Color3.fromRGB(255,255,255)
    btnFling.BackgroundColor3 = Color3.fromRGB(180,30,30)
    btnFling.AutoButtonColor = false
    btnFling.Size            = UDim2.new(1,0,0,36)
    Instance.new("UICorner", btnFling).CornerRadius = UDim.new(0,6)
    local stroke = Instance.new("UIStroke", btnFling)
    stroke.Thickness = 1
    stroke.Color     = Color3.fromRGB(120,0,0)
    local grad = Instance.new("UIGradient", btnFling)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200,50,50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150,20,20)),
    })

    local defaultText  = btnFling.Text
    local defaultColor = btnFling.BackgroundColor3

    btnFling.MouseButton1Click:Connect(function()
        grad:Destroy()
        btnFling.Text             = "🚀"
        btnFling.BackgroundColor3 = Color3.fromRGB(50,200,50)

        local char = player.Character
        if not char then return end
        local hrp      = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        local strength = tonumber(txtStrength.Text) or 160

        -- tạo BodyGyro để nghiêng người sang ngang (ngã)
        local gyro = Instance.new("BodyGyro")
        gyro.CFrame    = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) -- xoay ngang
        gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        gyro.P         = 1e4
        gyro.Parent    = hrp
        Debris:AddItem(gyro, 0.3)

        -- tạo BodyVelocity để nhảy thẳng lên
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0,1e5,0)
        bv.Velocity = Vector3.new(0, strength, 0)
        bv.Parent   = hrp
        Debris:AddItem(bv, 0.3)

        -- revert nút sau 0.3s
        delay(0.3, function()
            btnFling.Text             = defaultText
            btnFling.BackgroundColor3 = defaultColor
            local newGrad = Instance.new("UIGradient", btnFling)
            newGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(200,50,50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150,20,20)),
            })
            stroke.Color = Color3.fromRGB(120,0,0)
        end)
    end)
end

charAddedConn = player.CharacterAdded:Connect(makeGUI)
if player.Character then makeGUI() end
