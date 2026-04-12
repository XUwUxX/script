local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if _G.FlingActive then
    _G.FlingActive = false
    return
end

_G.FlingActive = true

local function CreateFlingPart()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Tạo một Part đóng vai trò là vật gây va chạm
    local flingPart = Instance.new("Part")
    flingPart.Name = "FlingHitbox"
    flingPart.Size = Vector3.new(5, 5, 5) -- Độ rộng vùng ảnh hưởng
    flingPart.Transparency = 1
    flingPart.CanCollide = false
    flingPart.CanTouch = true
    flingPart.Parent = char

    local attachment = Instance.new("Attachment", flingPart)
    local alignPos = Instance.new("AlignPosition", flingPart)
    alignPos.Attachment0 = attachment
    alignPos.Attachment1 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
    alignPos.RigidityEnabled = true

    _G.FlingConnection = RunService.Heartbeat:Connect(function()
        if not _G.FlingActive or not char.Parent then
            flingPart:Destroy()
            _G.FlingConnection:Disconnect()
            return
        end
        
        -- Gán vận tốc cực đại cho Part này thay vì nhân vật
        flingPart.AssemblyLinearVelocity = Vector3.new(0, 99999, 0)
        flingPart.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
    end)
end

CreateFlingPart()
player.CharacterAdded:Connect(CreateFlingPart)
