-- StarterPlayerScripts/AutoPerfAndFix.lua
local CollectionService = game:GetService("CollectionService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local UserInput         = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local LogService        = game:GetService("LogService")
local SoundService      = game:GetService("SoundService")

local player = Players.LocalPlayer

-- Tag names
local TAG_EFFECT   = "__OptEff"
local TAG_OBJ      = "__OptObj"
local TAG_COLLIDER = "__OptColl"

-- 0. Clear console log (if supported)
pcall(function() LogService:Clear() end)

-- 1. Disable global shadows, fog and environment scales
pcall(function()
    Lighting.GlobalShadows            = false
    Lighting.FogStart                 = 0
    Lighting.FogEnd                   = 0
    Lighting.EnvironmentDiffuseScale  = 0
    Lighting.EnvironmentSpecularScale = 0
end)

-- 1b. Haunted / dark atmosphere
pcall(function()
    Lighting.Brightness       = 2
    Lighting.Ambient          = Color3.fromRGB(10, 10, 15)
    Lighting.OutdoorAmbient   = Color3.fromRGB(5, 5, 10)
    Lighting.FogColor         = Color3.fromRGB(15, 15, 20)
    Lighting.FogStart         = 2
    Lighting.FogEnd           = 100
    Lighting.GlobalShadows    = true
    -- Add haunted skybox
    local sky = Instance.new("Sky")
    sky.Name   = "__HauntedSky"
    local skyId = "rbxassetid://393891820"
    sky.SkyboxBk = skyId
    sky.SkyboxDn = skyId
    sky.SkyboxFt = skyId
    sky.SkyboxLf = skyId
    sky.SkyboxRt = skyId
    sky.SkyboxUp = skyId
    sky.Parent = Lighting
end)

-- 2. Disable water waves on Terrain
pcall(function()
    local t = Workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterWaveSize  = 0
        t.WaterWaveSpeed = 0
    end
end)

-- 3. Mute all sounds
pcall(function() SoundService.Volume = 0 end)

-- 4. Reduce mesh draw distance
pcall(function() settings().Rendering.MeshPartDrawDistance = 0 end)

-- 5. Degrade high‑quality meshes & appearances
local function degradeHighQuality(v)
    if CollectionService:HasTag(v, TAG_OBJ) then return end
    if v:IsA("SpecialMesh") then
        pcall(function()
            v.Scale    = Vector3.new(0.1, 0.1, 0.1)
            v.MeshType = Enum.MeshType.Brick
        end)
        CollectionService:AddTag(v, TAG_OBJ)
    elseif v:IsA("SurfaceAppearance") then
        pcall(function()
            v.ColorMap  = nil
            v.NormalMap = nil
        end)
        CollectionService:AddTag(v, TAG_OBJ)
    elseif v:IsA("UnionOperation") then
        pcall(function()
            v.Material    = Enum.Material.Plastic
            v.Reflectance = 0
        end)
        CollectionService:AddTag(v, TAG_OBJ)
    end
end

-- 6. Disable post‑processing effects
local disableFX = {
    "BlurEffect", "SunRaysEffect", "ColorCorrectionEffect",
    "BloomEffect", "DepthOfFieldEffect"
}
local function optimizeEffect(e)
    if CollectionService:HasTag(e, TAG_EFFECT) then return end
    for _, cls in ipairs(disableFX) do
        if e:IsA(cls) then
            e.Enabled = false
            CollectionService:AddTag(e, TAG_EFFECT)
            return
        end
    end
end

-- 7. Optimize parts, decals, particles (skip RenderFidelity)
local function optimizeObj(v)
    if CollectionService:HasTag(v, TAG_OBJ) then return end

    -- skip SolidModel entirely
    if v.ClassName == "SolidModel" then
        CollectionService:AddTag(v, TAG_OBJ)
        return
    end

    local ok
    if v:IsA("MeshPart") then
        ok = pcall(function()
            v.CastShadow   = false
            v.CanQuery     = false
            v.CanCollide   = false
        end)
    elseif v:IsA("BasePart") then
        ok = pcall(function()
            v.Material    = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow  = false
            v.CanQuery    = false
        end)
    elseif v:IsA("Decal") or v:IsA("Texture") then
        ok = pcall(function() v.Transparency = 1 end)
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        ok = pcall(function() v.Enabled = false end)
    end

    if ok then
        CollectionService:AddTag(v, TAG_OBJ)
    end
end

-- 8. Set initial QualityLevel and hook attribute for toggling
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
player:GetAttributeChangedSignal("AutoPerfEnabled"):Connect(function()
    local on = player:GetAttribute("AutoPerfEnabled")
    pcall(function()
        settings().Rendering.QualityLevel = on and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end)
end)

-- 9. Apply optimizations on existing and new descendants
for _, e in ipairs(Lighting:GetDescendants()) do
    optimizeEffect(e)
end
Lighting.DescendantAdded:Connect(optimizeEffect)

for _, v in ipairs(Workspace:GetDescendants()) do
    optimizeObj(v)
    degradeHighQuality(v)
end
Workspace.DescendantAdded:Connect(function(v)
    optimizeObj(v)
    degradeHighQuality(v)
end)

-- 10. Focus‑based rendering/FPS cap
local function hasFocus()
    local ok, res = pcall(function() return UserInput:IsWindowFocused() end)
    return ok and res or true
end
local function disableRender()
    RunService:Set3dRenderingEnabled(false)
    pcall(setfpscap, 10)
end
local function enableRender()
    RunService:Set3dRenderingEnabled(true)
    pcall(setfpscap, 0)
end

UserInput.WindowFocusReleased:Connect(disableRender)
UserInput.WindowFocused:Connect(enableRender)
if hasFocus() then enableRender() else disableRender() end

-- 11. Prevent thin‑object clipping with hidden colliders
local RAY_LENGTH = 5
local function protectThin(item)
    if not (item:IsA("BasePart") and item.Size.Y < 0.5) then return end
    if CollectionService:HasTag(item, TAG_COLLIDER) then return end
    CollectionService:AddTag(item, TAG_COLLIDER)

    local collider = Instance.new("Part")
    collider.Name         = "__Collider"
    collider.Size         = Vector3.new(item.Size.X, 0.3, item.Size.Z)
    collider.Transparency = 1
    collider.CanCollide   = true
    collider.CanTouch     = false
    collider.Massless     = true
    collider.Anchored     = false
    collider.CFrame       = item.CFrame
    collider.Parent       = Workspace
    collider:SetNetworkOwner(nil)

    local weld = Instance.new("WeldConstraint", collider)
    weld.Part0, weld.Part1 = collider, item

    item.AncestryChanged:Connect(function(_, parent)
        if not parent then collider:Destroy() end
    end)

    local lastTime, lastVel = 0, Vector3.new()
    item:GetPropertyChangedSignal("AssemblyLinearVelocity"):Connect(function()
        local now = time()
        if now - lastTime < 0.2 then return end
        lastTime = now

        local vel = item.AssemblyLinearVelocity
        if lastVel.Magnitude > 2 and vel.Magnitude < 0.5 then
            local result = Workspace:Raycast(
                item.Position,
                Vector3.new(0, -(RAY_LENGTH + item.Size.Y / 2), 0)
            )
            if result and result.Position then
                item.CFrame = CFrame.new(result.Position + Vector3.new(0, item.Size.Y / 2, 0))
                item.AssemblyLinearVelocity = Vector3.zero
            end
        end
        lastVel = vel
    end)
end

for _, v in ipairs(Workspace:GetDescendants()) do protectThin(v) end
Workspace.DescendantAdded:Connect(protectThin)
