-- Kevinz Hub - Full Script (WalkFling đã bị loại bỏ), text size 12, gradient black-red fade, dashed rounded border, và các tính năng khác.

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
local HUB_VERSION = "v1.7.3"  -- phiên bản cập nhật

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
window.Size = UDim2.fromOffset(400, 380)  -- cố định 400x380
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = true
-- Bo góc
local uic = Instance.new("UICorner", window)
uic.CornerRadius = UDim.new(0, 12)
-- Cho clip con để dashed border cắt đúng bo góc
window.ClipsDescendants = true
window.Parent = gui

-- Gradient background: black -> red fade
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

-- Top bar với avatar và tên
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1, 0, 0, 30)  -- chiều cao 30
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
local topBarCorner = Instance.new("UICorner", topBar)
topBarCorner.CornerRadius = UDim.new(0, 8)

local success, thumb = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)
local avatar = Instance.new("ImageLabel", topBar)
avatar.Size = UDim2.new(0, 24, 0, 24)
avatar.Position = UDim2.new(0, 6, 0.5, -12)
avatar.BackgroundTransparency = 1
avatar.Image = success and thumb or ""
avatar.ImageTransparency = success and 0 or 1

local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 36, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextScaled = false
nameLabel.TextSize = 12
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeButton = Instance.new("TextButton", topBar)
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -32, 0, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeButton.Text = "-"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = false
closeButton.TextSize = 12
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.AutoButtonColor = false
local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(1, 0)
closeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
end)

-- Content area dưới topBar: dùng ScrollingFrame để scroll khi nội dung vượt khung
local content = Instance.new("ScrollingFrame", window)
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollBarThickness = 6

-- Helpers cho các input rows
local inputRow = 0
local rowHeight = 30
local padding = 6

local function createInput(labelText, getDefault, callback)
    inputRow = inputRow + 1
    local yOffset = (inputRow - 1) * (rowHeight + padding) + padding

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, rowHeight)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = false
    label.TextSize = 12
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
    input.TextScaled = false
    input.TextSize = 12
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
    local yOffset = (inputRow - 1) * (rowHeight + padding) + padding

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, rowHeight)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = false
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.4, -10, 1, 0)
    toggle.Position = UDim2.new(0.6, 10, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Text = "OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextScaled = false
    toggle.TextSize = 12
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

-- Tạo các input: WalkSpeed, JumpPower, FOV
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

-- Setup initial players listeners
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
        -- nếu ESP đang bật, áp dụng ngay
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

-- mini toggle để ẩn/hiện window
local miniToggle = Instance.new("TextButton", gui)
miniToggle.Size = UDim2.new(0, 28, 0, 28)
-- Đặt vị trí tương đối với chiều rộng window mới:
miniToggle.Position = UDim2.new(0, 50, 1, -40)
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "+"
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextScaled = false
miniToggle.TextSize = 12
miniToggle.TextColor3 = Color3.new(1, 1, 1)
miniToggle.AutoButtonColor = false
miniToggle.Visible = false
Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(1, 0)
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
end)

-- Tween-in khi mở window
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Anti features setup function (cải tiến không return khi nhảy)
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

-- Gun Highlight & Gun Aura
local gunHighlightTable = {}  -- map Tool -> Highlight
local gunAuraEnabled = false
local auraRadius = 10  -- mặc định

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

-- Anti features và reapply khi respawn
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

-- ESP update loop: auto cập nhật role mỗi 1s
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

-- ===== Thêm dashed border quanh window =====
do
    local borderContainer = Instance.new("Frame", window)
    borderContainer.Name = "DashedBorderContainer"
    borderContainer.BackgroundTransparency = 1
    borderContainer.Size = UDim2.new(1, 0, 1, 0)
    borderContainer.Position = UDim2.new(0, 0, 0, 0)
    borderContainer.ZIndex = window.ZIndex + 1

    local function drawDashed()
        for _, child in ipairs(borderContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        local w = window.AbsoluteSize.X
        local h = window.AbsoluteSize.Y
        if w <= 0 or h <= 0 then return end

        local dashLen = 10    -- độ dài mỗi đoạn (có thể chỉnh)
        local gapLen = 5      -- gap giữa đoạn
        local thickness = 2   -- độ dày border
        local color = Color3.fromRGB(255, 255, 255)  -- màu border

        -- Top edge
        local x = 0
        while x < w do
            local seg = Instance.new("Frame", borderContainer)
            seg.BackgroundColor3 = color
            seg.BorderSizePixel = 0
            local segWidth = math.min(dashLen, w - x)
            seg.Size = UDim2.new(0, segWidth, 0, thickness)
            seg.Position = UDim2.new(0, x, 0, 0)
            x = x + dashLen + gapLen
        end
        -- Bottom edge
        x = 0
        while x < w do
            local seg = Instance.new("Frame", borderContainer)
            seg.BackgroundColor3 = color
            seg.BorderSizePixel = 0
            local segWidth = math.min(dashLen, w - x)
            seg.Size = UDim2.new(0, segWidth, 0, thickness)
            seg.Position = UDim2.new(0, x, 1, -thickness)
            x = x + dashLen + gapLen
        end
        -- Left edge
        local y = 0
        while y < h do
            local seg = Instance.new("Frame", borderContainer)
            seg.BackgroundColor3 = color
            seg.BorderSizePixel = 0
            local segHeight = math.min(dashLen, h - y)
            seg.Size = UDim2.new(0, thickness, 0, segHeight)
            seg.Position = UDim2.new(0, 0, 0, y)
            y = y + dashLen + gapLen
        end
        -- Right edge
        y = 0
        while y < h do
            local seg = Instance.new("Frame", borderContainer)
            seg.BackgroundColor3 = color
            seg.BorderSizePixel = 0
            local segHeight = math.min(dashLen, h - y)
            seg.Size = UDim2.new(0, thickness, 0, segHeight)
            seg.Position = UDim2.new(1, -thickness, 0, y)
            y = y + dashLen + gapLen
        end
    end

    window:GetPropertyChangedSignal("AbsoluteSize"):Connect(drawDashed)
    task.defer(drawDashed)
end
