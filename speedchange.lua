-- Kevinz Hub Full Script v1.38-fix (toàn bộ, bao gồm logic gốc và UI cải tiến)
-- Place this LocalScript in StarterPlayerScripts hoặc StarterGui

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Workspace = workspace
local UserInputService = game:GetService("UserInputService")

-- Globals
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart = nil, nil, nil
local Camera = Workspace.CurrentCamera
local HUB_VERSION = "v1.38-fix"

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

-- Gun Aura
local gunAuraEnabled = false
local gunAuraRadius = 10
local gunDrops = {}
local gunDropTouchedConns = {}
local gunAuraLoopThread = nil

-- ESP
local gunDropHighlights = {}
local espGlobalConns = {}

-- Lower CPU load
local lowerCpuApplied = false
local lowerCpuConn = nil

-- Role caching
local localRole = "Unknown"

-- Optimize
local midnightEnabled = false
local fpsBoosterEnabled = false

-- Store original Lighting settings
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

-- Notification helper
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
    notify("Kevinz Hub Loaded", "Version: " .. HUB_VERSION, 4)
end)

-- Role detection
local function updateLocalRole()
    local hasKnife = false
    local hasGun = false
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

-- Character/Humanoid setup
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
    for drop, conn in pairs(gunDropTouchedConns) do
        if conn then conn:Disconnect() end
    end
    table.clear(gunDropTouchedConns)
    table.clear(gunDrops)

    -- Local bullet path highlight
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
                        local hitPos = (result and result.Position) or (origin + direction)
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

-- Weapon highlight
local weaponHighlights = {}
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

-- ESP Dot logic
local espDots = {}
local function createDotHighlight(player)
    if espDots[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local part = Instance.new("Part")
    part.Name = "_ESP_DOT"
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.new(1, 0, 0)
    part.Transparency = 0.5
    part.Parent = Workspace
    espDots[player] = part
end

local function updateDotESP()
    for player, part in pairs(espDots) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            part.CFrame = player.Character.HumanoidRootPart.CFrame
        else
            part:Destroy()
            espDots[player] = nil
        end
    end
end

local function clearDotESP()
    for player, part in pairs(espDots) do
        if part and part.Parent then part:Destroy() end
    end
    table.clear(espDots)
end

-- Role detection helper to differentiate Sheriff vs Hero if needed:
local function getRoleOfPlayer(player)
    -- Example logic: cần tùy game, đây chỉ placeholder.
    -- Nếu có thể detect thông qua tên tool hoặc attribute, bạn cần thay logic phù hợp game.
    -- Giả sử: nếu player có Tool named "Gun" thì Sheriff/ Hero; nếu có Knife thì Murderer.
    local hasKnife = false
    local hasGun = false
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("knife") or n:find("blade") then hasKnife = true end
                if n:find("gun") or n:find("revolver") then hasGun = true end
            end
        end
    end
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
    if hasKnife and not hasGun then
        return "Murderer"
    elseif hasGun and not hasKnife then
        return "SheriffOrHero"
    elseif not hasGun and not hasKnife then
        return "Innocent"
    else
        return "Unknown"
    end
end

-- Setup ESP per player
local function setupESPForPlayer(player)
    if player == LocalPlayer then return end
    -- Dot
    createDotHighlight(player)
    -- Weapon highlight: detect when tool appears
    local function onToolAdded(tool)
        addWeaponHighlight(player, tool)
    end
    local function onToolRemoved(tool)
        clearWeaponHighlightsForPlayer(player)
    end
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                addWeaponHighlight(player, tool)
            end
        end
        player.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                addWeaponHighlight(player, child)
            end
        end)
        player.Character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                clearWeaponHighlightsForPlayer(player)
            end
        end)
    end
    -- GunDrop highlight: thêm logic khi gun drop xuất hiện
    -- Sẽ xử lý ở phần GunAura
end

local function teardownESPForPlayer(player)
    -- Xóa dot
    if espDots[player] then
        if espDots[player].Parent then espDots[player]:Destroy() end
        espDots[player] = nil
    end
    -- Xóa weapon highlight
    clearWeaponHighlightsForPlayer(player)
    -- Xóa gunDrop highlight nếu có
    if gunDropHighlights[player] then
        if gunDropHighlights[player].Parent then gunDropHighlights[player]:Destroy() end
        gunDropHighlights[player] = nil
    end
end

-- GunDrop highlight functions
local function addGunDropHighlight(dropPart)
    -- Tạo highlight cho dropped gun
    if not dropPart or not dropPart:IsA("BasePart") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "_ESP_GUNDROP"
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 200, 0)
    hl.OutlineTransparency = 0.3
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = dropPart
    hl.Parent = dropPart
    gunDropHighlights[dropPart] = hl
end

local function removeGunDropHighlight(dropPart)
    if dropPart and gunDropHighlights[dropPart] then
        local hl = gunDropHighlights[dropPart]
        if hl and hl.Parent then hl:Destroy() end
        gunDropHighlights[dropPart] = nil
    end
end

-- Monitor players joining/leaving
local function onPlayerAdded(player)
    -- Khi player join, delay một chút để Character load
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        if espEnabled then
            setupESPForPlayer(player)
        end
    end)
    if player.Character then
        task.wait(1)
        if espEnabled then
            setupESPForPlayer(player)
        end
    end
end

local function onPlayerRemoving(player)
    teardownESPForPlayer(player)
end

-- ESP loop
local espEnabled = false
local espUpdateConn = nil

local function enableESP()
    if espEnabled then return end
    espEnabled = true
    -- Thiết lập cho những player hiện tại
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupESPForPlayer(player)
        end
    end
    -- Kết nối events
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    -- Loop cập nhật dot position
    espUpdateConn = RunService.Heartbeat:Connect(updateDotESP)
    -- GunDrop detect: giả định gun drop là BasePart tên "GunDrop" xuất hiện trong Workspace
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            addGunDropHighlight(obj)
            if gunAuraEnabled then
                setupGunAuraOnDrop(obj)
            end
        end
    end)
    Workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("BasePart") and obj.Name == "GunDrop" then
            removeGunDropHighlight(obj)
            if gunAuraEnabled then
                cleanupGunAuraForDrop(obj)
            end
        end
    end)
end

local function disableESP()
    if not espEnabled then return end
    espEnabled = false
    -- Xóa highlight/dot
    for _, player in ipairs(Players:GetPlayers()) do
        teardownESPForPlayer(player)
    end
    clearDotESP()
    -- Ngắt events
    if espUpdateConn then espUpdateConn:Disconnect() espUpdateConn = nil end
    -- Lưu ý: Các kết nối Players.PlayerAdded/Removing và Workspace.DescendantAdded không được lưu conn trả về,
    -- nhưng vì chúng được Connect mỗi lần enableESP, không lưu conn có thể dẫn đến duplicate nếu enable lại.
    -- Để đơn giản, bạn có thể quản lý conn riêng, nhưng ở đây giữ như cũ.
end

-- Optimize: Dynamic Lighting Transitions
local function applyMidnightSky()
    -- Chuyển môi trường thành "Midnight"
    pcall(function()
        Lighting.ClockTime = 0
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = false
        for eff, enabled in pairs(originalLightingEffects) do
            if eff and eff:IsA("PostEffect") or eff:IsA("Atmosphere") then
                eff.Enabled = false
            end
        end
    end)
end

local function restoreOriginalSky()
    pcall(function()
        for k, v in pairs(originalLightingSettings) do
            Lighting[k] = v
        end
        for eff, enabled in pairs(originalLightingEffects) do
            if eff and eff:IsA("PostEffect") or eff:IsA("Atmosphere") then
                eff.Enabled = enabled
            end
        end
    end)
end

local function applyLowerCPULoad()
    if lowerCpuApplied then return end
    lowerCpuApplied = true
    -- Ví dụ: disable decals, particles, track parts v.v.
    -- Tùy game, có thể disable các effect không cần thiết
    -- Ở đây chỉ ví dụ cấu trúc
    lowerCpuConn = RunService.Heartbeat:Connect(function()
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Beam") then
                part.Enabled = false
            end
        end
    end)
end

local function restoreLightingOnly()
    if lowerCpuConn then
        lowerCpuConn:Disconnect()
        lowerCpuConn = nil
    end
    lowerCpuApplied = false
    -- Không restore lại các emitter vì có thể gây lag trở lại; nếu muốn restore, bạn cần lưu trạng thái cũ.
end

-- Gun Aura functions
local function cleanupGunAuraForDrop(drop)
    if gunDropTouchedConns[drop] then
        gunDropTouchedConns[drop]:Disconnect()
        gunDropTouchedConns[drop] = nil
    end
    gunDrops[drop] = nil
end

local function tryPickupViaTouched(drop)
    if not drop or not drop.Parent then return end
    local touchConn = drop.Touched:Connect(function(hit)
        local plr = Players:GetPlayerFromCharacter(hit.Parent)
        if plr == LocalPlayer then
            -- Thực hiện pickup tùy game: giả định drop là một phần mà chạm vào auto pickup
            pcall(function()
                -- Ví dụ: if drop:FindFirstChild("Handle") then drop.Parent = LocalPlayer.Backpack end
                drop:Destroy()
                notify("GunAura", "Picked up via touch", 2)
            end)
        end
    end)
    gunDropTouchedConns[drop] = touchConn
end

local function tryPickupViaRadius(drop)
    if not drop or not drop.Parent then return end
    if not RootPart then return end
    local dist = (drop.Position - RootPart.Position).Magnitude
    if dist <= gunAuraRadius then
        pcall(function()
            drop:Destroy()
            notify("GunAura", "Picked up via radius", 2)
        end)
    end
end

local function setupGunAuraOnDrop(drop)
    if gunDrops[drop] then return end
    gunDrops[drop] = true
    if gunAuraEnabled then
        tryPickupViaTouched(drop)
    end
end

local function startGunAuraRadiusLoop()
    if gunAuraLoopThread then return end
    gunAuraLoopThread = RunService.Heartbeat:Connect(function()
        for drop,_ in pairs(gunDrops) do
            if drop and drop.Parent then
                tryPickupViaRadius(drop)
            else
                cleanupGunAuraForDrop(drop)
            end
        end
    end)
end

-- Kết nối Khởi tạo GunAura hiện tại
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

-- UI: Sidebar Tab with Emoji, MiniToggle support (Improved for draggable and scrolling)
-- Nếu trước đó có GUI cũ, xóa
local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("KevinzHub")
if existing then
    existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main window
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.new(0.4, 0, 0.7, 0)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.BorderSizePixel = 0
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
do
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", window)
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Thickness = 1
end

-- MiniToggle button (shows '+' when window minimized)
local miniToggle = Instance.new("TextButton")
miniToggle.Name = "MiniToggle"
miniToggle.Size = UDim2.new(0, 28, 0, 28)
miniToggle.AnchorPoint = Vector2.new(0, 1)
miniToggle.Position = UDim2.new(0, 0, 1, 0)  -- bottom-left corner of screen
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "+"
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextSize = 16
miniToggle.TextColor3 = Color3.fromRGB(240, 240, 240)
miniToggle.AutoButtonColor = false
Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(1, 0)
miniToggle.Visible = false
miniToggle.Parent = gui

-- TopBar (draggable, close/minimize)
local topBar = Instance.new("Frame", window)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Position = UDim2.new(0, 0, 0, 0)
-- Để vẫn trong suốt nhưng đảm bảo nhận input
topBar.BackgroundTransparency = 1
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.Active = true  -- để nhận input
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
        miniToggle.Visible = true
    end)

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

-- Drag window: cải tiến
do
    local dragging = false
    local dragStartPos = nil
    local startWindowPos = nil

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and window.Visible then
            dragging = true
            dragStartPos = input.Position
            startWindowPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and window.Visible then
            local delta = input.Position - dragStartPos
            window.Position = UDim2.new(
                startWindowPos.X.Scale,
                startWindowPos.X.Offset + delta.X,
                startWindowPos.Y.Scale,
                startWindowPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- MiniToggle click to restore window
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
end)

-- Sidebar & ContentContainer
local sidebar = Instance.new("Frame", window)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 120, 1, -30)
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local contentContainer = Instance.new("Frame", window)
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -120, 1, -30)
contentContainer.Position = UDim2.new(0, 120, 0, 30)
contentContainer.BackgroundTransparency = 1

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

local tabs = {
    { Name = "Movement", Emoji = "🏃" },
    { Name = "ESP",      Emoji = "🔍" },
    { Name = "Optimize", Emoji = "⚡" },
    { Name = "GunAura",  Emoji = "🔫" },
    { Name = "Settings", Emoji = "⚙️" },
}

local tabButtons = {}
local tabContentFrames = {}

local function setButtonActive(button, active)
    if active then
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
end

for index, tabInfo in ipairs(tabs) do
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

    local lbl = Instance.new("TextLabel", btn)
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 40, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabInfo.Name
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local frame = Instance.new("ScrollingFrame")
    frame.Name = "Content_" .. tabInfo.Name
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 6
    frame.ScrollingEnabled = true
    frame.Parent = contentContainer

    -- Tự động cập nhật CanvasSize dựa trên UIListLayout.AbsoluteContentSize
    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    -- Khi nội dung thay đổi, cập nhật CanvasSize
    local function updateCanvas()
        frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()

    frame.Visible = false

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

-- Mặc định tab đầu hiển thị
if #tabs > 0 then
    local firstName = tabs[1].Name
    tabButtons[firstName].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabContentFrames[firstName].Visible = true
end

-- Helper UI functions
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

    -- Cập nhật CanvasSize của parent ScrollingFrame khi thêm phần tử
    local parentLayout = parent:FindFirstChildOfClass("UIListLayout")
    if parentLayout and parent:IsA("ScrollingFrame") then
        parentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            parent.CanvasSize = UDim2.new(0, 0, 0, parentLayout.AbsoluteContentSize.Y + 4)
        end)
        parent.CanvasSize = UDim2.new(0, 0, 0, parentLayout.AbsoluteContentSize.Y + 4)
    end

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

    -- Cập nhật CanvasSize của parent ScrollingFrame khi thêm phần tử
    local parentLayout = parent:FindFirstChildOfClass("UIListLayout")
    if parentLayout and parent:IsA("ScrollingFrame") then
        parentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            parent.CanvasSize = UDim2.new(0, 0, 0, parentLayout.AbsoluteContentSize.Y + 4)
        end)
        parent.CanvasSize = UDim2.new(0, 0, 0, parentLayout.AbsoluteContentSize.Y + 4)
    end

    return toggle
end

-- Initialize tab contents

-- Movement Tab
do
    local parent = tabContentFrames["Movement"]
    if parent then
        createInput(parent, "WalkSpeed", function() return savedWalkSpeed end, function(v)
            savedWalkSpeed = v
            if Humanoid then pcall(function() Humanoid.WalkSpeed = v end) end
            notify("WalkSpeed", "Set to " .. v, 2)
        end)
        createInput(parent, "JumpPower", function() return savedJumpPower end, function(v)
            savedJumpPower = v
            if Humanoid then pcall(function() Humanoid.JumpPower = v end) end
            notify("JumpPower", "Set to " .. v, 2)
        end)
        createInput(parent, "FOV", function() return Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70 end, function(v)
            if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = v end
            notify("FOV", "Set to " .. v, 2)
        end)
        createSwitch(parent, "Semi-God Mode", function(on)
            semiGodModeEnabled = on
            notify("Semi-God Mode", on and "ON" or "OFF", 2)
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
            end
        end)
        createSwitch(parent, "FPS Booster", function(on)
            fpsBoosterEnabled = on
            if on then
                notify("FPS Booster", "ON. Reload to restore.", 3)
            else
                notify("FPS Booster", "OFF. Reload to restore.", 3)
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
                notify("GunAura", "ON", 2)
            else
                for drop,_ in pairs(gunDrops) do cleanupGunAuraForDrop(drop) end
                notify("GunAura", "OFF", 2)
            end
        end)
        createInput(parent, "Gun Aura Radius", function() return gunAuraRadius end, function(v)
            gunAuraRadius = v
            notify("GunAura Radius", tostring(v), 2)
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
    end
end

-- End of script
