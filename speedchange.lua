-- Kevinz Hub Full Script v1.7.5 (Fixed)
-- ESP logic fixed for proper round-to-round persistence and Sheriff vs Hero detection.
-- Fixed Sheriff gun auto-unequip bug caused by Gun Aura.
-- Includes full UI, Anti-Features, Gun Aura, Highlight Dropped Gun, and performance optimizations.
-- GUI nền đen, parent vào PlayerGui, chạy client-side. Re-inject hoặc queue_on_teleport nếu game teleport giữa places.

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserSettings = UserSettings() -- global

-- Local refs
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Saved defaults
local savedWalkSpeed = Humanoid.WalkSpeed
local savedJumpPower = Humanoid.JumpPower
local HUB_VERSION = "v1.7.5"

-- ================= GUI SETUP =================
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHub"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Add a UIScale to the main ScreenGui for overall scaling based on resolution
local uiScale = Instance.new("UIScale")
uiScale.Parent = gui
-- Adjust this value based on desired UI size on different resolutions.
-- A lower scale will make the UI physically smaller.
-- You might want to tie this to screen resolution if specific scaling is needed.
uiScale.Scale = 0.9 -- Default scale, can be adjusted for responsiveness


local window = Instance.new("Frame")
window.Name = "MainWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
-- Use scale for position and size to make it more responsive
window.Position = UDim2.fromScale(0.5, -0.5) -- Start off-screen (relative to screen height)
window.Size = UDim2.fromScale(0.4, 0.8) -- Make it 40% of screen width and 80% of screen height
window.MinSize = UDim2.new(0, 300, 0, 450) -- Add a minimum size to prevent it from becoming too small
window.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
window.BackgroundTransparency = 0.1
window.BorderSizePixel = 0
window.Active = true
window.Draggable = true
window.ZIndex = 2
window.ClipsDescendants = true
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", window)
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 1

-- Top bar
local topBar = Instance.new("Frame", window)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0.08, 0) -- 8% of window height
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
topBar.BorderSizePixel = 0

-- Avatar
local success, thumb = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)
local avatar = Instance.new("ImageLabel", topBar)
avatar.Name = "Avatar"
avatar.Size = UDim2.new(0, 24, 1, -6) -- Fixed width, scale height (with padding)
avatar.Position = UDim2.new(0, 6, 0, 3) -- Small fixed padding
avatar.BackgroundTransparency = 1
avatar.Image = success and thumb or ""
avatar.ImageTransparency = success and 0 or 1
local avatarCorner = Instance.new("UICorner", avatar)
avatarCorner.CornerRadius = UDim.new(1, 0) -- Circle

-- DisplayName
local nameLabel = Instance.new("TextLabel", topBar)
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(1, -60, 1, 0) -- Take full width minus space for avatar and button
nameLabel.Position = UDim2.new(0, 36, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Kevinz Hub | "..LocalPlayer.DisplayName
nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 14
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeButton = Instance.new("TextButton", topBar)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 28, 1, -4) -- Fixed width, scale height (with padding)
closeButton.Position = UDim2.new(1, -32, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.Text = "-"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.fromRGB(240, 240, 240)
closeButton.AutoButtonColor = false
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)

-- Content ScrollingFrame
local content = Instance.new("ScrollingFrame", window)
content.Name = "ContentFrame"
content.Size = UDim2.new(1, 0, 0.92, 0) -- Take remaining 92% of window height
content.Position = UDim2.new(0, 0, 0.08, 0) -- Position below top bar
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Active = true
content.ZIndex = 2
local uiList = Instance.new("UIListLayout", content)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8) -- Fixed pixel padding, acceptable for small gaps
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Mini toggle to reopen window
local miniToggle = Instance.new("TextButton", gui)
miniToggle.Name = "MiniToggle"
miniToggle.Size = UDim2.new(0, 28, 0, 28) -- Fixed size for mini toggle (can be scaled too)
miniToggle.Position = UDim2.new(0.05, 0, 0.95, 0) -- Position relative to screen
miniToggle.AnchorPoint = Vector2.new(0.5, 0.5)
miniToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniToggle.Text = "+"
miniToggle.Font = Enum.Font.GothamBold
miniToggle.TextSize = 16
miniToggle.TextColor3 = Color3.fromRGB(240, 240, 240)
miniToggle.AutoButtonColor = false
Instance.new("UICorner", miniToggle).CornerRadius = UDim.new(1, 0)
miniToggle.Visible = false

closeButton.MouseButton1Click:Connect(function()
    window.Visible = false
    miniToggle.Visible = true
end)
miniToggle.MouseButton1Click:Connect(function()
    window.Visible = true
    miniToggle.Visible = false
end)

-- Initial show with tween
task.defer(function()
    window.Visible = true
    TweenService:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5) -- Tween to center of the screen
    }):Play()
end)

-- ================= Helper UI functions =================
local inputRow = 0
-- ROW_HEIGHT will now be handled by UIListLayout and proportional sizes within the row

local function createInput(labelText, getDefault, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "InputRow_"..inputRow
    container.Size = UDim2.new(1, -20, 0, 40) -- Fixed height for rows (can be percentage of parent too)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = inputRow
    container.Parent = content

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(0.4, 0, 1, 0) -- 40% width of parent row
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", container)
    input.Name = "TextBox"
    input.Size = UDim2.new(0.6, -16, 1, -4) -- 60% width minus padding, fill height minus padding
    input.Position = UDim2.new(0.4, 8, 0, 2)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    input.TextColor3 = Color3.fromRGB(240, 240, 240)
    input.Text = ""
    input.PlaceholderText = tostring(getDefault())
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = input.Text
            local val = tonumber(text)
            if val then
                pcall(function() callback(val) end)
                input.PlaceholderText = tostring(val)
            end
            input.Text = ""
        end
    end)
    return input -- Return input for external updates if needed (e.g. for HP display)
end

local function createSwitch(labelText, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "SwitchRow_"..inputRow
    container.Size = UDim2.new(1, -20, 0, 40) -- Fixed height for rows
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
        pcall(function() callback(state) end)
    end)
end

local function createButton(labelText, callback)
    inputRow = inputRow + 1
    local container = Instance.new("Frame")
    container.Name = "ButtonRow_"..inputRow
    container.Size = UDim2.new(1, -20, 0, 40) -- Fixed height for rows
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    container.LayoutOrder = inputRow
    container.Parent = content

    local btn = Instance.new("TextButton", container)
    btn.Name = "Button"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = labelText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        task.delay(0.1, function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        pcall(function() callback() end)
    end)
end

-- ================= CORE LOGIC =================

--- ESP persistent with proper Sheriff vs Hero detection ---
local chamEnabled = false
local chamHighlights = {}
local initialGunGiven = {} -- track if player was given Gun at spawn (Sheriff)
local gameStartedTime = os.time() -- Track game start time for role detection delay
local gunRoundStartTime = 13 -- Time in seconds until guns/knives appear

-- NEW: Global state for dropped gun highlighting
local highlightDroppedGunEnabled = false -- This is now controlled by chamEnabled
local gunHighlightTable = {} -- Stores Highlight instances for dropped guns
local knifeHighlightTable = {} -- Stores Highlight instances for dropped/thrown knives

local heldItemHighlights = {} -- Stores highlights for currently held guns/knives

-- Determine role
local function getRole(player)
    local char = player.Character
    if char then
        -- Ưu tiên kiểm tra Murderer
        if char:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
            return "Murderer"
        end
        -- Sau đó kiểm tra Sheriff (người được cấp súng ban đầu)
        if initialGunGiven[player] then
            return "Sheriff"
        end
        -- Cuối cùng mới kiểm tra Hero (người nhặt được súng sau đó)
        if char:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun")) then
            return "Hero"
        end
    end
    return "Innocent"
end

-- Update highlight color/transparency based on role
local function updateHighlightColor(player)
    local h = chamHighlights[player]
    if not h or not h.Parent then return end
    local role = getRole(player)
    
    if role == "Murderer" then
        h.FillColor = Color3.fromRGB(200, 0, 0); h.FillTransparency = 0.4
        h.OutlineColor = Color3.fromRGB(255, 50, 50); h.OutlineTransparency = 0.2
    elseif role == "Sheriff" then
        h.FillColor = Color3.fromRGB(0, 100, 200); h.FillTransparency = 0.4
        h.OutlineColor = Color3.fromRGB(100, 150, 255); h.OutlineTransparency = 0.2
    elseif role == "Hero" then
        h.FillColor = Color3.fromRGB(255, 200, 0); h.FillTransparency = 0.4
        h.OutlineColor = Color3.fromRGB(255, 255, 100); h.OutlineTransparency = 0.2
    else -- Innocent
        h.FillColor = Color3.fromRGB(255, 255, 255); h.FillTransparency = 0.5
        h.OutlineColor = Color3.fromRGB(200, 200, 200); h.OutlineTransparency = 0.2
    end
end

-- Add Highlight for a player if not already present
local function addHighlightForPlayer(player)
    if not player.Character or not player.Character.Parent then return end
    if chamHighlights[player] and chamHighlights[player].Parent then
        updateHighlightColor(player)
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5; highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    chamHighlights[player] = highlight
    updateHighlightColor(player)
end

-- Remove highlight
local function removeHighlightForPlayer(player)
    if chamHighlights[player] then
        chamHighlights[player]:Destroy()
        chamHighlights[player] = nil
    end
    initialGunGiven[player] = nil
end

-- Add Highlight for a dropped Gun object
local function addHighlightForDroppedGun(droppedItem)
    if not (droppedItem:IsA("BasePart") or droppedItem:IsA("Model")) or droppedItem.Name ~= "GunDrop" then return end

    if gunHighlightTable[droppedItem] and gunHighlightTable[droppedItem].Parent then return end -- Already highlighted

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(0, 120, 255)
    hl.OutlineColor = Color3.fromRGB(100, 180, 255)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = droppedItem
    hl.Parent = droppedItem
    gunHighlightTable[droppedItem] = hl

    -- Send notification if it's a new highlight
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Gun Dropped!",
            Text = "Một khẩu súng đã bị rơi ở gần!",
            Duration = 4,
            Button1 = "OK"
        })
    end)
end

-- Remove Highlight for a dropped Gun object
local function removeHighlightForDroppedGun(droppedItem)
    if gunHighlightTable[droppedItem] then
        gunHighlightTable[droppedItem]:Destroy()
        gunHighlightTable[droppedItem] = nil
    end
end

-- NEW: Add Highlight for a dropped/thrown Knife object
local function addHighlightForKnife(knifeItem)
    if not (knifeItem:IsA("BasePart") or knifeItem:IsA("Model")) or (knifeItem.Name ~= "Knife" and knifeItem.Name ~= "Knife_Model") then return end

    if knifeHighlightTable[knifeItem] and knifeHighlightTable[knifeItem].Parent then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(128, 0, 128) -- Purple
    hl.OutlineColor = Color3.fromRGB(180, 50, 180)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = knifeItem
    hl.Parent = knifeItem
    knifeHighlightTable[knifeItem] = hl
end

-- NEW: Remove Highlight for a dropped/thrown Knife object
local function removeHighlightForKnife(knifeItem)
    if knifeHighlightTable[knifeItem] then
        knifeHighlightTable[knifeItem]:Destroy()
        knifeHighlightTable[knifeItem] = nil
    end
end

-- NEW: Add Highlight for held Gun/Knife
local function addHighlightForHeldItem(tool)
    if heldItemHighlights[tool] then return end

    local handle = tool:FindFirstChild("Handle")
    if not handle then return end

    local hl = Instance.new("Highlight")
    if tool.Name == "Gun" then
        hl.FillColor = Color3.fromRGB(0, 200, 0) -- Green
        hl.OutlineColor = Color3.fromRGB(50, 255, 50)
    elseif tool.Name == "Knife" then
        hl.FillColor = Color3.fromRGB(128, 0, 128) -- Purple
        hl.OutlineColor = Color3.fromRGB(180, 50, 180)
    else
        hl:Destroy()
        return
    end

    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0.2
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = handle
    hl.Parent = handle
    heldItemHighlights[tool] = hl
end

-- NEW: Remove Highlight for held Gun/Knife
local function removeHighlightForHeldItem(tool)
    if heldItemHighlights[tool] then
        heldItemHighlights[tool]:Destroy()
        heldItemHighlights[tool] = nil
    end
end


-- MODIFIED: Update all highlights based on chamEnabled state, including dropped guns and knives
local function updateAllChams()
    if chamEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Parent then
                addHighlightForPlayer(player)
            end
            -- Check for held items on all players (including local player for consistent logic)
            if player.Character then
                local heldTool = player.Character:FindFirstChildOfClass("Tool")
                if heldTool and (heldTool.Name == "Gun" or heldTool.Name == "Knife") then
                    addHighlightForHeldItem(heldTool)
                end
            end
        end
        -- Add/Update highlight for dropped guns if enabled
        for _, child in ipairs(workspace:GetChildren()) do
            if (child:IsA("BasePart") or child:IsA("Model")) and child.Name == "GunDrop" then
                addHighlightForDroppedGun(child)
            elseif (child:IsA("BasePart") or child:IsA("Model")) and (child.Name == "Knife" or child.Name == "Knife_Model") then
                addHighlightForKnife(child)
            end
        end
    else
        for player, _ in pairs(chamHighlights) do
            removeHighlightForPlayer(player)
        end
        -- Remove highlights for all dropped guns
        for droppedItem, _ in pairs(gunHighlightTable) do
            removeHighlightForDroppedGun(droppedItem)
        end
        -- Remove highlights for all dropped/thrown knives
        for knifeItem, _ in pairs(knifeHighlightTable) do
            removeHighlightForKnife(knifeItem)
        end
        -- Remove highlights for all held items
        for tool, _ in pairs(heldItemHighlights) do
            removeHighlightForHeldItem(tool)
        end
    end
end

-- Setup listeners for a given player
local function setupPlayerListeners(player)
    -- Proactively clean up highlights when character is removed (on respawn/round end)
    player.CharacterRemoving:Connect(function(char)
        removeHighlightForPlayer(player)
        -- Also remove highlights for any held items that might still be highlighted
        for tool, hl in pairs(heldItemHighlights) do
            if tool.Parent == char then
                removeHighlightForHeldItem(tool)
            end
        end
    end)

    -- CharacterAdded: reset state and detect role
    player.CharacterAdded:Connect(function(char)
        -- Reset flag for the new character
        initialGunGiven[player] = false -- Reset mỗi khi nhân vật mới xuất hiện

        -- MODIFIED: Logic kiểm tra súng Sheriff sau thời gian chờ 13 giây
        -- Đảm bảo chỉ kiểm tra sau khi game đã cấp súng/dao
        local function checkAndSetInitialGun()
            if not player.Character or player.Character ~= char then return end -- Đảm bảo vẫn là cùng char

            local hasGunNow = char:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun"))
            if hasGunNow then
                initialGunGiven[player] = true -- Đặt là true Vĩnh viễn cho round này nếu tìm thấy súng
                if chamEnabled and player ~= LocalPlayer then
                    addHighlightForPlayer(player)
                end
                return true -- Đã tìm thấy súng, ngừng kiểm tra
            end
            -- Nếu chưa có súng, không cần lặp lại kiểm tra vì logic game là cấp súng ở giây thứ 13
            -- Chỉ cần kiểm tra sau 13 giây là đủ.
            return false
        end

        -- Wait 13 seconds + a small buffer for gun to be given
        task.delay(gunRoundStartTime + 1, function() -- Wait 13s + 1s buffer
            checkAndSetInitialGun()
        end)

        -- Listen for tool changes to update role/color in real-time and highlight held items
        local backpack = player:WaitForChild("Backpack")
        char.ChildAdded:Connect(function(child)
            task.wait()
            updateHighlightColor(player)
            if chamEnabled and (child:IsA("Tool") and (child.Name == "Gun" or child.Name == "Knife")) then
                addHighlightForHeldItem(child)
            end
        end)
        char.ChildRemoved:Connect(function(child)
            task.wait()
            updateHighlightColor(player)
            if child:IsA("Tool") and (child.Name == "Gun" or child.Name == "Knife") then
                removeHighlightForHeldItem(child)
            end
        end)
        backpack.ChildAdded:Connect(function() task.wait() updateHighlightColor(player) end)
        backpack.ChildRemoved:Connect(function() task.wait() updateHighlightColor(player) end)

        local playerHumanoid = char:WaitForChild("Humanoid", 5)
        if playerHumanoid then
            playerHumanoid.Died:Connect(function()
                task.delay(0.1, function()
                    local role = getRole(player)
                    if role == "Sheriff" then
                        pcall(function()
                            StarterGui:SetCore("SendNotification", {
                                Title = "Sheriff Died!",
                                Text = player.DisplayName.." (Sheriff) đã chết!",
                                Duration = 5,
                                Button1 = "OK"
                            })
                        end)
                        -- Kiểm tra súng rơi sau khi Sheriff chết
                        task.delay(0.2, function()
                            for _, child in ipairs(workspace:GetChildren()) do
                                -- Rất quan trọng: Cần xác định chính xác tên của Part/Model súng khi nó rơi.
                                -- Dùng "GunDrop" như trong hình bạn cung cấp
                                if (child:IsA("BasePart") or child:IsA("Model")) and child.Name == "GunDrop" then
                                    if chamEnabled and not gunHighlightTable[child] then -- Only highlight if ESP is on
                                        addHighlightForDroppedGun(child)
                                    end
                                end
                            end
                        end)
                    elseif role == "Hero" then
                        pcall(function()
                            StarterGui:SetCore("SendNotification", {
                                Title = "Hero Died!",
                                Text = player.DisplayName.." (Hero) đã chết!",
                                Duration = 5,
                                Button1 = "OK"
                            })
                        end)
                    end
                end)
            end)
        end
    end)

    -- If Character already exists (script injected mid-round)
    if player.Character and player.Character.Parent then
        local char = player.Character
        initialGunGiven[player] = false

        local function checkAndSetInitialGunExistingChar()
            if not player.Character or player.Character ~= char then return end

            local hasGunNow = char:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun"))
            if hasGunNow then
                initialGunGiven[player] = true
                if chamEnabled and player ~= LocalPlayer then
                    addHighlightForPlayer(player)
                end
                return true
            end
            return false
        end
        
        -- If injected mid-round, check immediately after 13s (or if 13s already passed)
        local timeElapsed = os.time() - gameStartedTime
        if timeElapsed >= gunRoundStartTime then
            task.delay(0.5, checkAndSetInitialGunExistingChar) -- Short delay if already past time
        else
            task.delay(gunRoundStartTime - timeElapsed + 0.5, checkAndSetInitialGunExistingChar) -- Wait remaining time + buffer
        end

        -- Listen for tool changes
        local backpack = player:WaitForChild("Backpack")
        char.ChildAdded:Connect(function(child)
            task.wait()
            updateHighlightColor(player)
            if chamEnabled and (child:IsA("Tool") and (child.Name == "Gun" or child.Name == "Knife")) then
                addHighlightForHeldItem(child)
            end
        end)
        char.ChildRemoved:Connect(function(child)
            task.wait()
            updateHighlightColor(player)
            if child:IsA("Tool") and (child.Name == "Gun" or child.Name == "Knife") then
                removeHighlightForHeldItem(child)
            end
        end)
        backpack.ChildAdded:Connect(function() task.wait() updateHighlightColor(player) end)
        backpack.ChildRemoved:Connect(function() task.wait() updateHighlightColor(player) end)

        local playerHumanoid = char:FindFirstChild("Humanoid")
        if playerHumanoid then
            playerHumanoid.Died:Connect(function()
                task.delay(0.1, function()
                    local role = getRole(player)
                    if role == "Sheriff" then
                        pcall(function()
                            StarterGui:SetCore("SendNotification", {
                                Title = "Sheriff Died!",
                                Text = player.DisplayName.." (Sheriff) đã chết!",
                                Duration = 5,
                                Button1 = "OK"
                            })
                        end)
                        task.delay(0.2, function()
                            for _, child in ipairs(workspace:GetChildren()) do
                                if (child:IsA("BasePart") or child:IsA("Model")) and child.Name == "GunDrop" then
                                    if chamEnabled and not gunHighlightTable[child] then
                                        addHighlightForDroppedGun(child)
                                    end
                                end
                            end
                        end)
                    elseif role == "Hero" then
                        pcall(function()
                            StarterGui:SetCore("SendNotification", {
                                Title = "Hero Died!",
                                Text = player.DisplayName.." (Hero) đã chết!",
                                Duration = 5,
                                Button1 = "OK"
                            })
                        end)
                    end
                end)
            end)
        end
    end
end)

-- Initialize for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupPlayerListeners(player)
    end
end
-- When new player joins
Players.PlayerAdded:Connect(function(player)
    setupPlayerListeners(player)
    if chamEnabled then
        if player.Character then
            addHighlightForPlayer(player)
            local heldTool = player.Character:FindFirstChildOfClass("Tool")
            if heldTool and (heldTool.Name == "Gun" or heldTool.Name == "Knife") then
                addHighlightForHeldItem(heldTool)
            end
        else
            player.CharacterAdded:Wait()
            addHighlightForPlayer(player)
            local heldTool = player.Character:FindFirstChildOfClass("Tool")
            if heldTool and (heldTool.Name == "Gun" or heldTool.Name == "Knife") then
                addHighlightForHeldItem(heldTool)
            end
        end
    end
end)
-- When player leaves
Players.PlayerRemoving:Connect(function(player)
    removeHighlightForPlayer(player)
    for tool, hl in pairs(heldItemHighlights) do
        if tool.Parent == player.Character then -- If they leave while holding it
            removeHighlightForHeldItem(tool)
        end
    end
end)

-- Initial setup for dropped guns and knives when script runs
-- Lắng nghe ChildAdded cho BasePart/Model có tên "GunDrop" hoặc "Knife"
workspace.ChildAdded:Connect(function(child)
    if chamEnabled then -- Only highlight if ESP is on
        if (child:IsA("BasePart") or child:IsA("Model")) and child.Name == "GunDrop" then
            addHighlightForDroppedGun(child)
        elseif (child:IsA("BasePart") or child:IsA("Model")) and (child.Name == "Knife" or child.Name == "Knife_Model") then
            addHighlightForKnife(child)
        end
    end
end)

-- Phát hiện súng/dao đã có sẵn trong workspace khi script chạy (Part/Model)
for _, child in ipairs(workspace:GetChildren()) do
    if chamEnabled then -- Only highlight if ESP is on
        if (child:IsA("BasePart") or child:IsA("Model")) and child.Name == "GunDrop" then
            addHighlightForDroppedGun(child)
        elseif (child:IsA("BasePart") or child:IsA("Model")) and (child.Name == "Knife" or child.Name == "Knife_Model") then
            addHighlightForKnife(child)
        end
    end
end

-- Khi item Gun/Knife bị xóa (nhặt hoặc hủy)
workspace.ChildRemoved:Connect(function(child)
    if (child:IsA("BasePart") or child:IsA("Model")) and child.Name == "GunDrop" then
        removeHighlightForDroppedGun(child)
    elseif (child:IsA("BasePart") or child:IsA("Model")) and (child.Name == "Knife" or child.Name == "Knife_Model") then
        removeHighlightForKnife(child)
    end
end)


--- Anti Features ---
local function setupAntiFeatures()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if not Character or not Humanoid or not RootPart then return end
    local lastSafeCFrame = RootPart.CFrame

    Humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
            if RootPart and RootPart.Parent and Humanoid.FloorMaterial ~= Enum.Material.Air then
                lastSafeCFrame = RootPart.CFrame
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not RootPart or not RootPart.Parent then return end

        -- ANTI VOID
        if RootPart.Position.Y < (workspace.FallenPartsDestroyHeight or -500) then
            RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
        end

        local currentState = Humanoid:GetState()
        local isFallingOrJump = (currentState == Enum.HumanoidStateType.Freefall or currentState == Enum.HumanoidStateType.Jumping)

        -- ANTI FLING
        if RootPart.AssemblyLinearVelocity.Magnitude > 200 and not isFallingOrJump then
            RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
        end
    end)
end

--- Gun Aura (Auto Pickup) Logic ---
local gunAuraEnabled = false
local auraRadius = 30 -- Bán kính tự động nhặt súng

-- Auto Pickup Function
local function attemptAutoPickup(droppedGunPart)
    if not droppedGunPart or not droppedGunPart.Parent then return end

    -- To auto-pickup, you need to find the RemoteEvent the game uses to handle pickup.
    -- Or, if the game handles it via touch, you can try teleporting LocalPlayer.HumanoidRootPart to the gun's center.
    -- This part is highly game-dependent. Without knowing the specific game's events,
    -- this will only serve as a placeholder or a hint for manual exploitation.
    
    warn("Auto-pickup logic not fully implemented. Need to find game's specific pickup RemoteEvent or mechanic.")
    return false -- Return false if unable to pick up
end

-- Gun Aura: heartbeat kiểm tra liên tục để highlight và auto-pickup.
RunService.Heartbeat:Connect(function()
    if not (RootPart and RootPart.Parent) then
        local char = LocalPlayer.Character
        if char then RootPart = char:FindFirstChild("HumanoidRootPart") end
        if not RootPart then return end
    end

    -- Loop through currently highlighted guns (which are all "GunDrop" parts)
    for droppedItem, hl in pairs(gunHighlightTable) do
        if not (droppedItem and droppedItem.Parent and droppedItem:IsDescendantOf(workspace)) then
            removeHighlightForDroppedGun(droppedItem)
            continue
        end
        
        -- MODIFIED: Add Auto-pickup logic here
        if gunAuraEnabled then -- Check if Gun Aura (auto-pickup) is enabled
            if (RootPart.Position - droppedItem.Position).Magnitude <= auraRadius then
                -- Attempt to auto-pickup if within range
                attemptAutoPickup(droppedItem)
            end
        end
    end
end)

-- Semi-God Mode Logic
local semiGodModeEnabled = false
RunService.Heartbeat:Connect(function()
    if semiGodModeEnabled and Humanoid and Humanoid.Parent and Humanoid.Health < Humanoid.MaxHealth then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)


-- Notification on load
task.delay(1, function()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Kevinz Hub Loaded ✅",
            Text = "Version: "..HUB_VERSION,
            Duration = 5
        })
    end)
end)

-- Setup Anti Features initially
setupAntiFeatures()

-- ================= “Fix Lag + Lower CPU Load” with extended optimizations =================
local hideAccessoriesEnabled = false

local function optimizePerformance()
    pcall(function() Lighting.GlobalShadows = false end)
    pcall(function() Lighting.Brightness = 1 end)
    pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50) end)

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.CastShadow = false; v.Reflectance = 0 end)
        elseif v:IsA("PostEffect") or v:IsA("Atmosphere") then
            pcall(function() v.Enabled = false end)
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            pcall(function() v.Enabled = false end)
        elseif v:IsA("Decal") or v:IsA("Texture") then
            pcall(function() v.Transparency = 1 end)
        end
    end
    
    local ugs = UserSettings:GetService("UserGameSettings")
    if ugs.SetRenderingQualityLevel then
        pcall(function() ugs:SetRenderingQualityLevel(1) end)
    elseif ugs.SetGraphicsQualityLevel then
        pcall(function() ugs:SetGraphicsQualityLevel(1) end)
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0; terrain.WaterTransparency = 1
    end
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Optimization Applied",
            Text = "Đã áp dụng tối ưu sâu cho máy yếu.",
            Duration = 5
        })
    end)
end

-- ================= UI controls =================
inputRow = 0

-- WalkSpeed
createInput("WalkSpeed", function() return 16 end, function(v)
    savedWalkSpeed = v
    if Humanoid then Humanoid.WalkSpeed = v end
end)
-- JumpPower
createInput("JumpPower", function() return 50 end, function(v)
    savedJumpPower = v
    if Humanoid then Humanoid.JumpPower = v end
end)
-- FOV
createInput("FOV", function() return 70 end, function(v)
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = v end
end)

-- NEW: HP Display
local hpDisplayInput = nil -- Biến để lưu trữ tham chiếu đến TextBox hiển thị HP

createInput("Current HP", function() return 100 end, function(v)
    -- This function for setting HP is client-side only and will likely be reverted by the server.
    -- For actual HP modification, you would need to find a server-sided RemoteEvent/vulnerability.
    if Humanoid then
        Humanoid.Health = math.clamp(v, 0, Humanoid.MaxHealth)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "HP Adjustment Attempted",
                Text = "Đã cố gắng điều chỉnh HP thành "..v..". Lưu ý: Server có thể không chấp nhận thay đổi này.",
                Duration = 4
            })
        end)
    end
end)
-- Cập nhật HP display liên tục
RunService.Heartbeat:Connect(function()
    if hpDisplayInput and Humanoid and Humanoid.Parent then
        -- Cập nhật PlaceholderText thay vì Text để không xóa input của người dùng
        hpDisplayInput.PlaceholderText = string.format("HP: %.0f/%.0f", Humanoid.Health, Humanoid.MaxHealth)
    end
end)

-- Store the reference to the HP input after creation
local hpInputContainer = content:WaitForChild("InputRow_" .. inputRow)
if hpInputContainer then
    hpDisplayInput = hpInputContainer:FindFirstChild("TextBox")
end


-- ESP Theo Role (giờ đã bao gồm highlight dropped gun và knife)
createSwitch("ESP Theo Role", function(on)
    chamEnabled = on
    updateAllChams() -- Gọi hàm này để cập nhật tất cả highlights (người chơi, súng rơi, dao rơi, súng/dao cầm tay)
end)
-- Gun Aura (chỉ điều khiển auto-pickup)
createSwitch("Gun Aura (Auto Pickup)", function(on)
    gunAuraEnabled = on
end)
-- Gun Aura Radius
createInput("Gun Aura Radius", function() return auraRadius end, function(v)
    auraRadius = v
end)
-- Hide Accessories
createSwitch("Hide Accessories", function(on)
    hideAccessoriesEnabled = on
    -- This part is illustrative. A full implementation would need to handle new players and respawns.
    if on and LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Accessory") then
                local handle = item:FindFirstChild("Handle")
                if handle then handle.Transparency = 1 end
            end
        end
    end
end)

-- NEW: Semi-God Mode
createSwitch("Semi-God Mode", function(on)
    semiGodModeEnabled = on
    if on then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Semi-God Mode ON",
                Text = "HP của bạn sẽ liên tục được hồi đầy.",
                Duration = 3
            })
        end)
    else
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Semi-God Mode OFF",
                Text = "HP của bạn sẽ hoạt động bình thường.",
                Duration = 3
            })
        end)
    end
end)

-- Button Fix Lag + Lower CPU Load
createButton("Fix Lag + Lower CPU Load", optimizePerformance)

-- CharacterAdded reapply settings
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    
    setupAntiFeatures()

    task.wait(0.2)
    if Humanoid then
        Humanoid.WalkSpeed = savedWalkSpeed
        Humanoid.JumpPower = savedJumpPower
    end

    if chamEnabled then
        task.delay(0.6, updateAllChams) -- Delay slightly more to ensure roles are set and highlights applied
    end
end)
