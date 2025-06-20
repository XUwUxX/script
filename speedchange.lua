-- Kevinz Hub Full Script v1.18
-- - Manual dragging UI
-- - ESP Outline theo role + Weapon Highlight + Drop Highlight (GunDrop hồng đậm, KnifeDrop tím), loop 0.7s
-- - Gun Aura (auto grab GunDrop) độc lập với ESP, với Aura Distance và Aura Cooldown
-- - Notification khi Sheriff/Hero chết, khi GunDrop/KnifeDrop xuất hiện (khi ESP bật)
-- - Anti Features, Semi-God Mode, Movement Settings, Health Settings, Utilities
-- - OptimizePerformanceWithListener: tối ưu sâu: midnight sky, tắt hiệu ứng, giảm render chi tiết, override print/warn, event-driven disable object mới.

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserSettings = UserSettings()

-- Local refs
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Saved defaults
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.18"

-- ================= GUI SETUP =================
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
window.Size = UDim2.new(0.35, 0, 0.6, 0)
window.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
window.BorderSizePixel = 0
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui

-- Gradient black-red
local gradient = Instance.new("UIGradient", window)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(25, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
}
gradient.Rotation = 90
gradient.Transparency = NumberSequence.new(0, 0)
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
do
    local stroke = Instance.new("UIStroke", window)
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
end

-- Top bar (dùng để drag)
local topBar = Instance.new("Frame", window)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Position = UDim2.new(0, 0, 0, 0)
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

-- Avatar
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
    local avatarCorner = Instance.new("UICorner", avatar)
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatar.LayoutOrder = 1
end

-- Title label
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

-- Minimize & Close buttons
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

-- Content ScrollingFrame
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

-- Manual dragging for window via topBar
do
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            -- window.Position is UDim2: combine scale + offset
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            window.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
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

-- Initial show with tween
task.delay(2, function()
    window.Visible = true
    TweenService:Create(window, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5)
    }):Play()
end)

-- ================= Helper UI functions =================
local inputRow = 0
local ROW_HEIGHT = 30

-- Section header
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

-- Input row
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

-- Switch row
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

-- Button row
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

-- ================= CORE LOGIC =================

--- Anti Features setup ---
local function setupAntiFeatures()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if not Character or not Humanoid or not RootPart then return end
    local lastSafeCFrame = RootPart.CFrame

    Humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
            if RootPart and RootPart.Parent and Humanoid.FloorMaterial ~= Enum.Material.Air then
                lastSafeCFrame = RootPart.CFrame
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not RootPart or not RootPart.Parent then return end

        -- ANTI VOID
        if RootPart.Position.Y < (workspace.FallenPartsDestroyHeight or -500) then
            RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
        end

        local currentState = Humanoid:GetState()
        local isFallingOrJump = (currentState == Enum.HumanoidStateType.Freefall or currentState == Enum.HumanoidStateType.Jumping)

        -- ANTI FLING
        if RootPart.AssemblyLinearVelocity.Magnitude > 200 and not isFallingOrJump then
            RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
        end
    end)
end

--- Semi-God Mode (Ragdoll thay vì chết) ---
local semiGodModeEnabled = false
local function onHealthChanged(health)
    if not semiGodModeEnabled or not Humanoid or not Humanoid.Parent then return end
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

-- Notification on load
task.delay(1, function()
    notify("Kevinz Hub Loaded ✅", "Version: " .. HUB_VERSION, 4)
end)

-- Setup Anti Features
setupAntiFeatures()

-- ================= “Fix Lag + Lower CPU Load” tối ưu sâu =================

-- optimizePerformance: thực hiện một lần
local function optimizePerformance()
    -- Override print/warn để clear log
    pcall(function()
        print = function(...) end
        warn = function(...) end
    end)

    -- Lighting tối: midnight sky, tắt hiệu ứng
    pcall(function()
        -- Xóa mọi Sky có sẵn
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then
                child:Destroy()
            end
        end
        -- Thiết bầu trời midnight
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
        -- Tắt mọi PostEffect trong Lighting
        for _, eff in ipairs(Lighting:GetDescendants()) do
            if eff:IsA("PostEffect") then
                pcall(function() eff.Enabled = false end)
            end
        end
    end)

    -- Giảm chi tiết render trong Workspace
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                pcall(function()
                    obj.CastShadow = false
                    obj.Reflectance = 0
                    -- Nếu muốn, có thể chuyển Material về Plastic, nhưng nhiều game cấm:
                    -- obj.Material = Enum.Material.Plastic
                end)
            end
            if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
                pcall(function() obj.Enabled = false end)
            end
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
            end
            if obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() obj.Transparency = 1 end)
            end
            if obj:IsA("SpecialMesh") then
                pcall(function() obj.Scale = Vector3.new(0.1,0.1,0.1) end)
            end
        end
    end)

    -- Giảm chất lượng Graphics Level
    pcall(function()
        local ugs = UserSettings:GetService("UserGameSettings")
        if ugs.SetRenderingQualityLevel then
            ugs:SetRenderingQualityLevel(1)
        elseif ugs.SetGraphicsQualityLevel then
            ugs:SetGraphicsQualityLevel(1)
        end
    end)

    -- Terrain: tắt water effects
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
            terrain.CastShadow = false
        end
    end)

    -- Camera: tắt PostEffect con (nếu có)
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            for _, eff in ipairs(cam:GetDescendants()) do
                if eff:IsA("PostEffect") then
                    pcall(function() eff.Enabled = false end)
                end
            end
        end
    end)

    -- Thông báo hoàn thành
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Optimization Applied",
            Text = "Tối ưu sâu đã áp dụng: Midnight sky, tắt hiệu ứng, giảm render chi tiết.",
            Duration = 5
        })
    end)
end

-- optimizePerformanceWithListener: chạy một lần rồi kết nối để disable object mới
local optimized = false
local function optimizePerformanceWithListener()
    if optimized then return end
    optimized = true
    optimizePerformance()
    -- Kết nối event để disable object thêm mới
    workspace.DescendantAdded:Connect(function(obj)
        -- Disable tương tự khi optimizePerformance
        if obj:IsA("Sky") and obj.Parent == Lighting then
            pcall(function() obj:Destroy() end)
        end
        if obj:IsA("BasePart") then
            pcall(function()
                obj.CastShadow = false
                obj.Reflectance = 0
                -- obj.Material = Enum.Material.Plastic
            end)
        end
        if obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            pcall(function() obj.Enabled = false end)
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            pcall(function() obj.Enabled = false end)
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function() obj.Transparency = 1 end)
        end
        if obj:IsA("SpecialMesh") then
            pcall(function() obj.Scale = Vector3.new(0.1,0.1,0.1) end)
        end
    end)
end

-- ================= UI controls =================
inputRow = 0

-- Group 1: Movement Settings
createSection("Movement Settings")
createInput("WalkSpeed", function() return 16 end, function(v)
    savedWalkSpeed = v
    if Humanoid then Humanoid.WalkSpeed = v end
end)
createInput("JumpPower", function() return 50 end, function(v)
    savedJumpPower = v
    if Humanoid then Humanoid.JumpPower = v end
end)
createInput("FOV", function() return 70 end, function(v)
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = v end
end)

-- Group 2: Health & Semi-God
createSection("Health Settings")
do
    local hpDisplayInput
    createInput("Set HP (Attempt)", function() return 100 end, function(v)
        if Humanoid then
            Humanoid.Health = math.clamp(v, 0, Humanoid.MaxHealth)
            notify("HP Adjustment", "Đã cố gắng điều chỉnh HP thành " .. v .. ". Server có thể override.", 3)
        end
    end)
    RunService.Heartbeat:Connect(function()
        if hpDisplayInput == nil then
            local cont = content:FindFirstChild("InputRow_" .. inputRow)
            if cont then
                hpDisplayInput = cont:FindFirstChild("TextBox")
            end
        end
        if hpDisplayInput and Humanoid and Humanoid.Parent then
            hpDisplayInput.PlaceholderText = string.format("HP: %.0f/%.0f", Humanoid.Health, Humanoid.MaxHealth)
        end
    end)
end
createSwitch("Semi-God Mode", function(on)
    semiGodModeEnabled = on
    if on then
        notify("Semi-God Mode", "Bật: HP sẽ hồi lại khi chết.", 3)
    else
        notify("Semi-God Mode", "Tắt: hoạt động bình thường.", 3)
    end
end)

-- Group 3: Utilities
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
createButton("Fix Lag + Lower CPU Load", optimizePerformanceWithListener)

-- ================= DOT ESP + WEAPON/DROP HIGHLIGHT (ĐÃ FIX) =================

local espEnabled = false
local roleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),        -- Đỏ
    SheriffOrHero = Color3.fromRGB(50, 150, 255),  -- Xanh dương (Sheriff + Hero)
    Innocent = Color3.fromRGB(50, 255, 80),        -- Xanh lá
    Unknown  = Color3.fromRGB(180, 180, 180)       -- Xám
}
local lastRole = {}
local lastCharacter = {}
_G._KevinzHub_WeaponHighlights = {}
local gunDropESP = {}
_G._KevinzHub_KnifeHighlights = _G._KevinzHub_KnifeHighlights or {}

local function getRole(player)
    local hasKnife, hasGun = false, false
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        local n = tool.Name:lower()
        if n:find("knife") or n:find("blade") then hasKnife = true end
        if n:find("gun") or n:find("revolver") then hasGun = true end
    end
    for _, tool in ipairs((player.Character and player.Character:GetChildren()) or {}) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("blade") then hasKnife = true end
            if n:find("gun") or n:find("revolver") then hasGun = true end
        end
    end
    if hasKnife and not hasGun then return "Murderer"
    elseif hasGun and not hasKnife then return "SheriffOrHero"
    elseif hasGun and hasKnife then return "Unknown"
    else return "Innocent"
    end
end

local function updateDotESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local color = roleColors[getRole(player)] or roleColors.Unknown

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

local function clearDotESP(char)
    if char and char:FindFirstChild("Head") then
        local e = char.Head:FindFirstChild("DotESP")
        if e then e:Destroy() end
    end
end

local function clearWeaponHighlightsForPlayer(player)
    local tbl = _G._KevinzHub_WeaponHighlights[player]
    if tbl then
        for tool, hl in pairs(tbl) do
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
    end
    _G._KevinzHub_WeaponHighlights[player] = nil
end

local function addWeaponHighlight(player, toolInstance)
    if not espEnabled then return end
    if not toolInstance or not toolInstance:IsA("Tool") then return end
    if not _G._KevinzHub_WeaponHighlights[player] then
        _G._KevinzHub_WeaponHighlights[player] = {}
    end
    if _G._KevinzHub_WeaponHighlights[player][toolInstance] then return end

    local nameLower = toolInstance.Name:lower()
    local color = Color3.fromRGB(255, 255, 255)
    if nameLower:find("knife") or nameLower:find("blade") then
        color = Color3.fromRGB(160, 32, 240)
    elseif nameLower:find("gun") or nameLower:find("revolver") then
        color = Color3.fromRGB(100, 150, 255)
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

    _G._KevinzHub_WeaponHighlights[player][toolInstance] = hl
end

local function removeWeaponHighlight(player, toolInstance)
    if not _G._KevinzHub_WeaponHighlights[player] then return end
    local hl = _G._KevinzHub_WeaponHighlights[player][toolInstance]
    if hl and hl.Parent then
        hl:Destroy()
    end
    _G._KevinzHub_WeaponHighlights[player][toolInstance] = nil
end

local function highlightGunDrop(obj)
    if not espEnabled then return end
    if gunDropESP[obj] and gunDropESP[obj].Parent then return end
    if not obj:IsA("BasePart") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "_ESP_GUNDROP"
    hl.Adornee = obj
    hl.FillColor = Color3.fromRGB(255, 20, 147)
    hl.OutlineColor = Color3.fromRGB(255, 20, 147)
    hl.FillTransparency = 0.8
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
    gunDropESP[obj] = hl
end

local function removeGunDropESP(obj)
    if gunDropESP[obj] then
        if gunDropESP[obj].Parent then
            gunDropESP[obj]:Destroy()
        end
        gunDropESP[obj] = nil
    end
end

local function updatePlayer(player)
    local char = player.Character
    if char then
        if lastCharacter[player] ~= char then
            lastRole[player] = nil
            clearWeaponHighlightsForPlayer(player)
            clearDotESP(lastCharacter[player])
            lastCharacter[player] = char
        end
    else
        lastRole[player] = nil
        clearWeaponHighlightsForPlayer(player)
        clearDotESP(lastCharacter[player])
        lastCharacter[player] = nil
        return
    end

    if not espEnabled then
        clearWeaponHighlightsForPlayer(player)
        clearDotESP(char)
        lastRole[player] = nil
        return
    end

    -- Dot ESP
    if player ~= LocalPlayer then
        if char and char:FindFirstChild("Head") then
            local role = getRole(player)
            if lastRole[player] ~= role then
                updateDotESP(player)
                lastRole[player] = role
            end
        end
    end

    -- Weapon highlight
    local tbl = _G._KevinzHub_WeaponHighlights[player]
    if tbl then
        for toolInst, hl in pairs(tbl) do
            if not (toolInst and toolInst.Parent == char) then
                if hl and hl.Parent then hl:Destroy() end
                tbl[toolInst] = nil
            end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            if not (_G._KevinzHub_WeaponHighlights[player] and _G._KevinzHub_WeaponHighlights[player][child]) then
                addWeaponHighlight(player, child)
            end
        end
    end
end

local espLoopRunning = false
local espLoopInterval = 0.7
local function startEspLoop()
    if espLoopRunning then return end
    espLoopRunning = true
    task.spawn(function()
        while espEnabled do
            for _, player in ipairs(Players:GetPlayers()) do
                updatePlayer(player)
            end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "GunDrop" then
                    highlightGunDrop(obj)
                end
            end
            task.wait(espLoopInterval)
        end
        for obj, _ in pairs(gunDropESP) do
            removeGunDropESP(obj)
        end
        for obj, hl in pairs(_G._KevinzHub_KnifeHighlights) do
            if hl and hl.Parent then hl:Destroy() end
            _G._KevinzHub_KnifeHighlights[obj] = nil
        end
        espLoopRunning = false
    end)
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Head", 3)
        updateDotESP(player)
        char.ChildAdded:Connect(function() updateDotESP(player) end)
        char.ChildRemoved:Connect(function() updateDotESP(player) end)
    end)
    if player.Character and player.Character:FindFirstChild("Head") then
        updateDotESP(player)
    end
    player.Backpack.ChildAdded:Connect(function() updateDotESP(player) end)
    player.Backpack.ChildRemoved:Connect(function() updateDotESP(player) end)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
Players.PlayerAdded:Connect(setupPlayer)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "GunDrop" then
        if espEnabled then highlightGunDrop(obj) end
    elseif obj:IsA("BasePart") and obj.Name == "KnifeDrop" then
        if espEnabled then
            local hl = Instance.new("Highlight")
            hl.Name = "_ESP_KNIFEDROP"
            hl.Adornee = obj
            hl.FillColor = Color3.fromRGB(160, 32, 240)
            hl.OutlineColor = Color3.fromRGB(200, 100, 200)
            hl.FillTransparency = 0.8
            hl.OutlineTransparency = 0.2
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = obj
            _G._KevinzHub_KnifeHighlights[obj] = hl
        end
    end
end)
workspace.DescendantRemoving:Connect(function(obj)
    if obj.Name == "GunDrop" then
        removeGunDropESP(obj)
    elseif obj.Name == "KnifeDrop" then
        if _G._KevinzHub_KnifeHighlights[obj] then
            local hl = _G._KevinzHub_KnifeHighlights[obj]
            if hl and hl.Parent then hl:Destroy() end
            _G._KevinzHub_KnifeHighlights[obj] = nil
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    clearWeaponHighlightsForPlayer(player)
    clearDotESP(player.Character)
    lastRole[player] = nil
    lastCharacter[player] = nil
end)

createSection("ESP Settings")
createSwitch("ESP MM2 Dot + Vũ Khí & Drop", function(on)
    espEnabled = on
    if espEnabled then
        startEspLoop()
        StarterGui:SetCore("SendNotification", {
            Title = "ESP Enabled",
            Text = "Dot ESP, Weapon & Drop Highlight đã bật.",
            Duration = 3
        })
    else
        for _, player in ipairs(Players:GetPlayers()) do
            clearWeaponHighlightsForPlayer(player)
            clearDotESP(player.Character)
            lastRole[player] = nil
            lastCharacter[player] = nil
        end
        StarterGui:SetCore("SendNotification", {
            Title = "ESP Disabled",
            Text = "Đã tắt Dot ESP, Weapon & Drop Highlight.",
            Duration = 3
        })
    end
end)

-- ================= Setup notification when existing players die =================
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character:FindFirstChild("Humanoid")
        hum.Died:Connect(function()
            local role = getRole(player)
            if role == "Sheriff" or role == "Hero" then
                notify(role .. " Died", player.Name .. " (" .. role .. ") đã chết.", 4)
            end
        end)
    end
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                local role = getRole(player)
                if role == "Sheriff" or role == "Hero" then
                    notify(role .. " Died", player.Name .. " (" .. role .. ") đã chết.", 4)
                end
            end)
        end
    end)
end)

-- ================= UI: ESP section =================
createSection("ESP Settings")
createSwitch("ESP Theo Role + Highlight Vũ Khí & Drop", function(on)
    espEnabled = on
    if espEnabled then
        startEspLoop()
        notify("ESP Enabled", "Outline, Weapon Highlight và Drop Highlight đã bật.", 3)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                clearOutlineHighlight(player.Character)
            end
            clearWeaponHighlightsForPlayer(player)
            lastRole[player] = nil
            lastCharacter[player] = nil
        end
        -- Drop highlights removed in loop end
        notify("ESP Disabled", "Outline, Weapon Highlight và Drop Highlight đã tắt.", 3)
    end
end)

-- ================= UI: Gun Aura section =================
createSection("Gun Aura Settings")
createSwitch("Gun Aura (Auto Grab GunDrop)", function(on)
    gunAuraEnabled = on
    if on then
        notify("Gun Aura", "Auto Grab GunDrop đã bật.", 3)
    else
        notify("Gun Aura", "Auto Grab GunDrop đã tắt.", 3)
    end
end)
createInput("Aura Distance", function() return auraDistance end, function(v)
    auraDistance = v
    notify("Gun Aura", "Đã đặt Aura Distance = " .. tostring(v), 2)
end)
createInput("Aura Cooldown (s)", function() return auraCooldown end, function(v)
    auraCooldown = v
    notify("Gun Aura", "Đã đặt Aura Cooldown = " .. tostring(v) .. "s", 2)
end)

-- ================= UI: Optimization section =================
-- (Đã gắn callback optimizePerformanceWithListener lên nút "Fix Lag + Lower CPU Load" phía trên)

-- ================= CharacterAdded initial: reapply settings =================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    setupAntiFeatures()
    Humanoid.HealthChanged:Connect(onHealthChanged)
    task.wait(0.2)
    if Humanoid then
        Humanoid.WalkSpeed = savedWalkSpeed
        Humanoid.JumpPower = savedJumpPower
    end
end)

-- End of script v1.18
