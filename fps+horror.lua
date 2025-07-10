-- LocalScript (đặt trong StarterPlayerScripts)
local Players = game:GetService("Players")
local Debris  = game:GetService("Debris")

local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera

-- giữ connection để có thể disconnect khi đóng GUI
local charAddedConn

local function makeGUI()
    -- xoá GUI cũ nếu có
    local old = player.PlayerGui:FindFirstChild("SelfFlingGUI")
    if old then old:Destroy() end

    -- tạo ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name   = "SelfFlingGUI"
    screenGui.Parent = player.PlayerGui

    -- main Frame
    local frame = Instance.new("Frame", screenGui)
    frame.Size             = UDim2.new(0, 200, 0, 140)
    frame.Position         = UDim2.new(0.8, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.Active           = true
    frame.Draggable        = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", frame).Thickness    = 1

    -- title
    local title = Instance.new("TextLabel", frame)
    title.Text               = "🚀 Self‑Fling"
    title.Font               = Enum.Font.GothamBold
    title.TextSize           = 16
    title.TextColor3         = Color3.fromRGB(240,240,240)
    title.BackgroundTransparency = 1
    title.Size               = UDim2.new(1,0,0,28)

    -- nút X để huỷ GUI
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

    -- container cho nội dung
    local content = Instance.new("Frame", frame)
    content.Size               = UDim2.new(1,-16,1,-44)
    content.Position           = UDim2.new(0,8,0,32)
    content.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", content)
    layout.Padding            = UDim.new(0,8)
    layout.SortOrder          = Enum.SortOrder.LayoutOrder

    -- TextBox nhập strength
    local txtStrength = Instance.new("TextBox", content)
    txtStrength.PlaceholderText = "200"
    txtStrength.Text            = "200"
    txtStrength.Font            = Enum.Font.Gotham
    txtStrength.TextSize        = 14
    txtStrength.TextColor3      = Color3.fromRGB(230,230,230)
    txtStrength.BackgroundColor3 = Color3.fromRGB(35,35,35)
    txtStrength.Size            = UDim2.new(1,0,0,28)
    txtStrength.ClearTextOnFocus = false
    Instance.new("UICorner", txtStrength).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", txtStrength).Thickness    = 1

    -- nút Fling
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

    -- lưu trạng thái gốc
    local defaultText  = btnFling.Text
    local defaultColor = btnFling.BackgroundColor3

    -- logic Self‑Fling
    btnFling.MouseButton1Click:Connect(function()
        -- gỡ gradient để màu xanh hiện đúng
        grad:Destroy()

        -- đổi nút
        btnFling.Text             = "🚀"
        btnFling.BackgroundColor3 = Color3.fromRGB(50,200,50)

        -- chuẩn bị nhân vật
        local char = player.Character
        if not char then return end
        local hrp      = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- bật ragdoll ngay lập tức
        humanoid.PlatformStand = true

        -- đọc strength
        local strength = tonumber(txtStrength.Text) or 200

        -- tạo BodyVelocity đẩy thẳng lên, thời gian 0.2s
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0,1e5,0)                  -- chỉ lên y
        bv.Velocity = Vector3.new(0, strength, 0)
        bv.Parent   = hrp
        Debris:AddItem(bv, 0.2)

        -- sau 0.2s, dừng ragdoll
        delay(0.2, function()
            humanoid.PlatformStand = false

            -- revert nút về ban đầu
            btnFling.Text             = defaultText
            btnFling.BackgroundColor3 = defaultColor

            -- khôi phục gradient
            local newGrad = Instance.new("UIGradient", btnFling)
            newGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(200,50,50)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150,20,20)),
            })
            stroke.Color = Color3.fromRGB(120,0,0)
        end)
    end)
end

-- tạo GUI khi respawn
charAddedConn = player.CharacterAdded:Connect(makeGUI)
if player.Character then makeGUI() end
