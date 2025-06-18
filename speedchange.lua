local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedChangerUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game.CoreGui

local blur = Instance.new("BlurEffect")
blur.Size = 12
blur.Parent = game:GetService("Lighting")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 20)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(200, 200, 255)
uiStroke.Transparency = 0.25
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local shimmer = Instance.new("UIGradient")
shimmer.Rotation = 0
shimmer.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.4),
	NumberSequenceKeypoint.new(0.5, 0.1),
	NumberSequenceKeypoint.new(1, 0.4),
})
shimmer.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 255))
shimmer.Parent = frame

spawn(function()
	while true do
		shimmer.Rotation += 1
		wait(0.02)
	end
end)

local function boing(ui)
	ui.Position = ui.Position + UDim2.new(0, 0, 0, -20)
	ui:TweenPosition(
		ui.Position + UDim2.new(0, 0, 0, 20),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Elastic,
		0.6,
		true
	)
end

boing(frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kevinz Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(30, 30, 30)
title.TextScaled = true
title.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 280, 0, 40)
label.Position = UDim2.new(0, 10, 0, 40)
label.BackgroundTransparency = 1
label.Text = "WalkSpeed:"
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.TextScaled = true
label.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 100, 0, 40)
inputBox.Position = UDim2.new(0.5, -50, 0.3, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
inputBox.BackgroundTransparency = 0.2
inputBox.Text = tostring(humanoid.WalkSpeed)
inputBox.Font = Enum.Font.Gotham
inputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
inputBox.TextScaled = true
inputBox.ClearTextOnFocus = false
inputBox.Parent = frame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 10)

local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0, 50, 0, 40)
plus.Position = UDim2.new(0.75, -10, 0.3, 0)
plus.Text = "+"
plus.Font = Enum.Font.GothamBold
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
plus.TextScaled = true
plus.Parent = frame
Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 10)

local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0, 50, 0, 40)
minus.Position = UDim2.new(0.1, 10, 0.3, 0)
minus.Text = "-"
minus.Font = Enum.Font.GothamBold
minus.TextColor3 = Color3.fromRGB(255, 255, 255)
minus.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
minus.TextScaled = true
minus.Parent = frame
Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 10)

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(0, 280, 0, 40)
jumpLabel.Position = UDim2.new(0, 10, 0.55, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "JumpPower:"
jumpLabel.Font = Enum.Font.GothamBold
jumpLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
jumpLabel.TextScaled = true
jumpLabel.Parent = frame

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(0, 100, 0, 40)
jumpBox.Position = UDim2.new(0.5, -50, 0.7, 0)
jumpBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
jumpBox.BackgroundTransparency = 0.2
jumpBox.Text = tostring(humanoid.JumpPower)
jumpBox.Font = Enum.Font.Gotham
jumpBox.TextColor3 = Color3.fromRGB(0, 0, 0)
jumpBox.TextScaled = true
jumpBox.ClearTextOnFocus = false
jumpBox.Parent = frame
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 10)

jumpBox.FocusLost:Connect(function()
	local val = tonumber(jumpBox.Text)
	if val then
		val = math.clamp(val, 0, 200)
		humanoid.JumpPower = val
		jumpBox.Text = tostring(val)
	end
end)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 30, 0, 30)
toggle.Position = UDim2.new(1, -35, 0, 5)
toggle.Text = "×"
toggle.Font = Enum.Font.GothamBold
toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggle.BackgroundTransparency = 0.3
toggle.TextScaled = true
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 60, 0, 60)
mini.Position = UDim2.new(0, 20, 0.8, 0)
mini.Text = "⚙️"
mini.Font = Enum.Font.GothamBold
mini.TextColor3 = Color3.fromRGB(255, 255, 255)
mini.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
mini.Visible = false
mini.Active = true
mini.Draggable = true
mini.TextScaled = true
mini.Parent = screenGui
Instance.new("UICorner", mini).CornerRadius = UDim.new(1, 0)

local function updateSpeed(val)
	local speed = tonumber(val)
	if speed then
		speed = math.clamp(speed, 0, 200)
		humanoid.WalkSpeed = speed
		inputBox.Text = tostring(speed)
	end
end

plus.MouseButton1Click:Connect(function()
	updateSpeed(humanoid.WalkSpeed + 5)
end)

minus.MouseButton1Click:Connect(function()
	frame.Visible = false
	mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
	frame.Visible = true
	mini.Visible = false
	boing(frame)
end)

inputBox.FocusLost:Connect(function()
	updateSpeed(inputBox.Text)
end)

toggle.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Stickman ESP
for _, plr in pairs(game.Players:GetPlayers()) do
	if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		local torso = plr.Character:FindFirstChild("HumanoidRootPart")
		local esp = Instance.new("BillboardGui")
		esp.Name = "StickmanESP"
		esp.Adornee = torso
		esp.Size = UDim2.new(2, 0, 3, 0)
		esp.AlwaysOnTop = true
		esp.Parent = torso

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Parent = esp

		local line = Instance.new("UIStroke")
		line.Color = Color3.fromRGB(0, 255, 0)
		line.Thickness = 2
		line.Parent = frame
	end
end
