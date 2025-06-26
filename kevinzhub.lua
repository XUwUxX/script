-- KevinzHub UI Library (pro UI/UX: ripple effect, alpha depth, responsive, rounded, best-practice, no error)
-- Usage: local KevinzHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/XUwUxX/script/refs/heads/main/kevinzhub.lua"))()

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
    DepthShadow   = Color3.fromRGB(10,12,18),
    Ripple        = Color3.fromRGB(255,255,255),
}

local ALPHA_SHADOW = 0.22   -- Độ trong suốt của shadow chiều sâu
local ALPHA_RIPPLE = 0.18   -- Độ trong suốt của hiệu ứng ripple

local CORNER_RADIUS = UDim.new(0, 9)

local function makeUICorner(parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = CORNER_RADIUS
    c.Parent = parent
    return c
end

local function makeUIStroke(parent, c, thick)
    local s = Instance.new("UIStroke")
    s.Color = c or COLORS.Outline
    s.Thickness = thick or 1.15
    s.Parent = parent
    return s
end

local function makeShadow(parent, radius, trans)
    local shadow = Instance.new("ImageLabel")
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = COLORS.DepthShadow
    shadow.ImageTransparency = trans or ALPHA_SHADOW
    shadow.Size = UDim2.new(1, radius*2, 1, radius*2)
    shadow.Position = UDim2.new(0, -radius, 0, -radius)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Name = "DepthShadow"
    shadow.Parent = parent
    return shadow
end

local function RippleEffect(btn)
    btn.ClipsDescendants = true
    btn.MouseButton1Down:Connect(function(x, y)
        local abs = btn.AbsolutePosition
        local sz = btn.AbsoluteSize
        local r = Instance.new("Frame")
        r.BackgroundTransparency = 1-ALPHA_RIPPLE
        r.BackgroundColor3 = COLORS.Ripple
        r.Size = UDim2.new(0,0,0,0)
        r.Position = UDim2.new(0,(x-abs.X)-sz.X/2,0,(y-abs.Y)-sz.Y/2)
        r.AnchorPoint = Vector2.new(0.5,0.5)
        r.ZIndex = btn.ZIndex + 20
        makeUICorner(r).CornerRadius = UDim.new(1,0)
        r.Parent = btn
        local max = math.max(sz.X, sz.Y)
        TweenService:Create(r, TweenInfo.new(0.36, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(max*2.5, max*2.5), BackgroundTransparency=1}):Play()
        game:GetService("Debris"):AddItem(r, 0.4)
    end)
end

local function ResponsiveMainWindow()
    local scr = game:GetService("Workspace").CurrentCamera or workspace.CurrentCamera
    local function getScale()
        local w,h = scr.ViewportSize.X, scr.ViewportSize.Y
        local scale = math.min(math.clamp(w/1280,0.62,1), math.clamp(h/700,0.68,1))
        return scale
    end
    return getScale
end

local KevinzHub = {}
local _ui = {}

function KevinzHub:MakeNotification(opt)
    -- Notification hiệu ứng đẹp, shadow, bo góc, alpha cho chiều sâu
    if not _ui.notifFrame then
        local notifFrame = Instance.new("Frame", _ui.screenGui or PlayerGui)
        notifFrame.Name = "NotificationFrame"
        notifFrame.AnchorPoint = Vector2.new(1,0)
        notifFrame.Position = UDim2.new(1,-36,0,54)
        notifFrame.Size = UDim2.new(0, 340, 0, 0)
        notifFrame.BackgroundTransparency = 1
        notifFrame.Visible = true
        notifFrame.ZIndex = 200
        local notifList = Instance.new("UIListLayout", notifFrame)
        notifList.SortOrder = Enum.SortOrder.LayoutOrder
        notifList.Padding = UDim.new(0,12)
        _ui.notifFrame = notifFrame
    end
    local notif = Instance.new("Frame")
    notif.Name = "Notif"
    notif.Parent = _ui.notifFrame
    notif.Size = UDim2.new(1,0,0,55)
    notif.BackgroundColor3 = COLORS.NotifBg
    notif.BackgroundTransparency = 0
    notif.ZIndex = 201
    makeUICorner(notif)
    makeUIStroke(notif, COLORS.TabActive, 2)
    makeShadow(notif, 10, 0.26)
    local icon = Instance.new("ImageLabel", notif)
    icon.Name = "NotifIcon"
    icon.Size = UDim2.new(0,28,0,28)
    icon.Position = UDim2.new(0,14,0, (55-28)//2)
    icon.BackgroundTransparency = 1
    icon.Image = opt.Image or "rbxassetid://77339698"
    local lbl = Instance.new("TextLabel", notif)
    lbl.Name = "NotifText"
    lbl.Position = UDim2.new(0,52,0,3)
    lbl.Size = UDim2.new(1,-62,1,-6)
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
    TweenService:Create(notif, TweenInfo.new(0.20, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(lbl, TweenInfo.new(0.20, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    local duration = opt.Time or 2.6
    task.spawn(function()
        wait(duration)
        TweenService:Create(notif, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1,60,0,0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        wait(0.28)
        notif:Destroy()
    end)
end

function KevinzHub:MakeWindow(opt)
    local getScale = ResponsiveMainWindow()
    local function scale(v) return UDim2.new(v.X.Scale*getScale(), v.X.Offset, v.Y.Scale*getScale(), v.Y.Offset) end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KevinzHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = PlayerGui
    _ui.screenGui = screenGui

    local window = Instance.new("Frame", screenGui)
    window.Name = "MainWindow"
    window.AnchorPoint = Vector2.new(0.5,0.5)
    window.Position = UDim2.fromScale(0.5,0.5)
    window.Size = UDim2.new(0, math.floor(710*getScale()), 0, math.floor(520*getScale()))
    window.BackgroundColor3 = COLORS.WindowBg
    window.ZIndex = 10
    makeUICorner(window)
    makeUIStroke(window)
    makeShadow(window, 16, 0.15)
    _ui.window = window

    -- TopBar
    local topBar = Instance.new("Frame", window)
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1,0,0,40)
    topBar.BackgroundColor3 = COLORS.TopBarBg
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 11
    makeUICorner(topBar)
    makeUIStroke(topBar)
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

    -- Close/Minimize
    local btnMin = Instance.new("Frame", topBar)
    btnMin.Name = "MinimizeButton"
    btnMin.Size = UDim2.new(0,32,0,32)
    btnMin.Position = UDim2.new(1,-78,0.5,-16)
    btnMin.BackgroundColor3 = COLORS.ButtonBg
    btnMin.ZIndex = 12
    makeUICorner(btnMin)
    makeUIStroke(btnMin)
    local btnClose = Instance.new("Frame", topBar)
    btnClose.Name = "CloseButton"
    btnClose.Size = UDim2.new(0,32,0,32)
    btnClose.Position = UDim2.new(1,-40,0.5,-16)
    btnClose.BackgroundColor3 = COLORS.ButtonBg
    btnClose.ZIndex = 12
    makeUICorner(btnClose)
    makeUIStroke(btnClose)
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
    makeShadow(btnMin, 6, 0.16)
    makeShadow(btnClose, 6, 0.16)
    RippleEffect(btnClose)
    RippleEffect(btnMin)
    btnClose.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            KevinzHub:Destroy()
        end
    end)
    btnMin.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            window.Visible = false
            local rb = Instance.new("Frame", screenGui)
            rb.Name = "Restore"
            rb.Size = UDim2.new(0,32,0,32)
            rb.Position = UDim2.new(0,18,0,18)
            rb.BackgroundColor3 = COLORS.ButtonBg
            rb.ZIndex = 28
            makeUICorner(rb)
            makeUIStroke(rb)
            makeShadow(rb, 6, 0.16)
            local rbl = Instance.new("TextLabel", rb)
            rbl.Size = UDim2.fromScale(1,1)
            rbl.BackgroundTransparency = 1
            rbl.Font = Enum.Font.GothamBold
            rbl.Text = "X"
            rbl.TextSize = 20
            rbl.TextColor3 = COLORS.LabelText
            rbl.TextXAlignment = Enum.TextXAlignment.Center
            rbl.TextYAlignment = Enum.TextYAlignment.Center
            RippleEffect(rb)
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

    -- Sidebar
    local sidebarHolder = Instance.new("Frame", window)
    sidebarHolder.Name = "SidebarHolder"
    sidebarHolder.Position = UDim2.new(0,0,0,40)
    sidebarHolder.Size = UDim2.new(0,196,1,-40)
    sidebarHolder.BackgroundTransparency = 1
    sidebarHolder.ClipsDescendants = true
    local sidebar = Instance.new("Frame", sidebarHolder)
    sidebar.Name = "Sidebar"
    sidebar.Position = UDim2.new(0,0,0,0)
    sidebar.Size = UDim2.new(1,0,1,0)
    sidebar.BackgroundColor3 = COLORS.SidebarBg
    sidebar.ClipsDescendants = true
    makeUICorner(sidebar)
    makeUIStroke(sidebar)
    makeShadow(sidebar, 10, 0.13)
    local pad = Instance.new("UIPadding", sidebar)
    pad.PaddingTop, pad.PaddingLeft = UDim.new(0,10), UDim.new(0,8)
    pad.PaddingRight, pad.PaddingBottom = UDim.new(0,8), UDim.new(0,8)
    local searchBar = Instance.new("TextBox", sidebar)
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
    makeUICorner(searchBar)
    local list = Instance.new("UIListLayout", sidebar)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,9)
    list.Parent = sidebar

    -- User info bottom
    local function renderUserInfo()
        local uf = Instance.new("Frame")
        uf.Name = "UserInfo"
        uf.BackgroundTransparency=1
        uf.AnchorPoint = Vector2.new(0,1)
        uf.Position = UDim2.new(0,8,1,-14)
        uf.Size = UDim2.new(1,-16,0,54)
        uf.Parent = sidebar

        local thumb = "rbxassetid://77339698"
        local av = Instance.new("ImageLabel", uf)
        av.Name="Avatar"; av.Size=UDim2.new(0,44,0,44); av.Position=UDim2.new(0,0,0,5)
        av.BackgroundTransparency=1; av.Image=thumb
        coroutine.wrap(function()
            local id = LocalPlayer.UserId
            local img, isReady
            for _=1,12 do
                img, isReady = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isReady and typeof(img)=="string" and #img>0 then
                    thumb = img
                    break
                end
                wait(0.15)
            end
            av.Image = thumb
        end)()
        local nm = Instance.new("TextLabel", uf)
        nm.Name="Username"; nm.Size=UDim2.new(1,-52,1,0); nm.Position=UDim2.new(0,52,0,0)
        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.Text=LocalPlayer.Name
        nm.TextSize=15; nm.TextColor3=COLORS.LabelText; nm.TextXAlignment=Enum.TextXAlignment.Left
        return uf
    end
    local userInfoFrame = renderUserInfo()
    userInfoFrame.LayoutOrder = 1e9

    -- Tabs
    local tabs, tabContents, tabOrder = {}, {}, 0
    local scrolling = 0
    local function updateSidebarScroll()
        RunService.Heartbeat:Wait()
        local absContent = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 6
        local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 16
        if absContent > visible then
            sidebar.Position = UDim2.new(0,0,0,-scrolling)
        else
            sidebar.Position = UDim2.new(0,0,0,0)
            scrolling = 0
        end
        userInfoFrame.Position = UDim2.new(0,8,1,-userInfoFrame.Size.Y.Offset-10)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarScroll)
    sidebarHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarScroll)
    sidebarHolder.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local absContent = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 6
            local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 16
            if absContent > visible then
                scrolling = math.clamp(scrolling - input.Position.Z * 24, 0, absContent - visible)
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
            TweenService:Create(btn, TweenInfo.new(0.18, Enum.EasingStyle.Quint),
                {BackgroundColor3 = active and COLORS.TabActive or COLORS.TabInactive}
            ):Play()
            local icon = btn:FindFirstChild("TabIcon")
            if icon then
                TweenService:Create(icon, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                    ImageColor3 = active and COLORS.TabIconActive or COLORS.TabIconTint
                }):Play()
            end
            tabContents[n].Visible = active
            if active then
                tabContents[n].Position = tabContents[n].Position + UDim2.new(0,0,0,8)
                TweenService:Create(tabContents[n], TweenInfo.new(0.14, Enum.EasingStyle.Quint), {Position=UDim2.new(0,196,0,48)}):Play()
            end
        end
    end

    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = Instance.new("Frame", sidebar)
        btn.Name = tabOpt.Name.."Btn"
        btn.Size = UDim2.new(1,-16,0,44)
        btn.LayoutOrder = tabOrder
        btn.BackgroundColor3 = COLORS.TabInactive
        btn.ZIndex = 15
        makeUICorner(btn)
        makeUIStroke(btn)
        makeShadow(btn, 5, 0.10)
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
        RippleEffect(btn)
        tabs[tabOpt.Name] = btn

        local ct = Instance.new("Frame", window)
        ct.Name = tabOpt.Name.."Content"
        ct.Position = UDim2.new(0,196,0,48)
        ct.Size = UDim2.new(1,-210,1,-62)
        ct.BackgroundColor3 = COLORS.ContentBg
        ct.Visible = false
        ct.ClipsDescendants = true
        ct.ZIndex = 20
        makeUICorner(ct)
        makeUIStroke(ct)
        makeShadow(ct, 12, 0.07)
        tabContents[tabOpt.Name] = ct

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
            local secFrame = Instance.new("Frame", ct)
            secFrame.Name = secOpt.Name.."Section"
            secFrame.Size = UDim2.new(1,-36,0,0)
            secFrame.Position = UDim2.new(0,18,0,24 + (sectionOrder-1)*144)
            secFrame.BackgroundColor3 = COLORS.SectionBg
            secFrame.ZIndex = 21
            makeUICorner(secFrame)
            makeUIStroke(secFrame)
            makeShadow(secFrame, 6, 0.11)
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            local secLbl = Instance.new("TextLabel", secFrame)
            secLbl.Size = UDim2.new(1,-14,0,23)
            secLbl.Position = UDim2.new(0,8,0,7)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 15
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left

            local Section = {}
            local itemY = 36
            function Section:AddButton(btnOpt)
                local btn = Instance.new("Frame", secFrame)
                btn.Name = btnOpt.Name.."Btn"
                btn.Size = UDim2.new(0,150,0,32)
                btn.Position = UDim2.new(0,13,0,itemY)
                btn.BackgroundColor3 = COLORS.ButtonBg
                btn.ZIndex = 22
                makeUICorner(btn)
                makeUIStroke(btn)
                makeShadow(btn, 5, 0.10)
                RippleEffect(btn)
                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.fromScale(1,1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = btnOpt.Name
                lbl.TextSize = 15
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        if btnOpt.Callback then btnOpt.Callback() end
                    end
                end)
                itemY = itemY + 40
            end
            function Section:AddSlider(slOpt)
                local labelHeight = 18
                local sliderW = 168
                local textboxW = (slOpt.WithTextbox and 54) or 0
                local gap = slOpt.WithTextbox and 14 or 0
                local labelYOffset = 9

                local lbl = Instance.new("TextLabel", secFrame)
                lbl.Name = "SliderLabel"
                lbl.Size = UDim2.new(0,sliderW+textboxW+gap,0,labelHeight)
                lbl.Position = UDim2.new(0,13,0,itemY-labelHeight-labelYOffset)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = slOpt.Name
                lbl.TextSize = 14
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local sliderBg = Instance.new("Frame", secFrame)
                sliderBg.Name = slOpt.Name.."Slider"
                sliderBg.Position = UDim2.new(0,13,0,itemY)
                sliderBg.Size = UDim2.new(0,sliderW,0,13)
                sliderBg.BackgroundColor3 = COLORS.SliderTrack
                sliderBg.ZIndex = 23
                makeUICorner(sliderBg).CornerRadius = UDim.new(1,0)
                makeUIStroke(sliderBg)
                local sliderFill = Instance.new("Frame", sliderBg)
                sliderFill.Name = "SliderFill"
                sliderFill.Position = UDim2.new(0,0,0,0)
                sliderFill.Size = UDim2.new(0,0,1,0)
                sliderFill.BackgroundColor3 = COLORS.SliderFill
                makeUICorner(sliderFill).CornerRadius = UDim.new(1,0)
                local sliderKnob = Instance.new("Frame", sliderBg)
                sliderKnob.Name = "SliderKnob"
                sliderKnob.Size = UDim2.new(0,19,0,19)
                sliderKnob.Position = UDim2.new(0,0,0,-3)
                sliderKnob.BackgroundColor3 = COLORS.SliderKnob
                sliderKnob.BorderSizePixel = 0
                makeUICorner(sliderKnob)
                makeShadow(sliderKnob, 3, 0.15)
                RippleEffect(sliderKnob)
                local val = slOpt.Default or slOpt.Min or 0

                local function setSlider(v,updateTextbox)
                    v = math.clamp(tonumber(v) or slOpt.Min, slOpt.Min, slOpt.Max)
                    val = v
                    local percent = (v-slOpt.Min)/(slOpt.Max-slOpt.Min)
                    sliderFill.Size = UDim2.new(0, percent*sliderBg.Size.X.Offset, 1, 0)
                    sliderKnob.Position = UDim2.new(0, percent*sliderBg.Size.X.Offset-9, 0, -3)
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
                    textbox.Size = UDim2.new(0,textboxW,0,labelHeight+13)
                    textbox.Position = UDim2.new(0,13+sliderW+gap,0,itemY-2)
                    textbox.BackgroundColor3 = COLORS.TextboxBg
                    textbox.TextColor3 = COLORS.LabelText
                    textbox.Font = Enum.Font.Gotham
                    textbox.TextSize = 14
                    textbox.Text = tostring(val)
                    textbox.ClearTextOnFocus = true
                    textbox.PlaceholderText = ""
                    textbox.TextXAlignment = Enum.TextXAlignment.Center
                    textbox.BorderSizePixel = 0
                    textbox.ZIndex = 23
                    makeUICorner(textbox)
                    makeUIStroke(textbox, COLORS.Outline, 1)
                    makeShadow(textbox, 4, 0.15)
                    textbox.FocusLost:Connect(function(enter)
                        if enter then
                            setSlider(textbox.Text,false)
                        end
                    end)
                end

                itemY = itemY + labelHeight+29
            end

            function Section:AddToggle(opt)
                local toggleW, toggleH = 48, 24
                local toggleBg = Instance.new("Frame", secFrame)
                toggleBg.Name = opt.Name.."ToggleBG"
                toggleBg.Position = UDim2.new(0,13,0,itemY)
                toggleBg.Size = UDim2.new(0,toggleW,0,toggleH)
                toggleBg.BackgroundColor3 = COLORS.ToggleBg
                toggleBg.ZIndex = 23
                makeUICorner(toggleBg)
                makeUIStroke(toggleBg)
                makeShadow(toggleBg, 4, 0.14)
                RippleEffect(toggleBg)
                local knob = Instance.new("Frame", toggleBg)
                knob.Name = "Knob"
                knob.Position = UDim2.new(0,3,0,3)
                knob.Size = UDim2.new(0,18,0,18)
                knob.BackgroundColor3 = COLORS.ToggleOff
                makeUICorner(knob)
                makeShadow(knob, 2, 0.14)
                RippleEffect(knob)
                local on = opt.Default or false
                local function updateAppearance(animated)
                    local targetX = on and (toggleBg.Size.X.Offset - knob.Size.X.Offset - 3) or 3
                    if animated then
                        TweenService:Create(knob, TweenInfo.new(0.19, Enum.EasingStyle.Quint), {Position=UDim2.new(0,targetX,0,3)}):Play()
                        TweenService:Create(toggleBg, TweenInfo.new(0.19, Enum.EasingStyle.Quint),
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
                local toggleLbl = Instance.new("TextLabel", secFrame)
                toggleLbl.Name = "ToggleLabel"
                toggleLbl.Position = UDim2.new(0,13+toggleW+14,0,itemY)
                toggleLbl.Size = UDim2.new(0,180,0,toggleH)
                toggleLbl.BackgroundTransparency = 1
                toggleLbl.Font = Enum.Font.Gotham
                toggleLbl.Text = opt.Name
                toggleLbl.TextSize = 15
                toggleLbl.TextColor3 = COLORS.LabelText
                toggleLbl.TextXAlignment = Enum.TextXAlignment.Left

                itemY = itemY + toggleH + 15
            end

            return Section
        end
        return Tab
    end

    function Window:Destroy()
        KevinzHub:Destroy()
    end

    -- Đáp ứng mọi độ phân giải
    RunService.RenderStepped:Connect(function()
        local sc = getScale()
        window.Size = UDim2.new(0, math.floor(710*sc), 0, math.floor(520*sc))
    end)

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
