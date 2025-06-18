-- // Load Fluent-Renewed UI Library
local Library = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()

-- // Create Window
local Window = Library:CreateWindow({
    Title = "Kevinz Hub",
    Accent = Color3.fromRGB(255, 0, 50),
    Theme = Color3.fromRGB(20, 20, 20)
})
local MainFrame = Window.MainFrame

-- // Responsive scaling
local scale = Instance.new("UIScale", MainFrame)
scale.Scale = math.clamp(1, 0.5, 1.5)

-- // Make window draggable
Window.TitleBar.Active = true
Window.TitleBar.Draggable = true

-- // UI Gradient (Black to Red Fade)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(50, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
}
gradient.Rotation = 90
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 0.4)
}
gradient.Parent = MainFrame

-- // Headshot + Player Name
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

-- // Create Tab
local MainTab = Window:AddTab("Main")

MainTab:AddLabel("Movement Settings")

MainTab:AddInput("WalkSpeed", "Set your WalkSpeed", "16", function(val)
    local n = tonumber(val)
    if n then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = n
    end
end)

MainTab:AddInput("JumpPower", "Set your JumpPower", "50", function(val)
    local n = tonumber(val)
    if n then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = n
    end
end)

MainTab:AddInput("FOV", "Set your Field of View", tostring(workspace.CurrentCamera.FieldOfView), function(val)
    local n = tonumber(val)
    if n then
        workspace.CurrentCamera.FieldOfView = n
    end
end)

-- // Execute Button with Ripple Effect
MainTab:AddButton("Execute Script", "Run and notify", function(btn)
    -- Ripple effect
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.6
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    ripple.ClipsDescendants = true
    ripple.Parent = btn

    local uicorner = Instance.new("UICorner", ripple)
    uicorner.CornerRadius = UDim.new(1, 0)

    ripple:TweenSize(UDim2.new(1.5, 0, 4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, true, function()
        ripple:Destroy()
    end)

    -- Execution logic
    local t0 = tick()
    -- Place your logic here
    local t1 = tick()
    local ms = math.floor((t1 - t0) * 1000)

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kevinz Hub",
        Text = "Script executed in "..ms.."ms",
        Duration = 4
    })
end)

-- // Top-right toggle button with animation
local UIS = game:GetService("UserInputService")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 32)
toggleBtn.Position = UDim2.new(1, -130, 0, 10)
toggleBtn.AnchorPoint = Vector2.new(0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "Hide Kevinz Hub"
toggleBtn.TextSize = 14
toggleBtn.Parent = game.CoreGui
toggleBtn.ZIndex = 10000

local isVisible = true

toggleBtn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    toggleBtn.Text = isVisible and "Hide Kevinz Hub" or "Show Kevinz Hub"

    if isVisible then
        MainFrame:TweenPosition(UDim2.new(0.5, 0, 0.3, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
        MainFrame.Visible = true
    else
        MainFrame:TweenPosition(UDim2.new(0.5, 0, -1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.4, true, function()
            MainFrame.Visible = false
        end)
    end
end)

-- // Animate entrance
MainFrame.Position = UDim2.new(0.5, 0, -1, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenSize(UDim2.new(0, 500, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
MainFrame:TweenPosition(UDim2.new(0.5, 0, 0.3, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
