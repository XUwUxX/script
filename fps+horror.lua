-- StarterPlayerScripts/ImprovedFootFire.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function applyFootFire(char)
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if not root then return end

    -- Xoá cũ nếu có
    if root:FindFirstChild("FootFireAttachment") then
        root.FootFireAttachment:Destroy()
    end

    local attach = Instance.new("Attachment")
    attach.Name = "FootFireAttachment"
    attach.Position = Vector3.new(0, -2.5, 0)
    attach.Parent = root

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "FootFire"
    emitter.Texture = "rbxasset://textures/particles/fire_main.dds"  -- texture lửa Roblox gốc :contentReference[oaicite:1]{index=1}

    emitter.Rate = 50
    emitter.Lifetime = NumberRange.new(0.4, 0.7)
    emitter.Speed = NumberRange.new(1, 2)
    emitter.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(1, 0)
    }
    emitter.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    }
    emitter.Color = ColorSequence.new(
        ColorSequenceKeypoint.new(0, Color3.new(1, 0.5, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0))
    )
    emitter.LightEmission = 1
    emitter.LightInfluence = 0
    emitter.EmissionDirection = Enum.NormalId.Top
    emitter.VelocitySpread = 15
    emitter.LockedToPart = true
    emitter.Parent = attach

    -- Tắt emitter khi đứng im để tiết kiệm
    emitter.Enabled = false

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        RunService.Stepped:Connect(function()
            if root.Velocity.Magnitude > 1 then
                emitter.Enabled = true
            else
                emitter.Enabled = false
            end
        end)
    end
end

player.CharacterAdded:Connect(applyFootFire)
if player.Character then
    applyFootFire(player.Character)
end
