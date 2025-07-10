local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

local MAX_DIST = 120
local BULLET_SPEED = 850
local OVERPREDICT = 1.85
local ALPHA = 0.55
local MIN_SMOOTH = 0.2
local MAX_SMOOTH = 0.8
local ANGLE_SNAP = 3
local VEL_Y_THRESHOLD = 1.5
local CLOSE_DIST = 8
local CROSSHAIR_WEIGHT = 0.6
local FOV_LIMIT_DEG = 60
local SWITCH_DELAY = 0.1

local aimEnabled = false
local emaVel = Vector3.new()
local velInitialized = false
local lastTime = tick()
local lastTarget = nil
local lastSwitchTime = 0

-- 🔴 Vòng tròn đỏ chỉ mục tiêu
local aimDot = Instance.new("Part")
aimDot.Anchored = true
aimDot.CanCollide = false
aimDot.Size = Vector3.new(0.1, 0.1, 0.1)
aimDot.Transparency = 1
aimDot.Name = "__AimDot"
aimDot.Parent = Workspace

local bb = Instance.new("BillboardGui", aimDot)
bb.Size = UDim2.new(0, 12, 0, 12)
bb.AlwaysOnTop = true
bb.Name = "AimIndicator"
bb.Enabled = false

local frame = Instance.new("Frame", bb)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)

Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 1.8

StarterGui:SetCore("SendNotification", {
	Title = "Ultra Aimlock",
	Text = "Loaded for "..player.Name,
	Duration = 4,
})

-- Chuột phải bật/tắt
mouse.Button2Down:Connect(function()
	aimEnabled = true
	bb.Enabled = true
end)
mouse.Button2Up:Connect(function()
	aimEnabled = false
	bb.Enabled = false
end)

-- Cập nhật vận tốc (EMA)
local function updateEMAVel(part)
	local now = tick()
	local dt = now - lastTime
	lastTime = now

	local v = part.AssemblyLinearVelocity
	if dt > 0.5 then emaVel = v return end
	if not velInitialized then emaVel = v velInitialized = true
	else emaVel = emaVel * (1 - ALPHA) + v * ALPHA end
end

-- Dự đoán vị trí đạn sẽ đến
local function getPredictedPos(part)
	updateEMAVel(part)

	local camPos = camera.CFrame.Position
	local dist = (part.Position - camPos).Magnitude

	if dist < CLOSE_DIST then
		return part.Position -- Không dự đoán khi gần
	end

	local travel = (dist / BULLET_SPEED) * OVERPREDICT
	local horiz = Vector3.new(emaVel.X, 0, emaVel.Z)
	local base = part.Position + horiz * travel

	local jumping = math.abs(emaVel.Y) > VEL_Y_THRESHOLD
	local lowCeil = Workspace:Raycast(part.Position, Vector3.new(0, 5, 0)) ~= nil

	local y = (jumping or lowCeil or dist < 10)
		and part.Position.Y
		or (part.Position.Y + emaVel.Y * travel)

	return Vector3.new(base.X, y, base.Z)
end

-- Tìm mục tiêu tốt nhất
local function getSmartTarget()
	local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return end

	local best, bestScore = nil, math.huge
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= player and pl.Character then
			local part = pl.Character:FindFirstChild("LowerTorso") or pl.Character:FindFirstChild("HumanoidRootPart")
			local hum = pl.Character:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				local dist = (part.Position - myHRP.Position).Magnitude
				if dist <= MAX_DIST then
					local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local dx = math.abs(screenPos.X - camera.ViewportSize.X / 2)
						local dy = math.abs(screenPos.Y - camera.ViewportSize.Y / 2)
						local fovDist = math.sqrt(dx^2 + dy^2)
						local score = dist * (1 - CROSSHAIR_WEIGHT) + fovDist * CROSSHAIR_WEIGHT
						if score < bestScore then
							best, bestScore = part, score
						end
					end
				end
			end
		end
	end
	return best
end

-- Lấy độ mượt
local function getSmooth(dist)
	if dist < CLOSE_DIST then return 0 end
	local speedXZ = Vector3.new(emaVel.X, 0, emaVel.Z).Magnitude
	if math.abs(emaVel.Y) > VEL_Y_THRESHOLD then return MIN_SMOOTH end
	return speedXZ > 20 and MIN_SMOOTH or MAX_SMOOTH
end

-- Aim mỗi frame
RunService.RenderStepped:Connect(function()
	if not aimEnabled then return end

	local now = tick()
	local target = lastTarget
	if not target or now - lastSwitchTime > SWITCH_DELAY then
		target = getSmartTarget()
		lastTarget = target
		lastSwitchTime = now
	end
	if not target then return end

	local pred = getPredictedPos(target)
	local camPos = camera.CFrame.Position
	local wantDir = (pred - camPos).Unit
	local curDir = camera.CFrame.LookVector

	aimDot.Position = pred

	local angle = math.deg(math.acos(math.clamp(curDir:Dot(wantDir), -1, 1)))
	local dist = (target.Position - camPos).Magnitude
	if angle > FOV_LIMIT_DEG then return end

	if angle < ANGLE_SNAP or dist < CLOSE_DIST then
		camera.CFrame = CFrame.new(camPos, camPos + wantDir)
	else
		local smooth = getSmooth(dist)
		local newD = curDir:Lerp(wantDir, smooth)
		camera.CFrame = CFrame.new(camPos, camPos + newD)
	end
end)
