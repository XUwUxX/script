local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local defaultSpeed = humanoid.WalkSpeed

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "KevinzHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 200)
main.Position = UDim2.new(0.5, -180, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0
main.Name = "MainFrame"
main.ClipsDescendants = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- UIGradient ở góc phải đáy
local grad = Instance.new("UIGradient", main)
grad.Rotation = 45
grad.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 0.4)
}
grad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
}

-- Avatar + tên
local headshot = Instance.new("ImageLabel", main)
headshot.Size = UDim2.new(0, 40, 0, 40)
headshot.Position = UDim2.new(0, 10, 0, 10)
headshot.BackgroundTransparency = 1
headshot.Image = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png"):format(player.UserId)
Instance.new("UICorner", headshot).CornerRadius = UDim.new(1, 0)

local name = Instance.new("TextLabel", main)
name.Size = UDim2.new(1, -60, 0, 40)
name.Position = UDim2.new(0, 60, 0, 10)
name.BackgroundTransparency = 1
name.Font = Enum.Font.GothamBold
name.Text = player.DisplayName or player.Name
name.TextColor3 = Color3.new(1, 1, 1)
name.TextXAlignment = Enum.TextXAlignment.Left
name.TextSize = 20

-- TextBox chỉnh speed
local box = Instance.new("TextBox", main)
box.Size = UDim2.new(0.6, 0, 0, 36)
box.Position = UDim2.new(0.2, 0, 0.45, 0)
box.PlaceholderText = tostring(defaultSpeed)
box.Text = tostring(defaultSpeed)
box.TextColor3 = Color3.new(1, 1, 1)
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.Font = Enum.Font.Gotham
box.TextSize = 18
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

-- Toggle bật/tắt
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(1, -50, 0.45, 0)
toggle.Text = "✓"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

-- Toggle khung "+" ẩn/hiện
local sideToggle = Instance.new("TextButton", gui)
sideToggle.Size = UDim2.new(0, 40, 0, 40)
sideToggle.Position = UDim2.new(1, -50, 0.5, -20)
sideToggle.AnchorPoint = Vector2.new(1, 0)
sideToggle.Text = "+"
sideToggle.TextColor3 = Color3.new(1, 1, 1)
sideToggle.Font = Enum.Font.GothamBold
sideToggle.TextSize = 24
sideToggle.BackgroundColor3 = Color3.new(0, 0, 0)
sideToggle.BackgroundTransparency = 0.6
Instance.new("UICorner", sideToggle).CornerRadius = UDim.new(0, 10)

local toggleFrame = Instance.new("Frame", gui)
toggleFrame.Size = UDim2.new(0, 120, 0, 100)
toggleFrame.Position = UDim2.new(1, -130, 0.5, -50)
toggleFrame.AnchorPoint = Vector2.new(1, 0)
toggleFrame.BackgroundColor3 = Color3.new(0, 0, 0)
toggleFrame.BackgroundTransparency = 0.6
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 12)
toggleFrame.Visible = false

sideToggle.MouseButton1Click:Connect(function()
	toggleFrame.Visible = not toggleFrame.Visible
end)

-- Xử lý nhập số
box.FocusLost:Connect(function()
	local val = tonumber(box.Text)
	if val and val > 0 and val < 1000 then
		humanoid.WalkSpeed = val
	else
		box.Text = tostring(humanoid.WalkSpeed)
	end
end)

-- Bật tắt speed
local toggled = true
toggle.MouseButton1Click:Connect(function()
	toggled = not toggled
	if toggled then
		toggle.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
		local val = tonumber(box.Text)
		if val then humanoid.WalkSpeed = val end
	else
		toggle.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
		humanoid.WalkSpeed = defaultSpeed
	end
end)
