-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Mouse = Players.LocalPlayer:GetMouse()

-- GUI Container
local gui = Instance.new("ScreenGui")
gui.Name = "ResizableDraggableWindow"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main Window
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 300, 0, 200)
window.Position = UDim2.new(0.3, 0, 0.3, 0)
window.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
window.BorderSizePixel = 0
window.ClipsDescendants = false
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)

-- Drag Handle
local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(0, 66, 0, 5)
dragHandle.Position = UDim2.new(0.5, -33, 1, 6)
dragHandle.BackgroundColor3 = Color3.new(1, 1, 1)
dragHandle.BackgroundTransparency = 0.6
dragHandle.BorderSizePixel = 0
dragHandle.ZIndex = 2
dragHandle.Parent = window
Instance.new("UICorner", dragHandle).CornerRadius = UDim.new(0, 4)

-- Resize Wrapper
local resizeWrapper = Instance.new("Frame")
resizeWrapper.Size = UDim2.new(0, 16, 0, 16)
resizeWrapper.Position = UDim2.new(0, window.AbsoluteSize.X + 1, 0, window.AbsoluteSize.Y + 1)
resizeWrapper.BackgroundTransparency = 1
resizeWrapper.BorderSizePixel = 0
resizeWrapper.ZIndex = 3
resizeWrapper.Parent = window

-- Resize Bars (chữ L)
local horizontalBar = Instance.new("Frame")
horizontalBar.Size = UDim2.new(0, 13, 0, 3)
horizontalBar.Position = UDim2.new(0, 0, 1, -3)
horizontalBar.AnchorPoint = Vector2.new(0, 1)
horizontalBar.BackgroundColor3 = Color3.new(1, 1, 1)
horizontalBar.BackgroundTransparency = 0.6
horizontalBar.BorderSizePixel = 0
horizontalBar.Parent = resizeWrapper
Instance.new("UICorner", horizontalBar).CornerRadius = UDim.new(0, 5)

local verticalBar = Instance.new("Frame")
verticalBar.Size = UDim2.new(0, 3, 0, 13)
verticalBar.Position = UDim2.new(1, -3, 0, 0)
verticalBar.AnchorPoint = Vector2.new(1, 0)
verticalBar.BackgroundColor3 = Color3.new(1, 1, 1)
verticalBar.BackgroundTransparency = 0.6
verticalBar.BorderSizePixel = 0
verticalBar.Parent = resizeWrapper
Instance.new("UICorner", verticalBar).CornerRadius = UDim.new(0, 5)

-- Tween utility
local function fadeTo(frames, transparency)
	for _, f in ipairs(frames) do
		TweenService:Create(f, TweenInfo.new(0.12), {
			BackgroundTransparency = transparency
		}):Play()
	end
end

-- Hover + Drag + Touch setup
local function setupGlowAndDrag(frames, moveCallback)
	local dragging = false
	local startMouse, startValue
	local moveConn, endConn

	local function startDrag(input)
		if dragging then return end
		dragging = true
		startMouse = Vector2.new(Mouse.X, Mouse.Y)
		startValue = {
			pos = window.Position,
			size = window.Size
		}
		fadeTo(frames, 0)

		moveConn = RunService.RenderStepped:Connect(function()
			local delta = Vector2.new(Mouse.X, Mouse.Y) - startMouse
			moveCallback(delta, startValue)
		end)

		endConn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if moveConn then moveConn:Disconnect() end
				if endConn then endConn:Disconnect() end
				fadeTo(frames, 0.6)
			end
		end)
	end

	for _, frame in ipairs(frames) do
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				startDrag(input)
			end
		end)

		frame.MouseEnter:Connect(function()
			if not dragging then fadeTo(frames, 0) end
		end)

		frame.MouseLeave:Connect(function()
			if not dragging then fadeTo(frames, 0.6) end
		end)

		frame.TouchTap:Connect(function()
			if not dragging then fadeTo(frames, 0) end
		end)
	end
end

-- Drag logic
setupGlowAndDrag({dragHandle}, function(delta, start)
	window.Position = UDim2.new(
		start.pos.X.Scale,
		start.pos.X.Offset + delta.X,
		start.pos.Y.Scale,
		start.pos.Y.Offset + delta.Y
	)
end)

-- Resize logic
setupGlowAndDrag({horizontalBar, verticalBar}, function(delta, start)
	local newW = math.max(150, start.size.X.Offset + delta.X)
	local newH = math.max(100, start.size.Y.Offset + delta.Y)
	window.Size = UDim2.new(start.size.X.Scale, newW, start.size.Y.Scale, newH)
	resizeWrapper.Position = UDim2.new(0, newW + 1, 0, newH + 1)
end)

-- Update resizeWrapper position on size change
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	resizeWrapper.Position = UDim2.new(0, window.AbsoluteSize.X + 1, 0, window.AbsoluteSize.Y + 1)
end)
