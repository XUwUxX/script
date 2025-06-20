-- Kevinz Hub Refactored Script v1.23
-- Chạy client, LocalScript trong StarterPlayerScripts hoặc StarterGui
-- Tối ưu GunAura và FPS Booster để giảm lag

-- ================= Services =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserSettings = UserSettings()

-- ================= Biến toàn cục =================
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart = nil, nil, nil

-- Saved defaults
local savedWalkSpeed = 16
local savedJumpPower = 50
local HUB_VERSION = "v1"

-- Anti Features state
local lastSafeCFrame = nil

-- Semi-God Mode
local semiGodModeEnabled = false

-- Gun Aura state
local gunAuraEnabled = false
local auraDistance = 10
local auraCooldown = 5
local lastAuraTimes = {}   -- [dropInstance] = lastTime
local gunDropList = {}     -- [dropInstance] = true

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
local function createButton(labelText, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "ButtonRow_" .. inputRow
    container.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = inputRow
    container.Parent = content

    local btn = Instance.new("TextButton", container)
    btn.Name = "Button"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = labelText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        pcall(function() callback() end)
    end)
end

-- ================= Thiết lập Character/Humanoid =================
local function onCharacterAdded(char)
    Character = char
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    -- Lưu defaults lần đầu
    if Humanoid then
        savedWalkSpeed = Humanoid.WalkSpeed
        savedJumpPower = Humanoid.JumpPower
    end
    -- Thiết lập AntiFeatures
    if RootPart then lastSafeCFrame = RootPart.CFrame end
    if Humanoid then
        Humanoid.HealthChanged:Connect(function(h)
            if semiGodModeEnabled and Humanoid and Humanoid.Parent and h<=0 then
                Humanoid.Health = 1
                Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                task.delay(2.5, function()
                    if Humanoid and Humanoid.Parent and Humanoid:GetState()==Enum.HumanoidStateType.Physics then
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end)
            end
        end)
        Humanoid.StateChanged:Connect(function(_, newState)
            if (newState==Enum.HumanoidStateType.Landed or newState==Enum.HumanoidStateType.Running)
            and RootPart and RootPart.Parent and Humanoid.FloorMaterial~=Enum.Material.Air then
                lastSafeCFrame = RootPart.CFrame
            end
        end)
    end
    -- Gộp Heartbeat cho AntiFeatures + GunAura throttle
    local auraTimer = 0
    RunService.Heartbeat:Connect(function(dt)
        -- Anti Void / Anti Fling
        if RootPart and RootPart.Parent then
            if RootPart.Position.Y < (workspace.FallenPartsDestroyHeight or -500) and lastSafeCFrame then
                RootPart.CFrame = lastSafeCFrame + Vector3.new(0,5,0)
            end
            if Humanoid then
                local st = Humanoid:GetState()
                local isFallOrJump = (st==Enum.HumanoidStateType.Freefall or st==Enum.HumanoidStateType.Jumping)
                if RootPart.AssemblyLinearVelocity.Magnitude>200 and not isFallOrJump and lastSafeCFrame then
                    RootPart.CFrame = lastSafeCFrame + Vector3.new(0,3,0)
                end
            end
        end
        -- Gun Aura throttled: mỗi 0.3s mới check
        if gunAuraEnabled then
            auraTimer = auraTimer + dt
            if auraTimer >= 0.3 then
                auraTimer = 0
                -- Chỉ lặp qua gunDropList
                local now = tick()
                for dropObj,_ in pairs(gunDropList) do
                    if dropObj and dropObj.Parent then
                        local success, dist = pcall(function()
                            return (dropObj.Position - RootPart.Position).Magnitude
                        end)
                        if success and dist and dist<=auraDistance then
                            local lastT = lastAuraTimes[dropObj] or 0
                            if now - lastT >= auraCooldown then
                                lastAuraTimes[dropObj] = now
                                local orig = RootPart.CFrame
                                pcall(function()
                                    RootPart.CFrame = dropObj.CFrame + Vector3.new(0,3,0)
                                end)
                                -- Nếu muốn restore: delay và restore orig
                                task.delay(0.2, function()
                                    -- pcall(function() RootPart.CFrame = orig end)
                                end)
                                break
                            end
                        end
                    else
                        gunDropList[dropObj] = nil
                    end
                end
            end
        end
    end)
    -- Nếu Midnight đang bật khi respawn
    if midnightEnabled then
        Lighting.ClockTime = 0
        Lighting.Brightness = 35
        Lighting.Ambient = Color3.new(0,0,0)
        Lighting.OutdoorAmbient = Color3.new(0,0,0)
        Lighting.FogColor = Color3.new(0,0,0)
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e3
        Lighting.GlobalShadows = false
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then pcall(function() child:Destroy() end) end
        end
    end
    -- Nếu FPS Booster đang bật, scan hiện hữu theo nhóm cấp 1 để tránh lag
    if fpsBoosterEnabled then
        local function optimizePart(obj)
            if obj:IsA("BasePart") then
                pcall(function()
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Color = Color3.fromRGB(128,128,128)
                    obj.CastShadow = false
                    obj.Reflectance = 0
                end)
            end
            if obj:IsA("MeshPart") then
                pcall(function()
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Color = Color3.fromRGB(128,128,128)
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
                pcall(function() obj.Scale = Vector3.new(0.1,0.1,0.1) end)
            end
        end
        -- Scan các con cấp 1 của workspace để tránh lag scan quá lớn
        for _, child in ipairs(workspace:GetChildren()) do
            -- Nếu bạn biết folder cụ thể (ví dụ workspace.Map), chỉ scan trong đó để tối ưu
            task.spawn(function()
                for _, obj in ipairs(child:GetDescendants()) do
                    optimizePart(obj)
                end
            end)
        end
    end
end

-- Kết nối CharacterAdded
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- ================= Role Detection Helper =================
local roleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff  = Color3.fromRGB(50, 150, 255),
    Innocent = Color3.fromRGB(50, 255, 80),
    Unknown  = Color3.fromRGB(180, 180, 180),
}
local function getRole(player)
    local hasKnife, hasGun = false, false
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n=tool.Name:lower()
            if n:find("knife") or n:find("blade") then hasKnife=true end
            if n:find("gun") or n:find("revolver") then hasGun=true end
        end
    end
    if player.Character then
        for _, child in ipairs(player.Character:GetChildren()) do
            if child:IsA("Tool") then
                local n=child.Name:lower()
                if n:find("knife") or n:find("blade") then hasKnife=true end
                if n:find("gun") or n:find("revolver") then hasGun=true end
            end
        end
    end
    if hasKnife and not hasGun then return "Murderer"
    elseif hasGun and not hasKnife then return "Sheriff"
    elseif not hasGun and not hasKnife then return "Innocent"
    else return "Unknown" end
end

-- ================= ESP Manager (event-driven) =================
local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager.new()
    local self = setmetatable({}, ESPManager)
    self.weaponHighlights = {}       -- [player] = { [tool] = highlight }
    self.playerConnections = {}      -- [player] = { list of Conns }
    self.dropHighlights = {}         -- [BasePart] = highlight
    self.playerAddedConn = nil
    self.descendantAddedConn = nil
    self.descendantRemovingConn = nil
    return self
end

function ESPManager:updateDotESP(player)
    if not espEnabled or player==LocalPlayer then return end
    local char=player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local role=getRole(player)
    local color=roleColors[role] or roleColors.Unknown
    local head=char.Head
    local guiESP=head:FindFirstChild("DotESP")
    if not guiESP then
        guiESP=Instance.new("BillboardGui")
        guiESP.Name="DotESP"
        guiESP.Adornee=head
        guiESP.Size=UDim2.new(0,12,0,12)
        guiESP.AlwaysOnTop=true
        guiESP.LightInfluence=0
        guiESP.StudsOffset=Vector3.new(0,1,0)
        guiESP.Parent=head
        local frame=Instance.new("Frame",guiESP)
        frame.Name="Dot"
        frame.BackgroundColor3=color
        frame.BackgroundTransparency=0
        frame.BorderSizePixel=0
        frame.AnchorPoint=Vector2.new(0.5,0.5)
        frame.Position=UDim2.new(0.5,0,0.5,0)
        frame.Size=UDim2.new(1,0,1,0)
    else
        local frame=guiESP:FindFirstChild("Dot")
        if frame then frame.BackgroundColor3=color end
    end
end

function ESPManager:clearDotESP(player)
    local char=player.Character
    if char and char:FindFirstChild("Head") then
        local e=char.Head:FindFirstChild("DotESP")
        if e then e:Destroy() end
    end
end

function ESPManager:addWeaponHighlight(player,toolInstance)
    if not espEnabled or not toolInstance or not toolInstance:IsA("Tool") then return end
    if not self.weaponHighlights[player] then self.weaponHighlights[player]={} end
    if self.weaponHighlights[player][toolInstance] then return end
    local nameLower=toolInstance.Name:lower()
    local color=Color3.fromRGB(255,255,255)
    if nameLower:find("knife") or nameLower:find("blade") then color=Color3.fromRGB(160,32,240)
    elseif nameLower:find("gun") or nameLower:find("revolver") then color=Color3.fromRGB(100,150,255) end
    local handle=toolInstance:FindFirstChildWhichIsA("BasePart") or toolInstance:FindFirstChild("Handle")
    if not handle then return end
    local hl=Instance.new("Highlight")
    hl.Name="_ESP_WEAPON"
    hl.FillTransparency=1
    hl.OutlineColor=color
    hl.OutlineTransparency=0.2
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee=handle
    hl.Parent=handle
    self.weaponHighlights[player][toolInstance]=hl
end

function ESPManager:clearWeaponHighlightsForPlayer(player)
    local tbl=self.weaponHighlights[player]
    if tbl then
        for toolInst,hl in pairs(tbl) do
            if hl and hl.Parent then hl:Destroy() end
        end
    end
    self.weaponHighlights[player]=nil
end

function ESPManager:setupPlayer(player)
    local conns={}
    self.playerConnections[player]=conns
    local charAddedConn=player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Head",5)
        if espEnabled then self:updateDotESP(player) end
        local childAddedConn=char.ChildAdded:Connect(function(child)
            if espEnabled and child:IsA("Tool") then
                task.delay(0.1,function()
                    self:addWeaponHighlight(player,child)
                    self:updateDotESP(player)
                end)
            end
        end)
        local childRemovedConn=char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                if self.weaponHighlights[player] and self.weaponHighlights[player][child] then
                    local hl=self.weaponHighlights[player][child]
                    if hl and hl.Parent then hl:Destroy() end
                    self.weaponHighlights[player][child]=nil
                end
                if espEnabled then self:updateDotESP(player) end
            end
        end)
        table.insert(conns,childAddedConn)
        table.insert(conns,childRemovedConn)
    end)
    table.insert(conns,charAddedConn)
    if player.Character and player.Character:FindFirstChild("Head") then
        if espEnabled then self:updateDotESP(player) end
    end
    local backpackAddedConn=player.Backpack.ChildAdded:Connect(function(child)
        if espEnabled and child:IsA("Tool") then
            task.delay(0.1,function() self:updateDotESP(player) end)
        end
    end)
    local backpackRemovedConn=player.Backpack.ChildRemoved:Connect(function(child)
        if espEnabled and child:IsA("Tool") then
            task.delay(0.1,function() self:updateDotESP(player) end)
        end
    end)
    table.insert(conns,backpackAddedConn)
    table.insert(conns,backpackRemovedConn)
    local playerRemovingConn=player.AncestryChanged:Connect(function(_,parent)
        if not parent then self:teardownPlayer(player) end
    end)
    table.insert(conns,playerRemovingConn)
end

function ESPManager:teardownPlayer(player)
    local conns=self.playerConnections[player]
    if conns then
        for _,conn in ipairs(conns) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
    end
    self.playerConnections[player]=nil
    self:clearDotESP(player)
    self:clearWeaponHighlightsForPlayer(player)
end

function ESPManager:onDropAdded(obj)
    if not espEnabled then return end
    if obj:IsA("BasePart") and obj.Name=="GunDrop" then
        if not self.dropHighlights[obj] then
            local hl=Instance.new("Highlight")
            hl.Name="_ESP_GUNDROP"
            hl.Adornee=obj
            hl.FillColor=Color3.fromRGB(255,20,147)
            hl.OutlineColor=Color3.fromRGB(255,20,147)
            hl.FillTransparency=0.8
            hl.OutlineTransparency=0.2
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent=obj
            self.dropHighlights[obj]=hl
        end
        -- Thêm vào gunDropList để GunAura dùng
        gunDropList[obj]=true
    elseif obj:IsA("BasePart") and obj.Name=="KnifeDrop" then
        if not self.dropHighlights[obj] then
            local hl=Instance.new("Highlight")
            hl.Name="_ESP_KNIFEDROP"
            hl.Adornee=obj
            hl.FillColor=Color3.fromRGB(160,32,240)
            hl.OutlineColor=Color3.fromRGB(200,100,200)
            hl.FillTransparency=0.8
            hl.OutlineTransparency=0.2
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent=obj
            self.dropHighlights[obj]=hl
        end
        -- Nếu bạn có KnifeAura tương tự, có thể thêm knifeDropList
    end
end

function ESPManager:onDropRemoved(obj)
    local hl=self.dropHighlights[obj]
    if hl then if hl.Parent then hl:Destroy() end end
    self.dropHighlights[obj]=nil
    -- Xóa khỏi gunDropList nếu có
    if gunDropList[obj] then gunDropList[obj]=nil end
end

function ESPManager:Enable()
    if espEnabled then return end
    espEnabled=true
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LocalPlayer then self:setupPlayer(player) end
    end
    self.playerAddedConn=Players.PlayerAdded:Connect(function(player)
        if player~=LocalPlayer then self:setupPlayer(player) end
    end)
    self.dropHighlights={}  -- reset
    -- Scan existing drops: chỉ thêm vào gunDropList và highlight
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name=="GunDrop" or obj.Name=="KnifeDrop") then
            self:onDropAdded(obj)
        end
    end
    self.descendantAddedConn=workspace.DescendantAdded:Connect(function(obj)
        self:onDropAdded(obj)
    end)
    self.descendantRemovingConn=workspace.DescendantRemoving:Connect(function(obj)
        self:onDropRemoved(obj)
    end)
    notify("ESP Enabled", "Dot ESP, Weapon & Drop Highlight đã bật (event-driven).", 3)
end

function ESPManager:Disable()
    if not espEnabled then return end
    espEnabled=false
    if self.playerAddedConn then self.playerAddedConn:Disconnect(); self.playerAddedConn=nil end
    if self.descendantAddedConn then self.descendantAddedConn:Disconnect(); self.descendantAddedConn=nil end
    if self.descendantRemovingConn then self.descendantRemovingConn:Disconnect(); self.descendantRemovingConn=nil end
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LocalPlayer then self:teardownPlayer(player) end
    end
    for obj,hl in pairs(self.dropHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    self.dropHighlights={}
    -- Clear gunDropList
    gunDropList={}
    notify("ESP Disabled", "Dot ESP, Weapon & Drop Highlight đã tắt.", 3)
end

local espManager=ESPManager.new()

-- ================= Setup notification khi player chết =================
local function setupDeathNotification(player)
    player.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid",5)
        if hum then
            hum.Died:Connect(function()
                local role=getRole(player)
                if role=="Sheriff" or role=="Murderer" then
                    notify(role.." Died", player.Name.." ("..role..") đã chết.", 4)
                end
            end)
        end
    end)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum=player.Character:FindFirstChild("Humanoid")
        hum.Died:Connect(function()
            local role=getRole(player)
            if role=="Sheriff" or role=="Murderer" then
                notify(role.." Died", player.Name.." ("..role..") đã chết.", 4)
            end
        end)
    end
end

-- ================= Optimize Midnight & FPS Booster =================
local function applyMidnightSky()
    Lighting.ClockTime=0
    Lighting.Brightness=35
    Lighting.Ambient=Color3.new(0,0,0)
    Lighting.OutdoorAmbient=Color3.new(0,0,0)
    Lighting.FogColor=Color3.new(0,0,0)
    Lighting.FogStart=0
    Lighting.FogEnd=1e3
    Lighting.GlobalShadows=false
    Lighting.EnvironmentDiffuseScale=0
    Lighting.EnvironmentSpecularScale=0
    for _,child in ipairs(Lighting:GetChildren()) do
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
    Lighting.Ambient = originalLightingSettings.Ambient or Color3.new(1,1,1)
    Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient or Color3.new(1,1,1)
    Lighting.FogColor = originalLightingSettings.FogColor or Color3.new(0.7,0.7,0.7)
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
                obj.Material=Enum.Material.SmoothPlastic
                obj.Color=Color3.fromRGB(128,128,128)
                obj.CastShadow=false
                obj.Reflectance=0
            end)
        end
        if obj:IsA("MeshPart") then
            pcall(function()
                obj.Material=Enum.Material.SmoothPlastic
                obj.Color=Color3.fromRGB(128,128,128)
                obj.CastShadow=false
                obj.Reflectance=0
            end)
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function() obj.Transparency=1 end)
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            pcall(function() obj.Enabled=false end)
        end
        if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            pcall(function() obj.Enabled=false end)
        end
        if obj:IsA("SpecialMesh") then
            pcall(function() obj.Scale=Vector3.new(0.1,0.1,0.1) end)
        end
    end
    -- Scan hiện hữu theo nhóm cấp 1 workspace
    for _,child in ipairs(workspace:GetChildren()) do
        task.spawn(function()
            for _,obj in ipairs(child:GetDescendants()) do
                optimizePart(obj)
            end
        end)
    end
    -- Listener
    workspace.DescendantAdded:Connect(function(obj)
        optimizePart(obj)
    end)
    notify("FPS Booster", "FPS Booster đã bật: render đơn giản màu xám. Để restore, reload game hoặc thủ công.", 4)
end

-- ================= UI Controls =================
inputRow=0
-- Movement Settings
createSection("Movement Settings")
createInput("WalkSpeed", function() return savedWalkSpeed end, function(v)
    savedWalkSpeed=v
    if Humanoid then Humanoid.WalkSpeed=v end
end)
createInput("JumpPower", function() return savedJumpPower end, function(v)
    savedJumpPower=v
    if Humanoid then Humanoid.JumpPower=v end
end)
createInput("FOV", function()
    if workspace.CurrentCamera then return workspace.CurrentCamera.FieldOfView end
    return 70
end, function(v)
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=v end
end)

-- Health & Semi-God
createSection("Health Settings")
local hpDisplayInput
createInput("Set HP (Attempt)", function() return Humanoid and Humanoid.Health or 100 end, function(v)
    if Humanoid then
        Humanoid.Health = math.clamp(v,0,Humanoid.MaxHealth)
        notify("HP Adjustment", "Đã cố gắng điều chỉnh HP thành "..v..". Server có thể override.", 3)
    end
end)
RunService.Heartbeat:Connect(function()
    if not hpDisplayInput then
        local cont=content:FindFirstChild("InputRow_"..inputRow)
        if cont then hpDisplayInput=cont:FindFirstChild("TextBox") end
    end
    if hpDisplayInput and Humanoid and Humanoid.Parent then
        hpDisplayInput.PlaceholderText=string.format("HP: %.0f/%.0f",Humanoid.Health,Humanoid.MaxHealth)
    end
end)
createSwitch("Semi-God Mode", function(on)
    semiGodModeEnabled=on
    if on then notify("Semi-God Mode","Bật: HP sẽ hồi lại khi chết.",3)
    else notify("Semi-God Mode","Tắt: hoạt động bình thường.",3) end
end)

-- Utilities
createSection("Utilities")
createSwitch("Hide Accessories", function(on)
    if on and LocalPlayer.Character then
        for _,item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Accessory") then
                local handle=item:FindFirstChild("Handle")
                if handle then handle.Transparency=1 end
            end
        end
    end
end)
createButton("Fix Lag + Lower CPU Load (Deep)", function()
    notify("Use separate switches for Midnight Sky and FPS Booster.","Vui lòng dùng riêng switch.",4)
end)

-- ESP Settings
createSection("ESP Settings")
createSwitch("ESP Dot + Weapon & Drop Highlight", function(on)
    if on then espManager:Enable() else espManager:Disable() end
end)

-- Gun Aura Settings
createSection("Gun Aura Settings")
createSwitch("Gun Aura (Auto Grab GunDrop)", function(on)
    gunAuraEnabled=on
    if on then notify("Gun Aura","Auto Grab GunDrop đã bật.",3)
    else notify("Gun Aura","Auto Grab GunDrop đã tắt.",3) end
end)
createInput("Aura Distance", function() return auraDistance end, function(v)
    auraDistance=v; notify("Gun Aura","Đã đặt Aura Distance = "..tostring(v),2)
end)
createInput("Aura Cooldown (s)", function() return auraCooldown end, function(v)
    auraCooldown=v; notify("Gun Aura","Đã đặt Aura Cooldown = "..tostring(v).."s",2)
end)

-- Optimize Settings
createSection("Optimize Settings")
createSwitch("Midnight Sky Only", function(on)
    midnightEnabled=on
    if on then applyMidnightSky() else restoreOriginalSky() end
end)
createSwitch("FPS Booster", function(on)
    fpsBoosterEnabled=on
    if on then applyFPSBooster()
    else notify("FPS Booster","Không thể restore tự động. Reload game hoặc restore thủ công.",5) end
end)

-- ================= Setup PlayerAdded và Death Notifications =================
for _,player in ipairs(Players:GetPlayers()) do setupDeathNotification(player) end
Players.PlayerAdded:Connect(function(player) setupDeathNotification(player) end)

-- ================= End of Script v1.23 =================

