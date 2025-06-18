local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KevinzHubUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(200, 200, 255)
stroke.Transparency = 0.25

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Kevinz Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(30, 30, 30)
title.TextScaled = true
title.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.6, 0, 0, 25)
label.Position = UDim2.new(0.05, 0, 0.2, 0)
label.BackgroundTransparency = 1
label.Text = "WalkSpeed:"
label.Font = Enum.Font.Gotham
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.TextScaled = true
label.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 60, 0, 25)
inputBox.Position = UDim2.new(0.6, 0, 0.2, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
inputBox.Text = tostring(humanoid.WalkSpeed)
inputBox.Font = Enum.Font.Gotham
inputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
inputBox.TextScaled = true
inputBox.ClearTextOnFocus = false
inputBox.Parent = frame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0, 40, 0, 25)
plus.Position = UDim2.new(0.75, 0, 0.2, 0)
plus.Text = "+"
plus.Font = Enum.Font.GothamBold
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
plus.TextScaled = true
plus.Parent = frame
Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 6)

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 40, 0, 25)
hideBtn.Position = UDim2.new(0.05, 0, 0.2, 30)
hideBtn.Text = "-"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
hideBtn.TextScaled = true
hideBtn.Parent = frame
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(1, 0)

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(0.6, 0, 0, 25)
jumpLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "JumpPower:"
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
jumpLabel.TextScaled = true
jumpLabel.Parent = frame

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(0, 60, 0, 25)
jumpBox.Position = UDim2.new(0.6, 0, 0.5, 0)
jumpBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
jumpBox.Text = tostring(humanoid.JumpPower)
jumpBox.Font = Enum.Font.Gotham
jumpBox.TextColor3 = Color3.fromRGB(0, 0, 0)
jumpBox.TextScaled = true
jumpBox.ClearTextOnFocus = false
jumpBox.Parent = frame
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)

local toggleESP = Instance.new("TextButton")
toggleESP.Size = UDim2.new(0, 80, 0, 25)
toggleESP.Position = UDim2.new(0.33, 0, 0.75, 0)
toggleESP.Text = "ESP ON"
toggleESP.Font = Enum.Font.GothamBold
toggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleESP.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
toggleESP.TextScaled = true
toggleESP.Parent = frame
Instance.new("UICorner", toggleESP).CornerRadius = UDim.new(0, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.Text = "×"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.fromRGB(255, 0, 0)
close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundTransparency = 0.2
close.TextScaled = true
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 50, 0, 50)
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

-- Tăng giảm, nhập tốc độ
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

inputBox.FocusLost:Connect(function()
	updateSpeed(inputBox.Text)
end)

jumpBox.FocusLost:Connect(function()
	local val = tonumber(jumpBox.Text)
	if val then
		val = math.clamp(val, 0, 200)
		humanoid.JumpPower = val
		jumpBox.Text = tostring(val)
	end
end)

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
	frame.Visible = true
	mini.Visible = false
end)

close.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Stickman ESP
local espEnabled = true
local beams = {}

local function createLine(from, to, color)
	local a0 = Instance.new("Attachment", from)
	local a1 = Instance.new("Attachment", to)
	local beam = Instance.new("Beam")
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Color = ColorSequence.new(color)
	beam.Width0 = 0.1
	beam.Width1 = 0.1
	beam.FaceCamera = true
	beam.Parent = from
	table.insert(beams, beam)
end

local function drawStickman(char)
	local parts = {
		Head = char:FindFirstChild("Head"),
		Torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
		LArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
		RArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
		LLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
		RLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
	}
	if not (parts.Head and parts.Torso and parts.LArm and parts.RArm and parts.LLeg and parts.RLeg) then return end

	createLine(parts.Head, parts.Torso, Color3.fromRGB(0, 255, 0))
	createLine(parts.LArm, parts.Torso, Color3.fromRGB(255, 255, 0))
	createLine(parts.RArm, parts.Torso, Color3.fromRGB(255, 255, 0))
	createLine(parts.LLeg, parts.Torso, Color3.fromRGB(255, 100, 100))
	createLine(parts.RLeg, parts.Torso, Color3.fromRGB(255, 100, 100))
end

local function drawAllESP()
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			drawStickman(plr.Character)
		end
	end
end

toggleESP.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggleESP.Text = espEnabled and "ESP ON" or "ESP OFF"
	for _, b in pairs(beams) do
		b:Destroy()
	end
	table.clear(beams)
	if espEnabled then
		drawAllESP()
	end
end)

-- Vẽ ban đầu
drawAllESP()
