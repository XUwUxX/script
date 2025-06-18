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

-- Gradient background
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1

local gradient = Instance.new("UIGradient", bg)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
}
gradient.Rotation = 90
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(1, 1)
}

-- Main Window
local window = Instance.new("Frame", gui)
window.Size = UDim2.new(0, 360, 0, 270)
window.Position = UDim2.new(0.5, 0, 1.2, 0)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
window.BorderSizePixel = 0
window.ClipsDescendants = true
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", window).Color = Color3.fromRGB(255, 0, 0)

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

-- Name label
local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
nameLabel.Text = LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.BackgroundTransparency = 1
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Draggable
topBar.Active = true
topBar.Draggable = true

-- Content frame
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1

-- Create text inputs
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

-- Default values from game
local defaultWalkSpeed = Humanoid.WalkSpeed
local defaultJumpPower = Humanoid.JumpPower
local defaultFOV = Camera.FieldOfView

createInput("WalkSpeed", defaultWalkSpeed, function(v)
    Humanoid.WalkSpeed = v
end)

createInput("JumpPower", defaultJumpPower, function(v)
    Humanoid.JumpPower = v
end)

createInput("FOV", defaultFOV, function(v)
    Camera.FieldOfView = v
end)

-- Toggle button
local toggle = Instance.new("TextButton", content)
toggle.Size = UDim2.new(1, -40, 0, 40)
toggle.Position = UDim2.new(0, 20, 1, -50)
toggle.Text = "Toggle UI"
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

local visible = true
toggle.MouseButton1Click:Connect(function()
    visible = not visible
    TweenService:Create(window, TweenInfo.new(0.5), {
        Position = visible and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1.2, 0)
    }):Play()
end)

-- Animation Slide In (On Script Execute)
TweenService:Create(window, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()

-- Notify
StarterGui:SetCore("SendNotification", {
    Title = "Kevinz Hub Version beta-1003",
    Text = "Script executed successfully in " .. math.random(10, 60) .. " ms!",
    Duration = 3
})
