-- Gui tạo bằng code, không cần trong StarterGui
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- UI Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedChangerUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game.CoreGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = screenGui

-- UI Enhancements
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 20)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(180, 180, 255)
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- WalkSpeed Label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 280, 0, 40)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 1
label.Text = "WalkSpeed:"
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.TextScaled = true
label.Parent = frame

-- Speed Input
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

-- Plus Button
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

-- Minus Button
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

-- Hide Button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(1, -20, 0, -20)
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.Text = "×"
toggle.Font = Enum.Font.GothamBold
toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggle.BackgroundTransparency = 0.3
toggle.TextScaled = true
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

-- Mini Button
local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 60, 0, 60)
mini.Position = UDim2.new(0, 20, 0.7, 0)
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

-- Logic
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
	updateSpeed(humanoid.WalkSpeed - 5)
end)

inputBox.FocusLost:Connect(function()
	updateSpeed(inputBox.Text)
end)

toggle.MouseButton1Click:Connect(function()
	frame.Visible = false
	mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
	frame.Visible = true
	mini.Visible = false
end)

-- Animated background effect (shimmer)
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
		shimmer.Rotation = shimmer.Rotation + 1
		wait(0.02)
	end
end)
