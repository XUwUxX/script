-- Kevinz Hub - Full Script with GUI, WalkSpeed/JumpPower Save, Role-based ESP for Murder Mystery 2,
-- plus hidden features: anti void, anti linear fling, anti angular fling,
-- và ESP tự động cập nhật role mỗi 1s khi bật ESP.

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Local player references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Saved defaults
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.7.0"  -- cập nhật phiên bản

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Main window
local window = Instance.new("Frame")
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromOffset(550, 400)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = true
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)
window.Parent = gui

-- Gradient background
local gradient = Instance.new("UIGradient", window)
gradient.Rotation = 45
gradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 0))
}
gradient.Transparency = NumberSequence.new {
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(1, 0.2)
}

-- Top bar with avatar and name
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local avatar = Instance.new("ImageLabel", topBar)
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundTransparency = 1
avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.BackgroundTransparency = 1
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Content area
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

-- Helpers for dynamic input rows
local inputRow = 0
local function createInput(labelText, getDefault, callback)
    inputRow = inputRow + 1
    local rowHeight = 40
    local padding = 10
    local yOffset = (inputRow - 1) * (rowHeight + padding) + padding

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -40, 0, rowHeight)
    container.Position = UDim2.new(0, 20, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.6, -10, 1, 0)
    input.Position = UDim2.new(0.4, 10, 0, 0)
    input.Font = Enum.Font.Gotham
    local defaultVal = getDefault()
    input.PlaceholderText = tostring(defaultVal)
    input.Text = ""
    input.TextScaled = true
    input.ClearTextOnFocus = false
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    input.Parent = container

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
    local rowHeight = 40
    local padding = 10
    local yOffset = (inputRow - 1) * (rowHeight + padding) + padding

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -40, 0, rowHeight)
    container.Position = UDim2.new(0, 20, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.4, -10, 1, 0)
    toggle.Position = UDim2.new(0.6, 10, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Text = "OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextScaled = true
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)
    toggle.Parent = container

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- Inputs: WalkSpeed, JumpPower, FOV
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
createInput("FOV", function() return workspace.CurrentCamera.FieldOfView end, function(v)
    pcall(function() workspace.CurrentCamera.FieldOfView = v end)
end)

-- ESP theo role Murder Mystery 2
local chamEnabled = false
local chamHighlights = {}  -- map Player -> Highlight

-- Xác định role: dùng tên tool "Knife" và "Gun"
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
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.new(1, 1, 1)
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

-- Setup listeners để respawn & tool change
local function setupPlayerListeners(player)
    -- respawn
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
    -- Backpack changes
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

-- Switch ESP
createSwitch("ESP Theo Role", function(on)
    chamEnabled = on
    updateAllChams()
end)

-- Setup initial players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
        player.CharacterAdded:Connect(function(char)
            if chamEnabled then
                task.delay(0.5, function()
                    addHighlightForPlayer(player)
                end)
            end
        end)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    removeHighlightForPlayer(player)
end)

-- mini toggle để ẩn/hiện window
local miniToggle = Instance.new("TextButton", gui)
miniToggle.Size = UDim2.new(0, 36, 0, 36)
miniToggle.Position = UDim2.new(0, 50, 1, -50)
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "+"
miniToggle.TextScaled = true
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextColor3 = Color3.new(1, 1, 1)
miniToggle.AutoButtonColor = false
miniToggle.Visible = false
Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(1, 0)

local closeButton = Instance.new("TextButton", topBar)
closeButton.Size = UDim2.new(0, 36, 0, 36)
closeButton.Position = UDim2.new(1, -42, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeButton.Text = "-"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)
closeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
end)
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
end)

-- Tween-in
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Anti features setup function
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

        -- ANTI LINEAR FLING
        local vel = RootPart.AssemblyLinearVelocity
        if vel.Magnitude > 100 then
            pcall(function()
                RootPart.Velocity = Vector3.new(0, 0, 0)
                RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
            end)
        end

        -- ANTI ANGULAR FLING
        local angVel = RootPart.AssemblyAngularVelocity
        if angVel.Magnitude > 200 then
            pcall(function()
                RootPart.Velocity = Vector3.new(0,0,0)
                RootPart.RotVelocity = Vector3.new(0,0,0)
                local safePos = lastSafeCFrame.Position
                local _, _, safeY = lastSafeCFrame:ToOrientation()
                local newCFrame = CFrame.new(safePos) * CFrame.Angles(0, safeY, 0)
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

-- Handle local respawn: restore stats, re-setup anti, reapply ESP
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
    if Humanoid then
        task.wait(0.2)
        pcall(function()
            Humanoid.WalkSpeed = savedWalkSpeed
            Humanoid.JumpPower = savedJumpPower
        end)
    end
    setupAntiFeatures()
    if chamEnabled then
        task.delay(0.5, function()
            updateAllChams()
        end)
    end
end)
-- Setup anti lần đầu
setupAntiFeatures()

-- Notification khi hub load
task.delay(1, function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kevinz Hub Loaded ✅",
            Text = "Running version: " .. HUB_VERSION,
            Duration = 5
        })
    end)
end)

-- ========== Phần mới: vòng lặp tự động cập nhật role mỗi 1s ==========
-- Khi ESP bật (chamEnabled = true), chúng ta chạy một vòng lặp định kỳ:
spawn(function()
    while true do
        if chamEnabled then
            -- Duyệt qua những player đang có highlight (hoặc tất cả player) và cập nhật màu
            for player, highlight in pairs(chamHighlights) do
                -- Nếu highlight vẫn tồn tại, cập nhật color; nếu không, bỏ khỏi bảng
                if highlight and highlight.Parent then
                    updateHighlightColor(player)
                else
                    chamHighlights[player] = nil
                end
            end
        end
        wait(1)  -- lặp mỗi 1 giây
    end
end)
-- =====================================================================

