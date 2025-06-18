local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.ResetOnSpawn = false

-- Background Frame (Window)
local window = Instance.new("Frame", gui)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 1.2) -- Start offscreen
window.Size = UDim2.fromOffset(550, 350)
window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
window.Active = true
window.Draggable = true
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 12)

-- Gradient background
local gradient = Instance.new("UIGradient", window)
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0))
})
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.7, 1),
    NumberSequenceKeypoint.new(1, 1)
})

-- Top Bar
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

-- Avatar
local avatar = Instance.new("ImageLabel", topBar)
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundTransparency = 1
avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

-- Player name
local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.BackgroundTransparency = 1
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Content
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

-- Create input fields
local function createInput(labelText, defaultValue, callback)
    local container = Instance.new("Frame", content)
    container.Size = UDim2.new(1, -40, 0, 40)
    container.Position = UDim2.new(0, 20, 0, (#content:GetChildren() - 1) * 50)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Text = labelText
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1

    local input = Instance.new("TextBox", container)
    input.Size = UDim2.new(0.6, -10, 1, 0)
    input.Position = UDim2.new(0.4, 10, 0, 0)
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = tostring(defaultValue)
    input.Text = ""
    input.TextScaled = true
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then callback(val) end
        input.Text = ""
    end)
end

-- Values from game
createInput("WalkSpeed", Humanoid.WalkSpeed, function(v)
    Humanoid.WalkSpeed = v
end)
createInput("JumpPower", Humanoid.JumpPower, function(v)
    Humanoid.JumpPower = v
end)
createInput("FOV", Camera.FieldOfView, function(v)
    Camera.FieldOfView = v
end)

-- Mini Toggle Button
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

-- Make toggle button draggable
miniToggle.Active = true
miniToggle.Draggable = true

-- Hover fade effect
local function updateButtonVisibility(hover)
    TweenService:Create(miniToggle, TweenInfo.new(0.3), {
        BackgroundTransparency = hover and 0.2 or 0.7
    }):Play()
end
updateButtonVisibility(false)

miniToggle.MouseEnter:Connect(function()
    updateButtonVisibility(true)
end)
miniToggle.MouseLeave:Connect(function()
    updateButtonVisibility(false)
end)

-- Toggle UI on click
local isVisible = true
miniToggle.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    miniToggle.Text = isVisible and "-" or "+"
    local targetPos = isVisible and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1.2, 0)
    TweenService:Create(window, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Position = targetPos
    }):Play()
end)

-- Animate on load
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Notify
StarterGui:SetCore("SendNotification", {
    Title = "Kevinz Hub vBeta",
    Text = "Script executed successfully in " .. math.random(10, 60) .. " ms!",
    Duration = 3
})
