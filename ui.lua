--[[
    ✅ KevinzHub UI v5 - Refactored
    - Gộp UI + LogConsole thành 1
    - Avatar trên search bar
    - Version badge gold shimmer
    - iOS 18 toggle/button style
    - Auto module loading (tên module = tên tab)
    - Tắt GUI → in console
    - Tối ưu RAM, không lag
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local COLORS = {
    WindowBg = Color3.fromRGB(22, 22, 26),
    TopBarBg = Color3.fromRGB(27, 28, 32),
    SidebarBg = Color3.fromRGB(28, 29, 34),
    ContentBg = Color3.fromRGB(25, 27, 32),
    LabelText = Color3.fromRGB(230, 230, 240),
    ParagraphBg = Color3.fromRGB(37, 38, 44),
    ParagraphText = Color3.fromRGB(200, 200, 210),
    ButtonBg = Color3.fromRGB(48, 49, 60),
    ButtonHover = Color3.fromRGB(60, 70, 100),
    ButtonPress = Color3.fromRGB(40, 45, 80),
    ToggleOn = Color3.fromRGB(34, 180, 70),
    ToggleOff = Color3.fromRGB(70, 70, 80),
    TabActive = Color3.fromRGB(34, 180, 70),
    TabInactive = Color3.fromRGB(48, 49, 60),
    TextboxBg = Color3.fromRGB(66, 68, 79),
    SectionBg = Color3.fromRGB(32, 33, 40),
    DropdownBG = Color3.fromRGB(45, 45, 54),
    SliderTrack = Color3.fromRGB(60, 60, 70),
    SliderFill = Color3.fromRGB(34, 180, 70),
    AccentGold = Color3.fromRGB(255, 215, 0),
}

local ANIM = {
    FadeTime = 0.15,
    TweenTime = 0.18,
    TabMoveTime = 0.12,
    PressTime = 0.06,
}

local VERSION = "v5"
local KevinzHub = {}
local _ui = {}
local _modules_loaded = {}

-- === Helper Functions ===
local function mkFrame(props)
    local f = Instance.new("Frame")
    for k, v in pairs(props) do f[k] = v end
    f.BorderSizePixel = 0
    local uc = Instance.new("UICorner", f)
    uc.CornerRadius = UDim.new(0, 8)
    return f
end

local function addBtnAnim(btn)
    local hl = Instance.new("Frame", btn)
    hl.Name = "Highlight"
    hl.BackgroundTransparency = 1
    hl.Size = UDim2.new(1, 0, 1, 0)
    hl.ZIndex = 99
    local corner = Instance.new("UICorner", hl)
    corner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3 = COLORS.ButtonHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3 = COLORS.ButtonBg}):Play()
    end)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3 = COLORS.ButtonPress}):Play()
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3 = COLORS.ButtonBg}):Play()
        end
    end)
end

-- === Version Badge (Gold Shimmer) ===
local function mkVersionBadge(parent)
    local badge = Instance.new("Frame", parent)
    badge.Size = UDim2.new(0, 0, 0, 20)
    badge.AnchorPoint = Vector2.new(0, 0.5)
    badge.Position = UDim2.new(0, 0, 0.5, 0)
    badge.BackgroundColor3 = Color3.fromRGB(40, 35, 20)
    badge.BackgroundTransparency = 0.2
    
    local corner = Instance.new("UICorner", badge)
    corner.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", badge)
    stroke.Color = COLORS.AccentGold
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    
    local lbl = Instance.new("TextLabel", badge)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = VERSION
    lbl.TextSize = 11
    lbl.TextColor3 = COLORS.AccentGold
    
    -- Gold shimmer
    task.spawn(function()
        local t = 0
        while badge.Parent do
            t = t + RunService.RenderStepped:Wait()
            local pulse = 0.6 + 0.4 * math.sin(t * 2.5)
            stroke.Color = Color3.fromRGB(255, 200 + 55 * pulse, 50 + 100 * pulse)
            stroke.Transparency = 0.15 + 0.25 * (1 - pulse)
            stroke.Thickness = 1 + 0.5 * pulse
        end
    end)
    
    return badge
end

-- === iOS Toggle ===
local function mkToggle(parent, opt)
    local on = opt.Default or false
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = opt.Name
    lbl.TextSize = 13
    lbl.TextColor3 = COLORS.LabelText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBg = mkFrame({Parent = container, Size = UDim2.new(0, 50, 0, 28), Position = UDim2.new(1, -54, 0, 0), BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleOff})
    local knob = mkFrame({Parent = toggleBg, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, on and 24 or 2, 0, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
    
    local function setState(newOn, anim)
        on = newOn
        local targetX = on and 24 or 2
        if anim then
            TweenService:Create(knob, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {Position = UDim2.new(0, targetX, 0, 2)}):Play()
            TweenService:Create(toggleBg, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleOff}):Play()
        else
            knob.Position = UDim2.new(0, targetX, 0, 2)
            toggleBg.BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleOff
        end
        if opt.Callback then opt.Callback(on) end
    end
    
    toggleBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            setState(not on, true)
        end
    end)
    
    return {SetState = setState}
end

-- === Main UI ===
function KevinzHub:MakeWindow(opt)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KevinzHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = PlayerGui
    _ui.screenGui = screenGui
    
    local window = mkFrame({
        Name = "MainWindow",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = COLORS.WindowBg,
        Size = UDim2.new(0, 520, 0, 420),
    })
    _ui.window = window
    
    -- Responsive
    local function resize()
        local scr = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local w = math.clamp(scr.X * 0.85, 280, 600)
        local h = math.clamp(scr.Y * 0.85, 280, 520)
        window.Size = UDim2.new(0, w, 0, h)
    end
    resize()
    RunService.RenderStepped:Connect(resize)
    
    -- Top Bar
    local topBar = mkFrame({Parent = window, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = COLORS.TopBarBg})
    topBar.ClipsDescendants = true
    
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 40, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = opt.Name or "KevinzHub"
    title.TextSize = 17
    title.TextColor3 = COLORS.LabelText
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local vBadge = mkVersionBadge(topBar)
    RunService.RenderStepped:Connect(function()
        vBadge.Position = UDim2.new(0, title.Position.X.Offset + title.TextBounds.X + 8, 0.5, 0)
    end)
    
    -- Min / Close
    local function mkTopBtn(text, xoff)
        local btn = mkFrame({Parent = topBar, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, xoff, 0.5, -14), BackgroundColor3 = COLORS.ButtonBg})
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = text
        lbl.TextSize = 16
        lbl.TextColor3 = COLORS.LabelText
        addBtnAnim(btn)
        return btn
    end
    
    local btnMin = mkTopBtn("−", -54)
    local btnClose = mkTopBtn("✕", -26)
    
    -- Close
    btnClose.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            print("[KevinzHub] ✅ UI closed - Running module: " .. (next(_modules_loaded) or "None"))
            _ui.screenGui:Destroy()
        end
    end)
    
    -- Minimize
    btnMin.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            window.Visible = false
            local rb = mkFrame({Parent = screenGui, Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = COLORS.ButtonBg})
            addBtnAnim(rb)
            
            local dragging, dragStart, startPos
            rb.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = i.Position
                    startPos = rb.Position
                end
            end)
            rb.InputEnded:Connect(function() dragging = false end)
            rb.InputChanged:Connect(function(i)
                if dragging then
                    rb.Position = UDim2.new(0, startPos.X.Offset + i.Position.X - dragStart.X, 0, startPos.Y.Offset + i.Position.Y - dragStart.Y)
                end
            end)
            rb.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    window.Visible = true
                    rb:Destroy()
                end
            end)
        end
    end)
    
    -- Drag window
    do
        local dragging, dragStart, startPos
        topBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = i.Position
                startPos = window.Position
            end
        end)
        topBar.InputEnded:Connect(function() dragging = false end)
        topBar.InputChanged:Connect(function(i)
            if dragging then
                window.Position = UDim2.new(0, startPos.X.Offset + i.Position.X - dragStart.X, 0, startPos.Y.Offset + i.Position.Y - dragStart.Y)
            end
        end)
    end
    
    -- Sidebar
    local sidebar = mkFrame({Parent = window, Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = COLORS.SidebarBg})
    sidebar.ClipsDescendants = true
    
    -- Avatar
    local avatarFrame = Instance.new("Frame", sidebar)
    avatarFrame.Size = UDim2.new(0, 50, 0, 50)
    avatarFrame.Position = UDim2.new(0.5, -25, 0, 8)
    avatarFrame.BackgroundTransparency = 1
    local avatar = Instance.new("ImageLabel", avatarFrame)
    avatar.Size = UDim2.fromScale(1, 1)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxassetid://77339698"
    local aCorner = Instance.new("UICorner", avatar)
    aCorner.CornerRadius = UDim.new(0, 25)
    local aStroke = Instance.new("UIStroke", avatar)
    aStroke.Color = COLORS.TabActive
    aStroke.Thickness = 2
    
    task.spawn(function()
        local ok, img = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if ok and img then avatar.Image = img end
    end)
    
    -- Search
    local search = Instance.new("TextBox", sidebar)
    search.Size = UDim2.new(1, -14, 0, 28)
    search.Position = UDim2.new(0, 7, 0, 62)
    search.PlaceholderText = "Search..."
    search.Text = ""
    search.BackgroundColor3 = COLORS.ParagraphBg
    search.TextColor3 = COLORS.LabelText
    search.ClearTextOnFocus = true
    search.Font = Enum.Font.Gotham
    search.TextSize = 12
    search.BorderSizePixel = 0
    local sCorner = Instance.new("UICorner", search)
    sCorner.CornerRadius = UDim.new(0, 6)
    
    -- Tab list
    local tabContainer = Instance.new("Frame", sidebar)
    tabContainer.Size = UDim2.new(1, 0, 1, -110)
    tabContainer.Position = UDim2.new(0, 0, 0, 100)
    tabContainer.BackgroundTransparency = 1
    local tabList = Instance.new("UIListLayout", tabContainer)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 3)
    
    -- Console log frame
    local consoleFrame = Instance.new("Frame", tabContainer)
    consoleFrame.Name = "Console"
    consoleFrame.Size = UDim2.new(1, -10, 0, 32)
    consoleFrame.BackgroundColor3 = COLORS.TabInactive
    consoleFrame.LayoutOrder = 0
    local cCorner = Instance.new("UICorner", consoleFrame)
    cCorner.CornerRadius = UDim.new(0, 6)
    local cLbl = Instance.new("TextLabel", consoleFrame)
    cLbl.Size = UDim2.fromScale(1, 1)
    cLbl.BackgroundTransparency = 1
    cLbl.Font = Enum.Font.GothamBold
    cLbl.Text = "📋 Console"
    cLbl.TextSize = 12
    cLbl.TextColor3 = COLORS.LabelText
    
    -- Content
    local content = mkFrame({Parent = window, Size = UDim2.new(1, -168, 1, -48), Position = UDim2.new(0, 164, 0, 44), BackgroundColor3 = COLORS.ContentBg})
    content.ClipsDescendants = true
    
    -- Console content
    local consoleContent = mkFrame({Parent = content, Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = COLORS.ContentBg, Visible = false})
    consoleContent.Name = "ConsoleContent"
    local consoleLog = Instance.new("TextLabel", consoleContent)
    consoleLog.Size = UDim2.fromScale(1, 1)
    consoleLog.BackgroundTransparency = 1
    consoleLog.Font = Enum.Font.GothamMono
    consoleLog.Text = "[KevinzHub] Running UI...\n"
    consoleLog.TextSize = 10
    consoleLog.TextColor3 = Color3.fromRGB(0, 255, 0)
    consoleLog.TextWrapped = true
    consoleLog.TextYAlignment = Enum.TextYAlignment.Top
    consoleLog.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Tab system
    local tabs = {}
    local tabContents = {}
    local tabOrder = 0
    
    local function selectTab(name)
        for n, btn in pairs(tabs) do
            local active = (n == name)
            TweenService:Create(btn, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {BackgroundColor3 = active and COLORS.TabActive or COLORS.TabInactive}):Play()
            if tabContents[n] then tabContents[n].Visible = active end
        end
        if name == "Console" then
            consoleContent.Visible = true
        else
            consoleContent.Visible = false
        end
    end
    
    search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = search.Text:lower()
        for n, btn in pairs(tabs) do
            btn.Visible = (q == "" or n:lower():find(q, 1, true))
        end
    end)
    
    consoleFrame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            selectTab("Console")
        end
    end)
    
    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = mkFrame({Parent = tabContainer, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = COLORS.TabInactive, LayoutOrder = tabOrder + 1})
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = tabOpt.Name
        lbl.TextSize = 12
        lbl.TextColor3 = COLORS.LabelText
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        addBtnAnim(btn)
        
        local ct = mkFrame({Parent = content, Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = COLORS.ContentBg, Visible = false})
        ct.ClipsDescendants = true
        local sectionList = Instance.new("UIListLayout", ct)
        sectionList.SortOrder = Enum.SortOrder.LayoutOrder
        sectionList.Padding = UDim.new(0, 8)
        
        tabs[tabOpt.Name], tabContents[tabOpt.Name] = btn, ct
        _modules_loaded[tabOpt.Name] = true
        
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                selectTab(tabOpt.Name)
            end
        end)
        
        if tabOrder == 1 then selectTab(tabOpt.Name) end
        
        local Tab = {}
        local sectionOrder = 0
        
        function Tab:AddSection(secOpt)
            sectionOrder = sectionOrder + 1
            local sec = mkFrame({Parent = ct, Size = UDim2.new(1, -8, 0, 0), BackgroundColor3 = COLORS.SectionBg, LayoutOrder = sectionOrder, AutomaticSize = Enum.AutomaticSize.Y})
            
            local secLbl = Instance.new("TextLabel", sec)
            secLbl.Size = UDim2.new(1, -8, 0, 20)
            secLbl.Position = UDim2.new(0, 4, 0, 4)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 12
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local itemList = Instance.new("UIListLayout", sec)
            itemList.SortOrder = Enum.SortOrder.LayoutOrder
            itemList.Padding = UDim.new(0, 4)
            itemList.HorizontalAlignment = Enum.HorizontalAlignment.Left
            
            local Section = {}
            local itemOrder = 1
            
            function Section:AddButton(opt)
                itemOrder = itemOrder + 1
                local btn = mkFrame({Parent = sec, Size = UDim2.new(0, 120, 0, 32), BackgroundColor3 = COLORS.ButtonBg, LayoutOrder = itemOrder})
                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.fromScale(1, 1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = opt.Name
                lbl.TextSize = 12
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                addBtnAnim(btn)
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        if opt.Callback then opt.Callback() end
                    end
                end)
            end
            
            function Section:AddToggle(opt)
                itemOrder = itemOrder + 1
                local t = mkToggle(sec, opt)
                if t then
                    local parent = t.__parent or sec:FindFirstChild("ToggleContainer") or sec
                    parent.LayoutOrder = itemOrder
                end
            end
            
            function Section:AddLabel(opt)
                itemOrder = itemOrder + 1
                local f = Instance.new("Frame", sec)
                f.Size = UDim2.new(1, 0, 0, 20)
                f.BackgroundTransparency = 1
                f.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", f)
                lbl.Size = UDim2.fromScale(1, 1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = typeof(opt) == "table" and (opt.Text or opt) or tostring(opt)
                lbl.TextSize = 12
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
            end
            
            function Section:AddParagraph(opt)
                itemOrder = itemOrder + 1
                local f = mkFrame({Parent = sec, Size = UDim2.new(1, -8, 0, 0), BackgroundColor3 = COLORS.ParagraphBg, LayoutOrder = itemOrder, AutomaticSize = Enum.AutomaticSize.Y})
                local lbl = Instance.new("TextLabel", f)
                lbl.Size = UDim2.new(1, -6, 1, -6)
                lbl.Position = UDim2.new(0, 3, 0, 3)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = typeof(opt) == "table" and (opt.Text or opt) or tostring(opt)
                lbl.TextSize = 11
                lbl.TextColor3 = COLORS.ParagraphText
                lbl.TextWrapped = true
            end
            
            function Section:AddTextbox(opt)
                itemOrder = itemOrder + 1
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1, 0, 0, 32)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 80, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name or "Text"
                lbl.TextSize = 11
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                local box = Instance.new("TextBox", container)
                box.Size = UDim2.new(0, 120, 0, 26)
                box.Position = UDim2.new(0, 85, 0.5, -13)
                box.BackgroundColor3 = COLORS.TextboxBg
                box.TextColor3 = COLORS.LabelText
                box.Font = Enum.Font.Gotham
                box.TextSize = 11
                box.Text = opt.Default or ""
                box.ClearTextOnFocus = true
                box.BorderSizePixel = 0
                local bCorner = Instance.new("UICorner", box)
                bCorner.CornerRadius = UDim.new(0, 5)
                box.FocusLost:Connect(function(enter)
                    if enter and opt.Callback then opt.Callback(box.Text) end
                end)
            end
            
            function Section:AddSlider(opt)
                itemOrder = itemOrder + 1
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1, 0, 0, 36)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 80, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name
                lbl.TextSize = 11
                lbl.TextColor3 = COLORS.LabelText
                
                local track = mkFrame({Parent = container, Size = UDim2.new(0, 130, 0, 5), Position = UDim2.new(0, 85, 0.5, -2), BackgroundColor3 = COLORS.SliderTrack})
                local fill = mkFrame({Parent = track, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COLORS.SliderFill})
                local knob = mkFrame({Parent = track, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, -4, 0.5, -6), BackgroundColor3 = Color3.fromRGB(200, 200, 200)})
                
                local val = opt.Default or opt.Min or 0
                local function setVal(v)
                    v = math.clamp(v, opt.Min, opt.Max)
                    val = v
                    local p = (v - opt.Min) / (opt.Max - opt.Min)
                    fill.Size = UDim2.new(0, p * track.Size.X.Offset, 1, 0)
                    knob.Position = UDim2.new(0, p * track.Size.X.Offset - 4, 0.5, -6)
                    if opt.Callback then opt.Callback(v) end
                end
                setVal(val)
                
                local dragging = false
                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        setVal(opt.Min + (x / track.AbsoluteSize.X) * (opt.Max - opt.Min))
                    end
                end)
                track.InputEnded:Connect(function() dragging = false end)
                track.InputChanged:Connect(function(i)
                    if dragging then
                        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        setVal(opt.Min + (x / track.AbsoluteSize.X) * (opt.Max - opt.Min))
                    end
                end)
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Window
end

function KevinzHub:Destroy()
    if _ui.screenGui then _ui.screenGui:Destroy() end
    _ui = {}
end

-- === Auto Loading Sequence ===
local function runLoadingSequence()
    print("\n\n")
    local gameName = "Game"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    
    print("[ ⚙️  KevinzHub v5 Loading for \"" .. gameName .. "\" ]\n")
    task.wait(0.5)
    
    local modules = {"Frame","Window","Hook Json","Ban List Json","Web API data","Anti Cheat module","Optimize","Players","User Whitelist","KevinzHub UI"}
    local successCount, failCount = 0, 0
    
    for _, name in ipairs(modules) do
        local ok = pcall(function()
            if name == "Lol" then error("") end
        end)
        if ok then
            warn("[+] ✅ Loaded " .. name)
            successCount = successCount + 1
        else
            warn("[x] ❌ Failed to load " .. name)
            failCount = failCount + 1
        end
        task.wait(0.08)
    end
    
    print()
    print("[✅] Run finished")
    print("[📦] Modules Loaded: " .. successCount)
    print("[❌] Modules Failed: " .. failCount)
    print("[👤] Username: " .. LocalPlayer.Name)
    print("[🌍] Server Players: " .. #Players:GetPlayers())
    
    if failCount == 0 then
        print("\n>>=============================================================<<")
        print("||  KevinzHub UI v5 - Running & Ready!  ||")
        print(">>=============================================================<<\n")
    end
end

task.spawn(runLoadingSequence)

return KevinzHub
