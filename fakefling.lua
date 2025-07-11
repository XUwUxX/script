-- Services
local Players = game:GetService("Players")
local Debris  = game:GetService("Debris")
local UIS     = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui

-- Tạo GUI
local function makeGUI()
    if gui and gui.Parent then gui:Destroy() end

    gui = Instance.new("ScreenGui")
    gui.Name = "SelfFlingGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- Frame chứa
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 130)
    frame.Position = UDim2.new(0.75, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.9
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(180, 180, 180)
    stroke.Thickness = 1.5

    -- Title & nút đóng
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -30, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "🚀 Self‑Fling"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    local btnClose = Instance.new("TextButton", frame)
    btnClose.Text = "X"
    btnClose.Size = UDim2.new(0, 24, 0, 24)
    btnClose.Position = UDim2.new(1, -28, 0, 2)
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 16
    btnClose.TextColor3 = Color3.fromRGB(220,220,220)
    btnClose.BackgroundTransparency = 1
    btnClose.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Layout & content
    local content = Instance.new("Frame", frame)
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 30)
    content.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    content.Parent = frame

    -- TextBox strength
    local txtStrength = Instance.new("TextBox", content)
    txtStrength.Size = UDim2.new(1, 0, 0, 30)
    txtStrength.PlaceholderText = "95"
    txtStrength.Text = "95"
    txtStrength.Font = Enum.Font.Gotham
    txtStrength.TextSize = 14
    txtStrength.TextColor3 = Color3.new(1,1,1)
    txtStrength.BackgroundColor3 = Color3.fromRGB(30,30,30)
    txtStrength.BackgroundTransparency = 0.3
    txtStrength.ClearTextOnFocus = false
    Instance.new("UICorner", txtStrength).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", txtStrength).Color = Color3.fromRGB(100,100,100)

    -- Nút Fling
    local btnFling = Instance.new("TextButton", content)
    btnFling.Size = UDim2.new(1, 0, 0, 36)
    btnFling.Text = "FLING!"
    btnFling.Font = Enum.Font.GothamBold
    btnFling.TextSize = 16
    btnFling.TextColor3 = Color3.new(1,1,1)
    btnFling.BackgroundColor3 = Color3.fromRGB(200,50,50)
    Instance.new("UICorner", btnFling).CornerRadius = UDim.new(0,6)
    local flingStroke = Instance.new("UIStroke", btnFling)
    flingStroke.Color = Color3.fromRGB(130,20,20)
    local grad = Instance.new("UIGradient", btnFling)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220,70,70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180,40,40))
    })

    -- Hàm fling
    local function doFling()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and humanoid) then return end

        local strength = tonumber(txtStrength.Text) or 95

        -- HIệu ứng UX
        grad:Destroy()
        btnFling.Text = "🚀"
        btnFling.BackgroundColor3 = Color3.fromRGB(50,200,50)

        -- Nghiêng người
        local gyro = Instance.new("BodyGyro")
        gyro.CFrame = hrp.CFrame * CFrame.Angles(0,0,math.rad(90))
        gyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        gyro.P = 1e4
        gyro.Parent = hrp
        Debris:AddItem(gyro, 0.1)

        -- Tạo lực đẩy
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, strength, 0)
        bv.MaxForce = Vector3.new(0,1e5,0)
        bv.Parent = hrp
        Debris:AddItem(bv, 0.3)

        -- Reset UI sau fling
        task.delay(0.3, function()
            btnFling.Text = "FLING!"
            btnFling.BackgroundColor3 = Color3.fromRGB(200,50,50)
            local newGrad = Instance.new("UIGradient", btnFling)
            newGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220,70,70)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180,40,40))
            })
        end)
    end

    -- Kết nối chuột và phím R
    btnFling.MouseButton1Click:Connect(doFling)
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.R then
            doFling()
        end
    end)
end

-- Khởi tạo GUI một lần duy nhất
makeGUI()
