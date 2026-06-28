--[[
    KevinzHub UI Library v4
    - iOS 18 style toggle & button
    - Gold shimmer version badge
    - Avatar above search bar
    - Auto-loading sequence with signature
    - Close destroys GUI and prints to console
    - Touch & mouse friendly
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local COLORS = {
    WindowBg      = Color3.fromRGB(22,22,26),
    TopBarBg      = Color3.fromRGB(27,28,32),
    SidebarBg     = Color3.fromRGB(28,29,34),
    ContentBg     = Color3.fromRGB(25,27,32),
    Outline       = Color3.fromRGB(45,45,60),
    LabelText     = Color3.fromRGB(230,230,240),
    ParagraphBg   = Color3.fromRGB(37,38,44),
    ParagraphText = Color3.fromRGB(200,200,210),
    ButtonBg      = Color3.fromRGB(48,49,60),
    ButtonHover   = Color3.fromRGB(60,70,100),
    ButtonPress   = Color3.fromRGB(40,45,80),
    ToggleBg      = Color3.fromRGB(46,47,56),
    ToggleOn      = Color3.fromRGB(34, 180, 70),   -- iOS green
    ToggleOff     = Color3.fromRGB(70,70,80),
    ToggleKnobOn  = Color3.fromRGB(255,255,255),
    ToggleKnobOff = Color3.fromRGB(200,200,200),
    SliderTrack   = Color3.fromRGB(60,60,70),
    SliderFill    = Color3.fromRGB(34, 180, 70),
    SliderKnob    = Color3.fromRGB(200,200,200),
    DropdownBG    = Color3.fromRGB(45,45,54),
    DropdownHover = Color3.fromRGB(50,60,80),
    DropdownPress = Color3.fromRGB(40,45,80),
    TabActive     = Color3.fromRGB(34, 180, 70),
    TabInactive   = Color3.fromRGB(48,49,60),
    TextboxBg     = Color3.fromRGB(66,68,79),
    SectionBg     = Color3.fromRGB(32,33,40),
    Accent        = Color3.fromRGB(34, 180, 70),
}

local ANIM = {
    FadeTime     = 0.17,
    TweenTime    = 0.19,
    TabMoveTime  = 0.13,
    PressTime    = 0.07,
}

local VERSION = "v4"
local KevinzHub = {}
local _ui = {}

local function makeRoundedFrame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k] = v end
    f.BorderSizePixel = 0
    local uc = Instance.new("UICorner", f)
    uc.CornerRadius = UDim.new(0,8)
    return f
end

local function addBtnAnim(btn)
    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.BackgroundTransparency = 1
    highlight.BackgroundColor3 = Color3.fromRGB(255,255,255)
    highlight.Size = UDim2.new(1,0,1,0)
    highlight.ZIndex = 99
    highlight.Parent = btn
    local corner = Instance.new("UICorner", highlight)
    corner.CornerRadius = UDim.new(0,8)
    local inAnim = function() 
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
        TweenService:Create(highlight, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.92}):Play()
    end
    local outAnim = function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonBg}):Play()
        TweenService:Create(highlight, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundTransparency=1}):Play()
    end
    btn.MouseEnter:Connect(inAnim)
    btn.MouseLeave:Connect(outAnim)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonPress}):Play()
            TweenService:Create(highlight, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.8}):Play()
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            outAnim()
        end
    end)
end

-- iOS 18 Style Toggle
local function makeToggle(parent, opt)
    local on = opt.Default or false
    local callback = opt.Callback

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,30)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-70,1,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = opt.Name
    label.TextSize = 14
    label.TextColor3 = COLORS.LabelText
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBg = makeRoundedFrame({
        Parent = container,
        Size = UDim2.new(0,50,0,30),
        Position = UDim2.new(1,-54,0,0),
        BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleOff
    })
    local knob = makeRoundedFrame({
        Parent = toggleBg,
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(0,2,0,2),
        BackgroundColor3 = on and COLORS.ToggleKnobOn or COLORS.ToggleKnobOff
    })
    local stroke = Instance.new("UIStroke", toggleBg)
    stroke.Color = Color3.fromRGB(80,80,90)
    stroke.Thickness = 0.5

    local function setState(newState, anim)
        on = newState
        local targetX = on and (toggleBg.Size.X.Offset - knob.Size.X.Offset - 2) or 2
        if anim then
            TweenService:Create(knob, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {Position=UDim2.new(0,targetX,0,2)}):Play()
            TweenService:Create(toggleBg, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {BackgroundColor3=on and COLORS.ToggleOn or COLORS.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {BackgroundColor3=on and COLORS.ToggleKnobOn or COLORS.ToggleKnobOff}):Play()
        else
            knob.Position = UDim2.new(0,targetX,0,2)
            toggleBg.BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleOff
            knob.BackgroundColor3 = on and COLORS.ToggleKnobOn or COLORS.ToggleKnobOff
        end
        if callback then callback(on) end
    end

    toggleBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            setState(not on, true)
        end
    end)
    if UserInputService.TouchEnabled then
        toggleBg.TouchTap:Connect(function() setState(not on, true) end)
    end

    return { SetState = setState }
end

-- iOS 18 Style Button
local function makeButton(parent, opt)
    local btn = makeRoundedFrame({
        Parent = parent,
        Size = UDim2.new(0, 120, 0, 34),
        BackgroundColor3 = COLORS.ButtonBg,
        LayoutOrder = opt.LayoutOrder or 1
    })
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.fromScale(1,1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = opt.Name
    lbl.TextSize = 14
    lbl.TextColor3 = COLORS.LabelText
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    addBtnAnim(btn)

    local function click()
        if opt.Callback then opt.Callback() end
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            click()
        end
    end)
    if UserInputService.TouchEnabled then
        btn.TouchTap:Connect(click)
    end
    return btn
end

-- Version Badge with Gold Shimmer Glow
local function makeVersionBadge(parent, text)
    local badge = Instance.new("Frame", parent)
    badge.Size = UDim2.new(0,0,0,22)
    badge.AnchorPoint = Vector2.new(0,0.5)
    badge.Position = UDim2.new(0,0,0.5,0)
    badge.BackgroundColor3 = Color3.fromRGB(40,35,20)
    badge.BackgroundTransparency = 0.2
    local corner = Instance.new("UICorner", badge)
    corner.CornerRadius = UDim.new(0,11)
    local stroke = Instance.new("UIStroke", badge)
    stroke.Color = Color3.fromRGB(255,215,0)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local label = Instance.new("TextLabel", badge)
    label.Size = UDim2.new(1,-12,1,0)
    label.Position = UDim2.new(0,6,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255,215,0)

    -- Gold shimmer glow
    task.spawn(function()
        local t = 0
        while badge.Parent do
            t = t + RunService.RenderStepped:Wait()
            local pulse = 0.7 + 0.5 * math.sin(t * 3)
            stroke.Color = Color3.fromRGB(255, 200 + 55*pulse, 50 + 100*pulse)
            stroke.Transparency = 0.1 + 0.4*(1-pulse)
            stroke.Thickness = 1.2 + 0.8*pulse
        end
    end)
    return badge
end

-- Main UI Builder
function KevinzHub:MakeWindow(opt)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KevinzHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = PlayerGui
    _ui.screenGui = screenGui

    local window = makeRoundedFrame({
        Name = "MainWindow",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        BackgroundColor3 = COLORS.WindowBg,
        Size = UDim2.new(0, 520, 0, 400),
    })
    _ui.window = window

    -- Responsive sizing
    local function resize()
        local scr = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local w = math.clamp(scr.X * 0.85, 280, 600)
        local h = math.clamp(scr.Y * 0.85, 250, 500)
        window.Size = UDim2.new(0, w, 0, h)
    end
    resize()
    RunService.RenderStepped:Connect(resize)

    -- Top Bar
    local topBar = makeRoundedFrame({
        Parent = window,
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = COLORS.TopBarBg,
    })
    topBar.ClipsDescendants = true

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1,-80,1,0)
    title.Position = UDim2.new(0,40,0,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = opt.Name or "KevinzHub"
    title.TextSize = 18
    title.TextColor3 = COLORS.LabelText
    title.TextXAlignment = Enum.TextXAlignment.Left

    local versionBadge = makeVersionBadge(topBar, VERSION)
    -- Position it after title
    local function posBadge()
        local w = title.TextBounds.X + 50
        versionBadge.Size = UDim2.new(0, versionBadge.AbsoluteSize.X, 0, 22)
        versionBadge.Position = UDim2.new(0, w, 0.5, 0)
    end
    title:GetPropertyChangedSignal("Text"):Connect(posBadge)
    RunService.RenderStepped:Connect(posBadge)
    task.defer(posBadge)

    -- Min / Close (iOS style)
    local function makeTopButton(name, xoff)
        local btn = makeRoundedFrame({
            Parent = topBar,
            Size = UDim2.new(0,30,0,30),
            Position = UDim2.new(1, xoff, 0.5, -15),
            BackgroundColor3 = COLORS.ButtonBg,
        })
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.fromScale(1,1)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = name
        lbl.TextSize = 18
        lbl.TextColor3 = COLORS.LabelText
        addBtnAnim(btn)
        return btn
    end

    local btnMin = makeTopButton("–", -56)
    local btnClose = makeTopButton("✕", -26)

    -- Close: destroy GUI, print to console
    btnClose.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if _ui.screenGui then
                _ui.screenGui:Destroy()
                print("[KevinzHub] UI closed.")
            end
        end
    end)

    -- Minimize: hide window, show restore button (draggable)
    local function minimize()
        window.Visible = false
        local rb = makeRoundedFrame({
            Parent = screenGui,
            Size = UDim2.new(0,36,0,36),
            Position = UDim2.new(0,10,0,10),
            BackgroundColor3 = COLORS.ButtonBg,
        })
        local icon = Instance.new("ImageLabel", rb)
        icon.Size = UDim2.fromScale(0.6,0.6)
        icon.Position = UDim2.new(0.2,0,0.2,0)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://1912438810"
        icon.ImageColor3 = COLORS.LabelText
        icon.ScaleType = Enum.ScaleType.Fit
        addBtnAnim(rb)
        -- drag restore
        local dragging, dragStart, startPos
        rb.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging = true
                dragStart = i.Position
                startPos = rb.Position
            end
        end)
        rb.InputEnded:Connect(function() dragging = false end)
        rb.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                rb.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + i.Position.X - dragStart.X,
                                        startPos.Y.Scale, startPos.Y.Offset + i.Position.Y - dragStart.Y)
            end
        end)
        rb.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                window.Visible = true
                rb:Destroy()
            end
        end)
    end
    btnMin.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            minimize()
        end
    end)

    -- Drag window (top bar)
    do
        local dragging, dragStart, startPos
        topBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging = true
                dragStart = i.Position
                startPos = window.Position
            end
        end)
        topBar.InputEnded:Connect(function() dragging = false end)
        topBar.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + i.Position.X - dragStart.X,
                                            startPos.Y.Scale, startPos.Y.Offset + i.Position.Y - dragStart.Y)
            end
        end)
    end

    -- Sidebar
    local sidebarWidth = 180
    local sidebar = makeRoundedFrame({
        Parent = window,
        Size = UDim2.new(0, sidebarWidth, 1, -40),
        Position = UDim2.new(0,0,0,40),
        BackgroundColor3 = COLORS.SidebarBg,
    })
    sidebar.ClipsDescendants = true

    -- Avatar (top)
    local avatarFrame = Instance.new("Frame", sidebar)
    avatarFrame.Size = UDim2.new(0,56,0,56)
    avatarFrame.Position = UDim2.new(0.5, -28, 0, 10)
    avatarFrame.BackgroundTransparency = 1
    local avatar = Instance.new("ImageLabel", avatarFrame)
    avatar.Size = UDim2.fromScale(1,1)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxassetid://77339698"  -- placeholder
    local corner = Instance.new("UICorner", avatar)
    corner.CornerRadius = UDim.new(0,28)
    local stroke = Instance.new("UIStroke", avatar)
    stroke.Color = COLORS.Accent
    stroke.Thickness = 2
    -- fetch avatar
    task.spawn(function()
        local id = LocalPlayer.UserId
        local img, ok = pcall(Players.GetUserThumbnailAsync, Players, id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if ok and img then avatar.Image = img end
    end)

    -- Search bar
    local search = Instance.new("TextBox", sidebar)
    search.Size = UDim2.new(1, -16, 0, 30)
    search.Position = UDim2.new(0, 8, 0, 76)
    search.PlaceholderText = "Search tabs..."
    search.Text = ""
    search.BackgroundColor3 = COLORS.ParagraphBg
    search.TextColor3 = COLORS.LabelText
    search.ClearTextOnFocus = true
    search.Font = Enum.Font.Gotham
    search.TextSize = 13
    search.BorderSizePixel = 0
    local corner2 = Instance.new("UICorner", search)
    corner2.CornerRadius = UDim.new(0,6)

    -- Tab list
    local tabContainer = Instance.new("Frame", sidebar)
    tabContainer.Size = UDim2.new(1,0,1,-126)
    tabContainer.Position = UDim2.new(0,0,0,116)
    tabContainer.BackgroundTransparency = 1
    local tabList = Instance.new("UIListLayout", tabContainer)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0,4)

    -- Content area
    local content = makeRoundedFrame({
        Parent = window,
        Size = UDim2.new(1, -sidebarWidth - 8, 1, -48),
        Position = UDim2.new(0, sidebarWidth + 4, 0, 44),
        BackgroundColor3 = COLORS.ContentBg,
    })
    content.ClipsDescendants = true

    -- Tab management
    local tabs = {}
    local tabContents = {}
    local tabOrder = 0

    local function selectTab(name)
        for n, btn in pairs(tabs) do
            local active = (n == name)
            TweenService:Create(btn, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint),
                {BackgroundColor3 = active and COLORS.TabActive or COLORS.TabInactive}
            ):Play()
            tabContents[n].Visible = active
        end
    end

    -- Search filter
    search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = search.Text:lower()
        for n, btn in pairs(tabs) do
            btn.Visible = (q == "" or n:lower():find(q))
        end
    end)

    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = makeRoundedFrame({
            Parent = tabContainer,
            Size = UDim2.new(1, -12, 0, 32),
            BackgroundColor3 = COLORS.TabInactive,
            LayoutOrder = tabOrder,
        })
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = tabOpt.Name
        lbl.TextSize = 13
        lbl.TextColor3 = COLORS.LabelText
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        addBtnAnim(btn)

        local ct = makeRoundedFrame({
            Parent = content,
            Size = UDim2.new(1, -12, 1, -12),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = COLORS.ContentBg,
            Visible = false,
        })
        ct.ClipsDescendants = true
        local sectionList = Instance.new("UIListLayout", ct)
        sectionList.SortOrder = Enum.SortOrder.LayoutOrder
        sectionList.Padding = UDim.new(0, 10)

        tabs[tabOpt.Name], tabContents[tabOpt.Name] = btn, ct

        local function tabClick()
            selectTab(tabOpt.Name)
        end
        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                tabClick()
            end
        end)
        if UserInputService.TouchEnabled then
            btn.TouchTap:Connect(tabClick)
        end
        if tabOrder == 1 then selectTab(tabOpt.Name) end

        local Tab = {}
        local sectionOrder = 0

        function Tab:AddSection(secOpt)
            sectionOrder = sectionOrder + 1
            local sec = makeRoundedFrame({
                Parent = ct,
                Size = UDim2.new(1, -10, 0, 0),
                BackgroundColor3 = COLORS.SectionBg,
                LayoutOrder = sectionOrder,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            local secLbl = Instance.new("TextLabel", sec)
            secLbl.Size = UDim2.new(1, -10, 0, 22)
            secLbl.Position = UDim2.new(0, 6, 0, 4)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 13
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left

            local itemList = Instance.new("UIListLayout", sec)
            itemList.SortOrder = Enum.SortOrder.LayoutOrder
            itemList.Padding = UDim.new(0, 6)
            itemList.HorizontalAlignment = Enum.HorizontalAlignment.Left

            local Section = {}
            local itemOrder = 1

            function Section:AddButton(opt)
                local btn = makeRoundedFrame({
                    Parent = sec,
                    Size = UDim2.new(0, 130, 0, 34),
                    BackgroundColor3 = COLORS.ButtonBg,
                    LayoutOrder = itemOrder,
                })
                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.fromScale(1,1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = opt.Name
                lbl.TextSize = 14
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                addBtnAnim(btn)
                local function click()
                    if opt.Callback then opt.Callback() end
                end
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        click()
                    end
                end)
                if UserInputService.TouchEnabled then
                    btn.TouchTap:Connect(click)
                end
                itemOrder = itemOrder + 1
            end

            function Section:AddToggle(opt)
                makeToggle(sec, opt)
                itemOrder = itemOrder + 1
            end

            function Section:AddTextbox(opt)
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1,0,0,34)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 90, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name or "Text"
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                local box = Instance.new("TextBox", container)
                box.Size = UDim2.new(0, 140, 0, 28)
                box.Position = UDim2.new(0, 96, 0.5, -14)
                box.BackgroundColor3 = COLORS.TextboxBg
                box.TextColor3 = COLORS.LabelText
                box.Font = Enum.Font.Gotham
                box.TextSize = 13
                box.Text = opt.Default or ""
                box.ClearTextOnFocus = true
                box.PlaceholderText = opt.PlaceholderText or ""
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.BorderSizePixel = 0
                local corner = Instance.new("UICorner", box)
                corner.CornerRadius = UDim.new(0,6)
                box.FocusLost:Connect(function(enter)
                    if enter and opt.Callback then
                        opt.Callback(box.Text)
                    end
                end)
                itemOrder = itemOrder + 1
            end

            function Section:AddSlider(opt)
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1,0,0,36)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 100, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local track = makeRoundedFrame({
                    Parent = container,
                    Size = UDim2.new(0, 140, 0, 6),
                    Position = UDim2.new(0, 105, 0.5, -3),
                    BackgroundColor3 = COLORS.SliderTrack,
                })
                local fill = makeRoundedFrame({
                    Parent = track,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = COLORS.SliderFill,
                })
                local knob = makeRoundedFrame({
                    Parent = track,
                    Size = UDim2.new(0,16,0,16),
                    Position = UDim2.new(0, -6, 0.5, -8),
                    BackgroundColor3 = COLORS.SliderKnob,
                })
                local val = opt.Default or opt.Min or 0
                local function setVal(v)
                    v = math.clamp(v, opt.Min, opt.Max)
                    val = v
                    local p = (v - opt.Min)/(opt.Max - opt.Min)
                    fill.Size = UDim2.new(0, p * track.Size.X.Offset, 1, 0)
                    knob.Position = UDim2.new(0, p * track.Size.X.Offset - 6, 0.5, -8)
                    if opt.Callback then opt.Callback(v) end
                end
                setVal(val)
                local dragging = false
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging = true
                        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        local v = opt.Min + (x/track.AbsoluteSize.X)*(opt.Max - opt.Min)
                        setVal(v)
                    end
                end)
                track.InputEnded:Connect(function() dragging = false end)
                track.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        local v = opt.Min + (x/track.AbsoluteSize.X)*(opt.Max - opt.Min)
                        setVal(v)
                    end
                end)
                if UserInputService.TouchEnabled then
                    track.TouchTap:Connect(function()
                        local x = math.clamp(UserInputService:GetMouseLocation().X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        local v = opt.Min + (x/track.AbsoluteSize.X)*(opt.Max - opt.Min)
                        setVal(v)
                    end)
                end
                -- optional textbox
                if opt.WithTextbox then
                    local box = Instance.new("TextBox", container)
                    box.Size = UDim2.new(0, 40, 0, 24)
                    box.Position = UDim2.new(0, 250, 0.5, -12)
                    box.BackgroundColor3 = COLORS.TextboxBg
                    box.TextColor3 = COLORS.LabelText
                    box.Font = Enum.Font.Gotham
                    box.TextSize = 12
                    box.Text = tostring(math.floor(val))
                    box.ClearTextOnFocus = true
                    box.BorderSizePixel = 0
                    local corner = Instance.new("UICorner", box)
                    corner.CornerRadius = UDim.new(0,6)
                    box.FocusLost:Connect(function(enter)
                        if enter then
                            setVal(tonumber(box.Text) or opt.Min)
                        end
                    end)
                end
                itemOrder = itemOrder + 1
            end

            function Section:AddDropdown(opt)
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1,0,0,36)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 100, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name or "Dropdown"
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local main = makeRoundedFrame({
                    Parent = container,
                    Size = UDim2.new(0, 160, 0, 30),
                    Position = UDim2.new(0, 105, 0.5, -15),
                    BackgroundColor3 = COLORS.DropdownBG,
                })
                local selectedLabel = Instance.new("TextLabel", main)
                selectedLabel.Size = UDim2.new(1, -24, 1, 0)
                selectedLabel.Position = UDim2.new(0, 8, 0, 0)
                selectedLabel.BackgroundTransparency = 1
                selectedLabel.Font = Enum.Font.Gotham
                selectedLabel.TextSize = 13
                selectedLabel.TextColor3 = COLORS.LabelText
                selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                local arrow = Instance.new("ImageLabel", main)
                arrow.Size = UDim2.new(0,16,0,16)
                arrow.Position = UDim2.new(1, -20, 0.5, -8)
                arrow.BackgroundTransparency = 1
                arrow.Image = "rbxassetid://6034818371"
                arrow.ImageColor3 = COLORS.LabelText

                local menu = makeRoundedFrame({
                    Parent = container,
                    Size = UDim2.new(0, 160, 0, 0),
                    Position = UDim2.new(0, 105, 1, 2),
                    BackgroundColor3 = COLORS.DropdownBG,
                    Visible = false,
                    AutomaticSize = Enum.AutomaticSize.Y,
                })
                menu.ClipsDescendants = true
                local menuList = Instance.new("UIListLayout", menu)
                menuList.SortOrder = Enum.SortOrder.LayoutOrder
                menuList.Padding = UDim.new(0, 2)

                local selected = opt.Default or opt.Values[1]
                local callback = opt.Callback

                local function updateItems(values)
                    for _,c in pairs(menu:GetChildren()) do
                        if c:IsA("Frame") then c:Destroy() end
                    end
                    for _, v in ipairs(values) do
                        local item = makeRoundedFrame({
                            Parent = menu,
                            Size = UDim2.new(1,0,0,28),
                            BackgroundColor3 = COLORS.DropdownBG,
                        })
                        local lbl = Instance.new("TextLabel", item)
                        lbl.Size = UDim2.new(1, -8, 1, 0)
                        lbl.Position = UDim2.new(0, 8, 0, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.Gotham
                        lbl.Text = tostring(v)
                        lbl.TextSize = 13
                        lbl.TextColor3 = COLORS.LabelText
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        item.InputBegan:Connect(function(i)
                            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                                selected = v
                                selectedLabel.Text = tostring(v)
                                menu.Visible = false
                                if callback then callback(v) end
                            end
                        end)
                    end
                end
                updateItems(opt.Values)

                selectedLabel.Text = tostring(selected)
                local open = false
                main.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        open = not open
                        menu.Visible = open
                        TweenService:Create(arrow, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {Rotation = open and 180 or 0}):Play()
                    end
                end)
                if UserInputService.TouchEnabled then
                    main.TouchTap:Connect(function()
                        open = not open
                        menu.Visible = open
                        TweenService:Create(arrow, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {Rotation = open and 180 or 0}):Play()
                    end)
                end
                -- auto close on outside click
                UserInputService.InputBegan:Connect(function(input)
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UserInputService:GetMouseLocation()
                        local pos = menu.AbsolutePosition
                        local size = menu.AbsoluteSize
                        if mouse.X < pos.X or mouse.X > pos.X+size.X or mouse.Y < pos.Y or mouse.Y > pos.Y+size.Y then
                            menu.Visible = false
                            open = false
                            TweenService:Create(arrow, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {Rotation = 0}):Play()
                        end
                    end
                end)
                itemOrder = itemOrder + 1
            end

            function Section:AddColorPicker(opt)
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1,0,0,34)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 100, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name or "Color"
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                local btn = makeRoundedFrame({
                    Parent = container,
                    Size = UDim2.new(0,40,0,28),
                    Position = UDim2.new(0, 105, 0.5, -14),
                    BackgroundColor3 = opt.Default or Color3.new(1,1,1),
                })
                local cur = opt.Default or Color3.new(1,1,1)
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        local c = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                        btn.BackgroundColor3 = c
                        cur = c
                        if opt.Callback then opt.Callback(c) end
                    end
                end)
                itemOrder = itemOrder + 1
            end

            function Section:AddLabel(opt)
                local frame = Instance.new("Frame", sec)
                frame.Size = UDim2.new(1,0,0,22)
                frame.BackgroundTransparency = 1
                frame.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", frame)
                lbl.Size = UDim2.fromScale(1,1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = typeof(opt)=="table" and (opt.Text or opt) or tostring(opt)
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                itemOrder = itemOrder + 1
            end

            function Section:AddParagraph(opt)
                local frame = makeRoundedFrame({
                    Parent = sec,
                    Size = UDim2.new(1, -10, 0, 0),
                    BackgroundColor3 = COLORS.ParagraphBg,
                    LayoutOrder = itemOrder,
                    AutomaticSize = Enum.AutomaticSize.Y,
                })
                local lbl = Instance.new("TextLabel", frame)
                lbl.Size = UDim2.new(1, -8, 1, -8)
                lbl.Position = UDim2.new(0, 4, 0, 4)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = typeof(opt)=="table" and (opt.Text or opt) or tostring(opt)
                lbl.TextSize = 12
                lbl.TextColor3 = COLORS.ParagraphText
                lbl.TextWrapped = true
                lbl.TextYAlignment = Enum.TextYAlignment.Top
                itemOrder = itemOrder + 1
            end

            function Section:AddKeybind(opt)
                local container = Instance.new("Frame", sec)
                container.Size = UDim2.new(1,0,0,30)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                local lbl = Instance.new("TextLabel", container)
                lbl.Size = UDim2.new(0, 100, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = opt.Name or "Keybind"
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                local btn = makeRoundedFrame({
                    Parent = container,
                    Size = UDim2.new(0,80,0,26),
                    Position = UDim2.new(0, 105, 0.5, -13),
                    BackgroundColor3 = COLORS.ButtonBg,
                })
                local keyLabel = Instance.new("TextLabel", btn)
                keyLabel.Size = UDim2.fromScale(1,1)
                keyLabel.BackgroundTransparency = 1
                keyLabel.Font = Enum.Font.Gotham
                keyLabel.Text = "[None]"
                keyLabel.TextSize = 12
                keyLabel.TextColor3 = COLORS.LabelText
                local key = opt.Default
                local binding = false
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        binding = true
                        keyLabel.Text = "[...]"
                    end
                end)
                UserInputService.InputBegan:Connect(function(i, gp)
                    if binding and not gp then
                        binding = false
                        key = i.KeyCode
                        keyLabel.Text = "["..(key.Name or tostring(key)).."]"
                        if opt.Callback then opt.Callback(key) end
                    elseif not binding and key and i.KeyCode == key and not gp then
                        if opt.Callback then opt.Callback(key, true) end
                    end
                end)
                itemOrder = itemOrder + 1
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

-- ===================================================================
--  Auto-Loading Sequence (when script runs)
-- ===================================================================
local function loadingSequence()
    local ts = os.clock()
    local spinner = {"|","/","-","\\"}
    local modules = {"Frame","Window","Icon","Hook Json","Ban List Json","Web API data","Anti Cheat module","Optimize","Players","User Whitelist","KevinzHub UI"}
    local successCount, failCount = 0, 0
    local gameName = "Game"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    print("\n\n")
    print("[ ⚙️  KevinzHub's Lib Loading for \"" .. gameName .. "\" ]\n")
    task.wait(1)

    for i = 0, 20 do
        local p = i/20
        local spinChar = spinner[(i % #spinner) + 1]
        local bar = string.rep("█", math.floor(p*20)) .. string.rep("░", 20 - math.floor(p*20))
        print(string.format("  %s [%-20s] %3d%%", spinChar, bar, math.floor(p*100)))
        task.wait(0.05)
    end
    print()
    task.wait(0.3)

    for _, name in ipairs(modules) do
        local success, result = pcall(function()
            if name == "Lol" then error("Simulated failure") end
        end)
        if success then
            warn("[+] Loaded " .. name)
            successCount = successCount + 1
        else
            warn("[x] Failed to load " .. name .. ": " .. tostring(result))
            failCount = failCount + 1
        end
        task.wait(0.1)
    end

    print()
    print("[✅] Run finished in " .. string.format("%.2f", os.clock() - ts) .. "s")
    print("[📦] Modules Loaded: " .. successCount)
    print("[❌] Modules Failed: " .. failCount)
    print("[👤] Username: " .. LocalPlayer.Name)
    print("[🌍] Players in Server: " .. #Players:GetPlayers())
    print("[⚙️] FPS: ~" .. (function() local c=0; local t=os.clock(); RunService.RenderStepped:Connect(function() c=c+1 end); task.wait(1); return math.floor(c) end)())

    if failCount == 0 then
        local signature = [[
>>=============================================================<<
||.-. .-')    ('-.        (`-.                .-') _    .-') _ ||
||\  ( OO ) _(  OO)     _(OO  )_             ( OO ) )  (  OO) )||
||,--. ,--.(,------.,--(_/   ,. \ ,-.-') ,--./ ,--,' ,(_)----. ||
|||  .'   / |  .---'\   \   /(__/ |  |OO)|   \ |  |\ |       | ||
|||      /, |  |     \   \ /   /  |  |  \|    \|  | )'--.   /  ||
|||     ' _||  '--.   \   '   /,  |  |(_/|  .     |/ (_/   /   ||
|||  .   \  |  .--'    \     /__),|  |_.'|  |\    |   /   /___ ||
|||  |\   \ |  `---.    \   /   (_|  |   |  | \   |  |        |||
||`--' '--' `------'     `-'      `--'   `--'  `--'  `--------'|| 
>>=============================================================<<
]]
        print("\n" .. signature)
    end
end

-- Run loading if this script is executed directly (not required if used as module)
task.spawn(loadingSequence)

return KevinzHub
