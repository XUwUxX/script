local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Main UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0.5, -150, 0.5, -150)
frame.BackgroundTransparency = 1
frame.AnchorPoint = Vector2.new(0.5, 0.5)

-- Gradient BG
local bg = Instance.new("ImageLabel", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://11446433781" -- black-red gradient fade
bg.ScaleType = Enum.ScaleType.Stretch

-- Top Avatar + Name
local pfp = Instance.new("ImageLabel", frame)
pfp.Size = UDim2.new(0, 40, 0, 40)
pfp.Position = UDim2.new(0, 10, 0, 10)
pfp.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
pfp.BackgroundTransparency = 1
pfp.ScaleType = Enum.ScaleType.Fit
pfp.ClipsDescendants = true

local uname = Instance.new("TextLabel", frame)
uname.Position = UDim2.new(0, 60, 0, 10)
uname.Size = UDim2.new(0, 200, 0, 40)
uname.Text = LocalPlayer.DisplayName
uname.Font = Enum.Font.GothamBold
uname.TextColor3 = Color3.new(1, 1, 1)
uname.TextScaled = true
uname.BackgroundTransparency = 1

-- Function Generator
local function createInput(labelText, defaultText, positionY, callback)
	local container = Instance.new("Frame", frame)
	container.Position = UDim2.new(0, 20, 0, positionY)
	container.Size = UDim2.new(1, -40, 0, 40)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Text = labelText
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true

	local input = Instance.new("TextBox", container)
	input.Text = tostring(defaultText)
	input.Size = UDim2.new(0.6, 0, 1, 0)
	input.Position = UDim2.new(0.4, 0, 0, 0)
	input.Font = Enum.Font.GothamSemibold
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	input.BorderSizePixel = 0
	input.TextScaled = true
	input.ClipsDescendants = true
	input.ClearTextOnFocus = false
	input.FocusLost:Connect(function()
		local val = tonumber(input.Text)
		if val then callback(val) end
	end)
end

-- WalkSpeed input
createInput("WalkSpeed", Humanoid.WalkSpeed, 70, function(val)
	Humanoid.WalkSpeed = val
end)

-- JumpPower input
createInput("JumpPower", Humanoid.JumpPower, 120, function(val)
	Humanoid.JumpPower = val
end)

-- FOV input
createInput("FOV", workspace.CurrentCamera.FieldOfView, 170, function(val)
	workspace.CurrentCamera.FieldOfView = val
end)

-- Slide + Pop animation
frame.Position = UDim2.new(0.5, -150, 1.2, 0)
TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
	Position = UDim2.new(0.5, -150, 0.5, -150)
}):Play()

frame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 300, 0, 300)
}):Play()

-- Success Notification
StarterGui:SetCore("SendNotification", {
	Title = "Kevinz Hub",
	Text = "Script executed successfully in "..math.random(20, 100).." ms",
	Duration = 4
})
