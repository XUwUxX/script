local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local charAddedConn

local function makeGUI()
    local old = player.PlayerGui:FindFirstChild("SelfFlingGUI")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SelfFlingGUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 220, 0, 160)
    frame.Position = UDim2.new(0.7, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Transparency = 0.3

    if not Lighting:FindFirstChild("UI_Blur") then
        local blur = Instance.new("BlurEffect")
        blur.Name = "UI_Blur"
        blur.Size = 2
        blur.Parent = Lighting
    end

    local title = Instance.new("TextLabel", frame)
    title.Text = "🚀 Self‑Fling"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(230, 230, 230)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local btnClose = Instance.new("TextButton", frame)
    btnClose.Text = "X"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 18
    btnClose.TextColor3 = Color3.fromRGB(180, 180, 180)
    btnClose.BackgroundTransparency = 1
    btnClose.Size = UDim2.new(0, 30, 0, 30)
    btnClose.Position = UDim2.new(1, -34, 0, 4)
    btnClose.MouseEnter:Connect(function() btnClose.TextColor3 = Color3.fromRGB(255,255,255) end)
    btnClose.MouseLeave:Connect(function() btnClose.TextColor3 = Color3.fromRGB(180,180,180) end)
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    end)

    local content = Instance.new("Frame", frame)
    content.Size = UDim2.new(1, -24, 1, -50)
    content.Position = UDim2.new(0, 12, 0, 42)
    content.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local txtStrength = Instance.new("TextBox", content)
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

    local btnFling = Instance.new("TextButton", content)
    btnFling.Text = "FLING!"
    btnFling.Font = Enum.Font.GothamBold
    btnFling.TextSize = 16
    btnFling.TextColor3 = Color3.fromRGB(255,255,255)
    btnFling.BackgroundColor3 = Color3.from
