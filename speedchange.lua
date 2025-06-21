-- Kevinz Hub Full Script v2.0 - User-Friendly & Tabbed GUI
-- - Tab-based GUI for better organization
-- - Manual dragging UI
-- - ESP Outline by role + Weapon Highlight + Drop Highlight (GunDrop pink, KnifeDrop purple), loop 0.7s
-- - Gun Aura (auto grab GunDrop) independent of ESP, with Aura Distance and Aura Cooldown
-- - Notification when Sheriff/Hero dies, when GunDrop/KnifeDrop appear (when ESP is enabled)
-- - Anti Features, Semi-God Mode, Movement Settings, Health Settings, Utilities
-- - OptimizePerformanceWithListener: deep optimization: midnight sky, disable effects, reduce render detail, override print/warn, event-driven disable new objects.

-- ================= SERVICES & LOCAL REFS =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserSettings = UserSettings()
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Saved defaults (use table for better organization)
local Settings = {
    WalkSpeed = Humanoid.WalkSpeed,
    JumpPower = Humanoid.JumpPower,
    FOV = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70,
    SemiGodModeEnabled = false,
    ESPSettings = {
        Enabled = false,
        RoleColors = {
            Murderer = Color3.fromRGB(255, 50, 50),       -- Đỏ
            SheriffOrHero = Color3.fromRGB(50, 150, 255), -- Xanh dương
            Innocent = Color3.fromRGB(50, 255, 80),       -- Xanh lá
            Unknown = Color3.fromRGB(180, 180, 180)       -- Xám
        },
        UpdateInterval = 0.3, -- Giảm tần suất update ESP xuống 0.3s cho hiệu suất tốt hơn
        LastRole = {},
        LastCharacter = {},
        ActiveDotESPs = {},
        ActiveWeaponHighlights = {},
        ActiveDropHighlights = {},
    },
    GunAura = {
        Enabled = false,
        Distance = 50,
        Cooldown = 0.5, -- Giảm cooldown để nhặt nhanh hơn nhưng vẫn có throttle
        LastGrabTime = 0,
        ActiveGunDrops = {}, -- Thêm bảng để quản lý GunDrops
    },
    OptimizedPerformance = false,
    MidnightSkyEnabled = false,
    ReduceRenderDetailEnabled = false,
}

local HUB_VERSION = "v2.1 - Optimized" -- Cập nhật phiên bản

-- To store all connections for systematic disconnection
local activeConnections = {}
local function addConnection(conn)
    if conn then
        table.insert(activeConnections, conn)
    end
end
local function disconnectAllConnections()
    for _, conn in ipairs(activeConnections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    activeConnections = {}
end

-- ================= HELPER FUNCTIONS =================

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

-- ================= GUI SETUP =================
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5) -- Initial position for tween
window.Size = UDim2.new(0.4, 0, 0.7, 0) -- Slightly larger for tabs
window.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
window.BorderSizePixel = 0
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
local gradient = Instance.new("UIGradient", window)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(25, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
}
gradient.Rotation = 90
local stroke = Instance.new("UIStroke", window)
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 1

local topBar = Instance.new("Frame", window)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0
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

-- Tab Container
local tabContainer = Instance.new("Frame", window)
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundTransparency = 1
tabContainer.BorderSizePixel = 0
do
    local layout = Instance.new("UIListLayout", tabContainer)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 5)
end

-- Pages Container (holds individual tab content)
local pagesContainer = Instance.new("Frame", window)
pagesContainer.Name = "PagesContainer"
pagesContainer.Size = UDim2.new(1, -10, 1, -70) -- Adjusted for topBar + tabContainer
pagesContainer.Position = UDim2.new(0, 5, 0, 60)
pagesContainer.BackgroundTransparency = 1
pagesContainer.ClipsDescendants = true -- Important for hiding inactive pages

-- Mini toggle to reopen window
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

addConnection(minimizeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
end))
addConnection(miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
end))
addConnection(closeScriptButton.MouseButton1Click:Connect(function()
    disconnectAllConnections() -- Disconnect all before destroying GUI
    gui:Destroy()
end))
addConnection(gui.AncestryChanged:Connect(function()
    if not gui.Parent then
        disconnectAllConnections() -- Disconnect all if GUI is destroyed externally
    end
end))


do -- Manual dragging for window via topBar
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            window.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end
    addConnection(topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            addConnection(input.Changed:Connect(function() -- Connection for input.Changed needs to be managed
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end))
        end
    end))
    addConnection(topBar.InputChanged:Connect(onInputChanged))
end

task.delay(2, function()
    window.Visible = true
    TweenService:Create(window, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()
end)

-- ================= UI CREATION HELPERS (Adapted for Tabs) =================
local currentActivePage = nil
local ROW_HEIGHT = 30

local function createPage(name)
    local page = Instance.new("ScrollingFrame", pagesContainer)
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 6
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Active = true
    page.ZIndex = 2
    page.Visible = false -- Hidden by default
    do
        local uiList = Instance.new("UIListLayout", page)
        uiList.SortOrder = Enum.SortOrder.LayoutOrder
        uiList.Padding = UDim.new(0, 12)
        uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", page)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
    end
    return page
end

local function createTabButton(tabName, pageFrame)
    local tabButton = Instance.new("TextButton", tabContainer)
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1/4, 0, 1, 0) -- Adjust width based on number of tabs
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 14
    tabButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    tabButton.AutoButtonColor = false
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", tabButton).Color = Color3.fromRGB(60, 60, 60)
    Instance.new("UIStroke", tabButton).Thickness = 1

    addConnection(tabButton.MouseButton1Click:Connect(function()
        if currentActivePage then
            currentActivePage.Visible = false
            -- Reset previous tab button color
            local prevTabButton = tabContainer:FindFirstChild(currentActivePage.Name:gsub("Page", "Tab"))
            if prevTabButton then
                TweenService:Create(prevTabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end
        end
        pageFrame.Visible = true
        currentActivePage = pageFrame
        -- Highlight current tab button
        TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 0, 0)}):Play()
    end))
    return tabButton
end

local function createControl(parentFrame, labelText, controlType, defaultValue, callback)
    local order = #parentFrame:GetChildren() + 1 -- Simple layout order

    local container = Instance.new("Frame")
    container.Name = controlType .. "Row_" .. order
    container.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = order
    container.Parent = parentFrame

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

    if controlType == "Input" then
        local input = Instance.new("TextBox", container)
        input.Name = "TextBox"
        input.Size = UDim2.new(0.6, -16, 1, -4)
        input.Position = UDim2.new(0.4, 8, 0, 2)
        input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        input.TextColor3 = Color3.fromRGB(240, 240, 240)
        input.Text = ""
        input.PlaceholderText = tostring(defaultValue)
        input.ClearTextOnFocus = false
        input.Font = Enum.Font.Gotham
        input.TextSize = 14
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

        addConnection(input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local val = tonumber(input.Text)
                if val ~= nil then
                    pcall(function() callback(val) end)
                    input.PlaceholderText = tostring(val)
                end
                input.Text = ""
            end
        end))
        return input
    elseif controlType == "Switch" then
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

        local state = defaultValue -- Initialize state based on defaultValue
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(70, 70, 70)

        addConnection(toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = state and "ON" or "OFF"
            if state then
                TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 0)}):Play()
            else
                TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
            end
            pcall(function() callback(state) end)
        end))
        return toggle
    elseif controlType == "Button" then
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
        addConnection(btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
            task.delay(0.1, function()
                TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
            end)
            pcall(function() callback() end)
        end))
    end
end

local function createSectionHeader(parentFrame, title)
    local order = #parentFrame:GetChildren() + 1
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Section_" .. order
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parentFrame
end


-- ================= CORE LOGIC FUNCTIONS =================

-- Anti Features
local currentState = nil
local lastSafeCFrame = RootPart.CFrame

local function setupAntiFeatures()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if not Character or not Humanoid or not RootPart then return end

    addConnection(Humanoid.StateChanged:Connect(function(oldState, newState)
        currentState = newState
        if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
            if RootPart and RootPart.Parent and Humanoid.FloorMaterial ~= Enum.Material.Air then
                lastSafeCFrame = RootPart.CFrame
            end
        end
    end))
end

-- Semi-God Mode (Ragdoll instead of death)
local function onHealthChanged(health)
    if not Settings.SemiGodModeEnabled or not Humanoid or not Humanoid.Parent then return end
    if health <= 0 then
        Humanoid.Health = 1
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.delay(2.5, function()
            if Humanoid and Humanoid.Parent and Humanoid:GetState() == Enum.HumanoidStateType.Physics then
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Humanoid.Health = Humanoid.MaxHealth
            end
        end)
    end
end

-- Function to apply/remove Midnight Sky
local function applyMidnightSky(enable)
    pcall(function()
        -- Clear existing Sky objects (always clear if present, only add if enabling)
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                child:Destroy()
            end
        end

        if enable then
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
            notify("Midnight Sky", "Midnight Sky đã bật.", 3)
        else
            -- Reset to default Roblox lighting (approximate)
            Lighting.ClockTime = 14 -- Noon
            Lighting.Brightness = 2 -- Default brightness
            Lighting.Ambient = Color3.fromRGB(0,0,0) -- Default ambient
            Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127) -- Default outdoor ambient
            Lighting.FogColor = Color3.fromRGB(192, 203, 205) -- Default fog
            Lighting.FogStart = 0
            Lighting.FogEnd = 50000 -- Default large end
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
            notify("Midnight Sky", "Midnight Sky đã tắt. Đã đặt lại ánh sáng mặc định.", 3)
        end
    end)
end

-- Function to apply/remove render detail reduction for NEWLY ADDED OBJECTS
-- Initial scan is too laggy for large workspaces, rely on DescendantAdded for efficiency
local function applyRenderDetailReduction(enable)
    pcall(function()
        if enable then
            notify("Reduce Render Detail", "Giảm chi tiết render đã bật. Áp dụng cho các vật thể mới.", 3)
            -- Reduce Graphics Level (if not already lowest)
            local ugs = UserSettings:GetService("UserGameSettings")
            if ugs.SetRenderingQualityLevel then
                ugs:SetRenderingQualityLevel(1)
            elseif ugs.SetGraphicsQualityLevel then
                ugs:SetGraphicsQualityLevel(1)
            end

            -- Terrain: disable water effects
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
                terrain.CastShadow = false
            end
        else
            notify("Reduce Render Detail", "Giảm chi tiết render đã tắt. Các vật thể đã tối ưu sẽ không được hoàn nguyên.", 3)
            -- We do NOT attempt to revert properties of existing objects here
            -- as it can be very laggy on large workspaces.
            -- Instead, newly spawned objects will now have default properties.

            -- Reset Graphics Level (optional, as user might have custom settings)
            -- local ugs = UserSettings:GetService("UserGameSettings")
            -- if ugs.SetRenderingQualityLevel then
            --     ugs:SetRenderingQualityLevel(3) -- Or a medium value
            -- elseif ugs.SetGraphicsQualityLevel then
            --     ugs:SetGraphicsQualityLevel(3)
            -- end

            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0.1
                terrain.WaterWaveSpeed = 0.05
                terrain.WaterReflectance = 0.2
                terrain.WaterTransparency = 0.5
                terrain.CastShadow = true
            end
        end
    end)
end


-- ESP Logic
local function getRole(player)
    if not player or not player.Character then return "Unknown", Settings.ESPSettings.RoleColors.Unknown end

    local hasKnife, hasGun = false, false
    local items = {}
    if player.Backpack then
        for _, tool in ipairs(player.Backpack:GetChildren()) do table.insert(items, tool) end
    end
    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then table.insert(items, tool) end
        end
    end

    for _, tool in ipairs(items) do
        local n = tool.Name:lower()
        if n:find("knife") or n:find("blade") then hasKnife = true end
        if n:find("gun") or n:find("revolver") then hasGun = true end
    end

    local role
    if hasKnife and not hasGun then role = "Murderer"
    elseif hasGun and not hasKnife then role = "SheriffOrHero"
    elseif hasGun and hasKnife then role = "Unknown"
    else role = "Innocent"
    end
    return role, Settings.ESPSettings.RoleColors[role] or Settings.ESPSettings.RoleColors.Unknown
end

local function updateDotESP(player, currentRole, color)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end

    local head = char.Head
    local gui = Settings.ESPSettings.ActiveDotESPs[player]

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
        Settings.ESPSettings.ActiveDotESPs[player] = gui
    else
        local frame = gui:FindFirstChild("Dot")
        if frame then
            frame.BackgroundColor3 = color
        end
    end
end

local function clearDotESP(player)
    local gui = Settings.ESPSettings.ActiveDotESPs[player]
    if gui and gui.Parent then
        gui:Destroy()
    end
    Settings.ESPSettings.ActiveDotESPs[player] = nil
end

local function addWeaponHighlight(player, toolInstance)
    if not toolInstance or not toolInstance:IsA("Tool") then return end
    local handle = toolInstance:FindFirstChildWhichIsA("BasePart") or toolInstance:FindFirstChild("Handle")
    if not handle then return end

    if not Settings.ESPSettings.ActiveWeaponHighlights[player] then
        Settings.ESPSettings.ActiveWeaponHighlights[player] = {}
    end
    if Settings.ESPSettings.ActiveWeaponHighlights[player][toolInstance] then return end

    local nameLower = toolInstance.Name:lower()
    local color = Color3.fromRGB(255, 255, 255) -- Default
    if nameLower:find("knife") or nameLower:find("blade") then
        color = Color3.fromRGB(160, 32, 240) -- Purple for knives
    elseif nameLower:find("gun") or nameLower:find("revolver") then
        color = Color3.fromRGB(100, 150, 255) -- Blue for guns
    end

    local hl = Instance.new("Highlight")
    hl.Name = "_ESP_WEAPON"
    hl.FillTransparency = 1
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = handle
    hl.Parent = handle -- Parent to handle for easier cleanup

    Settings.ESPSettings.ActiveWeaponHighlights[player][toolInstance] = hl
end

local function clearWeaponHighlightsForPlayer(player)
    local tbl = Settings.ESPSettings.ActiveWeaponHighlights[player]
    if tbl then
        for tool, hl in pairs(tbl) do
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
    end
    Settings.ESPSettings.ActiveWeaponHighlights[player] = nil
end

local function highlightDrop(obj, dropType)
    if not obj:IsA("BasePart") then return end
    if Settings.ESPSettings.ActiveDropHighlights[obj] then return end

    local fillColor, outlineColor
    if dropType == "GunDrop" then
        fillColor = Color3.fromRGB(255, 20, 147) -- Deep Pink
        outlineColor = Color3.fromRGB(255, 20, 147)
    elseif dropType == "KnifeDrop" then
        fillColor = Color3.fromRGB(160, 32, 240) -- Purple
        outlineColor = Color3.fromRGB(200, 100, 200)
    else
        return -- Unknown drop type
    end

    local hl = Instance.new("Highlight")
    hl.Name = "_ESP_DROPHL"
    hl.Adornee = obj
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = 0.8
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
    Settings.ESPSettings.ActiveDropHighlights[obj] = hl
end

local function clearDropHighlight(obj)
    local hl = Settings.ESPSettings.ActiveDropHighlights[obj]
    if hl and hl.Parent then
        hl:Destroy()
    end
    Settings.ESPSettings.ActiveDropHighlights[obj] = nil
end

local espLoopRunning = false
local function startEspLoop()
    if espLoopRunning then return end
    espLoopRunning = true
    task.spawn(function()
        while Settings.ESPSettings.Enabled do
            -- Update Player ESP (Dot and Weapon)
            for _, player in ipairs(Players:GetPlayers()) do
                -- Only update if player's character exists
                if player.Character then
                    local char = player.Character
                    local currentRole, color = getRole(player)

                    -- Handle Character changes
                    if Settings.ESPSettings.LastCharacter[player] ~= char then
                        if Settings.ESPSettings.LastCharacter[player] then
                            clearDotESP(player)
                            clearWeaponHighlightsForPlayer(player)
                        end
                        Settings.ESPSettings.LastCharacter[player] = char
                        Settings.ESPSettings.LastRole[player] = nil -- Force update role ESP
                    end

                    -- Dot ESP update
                    if player ~= LocalPlayer and char:FindFirstChild("Head") then
                        if Settings.ESPSettings.LastRole[player] ~= currentRole then
                            updateDotESP(player, currentRole, color)
                            Settings.ESPSettings.LastRole[player] = currentRole
                        end
                    else
                        clearDotESP(player)
                    end

                    -- Weapon Highlight update
                    local activeWeaponHighlights = Settings.ESPSettings.ActiveWeaponHighlights[player] or {}
                    local currentWeapons = {}
                    for _, child in ipairs(char:GetChildren()) do
                        if child:IsA("Tool") then
                            currentWeapons[child] = true
                            if not activeWeaponHighlights[child] then
                                addWeaponHighlight(player, child)
                            end
                        end
                    end
                    -- Remove highlights for weapons no longer held
                    for toolInst, hl in pairs(activeWeaponHighlights) do
                        if not currentWeapons[toolInst] then
                            if hl and hl.Parent then hl:Destroy() end
                            activeWeaponHighlights[toolInst] = nil
                        end
                    end
                    Settings.ESPSettings.ActiveWeaponHighlights[player] = activeWeaponHighlights
                else
                    -- If character is gone, clear all associated ESP
                    clearDotESP(player)
                    clearWeaponHighlightsForPlayer(player)
                    Settings.ESPSettings.LastRole[player] = nil
                    Settings.ESPSettings.LastCharacter[player] = nil
                end
            end

            -- Clean up drop highlights for objects that no longer exist
            for obj, _ in pairs(Settings.ESPSettings.ActiveDropHighlights) do
                if not obj or not obj.Parent then
                    clearDropHighlight(obj)
                end
            end

            task.wait(Settings.ESPSettings.UpdateInterval)
        end
        -- Clean up all ESP elements when disabled
        for _, player in ipairs(Players:GetPlayers()) do
            clearDotESP(player)
            clearWeaponHighlightsForPlayer(player)
        end
        for obj, _ in pairs(Settings.ESPSettings.ActiveDropHighlights) do
            clearDropHighlight(obj)
        end
        espLoopRunning = false
    end)
end

-- Gun Aura Logic (Đã sửa đổi để thử nghiệm firetouchinterest)
local function checkAndGrabGunDrop()
    if not Settings.GunAura.Enabled or not RootPart or not Humanoid then return end
    local currentTime = tick()
    if currentTime - Settings.GunAura.LastGrabTime < Settings.GunAura.Cooldown then return end

    local currentRole, _ = getRole(LocalPlayer)
    if currentRole == "Murderer" then
        return -- Murderer không cần nhặt súng
    end

    local nearestGunDrop = nil
    local minDistance = Settings.GunAura.Distance

    -- Lặp qua danh sách gun drops đã được quản lý (được thêm khi DescendantAdded)
    for obj, _ in pairs(Settings.GunAura.ActiveGunDrops) do
        if obj and obj.Parent and obj:IsDescendantOf(Workspace) then -- Đảm bảo object vẫn tồn tại trong Workspace
            local distance = (RootPart.Position - obj.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestGunDrop = obj
            end
        else
            -- Nếu object không còn tồn tại, xóa nó khỏi danh sách
            Settings.GunAura.ActiveGunDrops[obj] = nil
        end
    end

    if nearestGunDrop then
        pcall(function()
            local grabbed = false

            -- Ưu tiên kích hoạt ProximityPrompt nếu có
            local prompt = nearestGunDrop:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled and prompt.ActionText ~= "" and prompt.Parent == nearestGunDrop then
                notify("Gun Aura", "Cố gắng nhặt GunDrop bằng ProximityPrompt.", 1)
                prompt:InputHoldEnd() -- Kết thúc giữ phím để kích hoạt
                grabbed = true
            end

            -- Nếu chưa nhặt, thử kích hoạt ClickDetector nếu có
            if not grabbed then
                local clickDetector = nearestGunDrop:FindFirstChildOfClass("ClickDetector")
                if clickDetector and clickDetector.MaxActivationDistance >= minDistance and clickDetector.Parent == nearestGunDrop then
                    notify("Gun Aura", "Cố gắng nhặt GunDrop bằng ClickDetector.", 1)
                    clickDetector:MouseClick() -- Kích hoạt ClickDetector
                    grabbed = true
                end
            end

            -- Nếu vẫn chưa nhặt, thử mô phỏng sự kiện Touched bằng firetouchinterest
            if not grabbed then
                if getgenv and getgenv().firetouchinterest then
                    notify("Gun Aura", "Cố gắng nhặt GunDrop bằng firetouchinterest.", 1)
                    firetouchinterest(RootPart, nearestGunDrop, 0) -- Bắt đầu chạm
                    task.wait(0.08) -- Đợi một chút
                    firetouchinterest(RootPart, nearestGunDrop, 1) -- Kết thúc chạm
                    grabbed = true
                else
                    -- Fallback nếu không có firetouchinterest, thử di chuyển nhẹ RootPart
                    notify("Gun Aura", "firetouchinterest không có. Thử nhặt bằng cách di chuyển nhẹ.", 1)
                    RootPart.CFrame = RootPart.CFrame + Vector3.new(0, 0.0001, 0)
                    grabbed = true
                end
            end

            if grabbed then
                Settings.GunAura.LastGrabTime = currentTime
            end
        end)
    end
end

-- ================= GLOBAL EVENT LISTENERS =================

-- Unified Heartbeat listener for performance critical tasks
local lastEspUpdateTime = 0
local lastGunAuraCheckTime = 0
addConnection(RunService.Heartbeat:Connect(function(dt)
    -- ANTI VOID/FLING
    if RootPart and RootPart.Parent then
        if RootPart.Position.Y < (Workspace.FallenPartsDestroyHeight or -500) then
            RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
        end
        local isFallingOrJump = (currentState == Enum.HumanoidStateType.Freefall or currentState == Enum.HumanoidStateType.Jumping)
        if RootPart.AssemblyLinearVelocity.Magnitude > 200 and not isFallingOrJump then
            RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
        end
    end

    -- GUN AURA (throttle using its own cooldown, not every frame)
    local currentTime = tick()
    if Settings.GunAura.Enabled and currentTime - lastGunAuraCheckTime >= Settings.GunAura.Cooldown then
        checkAndGrabGunDrop()
        lastGunAuraCheckTime = currentTime
    end

    -- ESP Loop is now in its own task.spawn, so no direct ESP update here
end))


-- Global Player and Character Listeners for ESP
local function setupPlayerListeners(player)
    if player == LocalPlayer then return end
    addConnection(player.CharacterAdded:Connect(function(char)
        addConnection(char.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                -- Setup Humanoid Died Listener when new humanoid exists
                local hum = char:WaitForChild("Humanoid", 5)
                if hum then addConnection(hum.Died:Connect(function()
                    local role, _ = getRole(player)
                    if role == "SheriffOrHero" then
                        notify(role .. " Died", player.Name .. " (" .. role .. ") đã chết.", 4)
                    end
                end)) end
            end
            -- Update ESP on character item changes
            if (child:IsA("Tool") or child:IsA("Backpack")) and Settings.ESPSettings.Enabled then
                task.delay(0.1, function() -- Small delay to allow items to fully load/equip
                    updateESPForPlayer(player)
                end)
            end
        end))
        addConnection(char.ChildRemoved:Connect(function(child)
            if (child:IsA("Tool") or child:IsA("Backpack")) and Settings.ESPSettings.Enabled then
                task.delay(0.1, function()
                    updateESPForPlayer(player)
                end)
            end
        end))
        -- Initial ESP update for new character
        task.delay(0.5, function() -- Give character time to load fully
            if Settings.ESPSettings.Enabled then
                updateESPForPlayer(player)
            end
        end)
    end))

    addConnection(player.Backpack.ChildAdded:Connect(function()
        if Settings.ESPSettings.Enabled then
            updateESPForPlayer(player)
        end
    end))
    addConnection(player.Backpack.ChildRemoved:Connect(function()
        if Settings.ESPSettings.Enabled then
            updateESPForPlayer(player)
        end
    end))
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayerListeners(player)
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then addConnection(hum.Died:Connect(function()
            local role, _ = getRole(player)
            if role == "SheriffOrHero" then
                notify(role .. " Died", player.Name .. " (" .. role .. ") đã chết.", 4)
            end
        end)) end
    end
end
addConnection(Players.PlayerAdded:Connect(setupPlayerListeners))
addConnection(Players.PlayerRemoving:Connect(function(player)
    clearWeaponHighlightsForPlayer(player)
    clearDotESP(player)
    Settings.ESPSettings.LastRole[player] = nil
    Settings.ESPSettings.LastCharacter[player] = nil
end))

-- Workspace Descendant Listeners for Drops and general optimization for NEW objects
addConnection(Workspace.DescendantAdded:Connect(function(obj)
    -- Optimize new objects if render detail reduction is enabled
    if Settings.ReduceRenderDetailEnabled then
        pcall(function()
            if obj:IsA("Sky") and obj.Parent == Lighting then
                obj:Destroy() -- Always remove Sky if Midnight Sky or render detail is on
            elseif obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Reflectance = 0
            elseif obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
                obj.Enabled = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("SpecialMesh") then
                obj.Scale = Vector3.new(0.1,0.1,0.1)
            elseif obj:IsA("PostEffect") then
                obj.Enabled = false
            end
        end)
    end

    -- Handle GunDrop/KnifeDrop for ESP and Gun Aura
    if obj:IsA("BasePart") then
        if obj.Name == "GunDrop" then
            Settings.GunAura.ActiveGunDrops[obj] = true -- Thêm vào danh sách GunDrops
            if Settings.ESPSettings.Enabled then
                highlightDrop(obj, obj.Name)
                notify("Item Drop", obj.Name .. " đã xuất hiện!", 2)
            end
        elseif obj.Name == "KnifeDrop" then
            if Settings.ESPSettings.Enabled then
                highlightDrop(obj, obj.Name)
                notify("Item Drop", obj.Name .. " đã xuất hiện!", 2)
            end
        end
    end
end))
addConnection(Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("BasePart") then
        if obj.Name == "GunDrop" then
            Settings.GunAura.ActiveGunDrops[obj] = nil -- Xóa khỏi danh sách GunDrops
            clearDropHighlight(obj)
        elseif obj.Name == "KnifeDrop" then
            clearDropHighlight(obj)
        end
    end
end))


-- Character Added: Reapply settings and setup listeners
addConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    setupAntiFeatures() -- Re-setup anti-features for new character
    addConnection(Humanoid.HealthChanged:Connect(onHealthChanged))
    task.wait(0.2) -- Small delay to ensure humanoid is fully ready
    if Humanoid then
        Humanoid.WalkSpeed = Settings.WalkSpeed
        Humanoid.JumpPower = Settings.JumpPower
    end
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = Settings.FOV
    end
end))

-- Run initial setups
setupAntiFeatures()
addConnection(Humanoid.HealthChanged:Connect(onHealthChanged))


-- Initial notification
task.delay(1, function()
    notify("Kevinz Hub Loaded ✅", "Version: " .. HUB_VERSION, 4)
end)

-- ================= UI TABS & CONTROLS IMPLEMENTATION =================

-- Tab: Player
local playerPage = createPage("Player")
local playerTabButton = createTabButton("Player", playerPage)
createSectionHeader(playerPage, "Movement Settings")
createControl(playerPage, "WalkSpeed", "Input", Settings.WalkSpeed, function(v)
    Settings.WalkSpeed = v
    if Humanoid then Humanoid.WalkSpeed = v end
    notify("Movement", "WalkSpeed đã đặt thành " .. v .. ".", 2)
end)
createControl(playerPage, "JumpPower", "Input", Settings.JumpPower, function(v)
    Settings.JumpPower = v
    if Humanoid then Humanoid.JumpPower = v end
    notify("Movement", "JumpPower đã đặt thành " .. v .. ".", 2)
end)
createControl(playerPage, "FOV", "Input", Settings.FOV, function(v)
    Settings.FOV = v
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = v end
    notify("Display", "FOV đã đặt thành " .. v .. ".", 2)
end)

createSectionHeader(playerPage, "Health Settings")
local hpDisplayInput = createControl(playerPage, "Set HP (Attempt)", "Input", Humanoid.Health, function(v)
    if Humanoid then
        Humanoid.Health = math.clamp(v, 0, Humanoid.MaxHealth)
        notify("HP Adjustment", "Đã cố gắng điều chỉnh HP thành " .. v .. ". Server có thể override.", 3)
    end
end)
-- Live HP update for the input field's placeholder
addConnection(RunService.Heartbeat:Connect(function() -- Use separate connection for UI update
    if hpDisplayInput and Humanoid and Humanoid.Parent then
        hpDisplayInput.PlaceholderText = string.format("HP: %.0f/%.0f", Humanoid.Health, Humanoid.MaxHealth)
    end
end))
createControl(playerPage, "Semi-God Mode", "Switch", Settings.SemiGodModeEnabled, function(on)
    Settings.SemiGodModeEnabled = on
    if on then
        notify("Semi-God Mode", "Bật: HP sẽ hồi lại khi chết.", 3)
    else
        notify("Semi-God Mode", "Tắt: hoạt động bình thường.", 3)
    end
end)

-- Tab: Visual
local visualPage = createPage("Visual")
local visualTabButton = createTabButton("Visual", visualPage)
createSectionHeader(visualPage, "ESP Settings")
local espToggle = createControl(visualPage, "ESP Theo Role + Highlight Vũ Khí & Drop", "Switch", Settings.ESPSettings.Enabled, function(on)
    Settings.ESPSettings.Enabled = on
    if on then
        startEspLoop()
        notify("ESP Enabled", "Dot ESP, Weapon & Drop Highlight đã bật.", 3)
    else
        -- Clear all ESP elements immediately when turned off
        for _, player in ipairs(Players:GetPlayers()) do
            clearDotESP(player)
            clearWeaponHighlightsForPlayer(player)
        end
        for obj, _ in pairs(Settings.ESPSettings.ActiveDropHighlights) do
            clearDropHighlight(obj)
        end
        espLoopRunning = false -- Stop the ESP loop
        notify("ESP Disabled", "Đã tắt Dot ESP, Weapon & Drop Highlight.", 3)
    end
end)

createSectionHeader(visualPage, "Utilities")
local midnightSkyToggle = createControl(visualPage, "Midnight Sky", "Switch", Settings.MidnightSkyEnabled, function(on)
    Settings.MidnightSkyEnabled = on
    applyMidnightSky(on)
end)
local reduceRenderDetailToggle = createControl(visualPage, "Reduce Render Detail", "Switch", Settings.ReduceRenderDetailEnabled, function(on)
    Settings.ReduceRenderDetailEnabled = on
    applyRenderDetailReduction(on)
end)
createControl(visualPage, "Hide Accessories", "Switch", false, function(on)
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Accessory") then
                local handle = item:FindFirstChild("Handle")
                if handle then handle.Transparency = (on and 1 or 0) end
            end
        end
        notify("Visual", "Hide Accessories đã " .. (on and "bật" or "tắt") .. ".", 2)
    end
end)

-- Tab: Automation
local automationPage = createPage("Automation")
local automationTabButton = createTabButton("Automation", automationPage)
createSectionHeader(automationPage, "Gun Aura Settings")
createControl(automationPage, "Gun Aura (Auto Grab GunDrop)", "Switch", Settings.GunAura.Enabled, function(on)
    Settings.GunAura.Enabled = on
    if on then
        notify("Gun Aura", "Auto Grab GunDrop đã bật.", 3)
    else
        notify("Gun Aura", "Auto Grab GunDrop đã tắt.", 3)
    end
end)
createControl(automationPage, "Aura Distance", "Input", Settings.GunAura.Distance, function(v)
    Settings.GunAura.Distance = math.max(0, v)
    notify("Gun Aura", "Đã đặt Aura Distance = " .. tostring(Settings.GunAura.Distance), 2)
end)
createControl(automationPage, "Aura Cooldown (s)", "Input", Settings.GunAura.Cooldown, function(v)
    Settings.GunAura.Cooldown = math.max(0, v)
    notify("Gun Aura", "Đã đặt Aura Cooldown = " .. tostring(Settings.GunAura.Cooldown) .. "s", 2)
end)

-- Default to first tab and ensure initial state is set
playerTabButton:MouseButton1Click()

-- Reapply initial state for switches on load
-- This ensures the GUI reflects the actual default settings (which might be true if set that way)
if Settings.SemiGodModeEnabled then
    local toggle = playerPage:FindFirstChild("SwitchRow_2"):FindFirstChild("Toggle")
    if toggle and toggle.Text == "OFF" then toggle:MouseButton1Click() end -- Trigger only if it's not already ON
end

if Settings.ESPSettings.Enabled then
    local toggle = visualPage:FindFirstChild("SwitchRow_1"):FindFirstChild("Toggle")
    if toggle and toggle.Text == "OFF" then toggle:MouseButton1Click() end
end

if Settings.MidnightSkyEnabled then
    local toggle = visualPage:FindFirstChild("SwitchRow_2"):FindFirstChild("Toggle")
    if toggle and toggle.Text == "OFF" then toggle:MouseButton1Click() end
end

if Settings.ReduceRenderDetailEnabled then
    local toggle = visualPage:FindFirstChild("SwitchRow_3"):FindFirstChild("Toggle")
    if toggle and toggle.Text == "OFF" then toggle:MouseButton1Click() end
end

if Settings.GunAura.Enabled then
    local toggle = automationPage:FindFirstChild("SwitchRow_1"):FindFirstChild("Toggle")
    if toggle and toggle.Text == "OFF" then toggle:MouseButton1Click() end
end
