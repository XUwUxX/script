-- KevinzHub GUI Script (Revised)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- Parent GUI to PlayerGui
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main Window Frame
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
-- Start off-screen at bottom; will tween into center
window.Position = UDim2.new(0.5, 0, 1.2, 0)
window.Size = UDim2.new(0, 550, 0, 350)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = false  -- We'll enable dragging via the top bar only
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
})
-- Optional: adjust transparency if you want a full gradient
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 0)
})
gradient.Parent = window

-- Top Bar (for title/avatar/minimize)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = window
-- Round only top corners
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

-- Make topBar draggable
topBar.Active = true
topBar.Draggable = true

-- Avatar
local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundTransparency = 1
-- Fetch headshot thumbnail
local success, thumbnailUrl = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)
if success and thumbnailUrl then
    avatar.Image = thumbnailUrl
else
    -- fallback: use a placeholder or leave blank
    avatar.Image = ""
end
avatar.Parent = topBar

-- Player name
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "PlayerName"
nameLabel.Size = UDim2.new(1, -100, 1, 0)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LocalPlayer.DisplayName or LocalPlayer.Name
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = topBar

-- Minimize/Restore Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
minimizeBtn.Position = UDim2.new(1, -8, 0.5, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizeBtn.Text = "_"
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = topBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

-- Hover effect for minimize button
minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

-- Content frame (holds input rows)
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.Parent = window

-- UIListLayout to stack inputs
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = content

-- Spacer padding at top
local paddingTop = Instance.new("UIPadding")
paddingTop.PaddingTop = UDim.new(0, 10)
paddingTop.PaddingLeft = UDim.new(0, 20)
paddingTop.PaddingRight = UDim.new(0, 20)
paddingTop.Parent = content

-- Utility to create one input row
local inputOrder = 0
local function createInput(labelText, defaultValue, callback)
    inputOrder = inputOrder + 1
    local container = Instance.new("Frame")
    container.Name = labelText .. "Container"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = inputOrder
    container.Parent = content

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = labelText .. "Label"
    label.Text = labelText
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    -- Input box
    local input = Instance.new("TextBox")
    input.Name = labelText .. "Input"
    input.Size = UDim2.new(0.6, 0, 1, 0)
    input.Position = UDim2.new(0.4, 10, 0, 0)
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = tostring(defaultValue)
    input.Text = ""
    input.TextScaled = true
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.ClearTextOnFocus = false
    input.Parent = container
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(input.Text)
            if val then
                -- call callback protected
                local success, err = pcall(function() callback(val) end)
                if not success then
                    warn("Error in input callback for "..labelText..": "..tostring(err))
                end
            end
            input.Text = ""
        end
    end)
end

-- Create inputs for WalkSpeed, JumpPower, FOV
createInput("WalkSpeed", Humanoid.WalkSpeed, function(v)
    Humanoid.WalkSpeed = v
end)
createInput("JumpPower", Humanoid.JumpPower, function(v)
    Humanoid.JumpPower = v
end)
createInput("FOV", Camera.FieldOfView, function(v)
    Camera.FieldOfView = v
end)

-- State for minimize/restore
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        -- Restore: tween size back to full
        isMinimized = false
        minimizeBtn.Text = "_"
        -- Animate window size
        TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 550, 0, 350)
        }):Play()
        -- Fade in content after resize
        content.Visible = true
    else
        -- Minimize: collapse to top bar height
        isMinimized = true
        minimizeBtn.Text = "+"
        -- Optionally hide content after tween
        TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 550, 0, 40)
        }):Play()
        -- Delay hiding content until tween nearly complete
        spawn(function()
            wait(0.25)
            content.Visible = false
        end)
    end
end)

-- Animate window on load: move into center
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Send Notification
StarterGui:SetCore("SendNotification", {
    Title = "Kevinz Hub vBeta",
    Text = "Script executed successfully!",
    Duration = 3
})
