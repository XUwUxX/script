-- // Load thư viện GUI Fluent-Renewed
local Library = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()

-- // Tạo Window
local Window = Library:CreateWindow({
    Title = "Kevinz Hub",
    Accent = Color3.fromRGB(255, 0, 50),
    Theme = Color3.fromRGB(20, 20, 20)
})

local MainFrame = Window.MainFrame

-- // Gradient nền (đen + đỏ dưới fade)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.new(0.2, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
}
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 0.4)
}
gradient.Rotation = 90
gradient.Parent = MainFrame

-- // Pop-in & Slide animation khi mở
MainFrame.Position = UDim2.new(0.5, 0, -1, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenPosition(UDim2.new(0.5, 0, 0.3, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.4, true)
MainFrame:TweenSize(UDim2.new(0, 500, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)

-- // Headshot + Tên người chơi
local header = Instance.new("Frame", Window.TitleBar)
header.Size = UDim2.new(0, 200, 1, 0)
header.BackgroundTransparency = 1

local avatar = Instance.new("ImageLabel", header)
avatar.Size = UDim2.new(0, 30, 0, 30)
avatar.Position = UDim2.new(0, 6, 0.5, -15)
avatar.BackgroundTransparency = 1
avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..game.Players.LocalPlayer.UserId.."&width=420&height=420&format=png"

local nameLabel = Instance.new("TextLabel", header)
nameLabel.Size = UDim2.new(1, -42, 1, 0)
nameLabel.Position = UDim2.new(0, 42, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = game.Players.LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.new(1,1,1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- // Tạo tab
local MainTab = Window:AddTab("Main")

MainTab:AddLabel("Chỉnh Thông Số Nhân Vật")

MainTab:AddInput("WalkSpeed", "Tốc độ đi", "16", function(txt)
    local n = tonumber(txt)
    if n then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = n
    end
end)

MainTab:AddInput("JumpPower", "Độ nhảy", "50", function(txt)
    local n = tonumber(txt)
    if n then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = n
    end
end)

MainTab:AddInput("FOV", "Field of View", tostring(workspace.CurrentCamera.FieldOfView), function(txt)
    local n = tonumber(txt)
    if n then
        workspace.CurrentCamera.FieldOfView = n
    end
end)

MainTab:AddButton("Execute Script", "Thực thi và thông báo", function()
    local start = tick()
    -- bạn có thể thêm hành động thực thi thực sự tại đây

    local elapsed = math.floor((tick() - start) * 1000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kevinz Hub",
        Text = "Script đã execute thành công trong "..elapsed.."ms",
        Duration = 4
    })
end)

-- // Thêm nút Show/Hide UI ở góc trên bên phải
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 32)
toggleBtn.Position = UDim2.new(1, -130, 0, 10)
toggleBtn.AnchorPoint = Vector2.new(0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "Ẩn Kevinz Hub"
toggleBtn.TextSize = 14
toggleBtn.Parent = game.CoreGui
toggleBtn.AutoButtonColor = true

local isVisible = true

toggleBtn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
    toggleBtn.Text = isVisible and "Ẩn Kevinz Hub" or "Hiện Kevinz Hub"
end)
