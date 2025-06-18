local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- UI chính
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "KevinzHub"
gui.ResetOnSpawn = false

-- TopBar chứa avatar + tên
local topBar = Instance.new("Frame", gui)
topBar.Size = UDim2.new(0, 320, 0, 50)
topBar.Position = UDim2.new(0.5, -160, 0, 20)
topBar.BackgroundTransparency = 0.2
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.Name = "TopBar"

local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 10)

-- Avatar (ảnh đại diện)
local avatar = Instance.new("ImageLabel", topBar)
avatar.Size = UDim2.new(0, 40, 0, 40)
avatar.Position = UDim2.new(0, 5, 0.5, -20)
avatar.BackgroundTransparency = 1
avatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", player.UserId)

local avatarCorner = Instance.new("UICorner", avatar)
avatarCorner.CornerRadius = UDim.new(1, 0)

-- Tên người chơi
local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Size = UDim2.new(1, -60, 1, 0)
nameLabel.Position = UDim2.new(0, 55, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = player.DisplayName or player.Name
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Frame chỉnh tốc độ
local frame = Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 320, 0, 150)
frame.Position = UDim2.new(0.5, -160, 0, 80)
frame.BackgroundTransparency = 0.1
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 12)

-- Slider nền
local sliderBG = Instance.new("Frame", frame)
sliderBG.Size = UDim2.new(0.8, 0, 0, 20)
sliderBG.Position = UDim2.new(0.1, 0, 0.4, 0)
sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBG.Name = "SliderBackground"

local sliderCorner = Instance.new("UICorner", sliderBG)
sliderCorner.CornerRadius = UDim.new(0, 8)

-- Thanh slider
local slider = Instance.new("Frame", sliderBG)
slider.Size = UDim2.new(0.16, 0, 1, 0)
slider.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
slider.Name = "SliderBar"

local sliderBarCorner = Instance.new("UICorner", slider)
sliderBarCorner.CornerRadius = UDim.new(0, 8)

-- Text hiển thị tốc độ
local speedText = Instance.new("TextLabel", frame)
speedText.Size = UDim2.new(1, 0, 0, 30)
speedText.Position = UDim2.new(0, 0, 0.65, 0)
speedText.BackgroundTransparency = 1
speedText.TextColor3 = Color3.new(1, 1, 1)
speedText.Font = Enum.Font.Gotham
speedText.TextSize = 18
speedText.Text = "Speed: 16"

-- Nút toggle ẩn/hiện
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
toggleBtn.Text = "-"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)

-- Logic toggle ẩn/hiện
local open = true
toggleBtn.MouseButton1Click:Connect(function()
	open = not open
	frame.Visible = open
	topBar.Visible = open
	toggleBtn.Text = open and "-" or "+"
end)

-- Slider logic (client-only)
local uis = game:GetService("UserInputService")

local function updateSpeed(x)
	local pos = math.clamp((x - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
	slider.Size = UDim2.new(pos, 0, 1, 0)
	local speed = math.floor(pos * 100)
	speedText.Text = "Speed: " .. speed
	humanoid.WalkSpeed = speed
end

sliderBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		updateSpeed(input.Position.X)
		local moveCon
		moveCon = uis.InputChanged:Connect(function(move)
			if move.UserInputType == Enum.UserInputType.MouseMovement then
				updateSpeed(move.Position.X)
			end
		end)
		uis.InputEnded:Connect(function(endInput)
			if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
				moveCon:Disconnect()
			end
		end)
	end
end)
