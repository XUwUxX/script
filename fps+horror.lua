-- LocalScript (đặt trong StarterPlayerScripts)
local Players  = game:GetService("Players")
local Debris   = game:GetService("Debris")

local player   = Players.LocalPlayer
local camera   = workspace.CurrentCamera

-- Hàm tạo GUI
local function makeGUI()
    -- Xoá GUI cũ nếu có
    local old = player.PlayerGui:FindFirstChild("SelfFlingGUI")
    if old then old:Destroy() end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name   = "SelfFlingGUI"
    screenGui.Parent = player.PlayerGui

    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Name               = "Container"
    frame.Size               = UDim2.new(0, 240, 0, 180)
    frame.Position           = UDim2.new(0.75, 0, 0.25, 0)
    frame.BackgroundColor3   = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel    = 0
    frame.Active             = true
    frame.Draggable          = true
    frame.Parent             = screenGui

    -- Bo góc + Stroke
    local uiCorner = Instance.new("UICorner", frame)
    uiCorner.CornerRadius    = UDim.new(0, 12)
    Instance.new("UIStroke", frame).Thickness = 1

    -- Title
    local title = Instance.new("TextLabel", frame)
    title.Text               = "🚀 Self‑Fling"
    title.Font               = Enum.Font.GothamBold
    title.TextSize           = 18
    title.TextColor3         = Color3.fromRGB(235,235,235)
    title.BackgroundTransparency = 1
    title.Size               = UDim2.new(1, 0, 0, 36)

    -- Close Button
    local btnClose = Instance.new("TextButton", frame)
    btnClose.Text             = "✕"
    btnClose.Font             = Enum.Font.GothamBold
    btnClose.TextSize         = 18
    btnClose.Size             = UDim2.new(0, 36, 0, 36)
    btnClose.Position         = UDim2.new(1, -40, 0, 0)
    btnClose.BackgroundTransparency = 1
    btnClose.TextColor3       = Color3.fromRGB(180,180,180)
    btnClose.Parent           = frame
    btnClose.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Content Holder
    local content = Instance.new("Frame", frame)
    content.Size               = UDim2.new(1, -20, 1, -56)
    content.Position           = UDim2.new(0, 10, 0, 46)
    content.BackgroundTransparency = 1
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 12)

    -- Strength Box
    local txtStrength = Instance.new("TextBox", content)
    txtStrength.Name            = "StrengthBox"
    txtStrength.PlaceholderText = "200"
    txtStrength.Text            = "200"
    txtStrength.Font            = Enum.Font.Gotham
    txtStrength.TextSize        = 16
    txtStrength.TextColor3      = Color3.fromRGB(230,230,230)
    txtStrength.BackgroundColor3 = Color3.fromRGB(30,30,30)
    txtStrength.Size            = UDim2.new(1, 0, 0, 32)
    txtStrength.ClearTextOnFocus = false
    local tbCorner = Instance.new("UICorner", txtStrength)
    tbCorner.CornerRadius       = UDim.new(0, 8)
    Instance.new("UIStroke", txtStrength).Thickness = 1

    -- Fling Button
    local btnFling = Instance.new("TextButton", content)
    btnFling.Name            = "FlingButton"
    btnFling.Text            = "FLING!"
    btnFling.Font            = Enum.Font.GothamBold
    btnFling.TextSize        = 18
    btnFling.TextColor3      = Color3.fromRGB(255,255,255)
    btnFling.BackgroundColor3 = Color3.fromRGB(180,30,30)
    btnFling.AutoButtonColor = false
    btnFling.Size            = UDim2.new(1, 0, 0, 40)
    local fbCorner = Instance.new("UICorner", btnFling)
    fbCorner.CornerRadius     = UDim.new(0, 8)
    local fbStroke = Instance.new("UIStroke", btnFling)
    fbStroke.Thickness        = 1
    fbStroke.Color            = Color3.fromRGB(120,0,0)
    local fbGrad   = Instance.new("UIGradient", btnFling)
    fbGrad.Color               = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200,50,50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150,20,20)),
    })

    -- Lưu giá trị gốc để revert
    local defaultText  = btnFling.Text
    local defaultColor = btnFling.BackgroundColor3

    -- Fling logic với hiệu ứng nút
    btnFling.MouseButton1Click:Connect(function()
        -- Đổi icon + màu xanh
        btnFling.Text            = "🚀"
        btnFling.BackgroundColor3 = Color3.fromRGB(50,200,50)

        -- Self‑fling
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                hum.PlatformStand = true

                local strength    = tonumber(txtStrength.Text) or 200
                local horizFactor = 0.4
                local upForce     = strength
                local duration    = 0.3

                local sign          = (math.random()<0.5 and -1) or 1
                local horizontalDir = camera.CFrame.RightVector * strength * horizFactor * sign
                local verticalDir   = Vector3.new(0, upForce, 0)
                local flingVector   = horizontalDir + verticalDir

                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.Velocity = flingVector
                bv.Parent   = hrp

                local bav = Instance.new("BodyAngularVelocity")
                bav.MaxTorque       = Vector3.new(1e5,1e5,1e5)
                bav.AngularVelocity = Vector3.new(
                    math.random(-8,8),
                    math.random(-8,8),
                    math.random(-8,8)
                )
                bav.Parent = hrp

                -- Sau khi xong, revert lại nút và reset trạng thái
                delay(duration, function()
                    bv:Destroy()
                    bav:Destroy()
                    if hum and hum.Parent then hum.PlatformStand = false end
                    btnFling.Text            = defaultText
                    btnFling.BackgroundColor3 = defaultColor
                end)
            else
                -- nếu thiếu HRP/Humanoid thì vẫn revert nút
                btnFling.Text            = defaultText
                btnFling.BackgroundColor3 = defaultColor
            end
        else
            btnFling.Text            = defaultText
            btnFling.BackgroundColor3 = defaultColor
        end
    end)
end

-- Gọi khi respawn / lần đầu
player.CharacterAdded:Connect(makeGUI)
if player.Character then
    makeGUI()
end
