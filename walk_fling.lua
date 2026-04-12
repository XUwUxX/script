-- Chuyển đổi từ Module sang Script thực thi trực tiếp
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local connection = _G.FlingConnection -- Sử dụng _G để tránh trùng lặp khi chạy lại script

-- Hàm thông báo an toàn (tránh lỗi SetCore)
local function Notify(title, text)
	task.spawn(function()
		local success = false
		while not success do
			success = pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = title,
					Text = text,
					Duration = 3
				})
			end)
			task.wait(0.5)
		end
	end)
end

-- Dừng script cũ nếu đang chạy
if _G.FlingConnection then
	_G.FlingConnection:Disconnect()
	_G.FlingConnection = nil
	Notify("Walk Fling", "Đã dừng phiên bản cũ")
	return -- Thoát để bạn bấm Run lần nữa nếu muốn bật lại
end

-- Kích hoạt Fling
Notify("Walk Fling", "Đã kích hoạt")

_G.FlingConnection = RunService.Heartbeat:Connect(function()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	
	if hrp then
		-- Tối ưu vật lý để xuyên thấu va chạm (Fling)
		hrp.AssemblyLinearVelocity = Vector3.new(0, 10000, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(10000, 10000, 10000)
		
		RunService.RenderStepped:Wait()
		
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end
end)
