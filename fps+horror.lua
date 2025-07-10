-- StarterPlayerScripts/AutoPerfAndFireEffect.lua

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- 1. Cài đặt ánh sáng hoàng hôn sáng vừa đủ
pcall(function()
    Lighting.GlobalShadows = true
    Lighting.Brightness = 2
    Lighting.ClockTime = 18.5
    Lighting.EnvironmentDiffuseScale = 0.2
    Lighting.EnvironmentSpecularScale = 0.2
    Lighting.FogStart = 100
    Lighting.FogEnd = 1000
    Lighting.FogColor = Color3.fromRGB(255, 170, 127)
    Lighting.Ambient = Color3.fromRGB(255, 150, 120)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 120, 90)

    -- Xoá Sky cũ và Atmosphere nếu có
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") or v:IsA("Atmosphere") then
            v:Destroy()
        end
    end

    -- Tạo Sky hoàng hôn với texture đầy đủ
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://159454299"
    sky.SkyboxDn = "rbxassetid://159454296"
    sky.SkyboxFt = "rbxassetid://159454293"
    sky.SkyboxLf = "rbxassetid://159454286"
    sky.SkyboxRt = "rbxassetid://159454300"
    sky.SkyboxUp = "rbxassetid://159454288"
    sky.Parent = Lighting

    -- Tạo Atmosphere để làm mềm hoàng hôn nhưng không làm tối skybox
    local atmos = Instance.new("Atmosphere")
    atmos.Haze = 0.3
    atmos.Color = Color3.fromRGB(255,180,150)
    atmos.Parent = Lighting
end)

-- 2. Tắt sóng nước
pcall(function()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
    end
end)

-- 3. Giảm chất lượng hiển thị
pcall(function()
    settings().Rendering.MeshPartDrawDistance = 0
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level02
end)

-- 4. Tắt các hiệu ứng nặng (chỉ giữ lại Sky & Atmosphere)
local function disableEffects(parent)
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect")
        or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end
disableEffects(Lighting)
Lighting.DescendantAdded:Connect(function(v)
    disableEffects(v.Parent)
end)

-- 5. Tối ưu đối tượng game để giảm tải
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

-- 6. Giảm âm lượng chung
pcall(function()
    SoundService.Volume = 0.1
end)

-- 7. Tắt render khi mất focus
local function hasFocus()
    local ok, res = pcall(function()
        return UserInput:IsWindowFocused()
    end)
    return ok and res
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

-- 8. Hiệu ứng lửa dưới chân nhân vật
local function applyFootFire(char)
    local root = char:WaitForChild("HumanoidRootPart", 10)
    if not root then return end

    if root:FindFirstChild("FireAttachment") then
        root.FireAttachment:Destroy()
    end

    local attachment = Instance.new("Attachment")
    attachment.Name = "FireAttachment"
    attachment.Position = Vector3.new(0, -2.5, 0)
    attachment.Parent = root

    local fire = Instance.new("ParticleEmitter")
    fire.Name = "FootFire"
    fire.Texture = "rbxassetid://3021864529"
    fire.Rate = 60
    fire.Lifetime = NumberRange.new(0.4, 0.6)
    fire.Speed = NumberRange.new(1, 2)
    fire.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(1, 0)
    }
    fire.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    }
    fire.Color = ColorSequence.new(Color3.new(1, 0.4, 0), Color3.new(1, 1, 0))
    fire.VelocitySpread = 20
    fire.EmissionDirection = Enum.NormalId.Top
    fire.LightEmission = 0.6
    fire.LockedToPart = true
    fire.Parent = attachment
end
Players.LocalPlayer.CharacterAdded:Connect(applyFootFire)
if player.Character then
    applyFootFire(player.Character)
end
