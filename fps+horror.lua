local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- 🌅 Hoàng hôn sáng + Skybox đẹp
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

    -- Xóa Sky & Atmosphere cũ
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") or v:IsA("Atmosphere") then
            v:Destroy()
        end
    end

    -- Tạo Sky mới
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://159454299"
    sky.SkyboxDn = "rbxassetid://159454296"
    sky.SkyboxFt = "rbxassetid://159454293"
    sky.SkyboxLf = "rbxassetid://159454286"
    sky.SkyboxRt = "rbxassetid://159454300"
    sky.SkyboxUp = "rbxassetid://159454288"
    sky.Parent = Lighting

    -- Atmosphere tạo chiều sâu nhưng không tối trời
    local atmos = Instance.new("Atmosphere")
    atmos.Haze = 0.3
    atmos.Color = Color3.fromRGB(255, 180, 150)
    atmos.Parent = Lighting
end)

-- 🌊 Tắt sóng nước
pcall(function()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
    end
end)

-- 🔧 Giảm chất lượng đồ họa
pcall(function()
    settings().Rendering.MeshPartDrawDistance = 0
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level02
end)

-- 🧹 Tắt hiệu ứng ánh sáng nặng (trừ Sky)
local function disableEffects(parent)
    for _, v in ipairs(parent:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end
disableEffects(Lighting)
Lighting.DescendantAdded:Connect(function(v)
    disableEffects(v.Parent)
end)

-- 🧱 Tối ưu vật thể trong Workspace
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

-- 🔇 Giảm âm lượng toàn bộ
pcall(function()
    SoundService.Volume = 0.1
end)

-- 🪟 Tắt render khi mất cửa sổ
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

-- 🔥 Lửa dưới chân tối ưu hóa
local currentEmitter
local humanoid
local hrp

local function createFootFireEmitter(root)
    if root:FindFirstChild("FireAttachment") then
        root.FireAttachment:Destroy()
    end

    local att = Instance.new("Attachment")
    att.Name = "FireAttachment"
    att.Position = Vector3.new(0, -2.5, 0)
    att.Parent = root

    local emit = Instance.new("ParticleEmitter")
    emit.Name = "FootFire"
    emit.Texture = "rbxassetid://3021864529"
    emit.Rate = 20 -- thấp để tối ưu
    emit.Lifetime = NumberRange.new(0.3, 0.5)
    emit.Speed = NumberRange.new(1, 2)
    emit.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(1, 0)
    }
    emit.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    }
    emit.Color = ColorSequence.new(Color3.new(1, 0.4, 0), Color3.new(1, 1, 0))
    emit.LightEmission = 0.4
    emit.LockedToPart = true
    emit.Enabled = false
    emit.Parent = att
    return emit
end

local function onCharacterAdded(char)
    hrp = char:WaitForChild("HumanoidRootPart", 10)
    humanoid = char:WaitForChild("Humanoid", 10)
    if hrp then
        currentEmitter = createFootFireEmitter(hrp)
    end
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- Theo dõi di chuyển để bật/tắt lửa
RunService.RenderStepped:Connect(function()
    if currentEmitter and humanoid and hrp then
        local moving = humanoid.MoveDirection.Magnitude > 0.1 and humanoid.FloorMaterial ~= Enum.Material.Air
        currentEmitter.Enabled = moving
    end
end)
