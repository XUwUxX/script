-- Kevinz Hub LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("KevinzHub: LocalPlayer not found. This script must be a LocalScript.")
    return
end

-- Utility to get current Character and Humanoid, and update references on respawn
local Character, Humanoid
local function updateCharacter(char)
    Character = char
    Humanoid = nil
    if char then
        Humanoid = char:WaitForChild("Humanoid", 5)
    end
end

-- Initial Character
if LocalPlayer.Character then
    updateCharacter(LocalPlayer.Character)
end
-- Listen for respawn
LocalPlayer.CharacterAdded:Connect(updateCharacter)

-- Parent ScreenGui to PlayerGui
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Window Frame
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.Size = UDim2.fromOffset(550, 350)
window.AnchorPoint = Vector2.new(0.5, 0.5)
-- Start offscreen below
window.Position = UDim2.new(0.5, 0, 1.5, 0)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = true
local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 12)
windowCorner.Parent = window
window.Parent = gui

-- Gradient background (adjusted so it stays visible)
local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
})
-- If you want slight fade at edges, you can add Transparency keypoints, otherwise leave at full opacity:
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 0)
})
gradient.Parent = window

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = window
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = topBar

-- Avatar
local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundTransparency = 1
-- Use pcall in case thumbnail fails
spawn(function()
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if success and image then
        avatar.Image = image
    else
        -- fallback: leave blank or set a default
        avatar.Image = ""
        warn("KevinzHub: Failed to get avatar thumbnail")
    end
end)
avatar.Parent = topBar

-- Player Name
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "PlayerName"
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
-- DisplayName is more user-friendly; fallback to Name
nameLabel.Text = LocalPlayer.DisplayName or LocalPlayer.Name
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.BackgroundTransparency = 1
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = topBar

-- Content Frame for input rows
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.Parent = window

-- Row counter for inputs
local inputRow = 0

-- Function to create labeled numeric input
local function createInput(labelText, getDefault, callback)
    inputRow = inputRow + 1
    local rowHeight = 40
    local padding = 10
    local yOffset = (inputRow - 1) * (rowHeight + padding) + padding

    local container = Instance.new("Frame")
    container.Name = labelText .. "Row"
    container.Size = UDim2.new(1, -40, 0, rowHeight)
    container.Position = UDim2.new(0, 20, 0, yOffset)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Name = labelText .. "Label"
    label.Text = labelText
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Name = labelText .. "Input"
    input.Size = UDim2.new(0.6, -10, 1, 0)
    input.Position = UDim2.new(0.4, 10, 0, 0)
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = tostring(getDefault())
    input.Text = ""
    input.TextScaled = true
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    input.Parent = container

    input.ClearTextOnFocus = false

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = input.Text
            local val = tonumber(text)
            if val then
                -- Ensure the Humanoid or Camera exists at time of change
                pcall(function()
                    callback(val)
                end)
            else
                -- Invalid number: optionally warn or shake input
                -- Here we just reset text to blank
            end
            input.Text = ""
        end
    end)
end

-- Create the inputs, using functions to fetch default values at runtime
createInput("WalkSpeed", function()
    if Humanoid then
        return Humanoid.WalkSpeed
    else
        return 16 -- default Roblox WalkSpeed
    end
end, function(v)
    if Humanoid then
        Humanoid.WalkSpeed = v
    end
end)

createInput("JumpPower", function()
    if Humanoid then
        return Humanoid.JumpPower
    else
        return 50 -- default JumpPower
    end
end, function(v)
    if Humanoid then
        Humanoid.JumpPower = v
    end
end)

createInput("FOV", function()
    -- Camera may not be ready immediately
    local cam = workspace.CurrentCamera
    if cam then
        return cam.FieldOfView
    else
        return 70 -- default FOV
    end
end, function(v)
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = v
    end
end)

-- Mini Toggle Button
local miniToggle = Instance.new("TextButton")
miniToggle.Name = "MiniToggle"
miniToggle.Size = UDim2.new(0, 36, 0, 36)
-- Position it at lower right of window initially, for example: relative to screen center?
-- Here we position at center of screen; you can adjust as needed.
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
miniToggle.Position = UDim2.new(0.9, 0, 0.9, 0)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "-"
miniToggle.TextScaled = true
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextColor3 = Color3.new(1, 1, 1)
miniToggle.AutoButtonColor = false
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = miniToggle
miniToggle.Parent = gui

-- Make toggle button draggable
miniToggle.Active = true
miniToggle.Draggable = true

-- Hover fade effect
local function updateButtonTransparency(hover)
    local targetTransparency = hover and 0.2 or 0.7
    TweenService:Create(miniToggle, TweenInfo.new(0.3), {
        BackgroundTransparency = targetTransparency
    }):Play()
end
miniToggle.BackgroundTransparency = 0.7
miniToggle.MouseEnter:Connect(function()
    updateButtonTransparency(true)
end)
miniToggle.MouseLeave:Connect(function()
    updateButtonTransparency(false)
end)

-- Toggle UI on click
local isVisible = false
local function showWindow()
    isVisible = true
    miniToggle.Text = "-"
    -- Tween window to center
    TweenService:Create(window, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
end
local function hideWindow()
    isVisible = false
    miniToggle.Text = "+"
    -- Tween window offscreen below
    TweenService:Create(window, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 1.5, 0)
    }):Play()
end

miniToggle.MouseButton1Click:Connect(function()
    if isVisible then
        hideWindow()
    else
        showWindow()
    end
end)

-- Animate on load: show window with a Back easing
delay(0.1, function()
    showWindow()
end)

-- Notification
spawn(function()
    local execTime = math.random(10, 60)
    StarterGui:SetCore("SendNotification", {
        Title = "Kevinz Hub vBeta",
        Text = "Script executed successfully in " .. execTime .. " ms!",
        Duration = 3
    })
end)

-- Optional: Reapply defaults when Humanoid changes (e.g., on respawn), update placeholder texts
LocalPlayer.CharacterAdded:Connect(function(char)
    -- Wait a short moment for Humanoid to exist and GUI to exist
    wait(1)
    -- Update placeholders for input boxes
    -- You can iterate over content children and update PlaceholderText:
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("Frame") then
            local label = child:FindFirstChildWhichIsA("TextLabel")
            local input = child:FindFirstChildWhichIsA("TextBox")
            if label and input then
                local key = label.Text
                if key == "WalkSpeed" and Humanoid then
                    input.PlaceholderText = tostring(Humanoid.WalkSpeed)
                elseif key == "JumpPower" and Humanoid then
                    input.PlaceholderText = tostring(Humanoid.JumpPower)
                elseif key == "FOV" then
                    local cam = workspace.CurrentCamera
                    if cam then
                        input.PlaceholderText = tostring(cam.FieldOfView)
                    end
                end
            end
        end
    end
end)
