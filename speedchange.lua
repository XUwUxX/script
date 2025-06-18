-- Kevinz Hub - Full Script with GUI, WalkSpeed/JumpPower Save, Role-based ESP for Murder Mystery 2,
-- plus hidden features: anti void, anti linear fling, anti angular fling,
-- ESP tự động cập nhật role mỗi 1s khi bật ESP,
-- Fix anti-return khi nhảy từ cao,
-- Thêm WalkFling toggle,
-- Highlight dropped gun và Gun Aura pick-up tự động với radius tùy chỉnh.

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService") -- nếu cần tagging

-- Local player references
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Saved defaults
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.7.1"  -- cập nhật phiên bản

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
window.Size = UDim2.fromOffset(550, 500)
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
-- Lấy thumbnail headshot
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
    -- CharacterAdded: re-add highlight khi respawn nếu ESP bật
    player.CharacterAdded:Connect(function(char)
        task.delay(0.5, function()
            if chamEnabled and player ~= LocalPlayer then
                addHighlightForPlayer(player)
            end
            if char then
                -- lắng nghe thay đổi tool để cập nhật role
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
    -- Backpack changes cũng cập nhật role
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
    end
end)
-- Khi player remove, xoá highlight map
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

    -- Cập nhật lastSafeCFrame khi chạm đất bình thường
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

    -- Heartbeat loop
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
            -- nếu tốc độ quá lớn và không phải đang rơi/jump bình thường => coi như fling
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
                -- Giữ nguyên hướng y cũ
                local _, yOri, _ = lastSafeCFrame:ToOrientation()
                local newCFrame = CFrame.new(safePos) * CFrame.Angles(0, yOri, 0)
                RootPart.CFrame = newCFrame + Vector3.new(0, 5, 0)
            end)
            -- Cho FrameGyro giữ orientation tạm thời
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

-- WalkFling feature
local walkFlingEnabled = false
local flingForce = 100  -- bạn có thể điều chỉnh mặc định, hoặc thêm input nếu muốn

-- Tạo toggle WalkFling
createSwitch("WalkFling (troll)", function(on)
    walkFlingEnabled = on
end)

-- Kết nối Touched event khi character tải xong
local function setupWalkFlingForCharacter(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.Touched:Connect(function(hit)
        if not walkFlingEnabled then return end
        -- Kiểm tra hit là part của người chơi khác
        local otherChar = hit:FindFirstAncestorWhichIsA("Model")
        if otherChar and otherChar ~= Character then
            local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
            local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
            if otherHum and otherRoot then
                -- Tính hướng fling: đẩy ra xa LocalPlayer
                local direction = (otherRoot.Position - root.Position)
                if direction.Magnitude > 0 then
                    direction = direction.Unit
                else
                    direction = Vector3.new(0, 1, 0)
                end
                -- Tạo BodyVelocity trên otherRoot
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = direction * flingForce + Vector3.new(0, 50, 0)
                bv.P = 1250
                bv.Parent = otherRoot
                -- Tự hủy sau 0.3s
                task.delay(0.3, function()
                    if bv and bv.Parent then
                        bv:Destroy()
                    end
                end)
            end
        end
    end)
end

-- Kết nối cho existing và respawn
if Character then
    setupWalkFlingForCharacter(Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
    -- Delay nhỏ để HumanoidRootPart ổn định
    task.delay(0.5, function()
        setupWalkFlingForCharacter(char)
    end)
end)

-- Gun Highlight & Gun Aura
local gunHighlightTable = {}  -- map Tool -> Highlight
local gunAuraEnabled = false
local auraRadius = 10  -- default meters

-- Toggle Gun Aura
createSwitch("Gun Aura", function(on)
    gunAuraEnabled = on
end)
-- Input radius Gun Aura
createInput("Gun Aura Radius", function() return auraRadius end, function(v)
    auraRadius = v
end)

-- Hàm highlight dropped gun
local function highlightDroppedGun(tool)
    if gunHighlightTable[tool] then return end
    -- Nếu tool có Handle, highlight lên Handle
    local adorneeObj = nil
    if tool:FindFirstChild("Handle") then
        adorneeObj = tool.Handle
    else
        -- fallback: cả tool
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

-- Hàm bỏ highlight khi tool được nhặt hoặc removed
local function removeHighlightDroppedGun(tool)
    local hl = gunHighlightTable[tool]
    if hl then
        pcall(function() hl:Destroy() end)
        gunHighlightTable[tool] = nil
    end
end

-- Loop kiểm tra dropped guns trong workspace
spawn(function()
    while true do
        -- Duyệt workspace descendants tìm Tool tên "Gun"
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj.Name == "Gun" then
                -- Nếu tool parent không phải là character của ai (đang rơi/trên ground)
                local parent = obj.Parent
                local inCharacter = false
                if parent and parent:FindFirstChildOfClass("Humanoid") then
                    inCharacter = true
                end
                if not inCharacter then
                    -- Highlight nếu chưa
                    highlightDroppedGun(obj)
                    -- Gun Aura: nếu enabled và LocalPlayer đang gần
                    if gunAuraEnabled and RootPart and RootPart.Parent then
                        -- tìm vị trí tool: lấy Handle Position hoặc PrimaryPart
                        local pos = nil
                        if obj:FindFirstChild("Handle") then
                            pos = obj.Handle.Position
                        elseif obj.PrimaryPart then
                            pos = obj.PrimaryPart.Position
                        end
                        if pos then
                            local dist = (RootPart.Position - pos).Magnitude
                            if dist <= auraRadius then
                                -- pick up tool: đưa vào Backpack
                                local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
                                pcall(function()
                                    obj.Parent = backpack
                                end)
                                -- Remove highlight
                                removeHighlightDroppedGun(obj)
                            end
                        end
                    end
                else
                    -- tool đang trên người chơi => remove highlight nếu có
                    removeHighlightDroppedGun(obj)
                end
            end
        end
        -- Clean up entries đã destroy
        for tool, hl in pairs(gunHighlightTable) do
            if not tool.Parent then
                removeHighlightDroppedGun(tool)
            end
        end
        wait(1)
    end
end)

-- Anti features và reapply stats khi respawn
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
    -- re-setup WalkFling
    task.delay(0.5, function()
        setupWalkFlingForCharacter(char)
    end)
    -- reapply ESP nếu bật
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
