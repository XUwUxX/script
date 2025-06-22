-- Kevinz Hub Refactored Script v1.31 (Fix movement persistence)
-- Chạy client, LocalScript trong StarterPlayerScripts hoặc StarterGui

-- ================= Services =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

-- ================= Biến toàn cục =================
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart = nil, nil, nil
local Camera = workspace.CurrentCamera

-- Phiên bản
local HUB_VERSION = "v1.31 (Movement Persistence)"

-- Movement defaults: lấy giá trị mặc định một lần khi script load xong (nếu Character đã tồn tại)
local savedWalkSpeed = 16
local savedJumpPower = 50

-- Sau script load, nếu Character đã load, cập nhật giá trị khởi tạo:
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    local hum0 = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum0 then
        savedWalkSpeed = hum0.WalkSpeed or savedWalkSpeed
        savedJumpPower = hum0.JumpPower or savedJumpPower
    end
end

-- Semi-God Mode
local semiGodModeEnabled = false

-- Gun Aura state
local gunAuraEnabled = false
local gunAuraRadius = 10      -- Mặc định radius 10 studs; có thể thay đổi qua UI
local gunDrops = {}           -- [dropInstance] = true
local gunDropTouchedConns = {}-- [dropInstance] = connection
local gunAuraLoopThread = nil

-- Caching localRole: scan cả Backpack + Character
local localRole = "Unknown"

-- Optimize Performance state
local midnightEnabled = false
local fpsBoosterEnabled = false

-- Lưu original Lighting settings
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

-- Khi load xong
task.delay(1, function()
    notify("Kevinz Hub Loaded ✅", "Version: " .. HUB_VERSION, 4)
end)

-- ================= UI Setup =================
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.new(0.35, 0, 0.6, 0)
window.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
window.BorderSizePixel = 0
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
do
    local gradient = Instance.new("UIGradient", window)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(25, 15, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
    }
    gradient.Rotation = 90
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", window)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
end

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
    pad.PaddingLeft = UDim.new(0, 6)
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
end
do
    local nameLabel = Instance.new("TextLabel", topBar)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, 0, 0.7, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Kevinz Hub | " .. LocalPlayer.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.TextWrapped = true
    nameLabel.TextScaled = true
    nameLabel.LayoutOrder = 2
end
local minimizeButton = Instance.new("TextButton", topBar)
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.TextColor3 = Color3.fromRGB(240, 240, 240)
minimizeButton.AutoButtonColor = false
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(1, 0)
minimizeButton.LayoutOrder = 3
local closeScriptButton = Instance.new("TextButton", topBar)
closeScriptButton.Name = "CloseScriptButton"
closeScriptButton.Size = UDim2.new(0, 20, 0, 20)
closeScriptButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeScriptButton.Text = "X"
closeScriptButton.Font = Enum.Font.GothamBold
closeScriptButton.TextSize = 12
closeScriptButton.TextColor3 = Color3.fromRGB(240, 240, 240)
closeScriptButton.AutoButtonColor = false
Instance.new("UICorner", closeScriptButton).CornerRadius = UDim.new(1, 0)
closeScriptButton.LayoutOrder = 4

local content = Instance.new("ScrollingFrame", window)
content.Name = "ContentFrame"
content.Size = UDim2.new(1, -10, 1, -40)
content.Position = UDim2.new(0, 5, 0, 30)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Active = true
content.ZIndex = 2
do
    local uiList = Instance.new("UIListLayout", content)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 12)
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pad = Instance.new("UIPadding", content)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
end

local miniToggle = Instance.new("TextButton", gui)
miniToggle.Name = "MiniToggle"
miniToggle.Size = UDim2.new(0, 28, 0, 28)
miniToggle.Position = UDim2.new(0, 50, 1, -40)
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "+"
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextSize = 16
miniToggle.TextColor3 = Color3.fromRGB(240, 240, 240)
miniToggle.AutoButtonColor = false
Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(1, 0)
miniToggle.Visible = false

minimizeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
end)
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
end)
closeScriptButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
do
    local dragging = false
    local dragStart, startPos
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
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
    topBar.InputChanged:Connect(onInputChanged)
end
task.delay(1, function()
    window.Visible = true
    TweenService:Create(window, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()
end)

-- ================= Helper UI functions =================
local inputRow = 0
local ROW_HEIGHT = 30
local function createSection(title)
    inputRow = inputRow + 1
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Section_" .. inputRow
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = inputRow
    lbl.Parent = content
end
local function createInput(labelText, getDefault, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "InputRow_" .. inputRow
    container.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = inputRow
    container.Parent = content

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
local function createSwitch(labelText, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "SwitchRow_" .. inputRow
    container.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = inputRow
    container.Parent = content

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

-- ================= Role Detection Helper cho LocalPlayer =================
-- Logic getRole local giống cũ
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
        -- notify("Role Changed", "Bạn hiện là " .. localRole, 2)
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

-- ================= Thiết lập Character/Humanoid chung =================
local function onCharacterAdded(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if Humanoid then
        -- Áp dụng savedWalkSpeed & savedJumpPower từ trước lên Humanoid mới
        -- Nếu savedWalkSpeed đã do user thay đổi, sẽ giữ. Nếu default, cũng áp dụng default ban đầu.
        pcall(function()
            Humanoid.WalkSpeed = savedWalkSpeed
        end)
        pcall(function()
            Humanoid.JumpPower = savedJumpPower
        end)
        -- Lắng nghe HealthChanged cho Semi-God Mode
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

    -- Highlight đường đạn cho local player
    Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            local toolName = child.Name:lower()
            if toolName:find("gun") or toolName:find("revolver") then
                child.Equipped:Connect(function()
                    child.Activated:Connect(function()
                        if not Camera then Camera = workspace.CurrentCamera end
                        local origin = Camera.CFrame.Position
                        local direction = Camera.CFrame.LookVector * 500
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local result = workspace:Raycast(origin, direction, rayParams)
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
                        part.Parent = workspace
                        Debris:AddItem(part, 0.5)
                    end)
                end)
            end
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    -- Nếu Character đã tồn tại khi script load, gọi onCharacterAdded ngay
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

-- ================= ESP from esp.lua (Dot ESP) =================
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

    local gui = head:FindFirstChild("DotESP")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "DotESP"
        gui.Adornee = head
        gui.Size = UDim2.new(0, 12, 0, 12)
        gui.AlwaysOnTop = true
        gui.LightInfluence = 0
        gui.StudsOffset = Vector3.new(0, 1, 0)
        gui.Parent = head

        local frame = Instance.new("Frame")
        frame.Name = "Dot"
        frame.BackgroundColor3 = color
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.AnchorPoint = Vector2.new(0.5,0.5)
        frame.Position = UDim2.new(0.5,0,0.5,0)
        frame.Size = UDim2.new(1,0,1,0)
        frame.Parent = gui
    else
        local frame = gui:FindFirstChild("Dot")
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
local espGlobalConns = {}

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
    notify("ESP Enabled", "Dot ESP đã bật.", 3)
end

local function disableESP()
    if not espEnabled then return end
    espEnabled = false
    if espGlobalConns.playerAdded then espGlobalConns.playerAdded:Disconnect() end
    if espGlobalConns.renderStepped then espGlobalConns.renderStepped:Disconnect() end
    espGlobalConns = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            teardownESPForPlayer(player)
        end
    end
    notify("ESP Disabled", "Dot ESP đã tắt.", 3)
end

-- ================= Setup notification khi player chết =================
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

-- ================= Optimize Midnight & FPS Booster =================
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
        if child:IsA("Sky") then pcall(function() child:Destroy() end) end
    end
    notify("Midnight Sky", "Ánh sáng tối đã bật.", 3)
    Lighting.DescendantAdded:Connect(function(obj)
        if obj:IsA("Sky") then pcall(function() obj:Destroy() end) end
    end)
end
local function restoreOriginalSky()
    Lighting.ClockTime = originalLightingSettings.ClockTime or 12
    Lighting.Brightness = originalLightingSettings.Brightness or 2
    Lighting.Ambient = originalLightingSettings.Ambient or Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient or Color3.new(1, 1, 1)
    Lighting.FogColor = originalLightingSettings.FogColor or Color3.new(0.7, 0.7, 0.7)
    Lighting.FogStart = originalLightingSettings.FogStart or 0
    Lighting.FogEnd = originalLightingSettings.FogEnd or 1000
    Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
    Lighting.EnvironmentDiffuseScale = originalLightingSettings.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = originalLightingSettings.EnvironmentSpecularScale
    notify("Midnight Sky", "Restore ánh sáng ban đầu (có thể cần reload map).", 3)
end

local function applyFPSBooster()
    local function optimizePart(obj)
        if obj:IsA("BasePart") then
            pcall(function()
                obj.Material = Enum.Material.SmoothPlastic
                obj.Color = Color3.fromRGB(128, 128, 128)
                obj.CastShadow = false
                obj.Reflectance = 0
            end)
        end
        if obj:IsA("MeshPart") then
            pcall(function()
                obj.Material = Enum.Material.SmoothPlastic
                obj.Color = Color3.fromRGB(128, 128, 128)
                obj.CastShadow = false
                obj.Reflectance = 0
            end)
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function() obj.Transparency = 1 end)
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            pcall(function() obj.Enabled = false end)
        end
        if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            pcall(function() obj.Enabled = false end)
        end
        if obj:IsA("SpecialMesh") then
            pcall(function() obj.Scale = Vector3.new(0.1, 0.1, 0.1) end)
        end
    end
    for _, child in ipairs(workspace:GetChildren()) do
        task.spawn(function()
            for _, obj in ipairs(child:GetDescendants()) do
                optimizePart(obj)
            end
        end)
    end
    workspace.DescendantAdded:Connect(function(obj)
        optimizePart(obj)
    end)
    notify("FPS Booster", "FPS Booster đã bật: render đơn giản màu xám. Để restore, reload game hoặc restore thủ công.", 4)
end

-- ================= Gun Aura functions =================
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
    if gunAuraLoopThread then
        -- thread sẽ tự dừng khi gunAuraEnabled = false
    end
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

-- ================= UI Controls =================
inputRow = 0
-- Movement Settings
createSection("Movement Settings")
createInput("WalkSpeed", function() return savedWalkSpeed end, function(v)
    savedWalkSpeed = v
    if Humanoid then
        pcall(function() Humanoid.WalkSpeed = v end)
    end
end)
createInput("JumpPower", function() return savedJumpPower end, function(v)
    savedJumpPower = v
    if Humanoid then
        pcall(function() Humanoid.JumpPower = v end)
    end
end)
createInput("FOV", function()
    if workspace.CurrentCamera then return workspace.CurrentCamera.FieldOfView end
    return 70
end, function(v)
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = v end
end)

-- Health & Semi-God
createSection("Health Settings")
local hpDisplayInput
createInput("Set HP (Attempt)", function() return Humanoid and Humanoid.Health or 100 end, function(v)
    if Humanoid then
        Humanoid.Health = math.clamp(v, 0, Humanoid.MaxHealth)
        notify("HP Adjustment", "Đã cố gắng điều chỉnh HP thành " .. v .. ". Server có thể override.", 3)
    end
end)
RunService.Heartbeat:Connect(function(dt)
    if not hpDisplayInput then
        local cont = content:FindFirstChild("InputRow_" .. inputRow)
        if cont then hpDisplayInput = cont:FindFirstChild("TextBox") end
    end
    if hpDisplayInput and Humanoid and Humanoid.Parent then
        hpDisplayInput.PlaceholderText = string.format("HP: %.0f/%.0f", Humanoid.Health, Humanoid.MaxHealth)
    end
end)
createSwitch("Semi-God Mode", function(on)
    semiGodModeEnabled = on
    if on then notify("Semi-God Mode", "Bật: HP sẽ hồi lại khi chết.", 3)
    else notify("Semi-God Mode", "Tắt: hoạt động bình thường.", 3) end
end)

-- Utilities
createSection("Utilities")
createSwitch("Hide Accessories", function(on)
    if on and LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Accessory") then
                local handle = item:FindFirstChild("Handle")
                if handle then handle.Transparency = 1 end
            end
        end
    end
end)

-- ESP Settings
createSection("ESP Settings")
createSwitch("ESP Dot + Weapon Highlight", function(on)
    if on then
        enableESP()
    else
        disableESP()
    end
end)

-- Gun Aura Settings
createSection("Gun Aura Settings")
createSwitch("Gun Aura (Touched + Radius)", function(on)
    gunAuraEnabled = on
    if on then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "GunDrop" then
                setupGunAuraOnDrop(obj)
            end
        end
        startGunAuraRadiusLoop()
        notify("Gun Aura", "Gun Aura đã bật: Touched & Radius.", 3)
    else
        gunAuraEnabled = false
        for drop, _ in pairs(gunDrops) do
            cleanupGunAuraForDrop(drop)
        end
        notify("Gun Aura", "Gun Aura đã tắt.", 3)
    end
end)
createInput("Gun Aura Radius", function() return gunAuraRadius end, function(v)
    if v and v >= 0 then
        gunAuraRadius = v
        notify("Gun Aura Radius", "Radius đặt thành " .. tostring(v) .. " studs.", 2)
    end
end)

-- Optimize Settings
createSection("Optimize Settings")
createSwitch("Midnight Sky Only", function(on)
    midnightEnabled = on
    if on then applyMidnightSky() else restoreOriginalSky() end
end)
createSwitch("FPS Booster", function(on)
    fpsBoosterEnabled = on
    if on then applyFPSBooster()
    else notify("FPS Booster", "Không thể restore tự động. Reload game hoặc restore thủ công.", 5) end
end)

-- ================= Setup PlayerAdded và Death Notifications =================
for _, player in ipairs(Players:GetPlayers()) do 
    setupDeathNotification(player)
end
Players.PlayerAdded:Connect(function(player) 
    setupDeathNotification(player)
end)

-- ================= Listen workspace drop events cho GunAura =================
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        setupGunAuraOnDrop(obj)
    end
end)
workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        cleanupGunAuraForDrop(obj)
    end
end)
