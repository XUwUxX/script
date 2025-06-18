-- Load UI library (Fluent‑Renewed)
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()

-- Tạo window chính
local window = Library:CreateWindow({
    Title = "Delta Hub",
    Accent = Color3.fromRGB(255, 50, 50),      -- đỏ nổi bật
    Theme = Color3.fromRGB(30, 30, 30)         -- xám tối gần đen
})

-- Tạo gradient background + hiệu ứng slide/pop-in
local mainFrame = window.MainFrame
do
    -- Background gradient
    local grad = Instance.new("UIGradient", mainFrame)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0.15,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(0.2,0,0))
    }
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.5)
    }

    -- Slide in từ trên xuống khi mở
    mainFrame.Position = UDim2.new(0.5,0, -1,0)
    mainFrame:TweenPosition(UDim2.new(0.5,0,0.3,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
end

-- Header: avatar headshot + tên người chơi
do
    local header = Instance.new("Frame", window.TitleBar)
    header.Size = UDim2.new(0,200,1,0)
    header.BackgroundTransparency = 1

    local img = Instance.new("ImageLabel", header)
    img.Size = UDim2.new(0,32,0,32)
    img.Position = UDim2.new(0,8,0.5,-16)
    img.BackgroundTransparency = 1
    img.Image = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png"):format(game.Players.LocalPlayer.UserId)

    local name = Instance.new("TextLabel", header)
    name.Size = UDim2.new(1,-48,1,0)
    name.Position = UDim2.new(0,48,0,0)
    name.BackgroundTransparency = 1
    name.Text = game.Players.LocalPlayer.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 20
end

-- Tạo tab chính
local tab = window:AddTab("Main")

-- Input và slider module
local ws, jp, fov = 16, 50, workspace.CurrentCamera.FieldOfView

tab:AddLabel("Movement & FOV Settings")

tab:AddInput("WalkSpeed", "Set character WalkSpeed", tostring(ws), function(val)
    local n = tonumber(val) or ws
    ws = n; game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = n
end)

tab:AddInput("JumpPower", "Set character JumpPower", tostring(jp), function(val)
    local n = tonumber(val) or jp
    jp = n; game.Players.LocalPlayer.Character.Humanoid.JumpPower = n
end)

tab:AddInput("FOV", "Set camera FieldOfView", tostring(fov), function(val)
    local n = tonumber(val) or fov
    fov = n; workspace.CurrentCamera.FieldOfView = n
end)

-- Nút Execute Script
tab:AddButton("Execute Script", "Run actions", function()
    local start = tick()
    -- Bạn có thể đặt đoạn mã exec ở đây
    -- e.g. game.Players.LocalPlayer.Character.Humanoid.Health = 0

    local t = math.floor((tick() - start)*1000)
    -- Thông báo thành công dùng Roblox Notification
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Delta Hub";
        Text = "Script đã execute thành công trong "..t.." ms";
        Duration = 3;
    })
end)

-- Pop-in animation khi lần đầu hiện window
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame:TweenSize(UDim2.new(0, 500, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)

-- Mở UI
window:Toggle()
