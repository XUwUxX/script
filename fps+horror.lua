local Players = game:GetService("Players")
local Debris  = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local charAddedConn

local function makeGUI()
	local old = player.PlayerGui:FindFirstChild("SelfFlingGUI")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui", player.PlayerGui)
	gui.Name = "SelfFlingGUI"
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 200, 0, 130)
	frame.Position = UDim2.new(0.75, 0, 0.35, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.3
	frame.Active = true
	frame.Draggable = true
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Thickness = 1

	local title = Instance.new("TextLabel", frame)
	title.Text = "🚀 Self‑Fling"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -30, 0, 28)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local btnClose = Instance.new("TextButton", frame)
	btnClose.Text = "X"
	btnClose.Font = Enum.Font.GothamBold
	btnClose.TextSize = 16
	btnClose.Size = UDim2.new(0, 24, 0, 24)
	btnClose.Position = UDim2.new(1, -28, 0, 2)
	btnClose.BackgroundTransparency = 1
	btnClose.TextColor3 = Color3.fromRGB(220, 220, 220)
	btnClose.MouseButton1Click:Connect(function()
		gui:Destroy()
		if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
	end)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local content = Instance.new("Frame", frame)
	content.Size = UDim2.new(1, -20, 1, -40)
	content.Position = UDim2.new(0, 10, 0, 30)
	content.BackgroundTransparency = 1
	layout.Parent = content

	local txtStrength = Instance.new("TextBox", content)
	txtStrength.PlaceholderText = "160"
	txtStrength.Text = "160"
	txtStrength.Font = Enum.Font.Gotham
	txtStrength.TextSize = 14
	txtStrength.TextColor3 = Color3.fromRGB(255, 255, 255)
	txtStrength.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	txtStrength.BackgroundTransparency = 0.1
	txtStrength.Size = UDim2.new(1, 0, 0, 30)
	txtStrength.ClearTextOnFocus = false
	Instance.new("UICorner", txtStrength).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", txtStrength).Color = Color3.fromRGB(80, 80, 80)

	local btnFling = Instance.new("TextButton", content)
	btnFling.Text = "FLING!"
	btnFling.Font = Enum.Font.GothamBold
	btnFling.TextSize = 16
	btnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnFling.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btnFling.Size = UDim2.new(1, 0, 0, 36)
	Instance.new("UICorner", btnFling).CornerRadius = UDim.new(0, 6)
	local flingStroke = Instance.new("UIStroke", btnFling)
	flingStroke.Color = Color3.fromRGB(130, 20, 20)
	local grad = Instance.new("UIGradient", btnFling)
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 70, 70)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 40, 40))
	})

	local defaultText = btnFling.Text
	local defaultColor = btnFling.BackgroundColor3

	btnFling.MouseButton1Click:Connect(function()
		grad:Destroy()
		btnFling.Text = "🚀"
		btnFling.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end

		local strength = tonumber(txtStrength.Text) or 160

		local gyro = Instance.new("BodyGyro")
		gyro.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) -- nằm ngang
		gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		gyro.P = 1e4
		gyro.Parent = hrp
		Debris:AddItem(gyro, 0.1)

		local bv = Instance.new("BodyVelocity")
		bv.Velocity = Vector3.new(0, strength, 0)
		bv.MaxForce = Vector3.new(0, 1e5, 0)
		bv.Parent = hrp
		Debris:AddItem(bv, 0.3)

		task.delay(0.3, function()
			btnFling.Text = defaultText
			btnFling.BackgroundColor3 = defaultColor
			local newGrad = Instance.new("UIGradient", btnFling)
			newGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 70, 70)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 40, 40))
			})
		end)
	end)
end

charAddedConn = player.CharacterAdded:Connect(makeGUI)
if player.Character then makeGUI() end
