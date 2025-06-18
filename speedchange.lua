-- Kevinz Hub - Full Script with GUI, WalkSpeed/JumpPower Save, Role-based ESP for Murder Mystery 2
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for local character & humanoid
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Saved defaults
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.4.0"  -- phiên bản mới

-- Create GUI
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
-- HeadShot thumbnail
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

-- Content area for inputs/switches
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

-- Helpers for dynamic input rows
local inputRow = 0

local function createInput(labelText, getDefault, callback)
    inputRow += 1
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
    -- Placeholder khởi tạo từ getDefault()
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
            -- Cập nhật placeholder thành giá trị mới
            input.PlaceholderText = tostring(val)
        end
        input.Text = ""
    end)
end

local function createSwitch(labelText, callback)
    inputRow += 1
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

-- Create inputs for WalkSpeed, JumpPower, FOV
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

createInput("FOV", function() return Camera.FieldOfView end, function(v)
    pcall(function() Camera.FieldOfView = v end)
end)

-- Chams ESP variables
local chamEnabled = false
local chamHighlights = {}  -- map Player -> Highlight instance

-- Function to determine role in Murder Mystery 2
-- Kiểm tra tool “Knife” => Murderer; “Gun” => Sheriff; else Innocent
local function getRole(player)
    local char = player.Character
    -- Nếu chưa có Character, tạm xem Innocent
    if char then
        -- Kiểm tra trên Character (equip) hoặc Backpack (chưa equip)
        -- Lưu ý: đổi tên tool nếu game dùng tên khác
        if char:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
            return "Murderer"
        end
        if char:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
            return "Sheriff"
        end
    end
    return "Innocent"
end

-- Update màu Highlight dựa role
local function updateHighlightColor(player)
    local h = chamHighlights[player]
    if not h or not h.Parent then return end
    local role = getRole(player)
    if role == "Murderer" then
        h.FillColor = Color3.fromRGB(255, 0, 0)       -- đỏ
    elseif role == "Sheriff" then
        h.FillColor = Color3.fromRGB(0, 0, 255)       -- xanh dương
    else
        h.FillColor = Color3.fromRGB(255, 255, 255)   -- trắng
    end
    -- Nếu muốn, có thể chỉnh OutlineColor theo role
end

-- Add Highlight for a player (nếu chưa có), rồi cập nhật màu
local function addHighlightForPlayer(player)
    if not player.Character then return end
    if chamHighlights[player] and chamHighlights[player].Parent then
        -- đã có, chỉ update màu
        updateHighlightColor(player)
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    -- Set tạm default; sẽ được update ngay sau
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    chamHighlights[player] = highlight
    -- Cập nhật màu theo role hiện tại
    updateHighlightColor(player)
end

-- Remove Highlight cho player
local function removeHighlightForPlayer(player)
    local h = chamHighlights[player]
    if h then
        pcall(function() h:Destroy() end)
        chamHighlights[player] = nil
    end
end

-- Khi ESP bật/tắt: apply hoặc remove cho tất cả
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

-- Thiết lập listeners để theo dõi respawn và tool changes cho một player
local function setupPlayerListeners(player)
    -- CharacterAdded: respawn
    player.CharacterAdded:Connect(function(char)
        -- Delay để Character và Backpack replicate đầy đủ
        task.delay(0.5, function()
            if chamEnabled and player ~= LocalPlayer then
                addHighlightForPlayer(player)
            end
            -- Lắng nghe tool trong Character mới
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
    -- Backpack changes (tool giao/trả)
    spawn(function()
        -- chờ Backpack replicate
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

-- Tạo switch Chams ESP
createSwitch("ESP Theo Role", function(on)
    chamEnabled = on
    updateAllChams()
end)

-- Thiết lập ban đầu cho tất cả players hiện có
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
    end
end

-- Khi có player mới join
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

-- Khi có player rời
Players.PlayerRemoving:Connect(function(player)
    removeHighlightForPlayer(player)
end)

-- mini toggle button để ẩn/hiện window
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

-- Close ("-") button trong topBar
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

-- Tween-in animation
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Handle local player respawn: restore WalkSpeed/JumpPower và reapply ESP cho others nếu bật
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        Humanoid = hum
        task.wait(0.2)
        pcall(function()
            Humanoid.WalkSpeed = savedWalkSpeed
            Humanoid.JumpPower = savedJumpPower
        end)
    end
    if chamEnabled then
        task.delay(0.5, function()
            updateAllChams()
        end)
    end
end)

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
