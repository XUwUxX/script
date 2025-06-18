-- Kevinz Hub - Full Script with GUI, ESP, Anti-Fling, Gun Aura
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local gunAuraRadius = 15
local gunAuraEnabled = false
local chamEnabled = false
local walkFlingEnabled = false
local HUB_VERSION = "v1.5.0"

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- GUI Setup
local window = Instance.new("Frame", gui)
window.Size = UDim2.fromOffset(550, 400)
window.Position = UDim2.fromScale(0.5, 0.5)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = true
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

-- UI Gradient
local gradient = Instance.new("UIGradient", window)
gradient.Rotation = 45
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
}

-- Top bar
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

-- Avatar + Name
local avatar = Instance.new("ImageLabel", topBar)
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundTransparency = 1
avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.BackgroundTransparency = 1
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Content Area
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

-- Input Row System
local inputRow = 0
local function createInput(labelText, getDefault, callback)
	inputRow += 1
	local yOffset = (inputRow - 1) * 50 + 10

	local container = Instance.new("Frame", content)
	container.Size = UDim2.new(1, -40, 0, 40)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Text = labelText
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.BackgroundTransparency = 1

	local input = Instance.new("TextBox", container)
	input.Size = UDim2.new(0.6, -10, 1, 0)
	input.Position = UDim2.new(0.4, 10, 0, 0)
	input.Font = Enum.Font.Gotham
	input.PlaceholderText = tostring(getDefault())
	input.Text = ""
	input.TextScaled = true
	input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	input.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

	input.FocusLost:Connect(function()
		local val = tonumber(input.Text)
		if val then callback(val) end
		input.Text = ""
	end)
end

local function createSwitch(labelText, callback)
	inputRow += 1
	local yOffset = (inputRow - 1) * 50 + 10

	local container = Instance.new("Frame", content)
	container.Size = UDim2.new(1, -40, 0, 40)
	container.Position = UDim2.new(0, 20, 0, yOffset)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Text = labelText
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton", container)
	toggle.Size = UDim2.new(0.4, -10, 1, 0)
	toggle.Position = UDim2.new(0.6, 10, 0, 0)
	toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggle.Text = "OFF"
	toggle.Font = Enum.Font.GothamBold
	toggle.TextScaled = true
	toggle.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

	local state = false
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = state and "ON" or "OFF"
		toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
		callback(state)
	end)
end

-- Controls
createInput("WalkSpeed", function() return savedWalkSpeed end, function(v)
	savedWalkSpeed = v
	if Humanoid then Humanoid.WalkSpeed = v end
end)

createInput("JumpPower", function() return savedJumpPower end, function(v)
	savedJumpPower = v
	if Humanoid then Humanoid.JumpPower = v end
end)

createInput("FOV", function() return Camera.FieldOfView end, function(v)
	Camera.FieldOfView = v
end)

createSwitch("Chams ESP", function(on) chamEnabled = on end)
createSwitch("WalkFling", function(on) walkFlingEnabled = on end)
createSwitch("Gun Aura", function(on) gunAuraEnabled = on end)
createInput("Gun Aura Radius", function() return gunAuraRadius end, function(v)
	gunAuraRadius = math.clamp(v, 5, 100)
end)

-- Gun ESP + Aura
local droppedGunHighlights = {}

local function highlightDroppedGun(gun)
	if droppedGunHighlights[gun] then return end
	local h = Instance.new("Highlight", gun)
	h.Adornee = gun
	h.FillColor = Color3.fromRGB(255, 255, 0)
	h.OutlineColor = Color3.new(1, 1, 1)
	h.FillTransparency = 0.6
	h.OutlineTransparency = 0.3
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	droppedGunHighlights[gun] = h
end

workspace.DescendantAdded:Connect(function(desc)
	if desc.Name == "Gun" and desc:IsA("Tool") then
		task.wait(0.1)
		if not desc:IsDescendantOf(LocalPlayer) then
			highlightDroppedGun(desc)
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if gunAuraEnabled and RootPart then
		for gun, _ in pairs(droppedGunHighlights) do
			local handle = gun:FindFirstChild("Handle")
			if handle and (handle.Position - RootPart.Position).Magnitude <= gunAuraRadius then
				pcall(function()
					firetouchinterest(handle, RootPart, 0)
					firetouchinterest(handle, RootPart, 1)
				end)
			end
		end
	end
end)

-- WalkFling
if RootPart then
	RootPart.Touched:Connect(function(hit)
		if walkFlingEnabled and hit.Parent then
			local otherHum = hit.Parent:FindFirstChildOfClass("Humanoid")
			local otherRoot = hit.Parent:FindFirstChild("HumanoidRootPart")
			if otherHum and otherRoot and otherHum ~= Humanoid then
				local dir = (otherRoot.Position - RootPart.Position).Unit
				otherRoot.AssemblyLinearVelocity = dir * 200 + Vector3.new(0, 150, 0)
			end
		end
	end)
end

-- Anti-Fling/Anti-Void
local lastSafeCFrame = RootPart.CFrame

RunService.Heartbeat:Connect(function()
	if not RootPart or not RootPart.Parent then return end
	if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then return end

	if RootPart.Position.Y < workspace.FallenPartsDestroyHeight then
		RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
	end

	if RootPart.AssemblyLinearVelocity.Magnitude > 100 then
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
	end

	lastSafeCFrame = RootPart.CFrame
end)

-- Respawn update
LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")
	task.wait(0.2)
	Humanoid.WalkSpeed = savedWalkSpeed
	Humanoid.JumpPower = savedJumpPower
end)

-- Notify
task.delay(1, function()
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Kevinz Hub ✅",
			Text = "Loaded v" .. HUB_VERSION,
			Duration = 5
		})
	end)
end)
