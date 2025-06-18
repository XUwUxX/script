-- Kevinz Hub - Full Script with GUI, WalkSpeed/JumpPower Save, Chams ESP Toggle

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Store WalkSpeed & JumpPower after changes
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.3.1"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local window = Instance.new("Frame")
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 1.2)
window.Size = UDim2.fromOffset(550, 400)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = true
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)
window.Parent = gui

-- Gradient + Material Effect
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

local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

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
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.6, -10, 1, 0)
    input.Position = UDim2.new(0.4, 10, 0, 0)
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = tostring(getDefault())
    input.Text = ""
    input.TextScaled = true
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    input.Parent = container

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then callback(val) end
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

-- Inputs
createInput("WalkSpeed", function() return savedWalkSpeed end, function(v)
    savedWalkSpeed = v
    if Humanoid then Humanoid.WalkSpeed = v end
end)

createInput("JumpPower", function() return savedJumpPower end, function(v)
    savedJumpPower = v
    if Humanoid then Humanoid.JumpPower = v end
end)

createInput("FOV", function() return Camera.FieldOfView end, function(v)
    Camera.FieldOfView = v
end)

-- Chams ESP
local chamEnabled = false
local chamHighlights = {}

local function updateChams(enable)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = chamHighlights[player]

            if enable then
                if not highlight or not highlight.Parent then
                    highlight = Instance.new("Highlight")
                    highlight.Adornee = char
                    highlight.FillColor = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = char
                    chamHighlights[player] = highlight
                end
            else
                if highlight then
                    highlight:Destroy()
                    chamHighlights[player] = nil
                end
            end
        end
    end
end

createSwitch("Chams ESP", function(on)
    chamEnabled = on
    updateChams(on)
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if chamEnabled then task.wait(1); updateChams(true) end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    chamHighlights[p] = nil
end)

-- Mini toggle
local miniToggle = Instance.new("TextButton", gui)
miniToggle.Size = UDim2.new(0, 36, 0, 36)
miniToggle.Position = UDim2.new(0.5, -18, 0.5, -18)
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "-"
miniToggle.TextScaled = true
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextColor3 = Color3.new(1, 1, 1)
miniToggle.AutoButtonColor = false
Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(1, 0)
miniToggle.Active = true
miniToggle.Draggable = true

local isVisible = true
miniToggle.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    miniToggle.Text = isVisible and "-" or "+"
    local targetPos = isVisible and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1.2, 0)
    TweenService:Create(window, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Position = targetPos
    }):Play()

    if isVisible then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Kevinz Hub",
                Text = "Version: " .. HUB_VERSION .. " resumed.",
                Duration = 3
            })
        end)
    end
end)

-- Animate on load
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Reset handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        Humanoid = hum
        task.wait(0.2)
        Humanoid.WalkSpeed = savedWalkSpeed
        Humanoid.JumpPower = savedJumpPower
    end
end)

-- Show load notification
task.delay(1, function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kevinz Hub Loaded ✅",
            Text = "Running version: " .. HUB_VERSION,
            Duration = 5
        })
    end)
end)
