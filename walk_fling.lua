-- Walk Fling Module
local WalkFling = {}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Internal state
local isFlinging = false
local flingThread

function WalkFling:Start()
	if isFlinging then return end
	isFlinging = true

	local movel = 0.1
	local player = Players.LocalPlayer

	flingThread = coroutine.create(function()
		while isFlinging do
			RunService.Heartbeat:Wait()

			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local vel = hrp.Velocity

				-- Gây va chạm cực mạnh
				hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
				RunService.RenderStepped:Wait()

				-- Reset lại vận tốc
				hrp.Velocity = vel
				RunService.Stepped:Wait()

				-- Nhún nhẹ để giữ động lực va chạm
				hrp.Velocity = vel + Vector3.new(0, movel, 0)
				movel = -movel
			end
		end
	end)

	coroutine.resume(flingThread)
end

function WalkFling:Stop()
	isFlinging = false
end

function WalkFling:IsRunning()
	return isFlinging
end

return WalkFling
