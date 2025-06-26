-- KevinzHub UI Library: UIListLayout auto-spacing, ripple effect, alpha-depth, responsive
-- Features: auto-spacing with UIListLayout for all controls, ripple animation, shadow/alpha, responsive scaling

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
    ToggleOn      = Color3.fromRGB(0,180,80),
    ToggleOff     = Color3.fromRGB(70,70,80),
    ToggleKnobOn  = Color3.fromRGB(35,36,40),
    SliderTrack   = Color3.fromRGB(60,60,70),
    SliderFill    = Color3.fromRGB(0,180,80),
    SliderKnob    = Color3.fromRGB(60,60,70),
    DropdownBG    = Color3.fromRGB(45,45,54),
    DropdownHover = Color3.fromRGB(50,60,80),
    DropdownPress = Color3.fromRGB(40,45,80),
    TabActive     = Color3.fromRGB(0,180,80),
    TabInactive   = Color3.fromRGB(48,49,60),
    TabIconTint   = Color3.fromRGB(180,180,210),
    TabIconActive = Color3.fromRGB(0,180,80),
    NotifBg       = Color3.fromRGB(30,32,38),
    NotifText     = Color3.fromRGB(240,240,255),
    TextboxBg     = Color3.fromRGB(66,68,79),
    SectionBg     = Color3.fromRGB(32,33,40),
    Shadow        = Color3.fromRGB(0,0,0)
}

local ANIM = {
    FadeTime     = 0.17,
    TweenTime    = 0.19,
    TabMoveTime  = 0.13,
    PressTime    = 0.07,
    NotifFadeIn  = 0.22,
    NotifFadeOut = 0.32,
    Ripple       = 0.38
}

local KevinzHub = {}
local _ui = {}

-- Ripple Effect Utility
local function rippleEffect(parent, x, y, color, alpha)
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = alpha or 0.85
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = 999
    ripple.ClipsDescendants = true
    ripple.BorderSizePixel = 0
    local uic = Instance.new("UICorner", ripple)
    uic.CornerRadius = UDim.new(1,0)
    ripple.Parent = parent
    local max = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    TweenService:Create(ripple, TweenInfo.new(ANIM.Ripple, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, max, 0, max),
        BackgroundTransparency = 1
    }):Play()
    delay(ANIM.Ripple, function() ripple:Destroy() end)
end

-- Shadow Utility (Frame with low alpha, underlay for depth)
local function addShadow(frame, thickness)
    local sh = Instance.new("ImageLabel")
    sh.Name = "Shadow"
    sh.Image = "rbxassetid://1316045217"
    sh.BackgroundTransparency = 1
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(10,10,118,118)
    sh.Size = frame.Size + UDim2.new(0,thickness*2,0,thickness*2)
    sh.Position = frame.Position - UDim2.new(0,thickness,0,thickness)
    sh.AnchorPoint = frame.AnchorPoint
    sh.ZIndex = (frame.ZIndex or 1) - 1
    sh.ImageColor3 = COLORS.Shadow
    sh.ImageTransparency = 0.82
    sh.Parent = frame.Parent
    frame:GetPropertyChangedSignal("Position"):Connect(function()
        sh.Position = frame.Position - UDim2.new(0,thickness,0,thickness)
    end)
    frame:GetPropertyChangedSignal("Size"):Connect(function()
        sh.Size = frame.Size + UDim2.new(0,thickness*2,0,thickness*2)
    end)
    return sh
end

local function makeRoundedFrame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k] = v end
    f.BorderSizePixel = 0
    local uc = Instance.new("UICorner", f)
    uc.CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = COLORS.Outline
    stroke.Thickness = 1.15
    return f
end

local function addBtnAnim(btn)
    btn.AutoButtonColor = false
    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.BackgroundTransparency = 1
    highlight.BackgroundColor3 = Color3.fromRGB(255,255,255)
    highlight.Size = UDim2.new(1,0,1,0)
    highlight.ZIndex = 99
    highlight.Parent = btn
    local corner = Instance.new("UICorner", highlight)
    corner.CornerRadius = UDim.new(0,8)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
        TweenService:Create(highlight, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.92}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonBg}):Play()
        TweenService:Create(highlight, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundTransparency=1}):Play()
    end)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonPress}):Play()
            TweenService:Create(highlight, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.8}):Play()
            local relX = i.Position.X - btn.AbsolutePosition.X
            local relY = i.Position.Y - btn.AbsolutePosition.Y
            rippleEffect(btn, relX, relY, Color3.fromRGB(255,255,255), 0.82)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
            TweenService:Create(highlight, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.92}):Play()
        end
    end)
end

-- Notification API
function KevinzHub:MakeNotification(opt)
    if pcall(function() return game:GetService("StarterGui"):SetCore("SendNotification",{}) end) then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = opt.Name or "Kevinzhub",
                Text = opt.Content or "",
                Duration = opt.Time or 2.5,
                Icon = opt.Image or "rbxassetid://77339698"
            })
        end)
    end
    if not _ui.notifFrame then
        local notifFrame = Instance.new("Frame", _ui.screenGui or PlayerGui)
        notifFrame.Name = "NotificationFrame"
        notifFrame.AnchorPoint = Vector2.new(1,0)
        notifFrame.Position = UDim2.new(1,-30,0,52)
        notifFrame.Size = UDim2.new(0, 340, 0, 0)
        notifFrame.BackgroundTransparency = 1
        notifFrame.Visible = true
        notifFrame.ZIndex = 200
        local notifList = Instance.new("UIListLayout", notifFrame)
        notifList.SortOrder = Enum.SortOrder.LayoutOrder
        notifList.Padding = UDim.new(0,10)
        _ui.notifFrame = notifFrame
    end
    local notif = makeRoundedFrame{
        Name = "Notif",
        Parent = _ui.notifFrame,
        Size = UDim2.new(1,0,0,54),
        BackgroundColor3 = COLORS.NotifBg,
        LayoutOrder = os.clock()*1000
    }
    notif.BackgroundTransparency = 1
    notif.ZIndex = 201
    local stroke = notif:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Thickness = 2 stroke.Color = COLORS.TabActive end

    local icon = Instance.new("ImageLabel", notif)
    icon.Name = "NotifIcon"
    icon.Size = UDim2.new(0,24,0,24)
    icon.Position = UDim2.new(0,14,0,15)
    icon.BackgroundTransparency = 1
    icon.Image = opt.Image or "rbxassetid://77339698"

    local lbl = Instance.new("TextLabel", notif)
    lbl.Name = "NotifText"
    lbl.Position = UDim2.new(0,48,0,3)
    lbl.Size = UDim2.new(1,-60,1,-6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = (opt.Name and (opt.Name.."\n") or "") .. (opt.Content or "")
    lbl.TextSize = 16
    lbl.TextColor3 = COLORS.NotifText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 202

    notif.Position = UDim2.new(1,60,0,0)
    notif.BackgroundTransparency = 1
    notif.Visible = true
    TweenService:Create(notif, TweenInfo.new(ANIM.NotifFadeIn, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(lbl, TweenInfo.new(ANIM.NotifFadeIn, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    local duration = opt.Time or 2.5
    task.spawn(function()
        wait(duration)
        TweenService:Create(notif, TweenInfo.new(ANIM.NotifFadeOut, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1,60,0,0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(lbl, TweenInfo.new(ANIM.NotifFadeOut, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        wait(ANIM.NotifFadeOut)
        notif:Destroy()
    end)
end

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
        Size = UDim2.new(0, math.clamp(workspace.CurrentCamera.ViewportSize.X * 0.48, 480, 840), 0, math.clamp(workspace.CurrentCamera.ViewportSize.Y * 0.68, 380, 700)),
        BackgroundColor3 = COLORS.WindowBg,
    })
    _ui.window = window
    addShadow(window, 18)

    -- Responsive resize
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        window.Size = UDim2.new(0, math.clamp(workspace.CurrentCamera.ViewportSize.X * 0.48, 480, 840), 0, math.clamp(workspace.CurrentCamera.ViewportSize.Y * 0.68, 380, 700))
    end)

    -- TopBar
    local topBar = makeRoundedFrame({
        Name = "TopBar", Parent = window,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = COLORS.TopBarBg,
    })
    topBar.ClipsDescendants = true

    local icon = Instance.new("ImageLabel", topBar)
    icon.Name = "GameIcon"
    icon.Size = UDim2.new(0,26,0,26)
    icon.Position = UDim2.new(0,13,0.5,-13)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://4483345998"

    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Name = "Title"
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.Position = UDim2.new(0, 50, 0.5, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = opt.Name or "KevinzHub"
    titleLabel.TextSize = 19
    titleLabel.TextColor3 = COLORS.LabelText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local btnMin = makeRoundedFrame{
        Name = "MinimizeButton", Parent = topBar,
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,-78,0.5,-16),
        BackgroundColor3 = COLORS.ButtonBg
    }
    local btnClose = makeRoundedFrame{
        Name = "CloseButton", Parent = topBar,
        Size = UDim2.new(0,32,0,32),
        Position = UDim2.new(1,-40,0.5,-16),
        BackgroundColor3 = COLORS.ButtonBg
    }
    local btnMinLbl = Instance.new("TextLabel", btnMin)
    btnMinLbl.Size = UDim2.fromScale(1,1)
    btnMinLbl.BackgroundTransparency = 1
    btnMinLbl.Font = Enum.Font.GothamBold
    btnMinLbl.Text = "–"
    btnMinLbl.TextSize = 22
    btnMinLbl.TextColor3 = COLORS.LabelText
    btnMinLbl.TextXAlignment = Enum.TextXAlignment.Center
    btnMinLbl.TextYAlignment = Enum.TextYAlignment.Center
    local btnCloseLbl = Instance.new("TextLabel", btnClose)
    btnCloseLbl.Size = UDim2.fromScale(1,1)
    btnCloseLbl.BackgroundTransparency = 1
    btnCloseLbl.Font = Enum.Font.GothamBold
    btnCloseLbl.Text = "X"
    btnCloseLbl.TextSize = 22
    btnCloseLbl.TextColor3 = COLORS.LabelText
    btnCloseLbl.TextXAlignment = Enum.TextXAlignment.Center
    btnCloseLbl.TextYAlignment = Enum.TextYAlignment.Center
    addBtnAnim(btnClose); addBtnAnim(btnMin)
    btnClose.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            KevinzHub:Destroy()
        end
    end)
    btnMin.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            window.Visible = false
            local rb = makeRoundedFrame{
                Name = "Restore", Parent = screenGui,
                Size = UDim2.new(0,32,0,32),
                Position = UDim2.new(0,18,0,18),
                BackgroundColor3 = COLORS.ButtonBg
            }
            local rbl = Instance.new("TextLabel", rb)
            rbl.Size = UDim2.fromScale(1,1)
            rbl.BackgroundTransparency = 1
            rbl.Font = Enum.Font.GothamBold
            rbl.Text = "X"
            rbl.TextSize = 20
            rbl.TextColor3 = COLORS.LabelText
            rbl.TextXAlignment = Enum.TextXAlignment.Center
            rbl.TextYAlignment = Enum.TextYAlignment.Center
            addBtnAnim(rb)
            rb.InputBegan:Connect(function(ii)
                if ii.UserInputType==Enum.UserInputType.MouseButton1 then
                    window.Visible=true; rb:Destroy()
                end
            end)
        end
    end)

    -- Drag logic
    do
        local dragging, startPos, dragStart
        topBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true
                dragStart = i.Position
                startPos = window.Position
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        topBar.InputChanged:Connect(function(i)
            if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                local delta = i.Position - dragStart
                window.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Sidebar + Tabs
    local sidebarHolder = Instance.new("Frame", window)
    sidebarHolder.Name = "SidebarHolder"
    sidebarHolder.Position = UDim2.new(0,0,0,38)
    sidebarHolder.Size = UDim2.new(0,200,1,-38)
    sidebarHolder.BackgroundTransparency = 1
    sidebarHolder.ClipsDescendants = true

    local sidebar = makeRoundedFrame{
        Name = "Sidebar", Parent = sidebarHolder,
        Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = COLORS.SidebarBg
    }
    sidebar.ClipsDescendants = true
    addShadow(sidebar, 10)

    local pad = Instance.new("UIPadding", sidebar)
    pad.PaddingTop, pad.PaddingLeft = UDim.new(0,10), UDim.new(0,8)
    pad.PaddingRight, pad.PaddingBottom = UDim.new(0,8), UDim.new(0,8)

    -- SearchBar
    local searchBar = Instance.new("TextBox")
    searchBar.Parent = sidebar
    searchBar.Size = UDim2.new(1,-16,0,28)
    searchBar.Position = UDim2.new(0,8,0,4)
    searchBar.PlaceholderText = "Tìm tab..."
    searchBar.Text = ""
    searchBar.BackgroundColor3 = COLORS.ParagraphBg
    searchBar.TextColor3 = COLORS.LabelText
    searchBar.ClearTextOnFocus = true
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextSize = 15
    searchBar.BorderSizePixel = 0
    searchBar.ZIndex = 2
    local searchCorner = Instance.new("UICorner", searchBar)
    searchCorner.CornerRadius = UDim.new(0,7)

    local sidebarList = Instance.new("UIListLayout", sidebar)
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0,8)
    sidebarList.Parent = sidebar

    -- User Info (bottom)
    local function renderUserInfo()
        local uf = Instance.new("Frame")
        uf.Name = "UserInfo"
        uf.BackgroundTransparency=1
        uf.AnchorPoint = Vector2.new(0,1)
        uf.Size = UDim2.new(1,-16,0,56)
        uf.LayoutOrder = 2^16
        uf.Parent = sidebar

        local av = Instance.new("ImageLabel", uf)
        av.Name="Avatar"; av.Size=UDim2.new(0,48,0,48)
        av.Position=UDim2.new(0,0,0,4)
        av.BackgroundTransparency=1; av.Image="rbxassetid://77339698"
        coroutine.wrap(function()
            local id = LocalPlayer.UserId
            local img, isReady
            for _=1,10 do
                img, isReady = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isReady and typeof(img)=="string" and #img>0 then
                    av.Image = img
                    break
                end
                wait(0.2)
            end
        end)()

        local nm = Instance.new("TextLabel", uf)
        nm.Name="Username"; nm.Size=UDim2.new(1,-60,1,0); nm.Position=UDim2.new(0,56,0,0)
        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.Text=LocalPlayer.Name
        nm.TextSize=15; nm.TextColor3=COLORS.LabelText; nm.TextXAlignment=Enum.TextXAlignment.Left
        return uf
    end
    local userInfoFrame = renderUserInfo()

    -- Tabs
    local tabs = {}
    local tabContents = {}
    local tabOrder = 0

    -- Sidebar scroll
    local scrolling = 0
    local function updateSidebarScroll()
        RunService.Heartbeat:Wait()
        local absContent = sidebarList.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 6
        local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 16
        if absContent > visible then
            sidebar.Position = UDim2.new(0,0,0,-scrolling)
        else
            sidebar.Position = UDim2.new(0,0,0,0)
            scrolling = 0
        end
        userInfoFrame.Position = UDim2.new(0,8,1,-userInfoFrame.Size.Y.Offset-10)
    end
    sidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarScroll)
    sidebarHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarScroll)
    sidebarHolder.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local absContent = sidebarList.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 6
            local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 16
            if absContent > visible then
                scrolling = math.clamp(scrolling - input.Position.Z * 26, 0, absContent - visible)
                sidebar.Position = UDim2.new(0,0,0,-scrolling)
            end
        end
    end)
    updateSidebarScroll()

    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBar.Text:lower()
        for tabName, tabBtn in pairs(tabs) do
            tabBtn.Visible = (query == "" or tabName:lower():find(query))
        end
        updateSidebarScroll()
    end)

    local function selectTab(name)
        for n,btn in pairs(tabs) do
            local active = (n==name)
            TweenService:Create(btn, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint),
                {BackgroundColor3 = active and COLORS.TabActive or COLORS.TabInactive}
            ):Play()
            local icon = btn:FindFirstChild("TabIcon")
            if icon then
                TweenService:Create(icon, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {
                    ImageColor3 = active and COLORS.TabIconActive or COLORS.TabIconTint
                }):Play()
            end
            tabContents[n].Visible = active
            if active then
                tabContents[n].Position = tabContents[n].Position + UDim2.new(0,0,0,8)
                TweenService:Create(tabContents[n], TweenInfo.new(ANIM.TabMoveTime, Enum.EasingStyle.Quint), {Position=UDim2.new(0,200,0,44)}):Play()
            end
        end
    end

    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = makeRoundedFrame{
            Name = tabOpt.Name.."Btn", Parent = sidebar,
            Size = UDim2.new(1,-16,0,44), LayoutOrder = tabOrder,
            BackgroundColor3 = COLORS.TabInactive
        }
        local icon = Instance.new("ImageLabel", btn)
        icon.Name = "TabIcon"
        icon.Size = UDim2.new(0,22,0,22)
        icon.Position = UDim2.new(0,10,0.5,-11)
        icon.BackgroundTransparency = 1
        icon.Image = tabOpt.Icon or "rbxassetid://4483345998"
        icon.ImageColor3 = COLORS.TabIconTint
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1,-38,1,0)
        lbl.Position = UDim2.new(0,38,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = tabOpt.Name
        lbl.TextSize = 15
        lbl.TextColor3 = COLORS.LabelText
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        addBtnAnim(btn)
        local ct = makeRoundedFrame{
            Name = tabOpt.Name.."Content", Parent = window,
            Position = UDim2.new(0,200,0,44),
            Size = UDim2.new(1,-220,1,-62),
            BackgroundColor3 = COLORS.ContentBg,
            Visible = false,
            ClipsDescendants = true
        }
        addShadow(ct, 8)
        tabs[tabOpt.Name], tabContents[tabOpt.Name] = btn, ct
        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                selectTab(tabOpt.Name)
            end
        end)
        if tabOrder == 1 then selectTab(tabOpt.Name) end

        -- Section API
        local Tab = {}
        local sectionOrder = 0

        function Tab:AddSection(secOpt)
            sectionOrder = sectionOrder + 1
            local secFrame = makeRoundedFrame{
                Name = secOpt.Name.."Section", Parent = ct,
                Size = UDim2.new(1,-32,0,0),
                Position = UDim2.new(0,16,0,20 + (sectionOrder-1)*132),
                BackgroundColor3 = COLORS.SectionBg,
                ClipsDescendants = true
            }
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            addShadow(secFrame, 5)
            local secList = Instance.new("UIListLayout", secFrame)
            secList.SortOrder = Enum.SortOrder.LayoutOrder
            secList.Padding = UDim.new(0,12)
            local secLbl = Instance.new("TextLabel", secFrame)
            secLbl.Size = UDim2.new(1,-14,0,25)
            secLbl.Position = UDim2.new(0,7,0,6)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 15
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            secLbl.LayoutOrder = 1

            local Section = {}

            function Section:AddButton(btnOpt)
                local btn = makeRoundedFrame{
                    Name = btnOpt.Name.."Btn", Parent = secFrame,
                    Size = UDim2.new(0,145,0,32),
                    BackgroundColor3 = COLORS.ButtonBg,
                    LayoutOrder = 2
                }
                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.fromScale(1,1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = btnOpt.Name
                lbl.TextSize = 15
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                addBtnAnim(btn)
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        if btnOpt.Callback then btnOpt.Callback() end
                    end
                end)
            end

            function Section:AddSlider(slOpt)
                local labelHeight = 18
                local sliderW = 166
                local textboxW = (slOpt.WithTextbox and 54) or 0
                local gap = slOpt.WithTextbox and 12 or 0
                local labelYOffset = 7

                local sliderHolder = Instance.new("Frame", secFrame)
                sliderHolder.Name = slOpt.Name.."SliderHolder"
                sliderHolder.Size = UDim2.new(1,0,0,36)
                sliderHolder.BackgroundTransparency = 1
                sliderHolder.LayoutOrder = 3

                local sliderList = Instance.new("UIListLayout", sliderHolder)
                sliderList.SortOrder = Enum.SortOrder.LayoutOrder
                sliderList.Padding = UDim.new(0,2)

                local lbl = Instance.new("TextLabel", sliderHolder)
                lbl.Name = "SliderLabel"
                lbl.Size = UDim2.new(0,sliderW+textboxW+gap,0,labelHeight)
                lbl.Position = UDim2.new(0,12,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = slOpt.Name
                lbl.TextSize = 14
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.LayoutOrder = 1

                local sliderRow = Instance.new("Frame", sliderHolder)
                sliderRow.Name = "SliderRow"
                sliderRow.Size = UDim2.new(1,0,0,18)
                sliderRow.BackgroundTransparency = 1
                sliderRow.LayoutOrder = 2

                local sliderBg = makeRoundedFrame{
                    Name = slOpt.Name.."Slider", Parent = sliderRow,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(0,sliderW,0,13),
                    BackgroundColor3 = COLORS.SliderTrack
                }
                local sliderFill = makeRoundedFrame{
                    Name = "SliderFill", Parent = sliderBg,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(0,0,1,0),
                    BackgroundColor3 = COLORS.SliderFill
                }
                local sliderKnob = Instance.new("Frame", sliderBg)
                sliderKnob.Name = "SliderKnob"
                sliderKnob.Size = UDim2.new(0,18,0,18)
                sliderKnob.Position = UDim2.new(0,0,0,-2)
                sliderKnob.BackgroundColor3 = COLORS.SliderKnob
                sliderKnob.BorderSizePixel = 0
                local corner = Instance.new("UICorner", sliderKnob)
                corner.CornerRadius = UDim.new(0, 6)
                local val = slOpt.Default or slOpt.Min or 0

                local function setSlider(v,updateTextbox)
                    v = math.clamp(tonumber(v) or slOpt.Min, slOpt.Min, slOpt.Max)
                    val = v
                    local percent = (v-slOpt.Min)/(slOpt.Max-slOpt.Min)
                    sliderFill.Size = UDim2.new(0, percent*sliderBg.Size.X.Offset, 1, 0)
                    sliderKnob.Position = UDim2.new(0, percent*sliderBg.Size.X.Offset-9, 0, -2)
                    if updateTextbox and slOpt.WithTextbox and textbox then
                        textbox.Text = tostring(math.floor(v))
                    end
                    if slOpt.Callback then slOpt.Callback(v) end
                end
                setSlider(val,true)
                local draggingSlider = false
                sliderKnob.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                    end
                end)
                sliderBg.InputEnded:Connect(function(i)
                    if i.UserInputState == Enum.UserInputState.End then
                        draggingSlider = false
                    end
                end)
                sliderBg.InputChanged:Connect(function(i)
                    if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local x = math.clamp(i.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                        local v = math.floor(slOpt.Min + (x/sliderBg.AbsoluteSize.X)*(slOpt.Max-slOpt.Min))
                        setSlider(v,true)
                    end
                end)
                sliderBg.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local x = math.clamp(i.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                        local v = math.floor(slOpt.Min + (x/sliderBg.AbsoluteSize.X)*(slOpt.Max-slOpt.Min))
                        setSlider(v,true)
                    end
                end)

                local textbox
                if slOpt.WithTextbox then
                    textbox = Instance.new("TextBox", sliderRow)
                    textbox.Size = UDim2.new(0,textboxW,0,labelHeight+10)
                    textbox.Position = UDim2.new(0,sliderW+gap,0,-2)
                    textbox.BackgroundColor3 = COLORS.TextboxBg
                    textbox.TextColor3 = COLORS.LabelText
                    textbox.Font = Enum.Font.Gotham
                    textbox.TextSize = 14
                    textbox.Text = tostring(val)
                    textbox.ClearTextOnFocus = true
                    textbox.PlaceholderText = ""
                    textbox.TextXAlignment = Enum.TextXAlignment.Center
                    textbox.BorderSizePixel = 0
                    local corner = Instance.new("UICorner", textbox)
                    corner.CornerRadius = UDim.new(0,6)
                    textbox.FocusLost:Connect(function(enter)
                        if enter then
                            setSlider(textbox.Text,false)
                        end
                    end)
                end
            end

            function Section:AddToggle(opt)
                local toggleW, toggleH = 48, 24
                local toggleRow = Instance.new("Frame", secFrame)
                toggleRow.Size = UDim2.new(1,0,0,toggleH)
                toggleRow.BackgroundTransparency = 1
                toggleRow.LayoutOrder = 4

                local toggleBg = makeRoundedFrame{
                    Name = opt.Name.."ToggleBG", Parent = toggleRow,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(0,toggleW,0,toggleH),
                    BackgroundColor3 = COLORS.ToggleBg
                }
                local knob = makeRoundedFrame{
                    Name = "Knob", Parent = toggleBg,
                    Position = UDim2.new(0,3,0,3),
                    Size = UDim2.new(0,18,0,18),
                    BackgroundColor3 = COLORS.ToggleOff
                }
                local on = opt.Default or false
                local function updateAppearance(animated)
                    local targetX = on and (toggleBg.Size.X.Offset - knob.Size.X.Offset - 3) or 3
                    if animated then
                        TweenService:Create(knob, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {Position=UDim2.new(0,targetX,0,3)}):Play()
                        TweenService:Create(toggleBg, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint),
                            {BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleBg}
                        ):Play()
                    else
                        knob.Position = UDim2.new(0,targetX,0,3)
                        toggleBg.BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleBg
                    end
                    knob.BackgroundColor3 = on and COLORS.ToggleKnobOn or COLORS.ToggleOff
                end
                updateAppearance(false)
                toggleBg.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        on = not on
                        updateAppearance(true)
                        if opt.Callback then opt.Callback(on) end
                        local relX = i.Position.X - toggleBg.AbsolutePosition.X
                        local relY = i.Position.Y - toggleBg.AbsolutePosition.Y
                        rippleEffect(toggleBg, relX, relY, Color3.fromRGB(0,255,120), 0.57)
                    end
                end)
                local toggleLbl = Instance.new("TextLabel", toggleRow)
                toggleLbl.Name = "ToggleLabel"
                toggleLbl.Position = UDim2.new(0,toggleW+14,0,0)
                toggleLbl.Size = UDim2.new(1,-toggleW-14,1,0)
                toggleLbl.BackgroundTransparency = 1
                toggleLbl.Font = Enum.Font.Gotham
                toggleLbl.Text = opt.Name
                toggleLbl.TextSize = 15
                toggleLbl.TextColor3 = COLORS.LabelText
                toggleLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            return Section
        end
        return Tab
    end

    function Window:Destroy()
        KevinzHub:Destroy()
    end

    return Window
end

function KevinzHub:Destroy()
    if _ui.screenGui then _ui.screenGui:Destroy() end
    if _ui.notifFrame then _ui.notifFrame:Destroy() end
    _ui = {}
end

function KevinzHub:Init()
    if _ui.screenGui then _ui.screenGui.Enabled = true end
end

return KevinzHub
