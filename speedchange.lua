-- Kevinz Hub Full Script with Dark Minimalist GUI, Frosted Glass, Gradient, 3D Grid Background, ESP, Anti Features, Gun Aura, Notification, etc.

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Local player references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Saved defaults
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.7.4"

-- ================= GUI SETUP =================
-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- === Frosted Overlay + BlurEffect ===
local overlay = Instance.new("Frame")
overlay.Name = "FrostedOverlay"
overlay.AnchorPoint = Vector2.new(0.5, 0.5)
overlay.Position = UDim2.fromScale(0.5, 0.5)
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.6
overlay.ZIndex = 1
overlay.Visible = false
overlay.Parent = gui

-- BlurEffect in Lighting
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "KevinzHubBlurEffect"
blurEffect.Size = 0
blurEffect.Parent = Lighting

local function setBlur(active)
    if active then
        overlay.Visible = true
        TweenService:Create(blurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = 12
        }):Play()
    else
        local tween = TweenService:Create(blurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = 0
        })
        tween:Play()
        tween.Completed:Connect(function()
            overlay.Visible = false
        end)
    end
end

-- Main window
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromOffset(400, 380)
window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
window.BackgroundTransparency = 0.3
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

-- Gradient overlay inside window
local gradient = Instance.new("UIGradient", window)
gradient.Rotation = 90
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0)),
}
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(1, 0.8),
}

-- Top bar
local topBar = Instance.new("Frame", window)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

-- Avatar
local success, thumb = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)
local avatar = Instance.new("ImageLabel", topBar)
avatar.Name = "Avatar"
avatar.Size = UDim2.new(0, 24, 0, 24)
avatar.Position = UDim2.new(0, 6, 0.5, -12)
avatar.BackgroundTransparency = 1
avatar.Image = success and thumb or ""
avatar.ImageTransparency = success and 0 or 1

-- DisplayName label
local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 36, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextScaled = false
nameLabel.TextSize = 14
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeButton = Instance.new("TextButton", topBar)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -32, 0, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeButton.Text = "-"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = false
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.fromRGB(240, 240, 240)
closeButton.AutoButtonColor = false
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)

-- Content ScrollingFrame
local content = Instance.new("ScrollingFrame", window)
content.Name = "ContentFrame"
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local uiList = Instance.new("UIListLayout", content)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8)

-- Helper functions for inputs/switches
local inputRow = 0
local ROW_HEIGHT = 30

local function createInput(labelText, getDefault, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "InputRow_"..inputRow
    container.Size = UDim2.new(1, -20, 0, ROW_HEIGHT)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = inputRow
    container.Parent = content

    -- Label
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

    -- TextBox
    local input = Instance.new("TextBox", container)
    input.Name = "TextBox"
    input.Size = UDim2.new(0.6, -16, 1, 0)
    input.Position = UDim2.new(0.4, 8, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.BackgroundTransparency = 0
    input.TextColor3 = Color3.fromRGB(240, 240, 240)
    input.Text = ""
    input.PlaceholderText = tostring(getDefault())
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function(enterPressed)
        local text = input.Text
        local val = tonumber(text)
        if val then
            pcall(function() callback(val) end)
            input.PlaceholderText = tostring(val)
        end
        input.Text = ""
    end)
end

local function createSwitch(labelText, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "SwitchRow_"..inputRow
    container.Size = UDim2.new(1, -20, 0, ROW_HEIGHT)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    container.BackgroundTransparency = 0.2
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
        callback(state)
    end)
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

-- Close / miniToggle behaviors
closeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
    setBlur(false)
end)
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
    setBlur(true)
end)

-- Show window and blur on initial load
task.defer(function()
    window.Visible = true
    setBlur(true)
    -- Tween-in
    TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end)

-- ================= CORE LOGIC =================

-- ---------- ESP theo Role (Murder Mystery 2) ----------
local chamEnabled = false
local chamHighlights = {}

local function getRole(player)
    local char = player.Character
    if char then
        if char:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
            return "Murderer"
        end
        if char:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
            return "Sheriff"
        end
    end
    return "Innocent"
end

local function updateHighlightColor(player)
    local h = chamHighlights[player]
    if not h or not h.Parent then return end
    local role = getRole(player)
    if role == "Murderer" then
        h.FillColor = Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then
        h.FillColor = Color3.fromRGB(0, 0, 255)
    else
        h.FillColor = Color3.fromRGB(255, 255, 255)
    end
end

local function addHighlightForPlayer(player)
    if not player.Character then return end
    if chamHighlights[player] and chamHighlights[player].Parent then
        updateHighlightColor(player)
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    chamHighlights[player] = highlight
    updateHighlightColor(player)
end

local function removeHighlightForPlayer(player)
    local h = chamHighlights[player]
    if h then
        pcall(function() h:Destroy() end)
        chamHighlights[player] = nil
    end
end

local function updateAllChams()
    if chamEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                addHighlightForPlayer(player)
            end
        end
    else
        for player, _ in pairs(chamHighlights) do
            removeHighlightForPlayer(player)
        end
    end
end

local function setupPlayerListeners(player)
    player.CharacterAdded:Connect(function(char)
        task.delay(0.5, function()
            if chamEnabled and player ~= LocalPlayer then
                addHighlightForPlayer(player)
            end
            if char then
                char.ChildAdded:Connect(function(child)
                    if child.Name == "Knife" or child.Name == "Gun" then
                        updateHighlightColor(player)
                    end
                end)
                char.ChildRemoved:Connect(function(child)
                    if child.Name == "Knife" or child.Name == "Gun" then
                        updateHighlightColor(player)
                    end
                end)
            end
        end)
    end)
    spawn(function()
        local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 5)
        if backpack then
            backpack.ChildAdded:Connect(function(child)
                if child.Name == "Knife" or child.Name == "Gun" then
                    updateHighlightColor(player)
                end
            end)
            backpack.ChildRemoved:Connect(function(child)
                if child.Name == "Knife" or child.Name == "Gun" then
                    updateHighlightColor(player)
                end
            end)
        end
    end)
end

-- Switch for ESP
createSwitch("ESP Theo Role", function(on)
    chamEnabled = on
    updateAllChams()
end)
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
        if chamEnabled then
            task.delay(0.5, function()
                addHighlightForPlayer(player)
            end)
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    removeHighlightForPlayer(player)
end)
-- ESP update loop to refresh colors every 1s
spawn(function()
    while true do
        if chamEnabled then
            for player, highlight in pairs(chamHighlights) do
                if highlight and highlight.Parent then
                    updateHighlightColor(player)
                else
                    chamHighlights[player] = nil
                end
            end
        end
        wait(1)
    end
end)

-- ---------- Anti Features ----------
local function setupAntiFeatures()
    if not Character or not Humanoid or not RootPart then return end
    local lastSafeCFrame = RootPart.CFrame

    Humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed
        or newState == Enum.HumanoidStateType.Running
        or newState == Enum.HumanoidStateType.Walking
        or newState == Enum.HumanoidStateType.RunningNoPhysics then
            if RootPart and RootPart.Parent then
                if Humanoid.FloorMaterial and Humanoid.FloorMaterial ~= Enum.Material.Air then
                    lastSafeCFrame = RootPart.CFrame
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not RootPart or not RootPart.Parent then return end

        -- ANTI VOID
        local posY = RootPart.Position.Y
        local voidY = workspace.FallenPartsDestroyHeight or -500
        if posY < voidY then
            pcall(function()
                RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
            end)
        end

        -- Kiểm tra trạng thái trước khi anti fling
        local currentState = Humanoid:GetState()
        local isFallingOrJump = (currentState == Enum.HumanoidStateType.Freefall
            or currentState == Enum.HumanoidStateType.FallingDown
            or currentState == Enum.HumanoidStateType.Jumping)

        -- ANTI LINEAR FLING
        local vel = RootPart.AssemblyLinearVelocity
        if vel.Magnitude > 200 and not isFallingOrJump then
            pcall(function()
                RootPart.Velocity = Vector3.new(0, 0, 0)
                RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
            end)
        end

        -- ANTI ANGULAR FLING
        local angVel = RootPart.AssemblyAngularVelocity
        if angVel.Magnitude > 300 and not isFallingOrJump then
            pcall(function()
                RootPart.Velocity = Vector3.new(0,0,0)
                RootPart.RotVelocity = Vector3.new(0,0,0)
                local safePos = lastSafeCFrame.Position
                local _, yOri, _ = lastSafeCFrame:ToOrientation()
                local newCFrame = CFrame.new(safePos) * CFrame.Angles(0, yOri, 0)
                RootPart.CFrame = newCFrame + Vector3.new(0, 5, 0)
            end)
            if not RootPart:FindFirstChild("AntiFlingGyro") then
                local bg = Instance.new("BodyGyro")
                bg.Name = "AntiFlingGyro"
                bg.Parent = RootPart
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.P = 1e4
                bg.CFrame = RootPart.CFrame
                task.delay(0.2, function()
                    if bg and bg.Parent then bg:Destroy() end
                end)
            end
        end
    end)
end

-- ---------- Gun Highlight & Gun Aura ----------
local gunHighlightTable = {}
local gunAuraEnabled = false
local auraRadius = 10

createSwitch("Gun Aura", function(on)
    gunAuraEnabled = on
end)
createInput("Gun Aura Radius", function() return auraRadius end, function(v)
    auraRadius = v
end)

local function highlightDroppedGun(tool)
    if gunHighlightTable[tool] then return end
    local adorneeObj = nil
    if tool:FindFirstChild("Handle") then
        adorneeObj = tool.Handle
    else
        adorneeObj = tool
    end
    local hl = Instance.new("Highlight")
    hl.Adornee = adorneeObj
    hl.FillColor = Color3.fromRGB(255, 255, 0)
    hl.OutlineColor = Color3.new(1, 1, 0)
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 0.5
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = adorneeObj
    gunHighlightTable[tool] = hl
end

local function removeHighlightDroppedGun(tool)
    local hl = gunHighlightTable[tool]
    if hl then
        pcall(function() hl:Destroy() end)
        gunHighlightTable[tool] = nil
    end
end

spawn(function()
    while true do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj.Name == "Gun" then
                local parent = obj.Parent
                local inCharacter = false
                if parent and parent:FindFirstChildOfClass("Humanoid") then
                    inCharacter = true
                end
                if not inCharacter then
                    highlightDroppedGun(obj)
                    if gunAuraEnabled and RootPart and RootPart.Parent then
                        local pos = nil
                        if obj:FindFirstChild("Handle") then
                            pos = obj.Handle.Position
                        elseif obj.PrimaryPart then
                            pos = obj.PrimaryPart.Position
                        end
                        if pos then
                            local dist = (RootPart.Position - pos).Magnitude
                            if dist <= auraRadius then
                                local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
                                pcall(function()
                                    obj.Parent = backpack
                                end)
                                removeHighlightDroppedGun(obj)
                            end
                        end
                    end
                else
                    removeHighlightDroppedGun(obj)
                end
            end
        end
        for tool, hl in pairs(gunHighlightTable) do
            if not tool.Parent then
                removeHighlightDroppedGun(tool)
            end
        end
        wait(1)
    end
end)

-- ---------- Background Grid 3D ----------
local gridFolder = nil
local gridEnabled = false
local GRID_SIZE = 100
local GRID_SPACING = 10
local GRID_THICKNESS = 0.2
local GRID_Y = 0

local function createGrid()
    if gridFolder then
        gridFolder:Destroy()
        gridFolder = nil
    end
    gridFolder = Instance.new("Folder")
    gridFolder.Name = "KevinzHub_GridBackground"
    gridFolder.Parent = workspace

    -- Lines along X-axis (vary x, fixed z)
    for i = -GRID_SIZE, GRID_SIZE, GRID_SPACING do
        local line = Instance.new("Part")
        line.Name = "GridLineX_"..i
        line.Size = Vector3.new((GRID_SIZE*2)+GRID_SPACING, GRID_THICKNESS, GRID_THICKNESS)
        line.Anchored = true
        line.CanCollide = false
        line.Material = Enum.Material.SmoothPlastic
        line.Color = Color3.fromRGB(100, 100, 100)
        line.Transparency = 0.5
        line.TopSurface = Enum.SurfaceType.Smooth
        line.BottomSurface = Enum.SurfaceType.Smooth
        line.CFrame = CFrame.new(0, GRID_Y, i)
        line.Parent = gridFolder
    end
    -- Lines along Z-axis (vary z, fixed x)
    for i = -GRID_SIZE, GRID_SIZE, GRID_SPACING do
        local line = Instance.new("Part")
        line.Name = "GridLineZ_"..i
        line.Size = Vector3.new(GRID_THICKNESS, GRID_THICKNESS, (GRID_SIZE*2)+GRID_SPACING)
        line.Anchored = true
        line.CanCollide = false
        line.Material = Enum.Material.SmoothPlastic
        line.Color = Color3.fromRGB(100, 100, 100)
        line.Transparency = 0.5
        line.TopSurface = Enum.SurfaceType.Smooth
        line.BottomSurface = Enum.SurfaceType.Smooth
        line.CFrame = CFrame.new(i, GRID_Y, 0)
        line.Parent = gridFolder
    end
end

local function removeGrid()
    if gridFolder then
        gridFolder:Destroy()
        gridFolder = nil
    end
end

createSwitch("Background Grid", function(on)
    gridEnabled = on
    if on then
        -- Optionally update GRID_Y based on player position:
        GRID_Y = RootPart and (RootPart.Position.Y - 5) or GRID_Y
        createGrid()
    else
        removeGrid()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
    setupAntiFeatures()
    -- Reset walk/jump values
    if Humanoid then
        task.wait(0.2)
        pcall(function()
            Humanoid.WalkSpeed = savedWalkSpeed
            Humanoid.JumpPower = savedJumpPower
        end)
    end
    -- Reapply ESP if needed
    if chamEnabled then
        task.delay(0.5, function()
            updateAllChams()
        end)
    end
    -- Update grid position if enabled
    if gridEnabled and RootPart then
        GRID_Y = RootPart.Position.Y - 5
        createGrid()
    end
end)

-- Initial setupAntiFeatures
setupAntiFeatures()

-- ---------- Notification on load ----------
task.delay(1, function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kevinz Hub Loaded ✅",
            Text = "Version: "..HUB_VERSION,
            Duration = 5
        })
    end)
end)

-- ---------- Create Inputs/Switches for core settings ----------
-- Reset inputRow so GUI elements appear in order
inputRow = 0

-- WalkSpeed, JumpPower, FOV
createInput("WalkSpeed", function() return savedWalkSpeed end, function(v)
    savedWalkSpeed = v
    if Humanoid then pcall(function() Humanoid.WalkSpeed = v end) end
end)
createInput("JumpPower", function() return savedJumpPower end, function(v)
    savedJumpPower = v
    if Humanoid then pcall(function() Humanoid.JumpPower = v end) end
end)
createInput("FOV", function() return workspace.CurrentCamera.FieldOfView end, function(v)
    pcall(function() workspace.CurrentCamera.FieldOfView = v end)
end)
-- ESP switch (already wired above)
-- Gun Aura
-- (The createSwitch and createInput calls for Gun Aura were already made above during GUI setup order)
-- But ensure ordering: if needed, move these calls here:
-- Note: since inputRow was reset, recreate Gun Aura UI after WalkSpeed/JumpPower/FOV:
createSwitch("ESP Theo Role", function(on)
    chamEnabled = on
    updateAllChams()
end)
createSwitch("Gun Aura", function(on)
    gunAuraEnabled = on
end)
createInput("Gun Aura Radius", function() return auraRadius end, function(v)
    auraRadius = v
end)
createSwitch("Background Grid", function(on)
    gridEnabled = on
    if on then
        GRID_Y = RootPart and (RootPart.Position.Y - 5) or GRID_Y
        createGrid()
    else
        removeGrid()
    end
end)

-- End of full script
