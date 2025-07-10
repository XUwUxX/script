-- StarterPlayerScripts/AutoPerfAndFireEffect.lua

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- 1. Tối ưu ánh sáng
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.FogStart = 0
    Lighting.FogEnd = 0
    Lighting.FogColor = Color3.new(0,0,0)
    Lighting.Ambient = Color3.new(0,0,0)
    Lighting.OutdoorAmbient = Color3.new(0,0,0)
    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
end)

-- 2. Tắt sóng nước
pcall(function()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
    end
end)

-- 3. Giảm chất lượng
pcall(function()
    settings().Rendering.MeshPartDrawDistance = 0
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- 4. Tắt hiệu ứng ánh sáng
local function disableEffects()
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect")
        or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end
disableEffects()
Lighting.DescendantAdded:Connect(disableEffects)

-- 5. Tối ưu đối tượng
local function optimizeObject(obj)
    if CollectionService:HasTag(obj, "__Optimized") then return end

    if obj:IsA("BasePart") then
        pcall(function()
            obj.CastShadow = false
            obj.Reflectance = 0
            obj.Material = Enum.Material.Plastic
            obj.CanQuery = false
        end)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        pcall(function() obj.Transparency = 1 end)
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        pcall(function() obj.Enabled = false end)
    elseif obj:IsA("SurfaceAppearance") then
        pcall(function() obj:Destroy() end)
    end

    CollectionService:AddTag(obj, "__Optimized")
end

for _, v in ipairs(Workspace:GetDescendants()) do
    optimizeObject(v)
end
Workspace.DescendantAdded:Connect(optimizeObject)

-- 6. Giảm âm lượng
pcall(function()
    SoundService.Volume = 0.1
end)

-- 7. Tắt render khi mất cửa sổ
local function hasFocus()
    local ok, res = pcall(function()
        return UserInput:IsWindowFocused()
    end)
    return ok and res or true
end

local function disableRender()
    RunService:Set3dRenderingEnabled(false)
    pcall(function() setfpscap(10) end)
end

local function enableRender()
    RunService:Set3dRenderingEnabled(true)
    pcall(function() setfpscap(0) end)
end

UserInput.WindowFocusReleased:Connect(disableRender)
UserInput.WindowFocused:Connect(enableRender)
if hasFocus() then enableRender() else disableRender() end

-- 8. 🔥 Hiệu ứng lửa dưới chân
player.CharacterAdded:Connect(function(char)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    -- Attachment dưới chân
    local attachment = Instance.new("Attachment")
    attachment.Name = "FireAttachment"
    attachment.Position = Vector3.new(0, -2.5, 0)
    attachment.Parent = root

    -- ParticleEmitter ngọn lửa
    local fire = Instance.new("ParticleEmitter")
    fire.Name = "FootFire"
    fire.Texture = "rbxassetid://3021864529"
    fire.Rate = 60
    fire.Lifetime = NumberRange.new(0.4, 0.6)
    fire.Speed = NumberRange.new(1, 2)
    fire.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(1, 0)
    })
    fire.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    fire.Color = ColorSequence.new(Color3.new(1, 0.4, 0), Color3.new(1, 1, 0))
    fire.VelocitySpread = 20
    fire.EmissionDirection = Enum.NormalId.Top
    fire.LightEmission = 0.6
    fire.LockedToPart = true
    fire.Parent = attachment
end)

-- Nếu đã spawn trước khi chạy script
if player.Character then
    player.Character:Destroy() -- reset để chạy lại CharacterAdded
end
