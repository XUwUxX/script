-- Kevinz Hub Full Script v1.36 (Sidebar Tab UI with Emoji Icons, Integrated Logic)
-- LocalScript chạy client, ví dụ đặt trong StarterPlayerScripts hoặc StarterGui

-- ================= Services =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Workspace = workspace

-- ================= Biến toàn cục =================
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart = nil, nil, nil
local Camera = Workspace.CurrentCamera

-- Phiên bản
local HUB_VERSION = "v1.36"

-- Movement defaults
local savedWalkSpeed = 16
local savedJumpPower = 50
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    local hum0 = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum0 then
        savedWalkSpeed = hum0.WalkSpeed or savedWalkSpeed
        savedJumpPower = hum0.JumpPower or savedJumpPower
    end
end

-- Semi-God
local semiGodModeEnabled = false

-- Gun Aura state (chỉ pick-up logic)
local gunAuraEnabled = false
local gunAuraRadius = 10
local gunDrops = {}           -- [dropInstance] = true
local gunDropTouchedConns = {}-- [dropInstance] = connection
local gunAuraLoopThread = nil

-- ESP Highlight GunDrop state
local gunDropHighlights = {}  -- [dropInstance] = {highlight = Highlight, billboard = BillboardGui}
local espGlobalConns = {
    playerAdded = nil,
    renderStepped = nil,
    gunDropAdded = nil,
    gunDropRemoving = nil,
}

-- Lower CPU load state
local lowerCpuApplied = false
local lowerCpuConn = nil  -- để disconnect DescendantAdded khi tắt

-- Caching localRole
local localRole = "Unknown"

-- Optimize Performance state
local midnightEnabled = false
local fpsBoosterEnabled = false

-- Lưu original Lighting settings để restore
local originalLightingSettings = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}
local originalLightingEffects = {}
for _, eff in ipairs(Lighting:GetDescendants()) do
    if eff:IsA("PostEffect") or eff:IsA("Atmosphere") then
        originalLightingEffects[eff] = eff.Enabled
    end
end

-- ================= Notification helper =================
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
            Button1 = "OK"
        })
    end)
end

task.delay(1, function()
    notify("Kevinz Hub Loaded ✅", "Version: " .. HUB_VERSION, 4)
end)

-- ================= Role Detection Helper =================
local function updateLocalRole()
    local hasKnife = false
    local hasGun = false
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("blade") then hasKnife = true end
                if n:find("gun") or n:find("revolver") then hasGun = true end
            end
        end
    end
    if Character then
        for _, child in ipairs(Character:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("knife") or n:find("blade") then hasKnife = true end
                if n:find("gun") or n:find("revolver") then hasGun = true end
            end
        end
    end
    local newRole
    if hasKnife and not hasGun then
        newRole = "Murderer"
    elseif hasGun and not hasKnife then
        newRole = "SheriffOrHero"
    elseif not hasGun and not hasKnife then
        newRole = "Innocent"
    else
        newRole = "Unknown"
    end
    if newRole ~= localRole then
        localRole = newRole
        --notify("Role Changed", "Bạn hiện là " .. localRole, 2)
    end
end

local function setupLocalRoleListeners()
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                updateLocalRole()
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                updateLocalRole()
            end
        end)
        updateLocalRole()
    end)
    if LocalPlayer:FindFirstChild("Backpack") then
        LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then updateLocalRole() end
        end)
        LocalPlayer.Backpack.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then updateLocalRole() end
        end)
    end
    if LocalPlayer.Character then
        Character = LocalPlayer.Character
        updateLocalRole()
    end
end
setupLocalRoleListeners()

-- ================= Character/Humanoid Setup =================
local function onCharacterAdded(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if Humanoid then
        pcall(function() Humanoid.WalkSpeed = savedWalkSpeed end)
        pcall(function() Humanoid.JumpPower = savedJumpPower end)
        Humanoid.HealthChanged:Connect(function(h)
            if semiGodModeEnabled and Humanoid and Humanoid.Parent and h <= 0 then
                Humanoid.Health = 1
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                task.delay(2.5, function()
                    if Humanoid and Humanoid.Parent and Humanoid:GetState() == Enum.HumanoidStateType.Physics then
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end)
            end
        end)
    end

    -- Reset GunAura khi respawn
    for drop, conn in pairs(gunDropTouchedConns) do
        if conn then conn:Disconnect() end
    end
    table.clear(gunDropTouchedConns)
    table.clear(gunDrops)

    -- Highlight đường đạn local player
    Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            local toolName = child.Name:lower()
            if toolName:find("gun") or toolName:find("revolver") then
                child.Equipped:Connect(function()
                    child.Activated:Connect(function()
                        if not Camera then Camera = Workspace.CurrentCamera end
                        local origin = Camera.CFrame.Position
                        local direction = Camera.CFrame.LookVector * 500
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local result = Workspace:Raycast(origin, direction, rayParams)
                        local hitPos
                        if result and result.Position then
                            hitPos = result.Position
                        else
                            hitPos = origin + direction
                        end
                        local diff = hitPos - origin
                        local distance = diff.Magnitude
                        local part = Instance.new("Part")
                        part.Name = "_BulletPath"
                        part.Anchored = true
                        part.CanCollide = false
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.new(1, 0, 0)
                        part.Transparency = 0.5
                        part.Size = Vector3.new(0.1, 0.1, distance)
                        part.CFrame = CFrame.new(origin, hitPos) * CFrame.new(0, 0, -distance/2)
                        part.Parent = Workspace
                        Debris:AddItem(part, 0.5)
                    end)
                end)
            end
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- ================= Weapon Highlight Helper =================
local weaponHighlights = {}  -- [player] = { [toolInstance] = highlight }
local function addWeaponHighlight(player, toolInstance)
    if not toolInstance or not toolInstance:IsA("Tool") then return end
    if not weaponHighlights[player] then weaponHighlights[player] = {} end
    if weaponHighlights[player][toolInstance] then return end
    local nameLower = toolInstance.Name:lower()
    local color = Color3.fromRGB(255, 255, 255)
    if nameLower:find("knife") or nameLower:find("blade") then
        color = Color3.fromRGB(255, 0, 255)
    elseif nameLower:find("gun") or nameLower:find("revolver") then
        color = Color3.fromRGB(0, 200, 255)
    end
    local handle = toolInstance:FindFirstChildWhichIsA("BasePart") or toolInstance:FindFirstChild("Handle")
    if not handle then return end
    local hl = Instance.new("Highlight")
    hl.Name = "_ESP_WEAPON"
    hl.FillTransparency = 1
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = handle
    hl.Parent = handle
    weaponHighlights[player][toolInstance] = hl
end

local function clearWeaponHighlightsForPlayer(player)
    local tbl = weaponHighlights[player]
    if tbl then
        for toolInst, hl in pairs(tbl) do
            if hl and hl.Parent then hl:Destroy() end
        end
    end
    weaponHighlights[player] = nil
end

-- ================= ESP Logic (Dot ESP + Weapon + GunDrop Highlight) =================
local roleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(0, 89, 255),
    Hero = Color3.fromRGB(255, 255, 0),
    Innocent = Color3.fromRGB(50, 255, 80),
    Unknown = Color3.fromRGB(180, 180, 180),
}

local roundSheriffUserId = nil
local roundActive = false
local roundId = 0

local function detectRoundReset()
    local everyoneInnocent = true
    for _, p in ipairs(Players:GetPlayers()) do
        local hasKnife, hasGun = false, false
        local backpack = p:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    if n:find("knife") or n:find("blade") then hasKnife = true end
                    if n:find("gun") or n:find("revolver") then hasGun = true end
                end
            end
        end
        for _, tool in ipairs((p.Character and p.Character:GetChildren()) or {}) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("blade") then hasKnife = true end
                if n:find("gun") or n:find("revolver") then hasGun = true end
            end
        end
        if hasKnife or hasGun then
            everyoneInnocent = false
            break
        end
    end
    if everyoneInnocent then
        roundSheriffUserId = nil
        roundActive = false
        roundId = roundId + 1
    end
end

local function monitorSheriffAssignment()
    for _, p in ipairs(Players:GetPlayers()) do
        local backpack = p:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    if n:find("gun") or n:find("revolver") then
                        if not roundSheriffUserId and not roundActive then
                            roundSheriffUserId = p.UserId
                            roundActive = true
                        end
                    end
                end
            end
        end
    end
end

local function getRole(player)
    local hasKnife, hasGun = false, false
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("blade") then hasKnife = true end
                if n:find("gun") or n:find("revolver") then hasGun = true end
            end
        end
    end
    for _, tool in ipairs((player.Character and player.Character:GetChildren()) or {}) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("blade") then hasKnife = true end
            if n:find("gun") or n:find("revolver") then hasGun = true end
        end
    end
    if hasKnife and not hasGun then
        return "Murderer"
    elseif hasGun and not hasKnife then
        if roundSheriffUserId and player.UserId == roundSheriffUserId and roundActive then
            return "Sheriff"
        elseif roundSheriffUserId and player.UserId ~= roundSheriffUserId and roundActive then
            return "Hero"
        else
            return "Unknown"
        end
    elseif not hasKnife and not hasGun then
        return "Innocent"
    else
        return "Unknown"
    end
end

local function updateDotESP(player)
    if not player or player == LocalPlayer then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local role = getRole(player)
    local color = roleColors[role] or roleColors.Unknown
    local head = char.Head

    local guiESP = head:FindFirstChild("DotESP")
    if not guiESP then
        guiESP = Instance.new("BillboardGui")
        guiESP.Name = "DotESP"
        guiESP.Adornee = head
        guiESP.Size = UDim2.new(0, 12, 0, 12)
        guiESP.AlwaysOnTop = true
        guiESP.LightInfluence = 0
        guiESP.StudsOffset = Vector3.new(0, 1, 0)
        guiESP.Parent = head

        local frame = Instance.new("Frame")
        frame.Name = "Dot"
        frame.BackgroundColor3 = color
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.AnchorPoint = Vector2.new(0.5,0.5)
        frame.Position = UDim2.new(0.5,0,0.5,0)
        frame.Size = UDim2.new(1,0,1,0)
        frame.Parent = guiESP
    else
        local frame = guiESP:FindFirstChild("Dot")
        if frame then
            frame.BackgroundColor3 = color
        end
    end
end

local function clearDotESP(player)
    if not player then return end
    if player.Character and player.Character:FindFirstChild("Head") then
        local e = player.Character.Head:FindFirstChild("DotESP")
        if e then e:Destroy() end
    end
end

local playerESPConns = {}  -- [player] = { ... }

local function setupESPForPlayer(player)
    if not player or player == LocalPlayer then return end
    local conns = {}
    playerESPConns[player] = conns

    local function onCharAdded(char)
        char:WaitForChild("Head", 5)
        updateDotESP(player)
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                task.delay(0.1, function()
                    addWeaponHighlight(player, child)
                end)
            end
        end
        local childAddedConn = char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.delay(0.1, function()
                    addWeaponHighlight(player, child)
                    updateDotESP(player)
                end)
            end
        end)
        local childRemovedConn = char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                if weaponHighlights[player] and weaponHighlights[player][child] then
                    local hl = weaponHighlights[player][child]
                    if hl and hl.Parent then hl:Destroy() end
                    weaponHighlights[player][child] = nil
                end
                updateDotESP(player)
            end
        end)
        table.insert(conns, childAddedConn)
        table.insert(conns, childRemovedConn)
    end

    local charAddedConn = player.CharacterAdded:Connect(onCharAdded)
    table.insert(conns, charAddedConn)
    if player.Character and player.Character:FindFirstChild("Head") then
        onCharAdded(player.Character)
    end

    local function connectBackpack(bp)
        if bp then
            local added = bp.ChildAdded:Connect(function(child)
                updateDotESP(player)
            end)
            local removed = bp.ChildRemoved:Connect(function(child)
                updateDotESP(player)
            end)
            table.insert(conns, added)
            table.insert(conns, removed)
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        connectBackpack(backpack)
    end
    local childAddedConnBP = player.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then
            connectBackpack(child)
        end
    end)
    table.insert(conns, childAddedConnBP)
end

local function teardownESPForPlayer(player)
    if not player then return end
    local conns = playerESPConns[player]
    if conns then
        for _, conn in ipairs(conns) do
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end
    end
    playerESPConns[player] = nil
    clearDotESP(player)
    clearWeaponHighlightsForPlayer(player)
end

local espEnabled = false

-- Highlight GunDrop Helper
local function addGunDropHighlight(drop)
    if not drop or not drop:IsA("BasePart") then return end
    if gunDropHighlights[drop] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "_ESP_GUNDROP_HL"
    hl.Adornee = drop
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = drop

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "_ESP_GUNDROP_BILLBOARD"
    billboard.Adornee = drop
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Parent = drop

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "GunDropLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Gun drop here"
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 24
    textLabel.TextScaled = false
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    gunDropHighlights[drop] = {highlight = hl, billboard = billboard}
end

local function removeGunDropHighlight(drop)
    local data = gunDropHighlights[drop]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        gunDropHighlights[drop] = nil
    end
end

local function enableESP()
    if espEnabled then return end
    espEnabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupESPForPlayer(player)
        end
    end
    espGlobalConns.playerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            setupESPForPlayer(player)
        end
    end)
    espGlobalConns.renderStepped = RunService.RenderStepped:Connect(function()
        detectRoundReset()
        monitorSheriffAssignment()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updateDotESP(player)
            end
        end
    end)
    -- GunDrop highlight
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            addGunDropHighlight(obj)
        end
    end
    espGlobalConns.gunDropAdded = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            addGunDropHighlight(obj)
        end
    end)
    espGlobalConns.gunDropRemoving = Workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            removeGunDropHighlight(obj)
        end
    end)
    notify("ESP Enabled", "Dot ESP & GunDrop highlight đã bật.", 3)
end

local function disableESP()
    if not espEnabled then return end
    espEnabled = false
    if espGlobalConns.playerAdded then espGlobalConns.playerAdded:Disconnect(); espGlobalConns.playerAdded = nil end
    if espGlobalConns.renderStepped then espGlobalConns.renderStepped:Disconnect(); espGlobalConns.renderStepped = nil end
    if espGlobalConns.gunDropAdded then espGlobalConns.gunDropAdded:Disconnect(); espGlobalConns.gunDropAdded = nil end
    if espGlobalConns.gunDropRemoving then espGlobalConns.gunDropRemoving:Disconnect(); espGlobalConns.gunDropRemoving = nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            teardownESPForPlayer(player)
        end
    end
    for drop, _ in pairs(gunDropHighlights) do
        removeGunDropHighlight(drop)
    end
    notify("ESP Disabled", "Dot ESP & GunDrop highlight đã tắt.", 3)
end

-- ================= Death Notification =================
local function setupDeathNotification(player)
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                local role = getRole(player)
                if role == "Sheriff" or role == "Hero" or role == "Murderer" then
                    notify(role .. " Died", player.Name .. " (" .. role .. ") đã chết.", 4)
                end
            end)
        end
    end)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character:FindFirstChild("Humanoid")
        hum.Died:Connect(function()
            local role = getRole(player)
            if role == "Sheriff" or role == "Hero" or role == "Murderer" then
                notify(role .. " Died", player.Name .. " (" .. role .. ") đã chết.", 4)
            end
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupDeathNotification(player)
end
Players.PlayerAdded:Connect(setupDeathNotification)

-- ================= Optimize Midnight Sky & Lower CPU Load =================
local function applyMidnightSky()
    Lighting.ClockTime = 0
    Lighting.Brightness = 35
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    Lighting.FogColor = Color3.new(0, 0, 0)
    Lighting.FogStart = 0
    Lighting.FogEnd = 1e3
    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            pcall(function() child:Destroy() end)
        end
    end
    Lighting.DescendantAdded:Connect(function(obj)
        if obj:IsA("Sky") then
            pcall(function() obj:Destroy() end)
        end
    end)
    -- Disable PostEffects
    for _, eff in ipairs(Lighting:GetDescendants()) do
        if eff:IsA("BloomEffect")
        or eff:IsA("SunRaysEffect")
        or eff:IsA("ColorCorrectionEffect")
        or eff:IsA("BlurEffect")
        or eff:IsA("ToneMapEffect")
        or eff:IsA("DepthOfFieldEffect")
        or eff:IsA("Atmosphere")
        then
            pcall(function() eff.Enabled = false end)
        end
    end
    notify("Midnight Sky", "Áp dụng Midnight Sky.", 3)
end

local function restoreOriginalSky()
    pcall(function() Lighting.ClockTime = originalLightingSettings.ClockTime end)
    pcall(function() Lighting.Brightness = originalLightingSettings.Brightness end)
    pcall(function() Lighting.Ambient = originalLightingSettings.Ambient end)
    pcall(function() Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient end)
    pcall(function() Lighting.FogColor = originalLightingSettings.FogColor end)
    pcall(function() Lighting.FogStart = originalLightingSettings.FogStart end)
    pcall(function() Lighting.FogEnd = originalLightingSettings.FogEnd end)
    pcall(function() Lighting.GlobalShadows = originalLightingSettings.GlobalShadows end)
    pcall(function() Lighting.EnvironmentDiffuseScale = originalLightingSettings.EnvironmentDiffuseScale end)
    pcall(function() Lighting.EnvironmentSpecularScale = originalLightingSettings.EnvironmentSpecularScale end)
    for eff, wasEnabled in pairs(originalLightingEffects) do
        if eff and eff.Parent then
            pcall(function() eff.Enabled = wasEnabled end)
        end
    end
    notify("Midnight Sky", "Restore Lighting cơ bản. Reload/rejoin để phục hồi parts.", 4)
end

local function disableLightingEffects()
    Lighting.GlobalShadows = false
    for _, eff in ipairs(Lighting:GetDescendants()) do
        if eff:IsA("BloomEffect")
        or eff:IsA("SunRaysEffect")
        or eff:IsA("ColorCorrectionEffect")
        or eff:IsA("BlurEffect")
        or eff:IsA("ToneMapEffect")
        or eff:IsA("DepthOfFieldEffect")
        or eff:IsA("Atmosphere")
        then
            pcall(function() eff.Enabled = false end)
        end
    end
end

local function applyLowerCPULoad()
    if lowerCpuApplied then return end
    lowerCpuApplied = true

    disableLightingEffects()

    local all = Workspace:GetDescendants()
    local batchSize = 50
    local total = #all

    local function processObj(obj)
        if obj:IsA("BasePart") then
            local suc, col = pcall(function() return obj.Color end)
            pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
            if suc and col then
                pcall(function() obj.Color = col end)
            end
            pcall(function() obj.Reflectance = 0 end)
            pcall(function() obj.CastShadow = false end)
        end
        if obj:IsA("SurfaceAppearance") then
            pcall(function() obj:Destroy() end)
        end
        if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            pcall(function() obj.Enabled = false end)
        end
        -- Nếu cần disable ParticleEmitter, Trail, v.v., có thể mở comment:
        -- if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        --     pcall(function() obj.Enabled = false end)
        -- end
    end

    task.spawn(function()
        local i = 1
        while i <= total do
            local j = math.min(i + batchSize - 1, total)
            for idx = i, j do
                local obj = all[idx]
                processObj(obj)
            end
            i = j + 1
            task.wait()
        end
    end)

    lowerCpuConn = Workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if obj then
                if obj:IsA("BasePart") or obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceAppearance") then
                    processObj(obj)
                end
            end
        end)
    end)

    pcall(function() Lighting.Ambient = Lighting.Ambient * 0.5 end)
    pcall(function() Lighting.OutdoorAmbient = Lighting.OutdoorAmbient * 0.5 end)

    notify("Lower CPU", "Áp dụng tối ưu: SmoothPlastic, tắt shadows/effects, giảm đèn.", 4)
end

local function restoreLightingOnly()
    pcall(function() Lighting.Ambient = originalLightingSettings.Ambient end)
    pcall(function() Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient end)
    for eff, wasEnabled in pairs(originalLightingEffects) do
        if eff and eff.Parent then
            pcall(function() eff.Enabled = wasEnabled end)
        end
    end
    pcall(function() Lighting.GlobalShadows = originalLightingSettings.GlobalShadows end)
    notify("Restore Lighting", "Restore Lighting cơ bản. Reload/rejoin để phục hồi parts.", 4)
end

-- ================= Gun Aura Logic =================
function cleanupGunAuraForDrop(drop)
    local conn = gunDropTouchedConns[drop]
    if conn then
        conn:Disconnect()
        gunDropTouchedConns[drop] = nil
    end
    gunDrops[drop] = nil
end

local function tryPickupViaTouched(drop)
    if not Character or not RootPart then return end
    if localRole == "Murderer" then return end
    notify("Gun Aura", "Đã chạm GunDrop, pick up ngay lập tức.", 2)
    cleanupGunAuraForDrop(drop)
end

local function tryPickupViaRadius(drop)
    if not Character or not RootPart then return end
    if localRole == "Murderer" then return end
    local success = false
    if drop and drop.Parent then
        success = pcall(function()
            firetouchinterest(drop, RootPart, 0)
            firetouchinterest(drop, RootPart, 1)
        end)
    end
    if success then
        notify("Gun Aura", "Pick up GunDrop bằng Radius.", 2)
    end
    cleanupGunAuraForDrop(drop)
end

function setupGunAuraOnDrop(drop)
    if not drop or not drop:IsA("BasePart") then return end
    cleanupGunAuraForDrop(drop)
    gunDrops[drop] = true
    if gunAuraEnabled then
        local conn = drop.Touched:Connect(function(hit)
            if not Character then return end
            local parent = hit.Parent
            if parent == Character or (parent and parent:IsDescendantOf(Character)) then
                tryPickupViaTouched(drop)
            end
        end)
        gunDropTouchedConns[drop] = conn
    end
end

local function startGunAuraRadiusLoop()
    if gunAuraLoopThread then end
    gunAuraLoopThread = task.spawn(function()
        local scanInterval = 0.2
        while gunAuraEnabled do
            if Character and RootPart then
                local r2 = gunAuraRadius * gunAuraRadius
                for drop, _ in pairs(gunDrops) do
                    if drop and drop.Parent then
                        local ok, pos = pcall(function() return drop.Position end)
                        if ok and pos then
                            local dx = pos.X - RootPart.Position.X
                            local dy = pos.Y - RootPart.Position.Y
                            local dz = pos.Z - RootPart.Position.Z
                            if dx*dx + dy*dy + dz*dz <= r2 then
                                tryPickupViaRadius(drop)
                            end
                        else
                            cleanupGunAuraForDrop(drop)
                        end
                    else
                        cleanupGunAuraForDrop(drop)
                    end
                end
            end
            task.wait(scanInterval)
        end
    end)
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        setupGunAuraOnDrop(obj)
    end
end)
Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        cleanupGunAuraForDrop(obj)
    end
end)

-- ================= UI: Sidebar Tab with Emoji =================

-- 1. Tạo ScreenGui & MainWindow
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.new(0.4, 0, 0.7, 0)  -- điều chỉnh theo ý bạn
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.BorderSizePixel = 0
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
do
    local corner = Instance.new("UICorner", window)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", window)
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Thickness = 1
end

-- 2. TopBar (draggable, close/minimize)
local topBar = Instance.new("Frame", window)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundTransparency = 1
do
    local layout = Instance.new("UIListLayout", topBar)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 5)
    local pad = Instance.new("UIPadding", topBar)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 5)
end
do
    -- Avatar
    local success, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    local avatar = Instance.new("ImageLabel", topBar)
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 24, 0, 24)
    avatar.BackgroundTransparency = 1
    avatar.Image = success and thumb or ""
    avatar.ImageTransparency = success and 0 or 1
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    avatar.LayoutOrder = 1

    -- Name label
    local nameLabel = Instance.new("TextLabel", topBar)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.6, 0, 0.7, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Kevinz Hub | " .. LocalPlayer.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.LayoutOrder = 2

    -- Minimize button
    local minimizeButton = Instance.new("TextButton", topBar)
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    minimizeButton.Text = "-"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 16
    minimizeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    minimizeButton.AutoButtonColor = false
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(1, 0)
    minimizeButton.LayoutOrder = 3
    minimizeButton.MouseButton1Click:Connect(function()
        window.Visible = false
        -- Bạn có thể tạo một nút bên ngoài để mở lại window nếu muốn
    end)

    -- Close button
    local closeScriptButton = Instance.new("TextButton", topBar)
    closeScriptButton.Name = "CloseScriptButton"
    closeScriptButton.Size = UDim2.new(0, 20, 0, 20)
    closeScriptButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeScriptButton.Text = "X"
    closeScriptButton.Font = Enum.Font.GothamBold
    closeScriptButton.TextSize = 14
    closeScriptButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    closeScriptButton.AutoButtonColor = false
    Instance.new("UICorner", closeScriptButton).CornerRadius = UDim.new(1, 0)
    closeScriptButton.LayoutOrder = 4
    closeScriptButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end

-- Drag window
do
    local dragging = false
    local dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 3. Tạo Sidebar và ContentContainer
local sidebar = Instance.new("Frame", window)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 120, 1, -30)  -- rộng 120px, cao full minus topBar
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local contentContainer = Instance.new("Frame", window)
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -120, 1, -30)
contentContainer.Position = UDim2.new(0, 120, 0, 30)
contentContainer.BackgroundTransparency = 1

-- Sidebar layout
local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.FillDirection = Enum.FillDirection.Vertical
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 4)
local sidebarPadding = Instance.new("UIPadding", sidebar)
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.PaddingBottom = UDim.new(0, 8)
sidebarPadding.PaddingLeft = UDim.new(0, 4)
sidebarPadding.PaddingRight = UDim.new(0, 4)

-- 4. Định nghĩa tabs với Emoji
local tabs = {
    { Name = "Movement", Emoji = "🏃" },
    { Name = "ESP",      Emoji = "🔍" },
    { Name = "Optimize", Emoji = "⚡" },
    { Name = "GunAura",  Emoji = "🔫" },
    { Name = "Settings", Emoji = "⚙️" },
}

-- 5. Tạo bảng lưu
local tabButtons = {}
local tabContentFrames = {}

local function setButtonActive(button, active)
    if active then
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
end

-- 6. Tạo nút sidebar và content frames (ScrollingFrame) cho mỗi tab
for index, tabInfo in ipairs(tabs) do
    -- Nút sidebar
    local btn = Instance.new("TextButton")
    btn.Name = "TabBtn_" .. tabInfo.Name
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BorderSizePixel = 0
    btn.LayoutOrder = index
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    -- Emoji icon
    local emojiLabel = Instance.new("TextLabel", btn)
    emojiLabel.Name = "IconEmoji"
    emojiLabel.Size = UDim2.new(0, 24, 1, 0)
    emojiLabel.Position = UDim2.new(0, 8, 0, 0)
    emojiLabel.BackgroundTransparency = 1
    emojiLabel.Text = tabInfo.Emoji or ""
    emojiLabel.Font = Enum.Font.Gotham
    emojiLabel.TextSize = 18
    emojiLabel.TextColor3 = Color3.fromRGB(230,230,230)
    emojiLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Label text
    local lbl = Instance.new("TextLabel", btn)
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 40, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabInfo.Name
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Content ScrollingFrame
    local frame = Instance.new("ScrollingFrame")
    frame.Name = "Content_" .. tabInfo.Name
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.ScrollBarThickness = 6
    frame.Visible = false
    frame.Parent = contentContainer

    -- UIListLayout trong content frame
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        if not frame.Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35,35,35)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not frame.Visible then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
        end
    end)

    -- Click handler
    btn.MouseButton1Click:Connect(function()
        for name, f in pairs(tabContentFrames) do
            f.Visible = false
            setButtonActive(tabButtons[name], false)
        end
        frame.Visible = true
        setButtonActive(btn, true)
    end)

    tabButtons[tabInfo.Name] = btn
    tabContentFrames[tabInfo.Name] = frame
end

-- 7. Mặc định chọn tab đầu
if #tabs > 0 then
    local firstName = tabs[1].Name
    tabButtons[firstName].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabContentFrames[firstName].Visible = true
end

-- 8. Helper createInput/createSwitch với parent param
local function createInput(parent, labelText, getDefault, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = (#parent:GetChildren()) + 1
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", container)
    input.Name = "TextBox"
    input.Size = UDim2.new(0.6, -16, 1, -4)
    input.Position = UDim2.new(0.4, 8, 0, 2)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.TextColor3 = Color3.fromRGB(240, 240, 240)
    input.Text = ""
    input.PlaceholderText = tostring(getDefault())
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = input.Text
            local val = tonumber(text)
            if val then
                pcall(function() callback(val) end)
                input.PlaceholderText = tostring(val)
            else
                input.PlaceholderText = tostring(getDefault())
            end
            input.Text = ""
        end
    end)
    return input
end

local function createSwitch(parent, labelText, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = (#parent:GetChildren()) + 1
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", container)
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0.4, -16, 1, -4)
    toggle.Position = UDim2.new(0.6, 8, 0, 2)
    toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    toggle.Text = "OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14
    toggle.TextColor3 = Color3.fromRGB(240, 240, 240)
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        if state then
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 0)}):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end
        pcall(function() callback(state) end)
    end)
    return toggle
end

-- 9. Khởi tạo nội dung cho từng tab

-- Movement Tab
do
    local parent = tabContentFrames["Movement"]
    if parent then
        createInput(parent, "WalkSpeed", function() return savedWalkSpeed end, function(v)
            savedWalkSpeed = v
            if Humanoid then pcall(function() Humanoid.WalkSpeed = v end) end
            notify("WalkSpeed", "Đã đặt WalkSpeed = " .. v, 2)
        end)
        createInput(parent, "JumpPower", function() return savedJumpPower end, function(v)
            savedJumpPower = v
            if Humanoid then pcall(function() Humanoid.JumpPower = v end) end
            notify("JumpPower", "Đã đặt JumpPower = " .. v, 2)
        end)
        createInput(parent, "FOV", function() return Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70 end, function(v)
            if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = v end
            notify("FOV", "Đã đặt FOV = " .. v, 2)
        end)
        createSwitch(parent, "Semi-God Mode", function(on)
            semiGodModeEnabled = on
            notify("Semi-God", on and "Bật Semi-God" or "Tắt Semi-God", 2)
        end)
    end
end

-- ESP Tab
do
    local parent = tabContentFrames["ESP"]
    if parent then
        createSwitch(parent, "ESP Dot + Weapon + GunDrop", function(on)
            if on then enableESP() else disableESP() end
        end)
    end
end

-- Optimize Tab
do
    local parent = tabContentFrames["Optimize"]
    if parent then
        createSwitch(parent, "Midnight Sky", function(on)
            midnightEnabled = on
            if on then
                applyMidnightSky()
                applyLowerCPULoad()
            else
                restoreOriginalSky()
                restoreLightingOnly()
                if lowerCpuConn then lowerCpuConn:Disconnect(); lowerCpuConn = nil end
                lowerCpuApplied = false
            end
        end)
        createSwitch(parent, "FPS Booster", function(on)
            fpsBoosterEnabled = on
            if on then
                notify("FPS Booster", "Bật FPS Booster. Reload để restore.", 3)
            else
                notify("FPS Booster", "Tắt FPS Booster. Reload để restore.", 3)
            end
        end)
    end
end

-- GunAura Tab
do
    local parent = tabContentFrames["GunAura"]
    if parent then
        createSwitch(parent, "Gun Aura (Touched+Radius)", function(on)
            gunAuraEnabled = on
            if on then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
                        setupGunAuraOnDrop(obj)
                    end
                end
                startGunAuraRadiusLoop()
                notify("GunAura", "Bật Gun Aura", 2)
            else
                for drop,_ in pairs(gunDrops) do cleanupGunAuraForDrop(drop) end
                notify("GunAura", "Tắt Gun Aura", 2)
            end
        end)
        createInput(parent, "Gun Aura Radius", function() return gunAuraRadius end, function(v)
            gunAuraRadius = v
            notify("GunAura Radius", "Đặt Radius = " .. v, 2)
        end)
    end
end

-- Settings Tab
do
    local parent = tabContentFrames["Settings"]
    if parent then
        createSwitch(parent, "Dark Theme", function(on)
            if on then
                window.BackgroundColor3 = Color3.fromRGB(20,20,20)
                sidebar.BackgroundColor3 = Color3.fromRGB(25,25,25)
                for _, btn in pairs(tabButtons) do
                    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
                    local icon = btn:FindFirstChild("IconEmoji")
                    if icon then icon.TextColor3 = Color3.fromRGB(230,230,230) end
                    local lbl = btn:FindFirstChild("Label")
                    if lbl then lbl.TextColor3 = Color3.fromRGB(230,230,230) end
                end
                for _, frame in pairs(tabContentFrames) do
                    for _, child in ipairs(frame:GetDescendants()) do
                        if child:IsA("TextLabel") then
                            child.TextColor3 = Color3.fromRGB(230,230,230)
                        elseif child:IsA("TextBox") then
                            child.TextColor3 = Color3.fromRGB(230,230,230)
                            child.BackgroundColor3 = Color3.fromRGB(50,50,50)
                        elseif child:IsA("TextButton") then
                            child.TextColor3 = Color3.fromRGB(230,230,230)
                            child.BackgroundColor3 = Color3.fromRGB(35,35,35)
                        end
                    end
                end
            else
                window.BackgroundColor3 = Color3.fromRGB(240,240,240)
                sidebar.BackgroundColor3 = Color3.fromRGB(250,250,250)
                for _, btn in pairs(tabButtons) do
                    btn.BackgroundColor3 = Color3.fromRGB(245,245,245)
                    local icon = btn:FindFirstChild("IconEmoji")
                    if icon then icon.TextColor3 = Color3.fromRGB(20,20,20) end
                    local lbl = btn:FindFirstChild("Label")
                    if lbl then lbl.TextColor3 = Color3.fromRGB(20,20,20) end
                end
                for _, frame in pairs(tabContentFrames) do
                    for _, child in ipairs(frame:GetDescendants()) do
                        if child:IsA("TextLabel") then
                            child.TextColor3 = Color3.fromRGB(20,20,20)
                        elseif child:IsA("TextBox") then
                            child.TextColor3 = Color3.fromRGB(20,20,20)
                            child.BackgroundColor3 = Color3.fromRGB(240,240,240)
                        elseif child:IsA("TextButton") then
                            child.TextColor3 = Color3.fromRGB(20,20,20)
                            child.BackgroundColor3 = Color3.fromRGB(245,245,245)
                        end
                    end
                end
            end
        end)
        -- Có thể thêm keybind manager, config lưu local, v.v.
    end
end

-- ================= End of Script =================
