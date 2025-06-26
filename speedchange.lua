-- KevinzHub Full Script v1.50 (UI Library Integrated, Sidebar Tab, Icon, All Logic Ported)
-- Place this LocalScript in StarterPlayerScripts or StarterGui

--[[
  REQUIREMENTS:
    + kevinzhub_ui_library.lua must be uploaded and accessible at:
      https://raw.githubusercontent.com/XUwUxX/script/refs/heads/main/kevinzhub.lua
    + This script assumes Roblox compatibility, proper permissions.
  USAGE:
    Place BOTH this file and kevinzhub_ui_library.lua in the same folder, or require/loadstring the UI lib.
]]

-- Load UI Library
local KevinzHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/XUwUxX/script/refs/heads/main/kevinzhub.lua"))()

-- Roblox Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Workspace = workspace
local UserInputService = game:GetService("UserInputService")

-- Globals
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart = nil, nil, nil
local Camera = Workspace.CurrentCamera
local HUB_VERSION = "v1.50"

-- Movement defaults
local savedWalkSpeed = 16
local savedJumpPower = 50
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    savedWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed or savedWalkSpeed
    savedJumpPower = LocalPlayer.Character.Humanoid.JumpPower or savedJumpPower
end

-- Double Jump / Infinity Jump settings
local infinityJumpEnabled = false
local maxJumpCount = 2  -- 1 jump + (maxJumpCount-1) mid-air jumps

-- Semi-God
local semiGodModeEnabled = false

-- Gun Aura
local gunAuraEnabled = false
local gunAuraRadius = 13
local gunDrops, gunDropTouchedConns = {}, {}
local gunAuraLoopThread = nil

-- ESP
local gunDropHighlights, espGlobalConns = {}, {}

-- Role caching
local localRole = "Unknown"

-- Optimize
local midnightEnabled = false
local fpsBoosterEnabled = false
local lowerCpuApplied = false
local lowerCpuConn = nil
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

-- Notification helper (uses UI library)
local function notify(title, text, duration)
    KevinzHub:MakeNotification({
        Name = title or "KevinzHub",
        Content = text or "",
        Time = duration or 3,
        Image = "rbxassetid://77339698"
    })
end

-- UI Setup
local window = KevinzHub:MakeWindow{ Name = "KevinzHub v" .. HUB_VERSION }
local tabMovement   = window:MakeTab{ Name = "Movement" }
local tabESP        = window:MakeTab{ Name = "ESP" }
local tabOptimize   = window:MakeTab{ Name = "Optimize" }
local tabGunAura    = window:MakeTab{ Name = "GunAura" }
local tabSettings   = window:MakeTab{ Name = "Settings" }

-- Role detection
local function updateLocalRole()
    local hasKnife, hasGun = false, false
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
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
    end
end

local function setupLocalRoleListeners()
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then updateLocalRole() end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then updateLocalRole() end
        end)
        updateLocalRole()
    end)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then updateLocalRole() end
        end)
        backpack.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then updateLocalRole() end
        end)
    end
    if LocalPlayer.Character then
        Character = LocalPlayer.Character
        updateLocalRole()
    end
end
setupLocalRoleListeners()

-- Character/Humanoid setup, Double Jump logic
local function onCharacterAdded(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if Humanoid then
        pcall(function() Humanoid.WalkSpeed = savedWalkSpeed end)
        pcall(function() Humanoid.JumpPower = savedJumpPower end)
        -- Semi-God logic
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

    -- Double Jump setup
    if Humanoid then
        local jumpCount = 0
        Humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed then
                jumpCount = 0
            elseif oldState ~= Enum.HumanoidStateType.Freefall and newState == Enum.HumanoidStateType.Jumping then
                jumpCount = 1
            end
        end)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not infinityJumpEnabled then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
                if not Humanoid or not Humanoid.Parent then return end
                if Humanoid:GetState() == Enum.HumanoidStateType.Freefall and jumpCount < maxJumpCount then
                    jumpCount = jumpCount + 1
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end

    -- Reset gun aura listeners
    for drop, conn in pairs(gunDropTouchedConns) do
        if conn then conn:Disconnect() end
    end
    table.clear(gunDropTouchedConns)
    table.clear(gunDrops)

    -- [REMOVED: Bullet path highlight]
    -- (No code for gun bullet highlight here anymore)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

-- ===== UI LOGIC =====

-- Movement Tab
do
    local sec = tabMovement:AddSection{ Name = "Movement" }
    sec:AddSlider{
        Name = "WalkSpeed", Min = 4, Max = 200, Default = savedWalkSpeed, WithTextbox = true,
        Callback = function(v)
            savedWalkSpeed = v
            if Humanoid then pcall(function() Humanoid.WalkSpeed = v end) end
            notify("WalkSpeed", "Set to " .. v, 2)
        end
    }
    sec:AddSlider{
        Name = "JumpPower", Min = 20, Max = 200, Default = savedJumpPower, WithTextbox = true,
        Callback = function(v)
            savedJumpPower = v
            if Humanoid then pcall(function() Humanoid.JumpPower = v end) end
            notify("JumpPower", "Set to " .. v, 2)
        end
    }
    sec:AddSlider{
        Name = "FOV", Min = 50, Max = 120, Default = (Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70), WithTextbox = true,
        Callback = function(v)
            if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = v end
            notify("FOV", "Set to " .. v, 2)
        end
    }
    sec:AddToggle{
        Name = "Semi-God Mode", Default = false,
        Callback = function(on)
            semiGodModeEnabled = on
            notify("Semi-God Mode🔥", on and "ON" or "OFF", 2)
        end
    }
    sec:AddToggle{
        Name = "Double Jump", Default = false,
        Callback = function(on)
            infinityJumpEnabled = on
            if on then
                notify("Double Jump", "Enabled (max " .. tostring(maxJumpCount) .. " jumps)", 2)
            else
                notify("Double Jump", "Disabled", 2)
            end
        end
    }
    sec:AddSlider{
        Name = "Max Jump Count", Min = 1, Max = 8, Default = maxJumpCount, WithTextbox = true,
        Callback = function(v)
            if type(v) == "number" and v >= 1 then
                maxJumpCount = math.floor(v)
                notify("Max Jump Count", "Set to " .. maxJumpCount, 2)
            else
                notify("Max Jump Count", "Invalid value", 2)
            end
        end
    }
end

-- ESP Tab
do
    local sec = tabESP:AddSection{ Name = "ESP" }
    local espToggle = false

    -- ESP logic
    local weaponHighlights, playerESPConns = {}, {}
    local roleColors = {
        Murderer = Color3.fromRGB(255, 50, 50),
        Sheriff = Color3.fromRGB(0, 89, 255),
        Hero = Color3.fromRGB(255, 255, 0),
        Innocent = Color3.fromRGB(50, 255, 80),
        Unknown = Color3.fromRGB(180, 180, 180),
    }
    local roundSheriffUserId, roundActive = nil, false
    local function detectRoundReset()
        local everyoneInnocent = true
        for _, p in ipairs(Players:GetPlayers()) do
            local hasKnife, hasGun = false, false
            local bp = p:FindFirstChild("Backpack")
            if bp then
                for _, tool in ipairs(bp:GetChildren()) do
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
        end
    end
    local function monitorSheriffAssignment()
        for _, p in ipairs(Players:GetPlayers()) do
            local bp = p:FindFirstChild("Backpack")
            if bp then
                for _, tool in ipairs(bp:GetChildren()) do
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
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
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
            if frame then frame.BackgroundColor3 = color end
        end
    end

    local function clearDotESP(player)
        if player.Character and player.Character:FindFirstChild("Head") then
            local e = player.Character.Head:FindFirstChild("DotESP")
            if e then e:Destroy() end
        end
    end

    local function addWeaponHighlight(player, toolInstance)
        if not toolInstance:IsA("Tool") then return end
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

    local function setupESPForPlayer(player)
        if player == LocalPlayer then return end
        local conns = {}
        playerESPConns[player] = conns
        local function onCharAdded(char)
            char:WaitForChild("Head", 5)
            updateDotESP(player)
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Tool") then
                    task.delay(0.1, function() addWeaponHighlight(player, child) end)
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
        table.insert(conns, player.CharacterAdded:Connect(onCharAdded))
        if player.Character and player.Character:FindFirstChild("Head") then
            onCharAdded(player.Character)
        end
        local function connectBackpack(bp)
            if bp then
                local added = bp.ChildAdded:Connect(function() updateDotESP(player) end)
                local removed = bp.ChildRemoved:Connect(function() updateDotESP(player) end)
                table.insert(conns, added)
                table.insert(conns, removed)
            end
        end
        local backpack = player:FindFirstChild("Backpack")
        if backpack then connectBackpack(backpack) end
        table.insert(conns, player.ChildAdded:Connect(function(child)
            if child.Name == "Backpack" then connectBackpack(child) end
        end))
    end

    local function teardownESPForPlayer(player)
        local conns = playerESPConns[player]
        if conns then
            for _, conn in ipairs(conns) do
                if conn and conn.Disconnect then conn:Disconnect() end
            end
        end
        playerESPConns[player] = nil
        clearDotESP(player)
        clearWeaponHighlightsForPlayer(player)
    end

    local function addGunDropHighlight(drop)
        if not drop:IsA("BasePart") then return end
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
        if espGlobalConns.enabled then return end
        espGlobalConns.enabled = true
        for _, player in ipairs(Players:GetPlayers()) do
            setupESPForPlayer(player)
        end
        espGlobalConns.playerAdded = Players.PlayerAdded:Connect(function(player)
            setupESPForPlayer(player)
        end)
        espGlobalConns.renderStepped = RunService.RenderStepped:Connect(function()
            detectRoundReset()
            monitorSheriffAssignment()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then updateDotESP(player) end
            end
        end)
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
        notify("ESP Enabled✅", "Dot ESP", 3)
    end

    local function disableESP()
        if not espGlobalConns.enabled then return end
        espGlobalConns.enabled = false
        if espGlobalConns.playerAdded then espGlobalConns.playerAdded:Disconnect() end
        if espGlobalConns.renderStepped then espGlobalConns.renderStepped:Disconnect() end
        if espGlobalConns.gunDropAdded then espGlobalConns.gunDropAdded:Disconnect() end
        if espGlobalConns.gunDropRemoving then espGlobalConns.gunDropRemoving:Disconnect() end
        for _, player in ipairs(Players:GetPlayers()) do
            teardownESPForPlayer(player)
        end
        for drop, _ in pairs(gunDropHighlights) do
            removeGunDropHighlight(drop)
        end
        notify("ESP Disabled❌", "Dot ESP", 3)
    end

    sec:AddToggle{
        Name = "ESP Dot + Weapon + GunDrop", Default = false,
        Callback = function(on)
            espToggle = on
            if on then enableESP() else disableESP() end
        end
    }
end

-- Optimize Tab
do
    local sec = tabOptimize:AddSection{ Name = "Optimize" }

    local midnightDescConn = nil
    local function disablePostEffects()
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

    local function transitionLighting(toMidnight, duration)
        duration = duration or 2
        local startTime = tick()
        local initial = {}
        for k,v in pairs(originalLightingSettings) do initial[k]=v end
        local target = {}
        if toMidnight then
            target.ClockTime = 0
            target.Brightness = 35
            target.Ambient = Color3.new(0,0,0)
            target.OutdoorAmbient = Color3.new(0,0,0)
            target.FogColor = Color3.new(0,0,0)
            target.FogStart = 0
            target.FogEnd = 1e3
            target.GlobalShadows = false
            target.EnvironmentDiffuseScale = 0
            target.EnvironmentSpecularScale = 0
        else
            for k,v in pairs(originalLightingSettings) do target[k]=v end
        end
        task.spawn(function()
            while true do
                local elapsed = tick() - startTime
                local t = math.clamp(elapsed / duration, 0, 1)
                Lighting.ClockTime = initial.ClockTime + (target.ClockTime - initial.ClockTime) * t
                Lighting.Brightness = initial.Brightness + (target.Brightness - initial.Brightness) * t
                Lighting.Ambient = initial.Ambient:Lerp(target.Ambient, t)
                Lighting.OutdoorAmbient = initial.OutdoorAmbient:Lerp(target.OutdoorAmbient, t)
                Lighting.FogColor = initial.FogColor:Lerp(target.FogColor, t)
                Lighting.FogStart = initial.FogStart + (target.FogStart - initial.FogStart) * t
                Lighting.FogEnd = initial.FogEnd + (target.FogEnd - initial.FogEnd) * t
                Lighting.EnvironmentDiffuseScale = initial.EnvironmentDiffuseScale + (target.EnvironmentDiffuseScale - initial.EnvironmentDiffuseScale) * t
                Lighting.EnvironmentSpecularScale = initial.EnvironmentSpecularScale + (target.EnvironmentSpecularScale - initial.EnvironmentSpecularScale) * t
                Lighting.GlobalShadows = target.GlobalShadows
                if t >= 1 then break end
                RunService.RenderStepped:Wait()
            end
        end)
    end

    local function applyMidnightSky()
        transitionLighting(true, 2)
        disablePostEffects()
        if midnightDescConn then midnightDescConn:Disconnect() end
        midnightDescConn = Lighting.DescendantAdded:Connect(function(obj)
            if obj:IsA("Sky") then
                pcall(function() obj:Destroy() end)
            end
        end)
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                pcall(function() child:Destroy() end)
            end
        end
        notify("Midnight Sky🎧", "Transitioning to midnight...", 3)
    end

    local function restoreOriginalSky()
        transitionLighting(false, 2)
        if midnightDescConn then
            midnightDescConn:Disconnect()
            midnightDescConn = nil
        end
        for eff, wasEnabled in pairs(originalLightingEffects) do
            if eff and eff.Parent then
                pcall(function() eff.Enabled = wasEnabled end)
            end
        end
        notify("Midnight Sky🎧", "Restoring lighting...", 4)
    end

    local function applyLowerCPULoad()
        if lowerCpuApplied then return end
        lowerCpuApplied = true
        disablePostEffects()
        local all = Workspace:GetDescendants()
        local batchSize = 50
        local total = #all
        local function processObj(obj)
            if obj:IsA("BasePart") then
                local suc, col = pcall(function() return obj.Color end)
                pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
                if suc and col then pcall(function() obj.Color = col end) end
                pcall(function() obj.Reflectance = 0 end)
                pcall(function() obj.CastShadow = false end)
            end
            if obj:IsA("SurfaceAppearance") then
                pcall(function() obj:Destroy() end)
            end
            if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
                pcall(function() obj.Enabled = false end)
            end
        end
        task.spawn(function()
            local i = 1
            while i <= total do
                local j = math.min(i + batchSize - 1, total)
                for idx = i, j do
                    processObj(all[idx])
                end
                i = j + 1
                task.wait()
            end
        end)
        if lowerCpuConn then lowerCpuConn:Disconnect() end
        lowerCpuConn = Workspace.DescendantAdded:Connect(function(obj)
            task.defer(function()
                if obj:IsA("BasePart") or obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceAppearance") then
                    processObj(obj)
                end
            end)
        end)
        pcall(function() Lighting.Ambient = Lighting.Ambient * 0.5 end)
        pcall(function() Lighting.OutdoorAmbient = Lighting.OutdoorAmbient * 0.5 end)
        notify("Lower CPU🏖", "Higher FPS", 4)
    end

    local function restoreLightingOnly()
        transitionLighting(false, 2)
        if lowerCpuConn then
            lowerCpuConn:Disconnect()
            lowerCpuConn = nil
        end
        lowerCpuApplied = false
        for eff, wasEnabled in pairs(originalLightingEffects) do
            if eff and eff.Parent then
                pcall(function() eff.Enabled = wasEnabled end)
            end
        end
        notify("Restore Lighting✨", "Restoring lighting settings.", 4)
    end

    sec:AddToggle{
        Name = "Midnight Sky", Default = false,
        Callback = function(on)
            midnightEnabled = on
            if on then
                applyMidnightSky()
                applyLowerCPULoad()
            else
                restoreOriginalSky()
                restoreLightingOnly()
            end
        end
    }
    sec:AddToggle{
        Name = "FPS Booster", Default = false,
        Callback = function(on)
            fpsBoosterEnabled = on
            if on then
                notify("FPS Booster", "ON. Reload to restore.", 3)
            else
                notify("FPS Booster", "OFF. Reload to restore.", 3)
            end
        end
    }
end

-- GunAura Tab
do
    local sec = tabGunAura:AddSection{ Name = "GunAura" }
    local function cleanupGunAuraForDrop(drop)
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
        notify("Gun Aura✨", "Auto grab when gun near", 2)
        cleanupGunAuraForDrop(drop)
    end

    local function tryPickupViaRadius(drop)
        if not Character or not RootPart then return end
        if localRole == "Murderer" then return end
        local success = pcall(function()
            firetouchinterest(drop, RootPart, 0)
            firetouchinterest(drop, RootPart, 1)
        end)
        if success then
            notify("Done auto grab✅", "🏖", 2)
        end
        cleanupGunAuraForDrop(drop)
    end

    local function setupGunAuraOnDrop(drop)
        if not drop:IsA("BasePart") then return end
        cleanupGunAuraForDrop(drop)
        gunDrops[drop] = true
        if gunAuraEnabled then
            local conn = drop.Touched:Connect(function(hit)
                if Character and hit.Parent and (hit.Parent == Character or hit.Parent:IsDescendantOf(Character)) then
                    tryPickupViaTouched(drop)
                end
            end)
            gunDropTouchedConns[drop] = conn
        end
    end

    local function startGunAuraRadiusLoop()
        gunAuraLoopThread = task.spawn(function()
            while gunAuraEnabled do
                if Character and RootPart then
                    local r2 = gunAuraRadius * gunAuraRadius
                    for drop,_ in pairs(gunDrops) do
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
                task.wait(0.2)
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

    sec:AddToggle{
        Name = "Gun Aura (Touched+Radius)", Default = false,
        Callback = function(on)
            gunAuraEnabled = on
            if on then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
                        setupGunAuraOnDrop(obj)
                    end
                end
                startGunAuraRadiusLoop()
                notify("GunAura", "ON", 2)
            else
                for drop,_ in pairs(gunDrops) do cleanupGunAuraForDrop(drop) end
                notify("GunAura", "OFF", 2)
            end
        end
    }
    sec:AddSlider{
        Name = "Gun Aura Radius", Min = 5, Max = 50, Default = gunAuraRadius, WithTextbox = true,
        Callback = function(v)
            gunAuraRadius = v
            notify("GunAura Radius", tostring(v), 2)
        end
    }
end

-- Settings Tab
do
    local sec = tabSettings:AddSection{ Name = "Settings" }
    local isDark = true
    sec:AddToggle{
        Name = "Dark Theme", Default = true,
        Callback = function(on)
            isDark = on
            KevinzHub:MakeNotification({
                Name = "Theme",
                Content = on and "Dark" or "Light",
                Time = 2
            })
            -- The actual color swap must be handled by developer, as the current UI lib doesn't expose
            -- a global theme switch; you can adjust the COLORS table in the library for full support.
        end
    }
end

notify("KevinzHub Loaded✅", "🚀Version: " .. HUB_VERSION, 4)
