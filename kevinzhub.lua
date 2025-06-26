-- KevinzHub UI Library: Spacing đều, không lỗi ẩn, ripple, màu alpha thấp, bo góc, auto responsive, cực tối ưu
-- Tác giả: XUwUxX, 2024-2025

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local COLORS = {
    WindowBg      = Color3.fromRGB(28,29,36),
    TopBarBg      = Color3.fromRGB(34,36,45),
    SidebarBg     = Color3.fromRGB(34,36,45),
    ContentBg     = Color3.fromRGB(36,38,50),
    Outline       = Color3.fromRGB(45,48,68),
    LabelText     = Color3.fromRGB(240,240,255),
    SectionBg     = Color3.fromRGB(39,41,54),
    ButtonBg      = Color3.fromRGB(50,54,74),
    ButtonHover   = Color3.fromRGB(60,70,110),
    ButtonPress   = Color3.fromRGB(35,38,55),
    ButtonRipple  = Color3.fromRGB(120,140,200),
    ToggleBg      = Color3.fromRGB(46,47,56),
    ToggleOn      = Color3.fromRGB(0,180,120),
    ToggleOff     = Color3.fromRGB(70,70,80),
    ToggleKnobOn  = Color3.fromRGB(35,36,40),
    SliderTrack   = Color3.fromRGB(60,65,80),
    SliderFill    = Color3.fromRGB(0,180,120),
    SliderKnob    = Color3.fromRGB(70,80,120),
    TextboxBg     = Color3.fromRGB(66,68,79),
    NotifBg       = Color3.fromRGB(30,32,38),
    NotifText     = Color3.fromRGB(240,240,255),
    Shadow        = Color3.fromRGB(0,0,0),
}

local ALPHAS = {
    Shadow   = 0.22, -- bóng mờ
    Ripple   = 0.22,
    Section  = 0.14,
    Button   = 0.08
}

local RADIUS = UDim.new(0,10)

local ANIM = {
    FadeTime     = 0.17,
    TweenTime    = 0.18,
    TabMoveTime  = 0.13,
    PressTime    = 0.07,
    NotifFadeIn  = 0.24,
    NotifFadeOut = 0.32,
    Ripple       = 0.34
}

local KevinzHub = {}
local _ui = {}

-- Utility
local function addShadow(frame, alpha, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = 1 - (alpha or 0.2)
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
    shadow.Position = UDim2.new(0, -(size or 10), 0, -(size or 10))
    shadow.ZIndex = (frame.ZIndex or 1) - 1
    shadow.Parent = frame
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    return shadow
end

local function rippleEffect(btn)
    btn.ClipsDescendants = true
    btn.MouseButton1Down:Connect(function(x,y)
        local abs = btn.AbsolutePosition
        local pos = Vector2.new(x,y)-abs
        local ripple = Instance.new("Frame")
        ripple.AnchorPoint = Vector2.new(0.5,0.5)
        ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
        ripple.Size = UDim2.new(0,0,0,0)
        ripple.BackgroundColor3 = COLORS.ButtonRipple
        ripple.BackgroundTransparency = 1-ALPHAS.Ripple
        ripple.BorderSizePixel = 0
        ripple.ZIndex = btn.ZIndex+5
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = btn:FindFirstChildOfClass("UICorner") and btn:FindFirstChildOfClass("UICorner").CornerRadius or RADIUS
        ripple.Parent = btn
        local maxLen = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.2
        TweenService:Create(ripple, TweenInfo.new(ANIM.Ripple, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, maxLen, 0, maxLen),
            BackgroundTransparency = 1
        }):Play()
        game:GetService("Debris"):AddItem(ripple, ANIM.Ripple)
    end)
end

local function makeRoundedFrame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k] = v end
    f.BorderSizePixel = 0
    local uc = Instance.new("UICorner", f)
    uc.CornerRadius = RADIUS
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = COLORS.Outline
    stroke.Thickness = 1.1
    stroke.Transparency = 1-ALPHAS.Section
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
    corner.CornerRadius = RADIUS
    rippleEffect(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
        TweenService:Create(highlight, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.93}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonBg}):Play()
        TweenService:Create(highlight, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundTransparency=1}):Play()
    end)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonPress}):Play()
            TweenService:Create(highlight, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.86}):Play()
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
            TweenService:Create(highlight, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0.93}):Play()
        end
    end)
end

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
        notifList.Padding = UDim.new(0,12)
        _ui.notifFrame = notifFrame
    end
    local notif = makeRoundedFrame{
        Name = "Notif",
        Parent = _ui.notifFrame,
        Size = UDim2.new(1,0,0,56),
        BackgroundColor3 = COLORS.NotifBg,
        LayoutOrder = os.clock()*1000
    }
    notif.BackgroundTransparency = 1
    notif.ZIndex = 201
    local stroke = notif:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Thickness = 2 stroke.Color = COLORS.TabActive end

    local icon = Instance.new("ImageLabel", notif)
    icon.Name = "NotifIcon"
    icon.Size = UDim2.new(0,28,0,28)
    icon.Position = UDim2.new(0,14,0,14)
    icon.BackgroundTransparency = 1
    icon.Image = opt.Image or "rbxassetid://77339698"

    local lbl = Instance.new("TextLabel", notif)
    lbl.Name = "NotifText"
    lbl.Position = UDim2.new(0,52,0,3)
    lbl.Size = UDim2.new(1,-70,1,-6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = (opt.Name and (opt.Name.."\n") or "") .. (opt.Content or "")
    lbl.TextSize = 16
    lbl.TextColor3 = COLORS.NotifText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 202

    addShadow(notif, ALPHAS.Shadow, 24)

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
    screenGui.IgnoreGuiInset = false
    screenGui.Parent = PlayerGui
    _ui.screenGui = screenGui

    local window = makeRoundedFrame({
        Name = "MainWindow",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.new(0.55,0,0.68,0), -- Auto responsive
        BackgroundColor3 = COLORS.WindowBg,
        ZIndex = 1
    })
    _ui.window = window
    addShadow(window, ALPHAS.Shadow, 32)

    -- TopBar
    local topBar = makeRoundedFrame({
        Name = "TopBar",
        Parent = window,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,44),
        BackgroundColor3 = COLORS.TopBarBg,
        ZIndex = 3
    })
    topBar.ClipsDescendants = true

    local icon = Instance.new("ImageLabel", topBar)
    icon.Name = "GameIcon"
    icon.Size = UDim2.new(0,28,0,28)
    icon.Position = UDim2.new(0,15,0.5,-14)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://4483345998"

    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Name = "Title"
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.Position = UDim2.new(0, 58, 0.5, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = opt.Name or "KevinzHub"
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = COLORS.LabelText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local btnMin = makeRoundedFrame{
        Name = "MinimizeButton", Parent = topBar,
        Size = UDim2.new(0,34,0,34),
        Position = UDim2.new(1,-82,0.5,-17),
        BackgroundColor3 = COLORS.ButtonBg,
        ZIndex = 5
    }
    local btnClose = makeRoundedFrame{
        Name = "CloseButton", Parent = topBar,
        Size = UDim2.new(0,34,0,34),
        Position = UDim2.new(1,-40,0.5,-17),
        BackgroundColor3 = COLORS.ButtonBg,
        ZIndex = 5
    }
    local btnMinLbl = Instance.new("TextLabel", btnMin)
    btnMinLbl.Size = UDim2.fromScale(1,1)
    btnMinLbl.BackgroundTransparency = 1
    btnMinLbl.Font = Enum.Font.GothamBold
    btnMinLbl.Text = "–"
    btnMinLbl.TextSize = 23
    btnMinLbl.TextColor3 = COLORS.LabelText
    btnMinLbl.TextXAlignment = Enum.TextXAlignment.Center
    btnMinLbl.TextYAlignment = Enum.TextYAlignment.Center
    local btnCloseLbl = Instance.new("TextLabel", btnClose)
    btnCloseLbl.Size = UDim2.fromScale(1,1)
    btnCloseLbl.BackgroundTransparency = 1
    btnCloseLbl.Font = Enum.Font.GothamBold
    btnCloseLbl.Text = "X"
    btnCloseLbl.TextSize = 23
    btnCloseLbl.TextColor3 = COLORS.LabelText
    btnCloseLbl.TextXAlignment = Enum.TextXAlignment.Center
    btnCloseLbl.TextYAlignment = Enum.TextYAlignment.Center
    addBtnAnim(btnClose); addBtnAnim(btnMin)
    btnClose.ZIndex = 6
    btnMin.ZIndex = 6
    rippleEffect(btnClose)
    rippleEffect(btnMin)
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
                Size = UDim2.new(0,38,0,38),
                Position = UDim2.new(0,18,0,18),
                BackgroundColor3 = COLORS.ButtonBg,
                ZIndex = 10
            }
            local rbl = Instance.new("TextLabel", rb)
            rbl.Size = UDim2.fromScale(1,1)
            rbl.BackgroundTransparency = 1
            rbl.Font = Enum.Font.GothamBold
            rbl.Text = "☰"
            rbl.TextSize = 22
            rbl.TextColor3 = COLORS.LabelText
            rbl.TextXAlignment = Enum.TextXAlignment.Center
            rbl.TextYAlignment = Enum.TextYAlignment.Center
            addBtnAnim(rb)
            rippleEffect(rb)
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
    sidebarHolder.Position = UDim2.new(0,0,0,44)
    sidebarHolder.Size = UDim2.new(0,200,1,-44)
    sidebarHolder.BackgroundTransparency = 1
    sidebarHolder.ClipsDescendants = true

    local sidebar = makeRoundedFrame{
        Name = "Sidebar", Parent = sidebarHolder,
        Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = COLORS.SidebarBg
    }
    sidebar.ClipsDescendants = true

    local pad = Instance.new("UIPadding", sidebar)
    pad.PaddingTop, pad.PaddingLeft = UDim.new(0,16), UDim.new(0,10)
    pad.PaddingRight, pad.PaddingBottom = UDim.new(0,10), UDim.new(0,10)

    -- SearchBar
    local searchBar = Instance.new("TextBox")
    searchBar.Parent = sidebar
    searchBar.Size = UDim2.new(1,0,0,28)
    searchBar.Position = UDim2.new(0,0,0,0)
    searchBar.PlaceholderText = "Tìm tab..."
    searchBar.Text = ""
    searchBar.BackgroundColor3 = COLORS.SectionBg
    searchBar.TextColor3 = COLORS.LabelText
    searchBar.ClearTextOnFocus = true
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextSize = 15
    searchBar.BorderSizePixel = 0
    searchBar.ZIndex = 2
    local searchCorner = Instance.new("UICorner", searchBar)
    searchCorner.CornerRadius = RADIUS

    local list = Instance.new("UIListLayout", sidebar)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,14)
    list.Parent = sidebar

    -- User Info bottom (headshot luôn hiện)
    local function renderUserInfo()
        local uf = Instance.new("Frame")
        uf.Name = "UserInfo"
        uf.BackgroundTransparency=1
        uf.AnchorPoint = Vector2.new(0,1)
        uf.Position = UDim2.new(0,8,1,-14)
        uf.Size = UDim2.new(1,-16,0,54)
        uf.Parent = sidebar

        local av = Instance.new("ImageLabel", uf)
        av.Name="Avatar"; av.Size=UDim2.new(0,44,0,44); av.Position=UDim2.new(0,2,0,5)
        av.BackgroundTransparency=1; av.Image="rbxassetid://77339698"
        coroutine.wrap(function()
            local id = LocalPlayer.UserId
            local img, isReady
            for _=1,12 do
                img, isReady = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isReady and typeof(img)=="string" and #img>0 and not img:match("rbxasset://") then
                    av.Image = img
                    break
                end
                wait(0.18)
            end
        end)()

        local nm = Instance.new("TextLabel", uf)
        nm.Name="Username"; nm.Size=UDim2.new(1,-54,1,0); nm.Position=UDim2.new(0,54,0,0)
        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.Text=LocalPlayer.Name
        nm.TextSize=15; nm.TextColor3=COLORS.LabelText; nm.TextXAlignment=Enum.TextXAlignment.Left
        return uf
    end
    local userInfoFrame = renderUserInfo()
    userInfoFrame.LayoutOrder = 1e6

    -- Tabs
    local tabs = {}
    local tabContents = {}
    local tabOrder = 0

    -- Sidebar scroll
    local scrolling = 0
    local function updateSidebarScroll()
        RunService.Heartbeat:Wait()
        local absContent = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 8
        local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 16
        if absContent > visible then
            sidebar.Position = UDim2.new(0,0,0,-scrolling)
        else
            sidebar.Position = UDim2.new(0,0,0,0)
            scrolling = 0
        end
        userInfoFrame.Position = UDim2.new(0,8,1,-userInfoFrame.Size.Y.Offset-8)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarScroll)
    sidebarHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarScroll)
    sidebarHolder.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local absContent = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 8
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
                    ImageColor3 = active and COLORS.ToggleOn or COLORS.TabIconTint
                }):Play()
            end
            tabContents[n].Visible = active
            if active then
                tabContents[n].Position = tabContents[n].Position + UDim2.new(0,0,0,8)
                TweenService:Create(tabContents[n], TweenInfo.new(ANIM.TabMoveTime, Enum.EasingStyle.Quint), {Position=UDim2.new(0,200,0,54)}):Play()
            end
        end
    end

    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = makeRoundedFrame{
            Name = tabOpt.Name.."Btn", Parent = sidebar,
            Size = UDim2.new(1,0,0,44), LayoutOrder = tabOrder,
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
            Position = UDim2.new(0,200,0,54),
            Size = UDim2.new(1,-220,1,-72),
            BackgroundColor3 = COLORS.ContentBg,
            Visible = false
        }
        ct.ClipsDescendants = true
        addShadow(ct, ALPHAS.Button, 18)
        tabs[tabOpt.Name], tabContents[tabOpt.Name] = btn, ct
        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                selectTab(tabOpt.Name)
            end
        end)
        if tabOrder == 1 then selectTab(tabOpt.Name) end

        local Tab = {}
        local sectionOrder = 0
        function Tab:AddSection(secOpt)
            sectionOrder = sectionOrder + 1
            local secFrame = makeRoundedFrame{
                Name = secOpt.Name.."Section", Parent = ct,
                Size = UDim2.new(1,-32,0,0),
                Position = UDim2.new(0,16,0,22 + (sectionOrder-1)*142),
                BackgroundColor3 = COLORS.SectionBg,
            }
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            addShadow(secFrame, ALPHAS.Section, 20)
            local secLbl = Instance.new("TextLabel", secFrame)
            secLbl.Size = UDim2.new(1,-14,0,23)
            secLbl.Position = UDim2.new(0,7,0,8)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 15
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left

            local Section = {}
            local itemY = 36
            function Section:AddButton(btnOpt)
                local btn = makeRoundedFrame{
                    Name = btnOpt.Name.."Btn", Parent = secFrame,
                    Size = UDim2.new(0,145,0,32),
                    Position = UDim2.new(0,12,0,itemY),
                    BackgroundColor3 = COLORS.ButtonBg
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
                rippleEffect(btn)
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        if btnOpt.Callback then btnOpt.Callback() end
                    end
                end)
                itemY = itemY + 44
            end
            function Section:AddSlider(slOpt)
                local labelHeight = 18
                local sliderW = 168
                local textboxW = (slOpt.WithTextbox and 54) or 0
                local gap = slOpt.WithTextbox and 14 or 0
                local labelYOffset = 10

                local lbl = Instance.new("TextLabel", secFrame)
                lbl.Name = "SliderLabel"
                lbl.Size = UDim2.new(0,sliderW+textboxW+gap,0,labelHeight)
                lbl.Position = UDim2.new(0,12,0,itemY-labelHeight-labelYOffset)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = slOpt.Name
                lbl.TextSize = 14
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local sliderBg = makeRoundedFrame{
                    Name = slOpt.Name.."Slider", Parent = secFrame,
                    Position = UDim2.new(0,12,0,itemY),
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
                corner.CornerRadius = RADIUS
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
                    textbox = Instance.new("TextBox", secFrame)
                    textbox.Size = UDim2.new(0,textboxW,0,labelHeight+11)
                    textbox.Position = UDim2.new(0,12+sliderW+gap,0,itemY-2)
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
                    corner.CornerRadius = RADIUS
                    textbox.FocusLost:Connect(function(enter)
                        if enter then
                            setSlider(textbox.Text,false)
                        end
                    end)
                end

                itemY = itemY + labelHeight+26
            end

            function Section:AddToggle(opt)
                local toggleW, toggleH = 48, 24
                local toggleBg = makeRoundedFrame{
                    Name = opt.Name.."ToggleBG", Parent = secFrame,
                    Position = UDim2.new(0,12,0,itemY),
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
                    end
                end)
                rippleEffect(toggleBg)
                local toggleLbl = Instance.new("TextLabel", secFrame)
                toggleLbl.Name = "ToggleLabel"
                toggleLbl.Position = UDim2.new(0,12+toggleW+16,0,itemY)
                toggleLbl.Size = UDim2.new(0,180,0,toggleH)
                toggleLbl.BackgroundTransparency = 1
                toggleLbl.Font = Enum.Font.Gotham
                toggleLbl.Text = opt.Name
                toggleLbl.TextSize = 15
                toggleLbl.TextColor3 = COLORS.LabelText
                toggleLbl.TextXAlignment = Enum.TextXAlignment.Left

                itemY = itemY + toggleH + 16
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
