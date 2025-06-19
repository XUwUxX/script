-- Kevinz Hub Full Script với Dark Minimalist GUI, Gradient, UI Grid Background “liền” trong window, ESP, Anti Features, Gun Aura, Notification, v.v.
-- Phần blur/overlay đã được loại bỏ hoàn toàn.

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
local HUB_VERSION = "v1.7.5"

-- ================= GUI SETUP =================
-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Main window
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromOffset(400, 380)  -- cố định kích thước
window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
window.BackgroundTransparency = 0.3  -- semi-translucent để thấy grid UI phía sau nhưng không mờ background game
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

-- Gradient overlay inside window (đen->đỏ sẫm, mờ)
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

-- === UI Grid Background inside window ===
local gridContainer = Instance.new("Frame", window)
gridContainer.Name = "UIGridBackground"
gridContainer.AnchorPoint = Vector2.new(0, 0)
gridContainer.Position = UDim2.new(0, 0, 0, 0)
gridContainer.Size = UDim2.new(1, 0, 1, 0)  -- full window
gridContainer.BackgroundTransparency = 1
gridContainer.ZIndex = 1  -- để dưới content, trên background color+gradient

-- Hàm vẽ lại grid khi size window thay đổi hoặc khởi tạo
local function drawUIGrid()
    -- Xóa các line cũ
    for _, child in ipairs(gridContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    -- Lấy kích thước thực tế (px)
    local absSize = window.AbsoluteSize
    local widthPx = absSize.X
    local heightPx = absSize.Y
    -- Chọn spacing (px) cho grid, ví dụ 20 px
    local spacing = 20
    local lineThickness = 1

    -- Màu line: nhạt so với background, ví dụ trắng nhẹ với transparency
    local lineColor = Color3.fromRGB(200, 200, 200)
    local lineTrans = 0.8

    -- Vẽ đường dọc
    local x = 0
    while x <= widthPx do
        local line = Instance.new("Frame")
        line.Name = "GridLineV"
        line.Size = UDim2.new(0, lineThickness, 1, 0)
        line.Position = UDim2.new(0, x, 0, 0)
        line.BackgroundColor3 = lineColor
        line.BackgroundTransparency = lineTrans
        line.ZIndex = 1
        line.Parent = gridContainer
        x = x + spacing
    end
    -- Vẽ đường ngang
    local y = 0
    while y <= heightPx do
        local line = Instance.new("Frame")
        line.Name = "GridLineH"
        line.Size = UDim2.new(1, 0, 0, lineThickness)
        line.Position = UDim2.new(0, 0, 0, y)
        line.BackgroundColor3 = lineColor
        line.BackgroundTransparency = lineTrans
        line.ZIndex = 1
        line.Parent = gridContainer
        y = y + spacing
    end
end

-- Kết nối với AbsoluteSize thay đổi
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    task.defer(drawUIGrid)
end)
-- Lần đầu
task.defer(drawUIGrid)

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

-- Content ScrollingFrame (trên gridContainer)
local content = Instance.new("ScrollingFrame", window)
content.Name = "ContentFrame"
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ZIndex = 2  -- trên grid

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

-- Close / miniToggle behaviors (chỉ hide/show window, không blur)
closeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
end)
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
end)

-- Show window on initial load (không blur)
task.defer(function()
    window.Visible = true
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

-- Setup ESP listeners
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

-- Hàm highlight dropped gun
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

-- ---------- Setup Anti Features initially ----------
setupAntiFeatures()

-- ---------- Create Inputs/Switches for core settings ----------
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
-- ESP Theo Role
createSwitch("ESP Theo Role", function(on)
    chamEnabled = on
    updateAllChams()
end)
-- Gun Aura
createSwitch("Gun Aura", function(on)
    gunAuraEnabled = on
end)
createInput("Gun Aura Radius", function() return auraRadius end, function(v)
    auraRadius = v
end)
-- Không còn Background Grid 3D hay blur overlay

-- ---------- CharacterAdded để reapply khi respawn ----------
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
    setupAntiFeatures()
    -- Reset walk/jump
    if Humanoid then
        task.wait(0.2)
        pcall(function()
            Humanoid.WalkSpeed = savedWalkSpeed
            Humanoid.JumpPower = savedJumpPower
        end)
    end
    -- Reapply ESP nếu đang bật
    if chamEnabled then
        task.delay(0.5, function()
            updateAllChams()
        end)
    end
    -- Gun Aura logic tự chạy trong loop
end)

-- ========== Kết thúc full script ==========
