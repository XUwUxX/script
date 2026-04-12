local WalkFling = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local connection
local player = Players.LocalPlayer

local function Notify(title, text)
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = 3
	})
end

function WalkFling:Start()
	if connection then return end
	
	Notify("Walk Fling", "Đã kích hoạt")

	connection = RunService.Heartbeat:Connect(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.new(0, 5000, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(10000, 10000, 10000)
			
			RunService.RenderStepped:Wait()
			
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
	end)
end

function WalkFling:Stop()
	if connection then
		connection:Disconnect()
		connection = nil
		Notify("Walk Fling", "Đã dừng")
	end
end

function WalkFling:IsRunning()
	return connection ~= nil
end

return WalkFling
