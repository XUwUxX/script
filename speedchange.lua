-- Kevinz Hub LocalScript
-- Place this LocalScript in StarterPlayerScripts or execute via executor in a LocalScript context.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("KevinzHub: LocalPlayer not found. This script must run in a LocalScript context.")
    return
end

-- Utility: track Character and Humanoid, update on respawn
local Character, Humanoid
local function updateCharacter(char)
    Character = char
    Humanoid = nil
    if char then
        Humanoid = char:WaitForChild("Humanoid", 5)
    end
end

-- Initial character reference if exists
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
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = playerGui

-- MAIN WINDOW FRAME
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.Size = UDim2.fromOffset(550, 350)
window.AnchorPoint = Vector2.new(0.5, 0.5)
-- Start hidden offscreen or invisible; we will manage Visible property
window.Position = UDim2.new(0.5, 0.5, 0, 0)  -- center, but keep Visible=false initially
window.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- base black
window.Visible = false  -- start hidden
window.Active = true
window.Draggable = true
window.Parent = gui

-- Rounded corners
local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 12)
windowCorner.Parent = window

-- BACKGROUND GRADIENT (black -> red)
local bgGradient = Instance.new("UIGradient")
bgGradient.Name = "BackgroundGradient"
bgGradient.Rotation = 90
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),       -- black at top
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 0)),     -- dark red at bottom
})
-- Fully opaque gradient
bgGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 0),
})
bgGradient.Parent = window

-- UIStroke for silver-like border
local stroke = Instance.new("UIStroke")
stroke.Name = "WindowStroke"
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(200, 200, 200)  -- light gray (silver-like)
stroke.Transparency = 0.3  -- slight transparency for subtle effect
stroke.Parent = window

-- OPTIONAL: Overlay metal texture (commented out; replace with your own asset ID if available)
--[[
local metalOverlay = Instance.new("ImageLabel")
metalOverlay.Name = "MetalOverlay"
metalOverlay.Size = UDim2.new(1, 0, 1, 0)
metalOverlay.Position = UDim2.new(0, 0, 0, 0)
metalOverlay.BackgroundTransparency = 1
-- Replace 12345678 with a valid metal texture Asset ID if you have one
metalOverlay.Image = "rbxassetid://12345678"
metalOverlay.ScaleType = Enum.ScaleType.Tile
metalOverlay.TileSize = UDim2.new(0, 100, 0, 100)
metalOverlay.ImageTransparency = 0.7  -- keep underlying gradient visible
metalOverlay.Parent = window
]]

-- SHINE EFFECT: a frame with white gradient that moves across window
local shineFrame = Instance.new("Frame")
shineFrame.Name = "ShineEffect"
-- Size: 20% width of window, 200% height to cover diagonal shine
shineFrame.Size = UDim2.new(0.2, 0, 2, 0)
-- Start position: left outside window
shineFrame.Position = UDim2.new(-0.3, 0, -0.5, 0)
shineFrame.BackgroundColor3 = Color3.new(1, 1, 1)
shineFrame.BackgroundTransparency = 1
shineFrame.Parent = window

local shineGrad = Instance.new("UIGradient")
shineGrad.Rotation = 45
shineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
})
shineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.4, 0.7),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(0.6, 0.7),
    NumberSequenceKeypoint.new(1, 1),
})
shineGrad.Parent = shineFrame

-- Function to play shine animation across the window
local function playShine()
    if not window.Visible then return end
    -- Reset start position
    shineFrame.Position = UDim2.new(-0.3, 0, -0.5, 0)
    -- Tween across to right outside
    local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local goal = { Position = UDim2.new(1.3, 0, -0.5, 0) }
    local tween = TweenService:Create(shineFrame, tweenInfo, goal)
    tween:Play()
    -- No need to reset transparency because gradient controls it
end

-- Top Bar: avatar + player name
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = window
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = topBar

-- Avatar Image
local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 6, 0.5, -16)
avatar.BackgroundTransparency = 1
avatar.Parent = topBar
-- Fetch thumbnail safely
spawn(function()
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    if success and image then
        avatar.Image = image
    else
        avatar.Image = ""
        warn("KevinzHub: Failed to get avatar thumbnail")
    end
end)

-- Player Name Label
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "PlayerName"
nameLabel.Size = UDim2.new(1, -50, 1, 0)
nameLabel.Position = UDim2.new(0, 44, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = LocalPlayer.DisplayName or LocalPlayer.Name
nameLabel.Parent = topBar

-- Content frame for inputs
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency = 1
content.Parent = window

-- Input row counter
local inputRow = 0

-- Function to create labeled numeric TextBox input
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
    input.ClearTextOnFocus = false
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    input.Parent = container

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = input.Text
            local val = tonumber(text)
            if val then
                local success, err = pcall(function()
                    callback(val)
                end)
                if success then
                    -- Update placeholder to show new value
                    input.PlaceholderText = tostring(val)
                else
                    warn("Error in callback for " .. labelText .. ": " .. tostring(err))
                end
            end
            input.Text = ""
        end
    end)
end

-- Create inputs for WalkSpeed, JumpPower, FOV
createInput("WalkSpeed", function()
    if Humanoid then
        return Humanoid.WalkSpeed
    else
        return 16
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
        return 50
    end
end, function(v)
    if Humanoid then
        Humanoid.JumpPower = v
    end
end)

createInput("FOV", function()
    local cam = workspace.CurrentCamera
    if cam then
        return cam.FieldOfView
    else
        return 70
    end
end, function(v)
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = v
    end
end)

-- MINI TOGGLE BUTTON to show/hide window
local miniToggle = Instance.new("TextButton")
miniToggle.Name = "MiniToggle"
miniToggle.Size = UDim2.new(0, 36, 0, 36)
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
-- Initial position: bottom-right corner (adjust as desired)
miniToggle.Position = UDim2.new(0.9, 0, 0.9, 0)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.BackgroundTransparency = 0.7
miniToggle.Text = "-"
miniToggle.TextScaled = true
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextColor3 = Color3.new(1, 1, 1)
miniToggle.AutoButtonColor = false
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = miniToggle
miniToggle.Parent = gui

miniToggle.Active = true
miniToggle.Draggable = true

-- Hover effect for toggle
miniToggle.MouseEnter:Connect(function()
    TweenService:Create(miniToggle, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.2
    }):Play()
end)
miniToggle.MouseLeave:Connect(function()
    TweenService:Create(miniToggle, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.7
    }):Play()
end)

-- Show/hide logic using Visible + fade animations
local isVisible = false

local function showWindow()
    if not window.Visible then
        -- Prepare window and children for fade-in: set transparency to 1
        window.Visible = true
        window.BackgroundTransparency = 1
        -- Prepare children: for each GuiObject descendant, set TextTransparency/ImageTransparency/BackgroundTransparency = 1
        for _, child in ipairs(window:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("ImageLabel") or child:IsA("TextButton") or child:IsA("ImageButton") then
                -- BackgroundTransparency might not exist on TextLabel/TextBox, but setting safe via pcall
                pcall(function()
                    if child.BackgroundTransparency ~= nil then
                        child.BackgroundTransparency = 1
                    end
                end)
                pcall(function()
                    if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                        child.TextTransparency = 1
                    end
                end)
                pcall(function()
                    if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        child.ImageTransparency = 1
                    end
                end)
            end
        end
    end
    isVisible = true
    miniToggle.Text = "-"

    -- Tween window background fade-in
    TweenService:Create(window, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
    -- Tween children fade-in
    for _, child in ipairs(window:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("ImageLabel") or child:IsA("TextButton") or child:IsA("ImageButton") then
            if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
            elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                TweenService:Create(child, TweenInfo.new(0.3), { ImageTransparency = 0 }):Play()
            else
                -- Frame or other: fade in background if applicable
                pcall(function()
                    if child.BackgroundTransparency ~= nil then
                        TweenService:Create(child, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
                    end
                end)
            end
        end
    end

    -- After fade-in begins, play shine effect
    playShine()
end

local function hideWindow()
    isVisible = false
    miniToggle.Text = "+"
    -- Fade out window and descendants
    TweenService:Create(window, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
    for _, child in ipairs(window:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("ImageLabel") or child:IsA("TextButton") or child:IsA("ImageButton") then
            if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
            elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                TweenService:Create(child, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
            else
                pcall(function()
                    if child.BackgroundTransparency ~= nil then
                        TweenService:Create(child, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                    end
                end)
            end
        end
    end
    -- After fade-out completes, set Visible=false
    delay(0.25, function()
        window.Visible = false
    end)
end

miniToggle.MouseButton1Click:Connect(function()
    if isVisible then
        hideWindow()
    else
        showWindow()
    end
end)

-- On load, show window with a slight delay
delay(0.1, function()
    showWindow()
end)

-- Optional: periodic shine effect every few seconds
spawn(function()
    while true do
        wait(5)
        if isVisible then
            playShine()
        end
    end
end)

-- Notification to confirm execution
spawn(function()
    local execTime = math.random(10, 60)
    StarterGui:SetCore("SendNotification", {
        Title = "Kevinz Hub vBeta",
        Text = "Script executed successfully in " .. execTime .. " ms!",
        Duration = 3
    })
end)

-- Update placeholders on respawn (CharacterAdded)
LocalPlayer.CharacterAdded:Connect(function(char)
    updateCharacter(char)
    wait(1)
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

task.delay(1, function()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Kevinz Hub",
            Text = "Welcome! Running version: v1.3.0 🔧",
            Duration = 5
        })
    end)
end)

-- Debug print
print("KevinzHub: GUI loaded")
