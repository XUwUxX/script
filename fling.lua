--== Ultimate Smart Fling Script ==--

--⚙️ Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--🧠 Cấu hình
local LocalPlayer = Players.LocalPlayer
local targetName = "PlayerNameHere" -- 👈 THAY TÊN NGƯỜI CHƠI Ở ĐÂY
local MAX_FLING_TIME = 5 -- Giới hạn thời gian fling
local FLING_FORCE = 10000
local CHECK_INTERVAL = 0.1

--🔍 Helper: Lấy HRP
local function getHRP(player)
	local char = player and player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

--🧠 Kiểm tra mục tiêu bị fling thật hay không
local function wasFlung(targetHRP)
	if not targetHRP then return false end
	local velocity = targetHRP.Velocity
	local speed = velocity.Magnitude
	local verticalSpeed = math.abs(velocity.Y)
	local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

	return speed > 90 and verticalSpeed < 60 and horizontalSpeed > 70
end

--⚡ Vòng lặp gây fling (dành cho nhân vật bạn)
local function applyFlingLoop(hrp)
	local movel = 0.1
	while true do
		if not hrp or not hrp.Parent then break end
		local vel = hrp.Velocity

		-- Gây lực cực mạnh
		hrp.Velocity = vel * FLING_FORCE + Vector3.new(
			math.random(-10000, 10000),
			10000,
			math.random(-10000, 10000)
		)

		RunService.RenderStepped:Wait()
		hrp.Velocity = vel
		RunService.Stepped:Wait()
		hrp.Velocity = vel + Vector3.new(0, movel, 0)
		movel = -movel
	end
end

--🎯 Fling mục tiêu
local function flingTarget()
	local targetPlayer = Players:FindFirstChild(targetName)
	if not targetPlayer then warn("❌ Không tìm thấy mục tiêu"); return end

	local myHRP = getHRP(LocalPlayer)
	local targetHRP = getHRP(targetPlayer)
	if not myHRP or not targetHRP then warn("❌ Không có HumanoidRootPart"); return end

	local originalCFrame = myHRP.CFrame

	-- Teleport vào người họ
	myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 0.5, 0)

	-- Bắt đầu fling
	local flingRunning = true
	local flingThread = coroutine.create(function()
		applyFlingLoop(myHRP)
	end)
	coroutine.resume(flingThread)

	-- Theo dõi mục tiêu
	local start = tick()
	while tick() - start < MAX_FLING_TIME and flingRunning do
		task.wait(CHECK_INTERVAL)
		if not targetHRP or not targetHRP.Parent then break end

		if wasFlung(targetHRP) then
			print("✅ Đối thủ đã bị fling:", targetHRP.Velocity)
			flingRunning = false
			break
		end
	end

	-- Dừng fling và quay lại
	pcall(function() coroutine.close(flingThread) end)
	myHRP.CFrame = originalCFrame
end

--🔥 Chạy
flingTarget()
