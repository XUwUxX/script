-- KevinzHub UI Library - Nâng cấp UI/UX: spacing tự động, ripple effect, chiều sâu alpha, responsive, headshot luôn hiện
-- Nâng cấp theo 9 gợi ý, spacing dùng UIListLayout, ripple cho button, shadow alpha, test đa độ phân giải tốt

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
    Ripple        = Color3.fromRGB(255,255,255),
    Shadow        = Color3.fromRGB(10,10,15),
}

local ANIM = {
    FadeTime     = 0.13,
    TweenTime    = 0.16,
    TabMoveTime  = 0.11,
    PressTime    = 0.07,
    Ripple       = 0.34,
    NotifFadeIn  = 0.19,
    NotifFadeOut = 0.28,
}

local KevinzHub = {}
local _ui = {}

-- Ripple Effect (hiệu ứng click nước lan tỏa)
local function rippleEffect(button)
    button.ClipsDescendants = true
    button.MouseButton1Down:Connect(function(x, y)
        local abs = button.AbsolutePosition
        local size = button.AbsoluteSize
        local ripple = Instance.new("Frame", button)
        ripple.BackgroundColor3 = COLORS.Ripple
        ripple.BackgroundTransparency = 0.85
        ripple.Size = UDim2.new(0,0,0,0)
        ripple.Position = UDim2.new(0,x-abs.X,0,y-abs.Y)
        ripple.AnchorPoint = Vector2.new(0.5,0.5)
        ripple.ZIndex = 99
        ripple.BorderSizePixel = 0
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1,0)
        TweenService:Create(ripple, TweenInfo.new(ANIM.Ripple, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1, Size = UDim2.new(0,size.X*1.8,0,size.Y*1.8)}
        ):Play()
        game:GetService("Debris"):AddItem(ripple, ANIM.Ripple)
    end)
end

-- Shadow Effect (chiều sâu alpha)
local function shadowEffect(frame, blur, alpha)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = frame
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = 1-alpha
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.Size = frame.Size + UDim2.new(0,blur,0,blur)
    shadow.Position = frame.Position + UDim2.new(0,-blur/2,0,-blur/2)
    shadow.ZIndex = frame.ZIndex-1
    shadow.AnchorPoint = frame.AnchorPoint
    shadow.Visible = frame.Visible
    frame:GetPropertyChangedSignal("Size"):Connect(function()
        shadow.Size = frame.Size + UDim2.new(0,blur,0,blur)
    end)
    frame:GetPropertyChangedSignal("Position"):Connect(function()
        shadow.Position = frame.Position + UDim2.new(0,-blur/2,0,-blur/2)
    end)
    frame:GetPropertyChangedSignal("Visible"):Connect(function()
        shadow.Visible = frame.Visible
    end)
end

-- Utility: Rounded Frame
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
    btn.BackgroundColor3 = COLORS.ButtonBg
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonBg}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonPress}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(ANIM.PressTime, Enum.EasingStyle.Quint), {BackgroundColor3=COLORS.ButtonHover}):Play()
    end)
    rippleEffect(btn)
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
    shadowEffect(notif, 12, 0.26)
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
        Size = UDim2.new(0.7,0,0.74,0),
        BackgroundColor3 = COLORS.WindowBg,
    })
    _ui.window = window
    shadowEffect(window, 20, 0.20)

    -- TopBar
    local topBar = makeRoundedFrame({
        Name = "TopBar",
        Parent = window,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = COLORS.TopBarBg,
    })

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

    local btnMin = Instance.new("TextButton", topBar)
    btnMin.Name = "MinimizeButton"
    btnMin.Size = UDim2.new(0,32,0,32)
    btnMin.Position = UDim2.new(1,-78,0.5,-16)
    btnMin.BackgroundTransparency = 0
    btnMin.Text = "–"
    btnMin.TextSize = 22
    btnMin.TextColor3 = COLORS.LabelText
    btnMin.Font = Enum.Font.GothamBold
    addBtnAnim(btnMin)
    local btnClose = Instance.new("TextButton", topBar)
    btnClose.Name = "CloseButton"
    btnClose.Size = UDim2.new(0,32,0,32)
    btnClose.Position = UDim2.new(1,-40,0.5,-16)
    btnClose.BackgroundTransparency = 0
    btnClose.Text = "X"
    btnClose.TextSize = 22
    btnClose.TextColor3 = COLORS.LabelText
    btnClose.Font = Enum.Font.GothamBold
    addBtnAnim(btnClose)
    btnClose.MouseButton1Click:Connect(function() KevinzHub:Destroy() end)
    btnMin.MouseButton1Click:Connect(function()
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
        rb.MouseButton1Click:Connect(function()
            window.Visible=true; rb:Destroy()
        end)
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
    sidebarHolder.Position = UDim2.new(0,0,0,38)
    sidebarHolder.Size = UDim2.new(0,208,1,-38)
    sidebarHolder.BackgroundTransparency = 1
    sidebarHolder.ClipsDescendants = true

    local sidebar = makeRoundedFrame{
        Name = "Sidebar", Parent = sidebarHolder,
        Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = COLORS.SidebarBg
    }
    sidebar.ClipsDescendants = true

    local pad = Instance.new("UIPadding", sidebar)
    pad.PaddingTop, pad.PaddingLeft = UDim.new(0,12), UDim.new(0,8)
    pad.PaddingRight, pad.PaddingBottom = UDim.new(0,8), UDim.new(0,8)

    local sidebarList = Instance.new("UIListLayout", sidebar)
    sidebarList.Padding = UDim.new(0,8)
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder

    -- SearchBar
    local searchBar = Instance.new("TextBox", sidebar)
    searchBar.Size = UDim2.new(1,-16,0,29)
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
    searchBar.LayoutOrder = 0

    -- User Info bottom (headshot luôn hiện, spacing đẹp)
    local function renderUserInfo()
        local uf = Instance.new("Frame")
        uf.Name = "UserInfo"
        uf.BackgroundTransparency=1
        uf.Size = UDim2.new(1,-10,0,54)
        uf.LayoutOrder = 10000
        local av = Instance.new("ImageLabel", uf)
        av.Name="Avatar"; av.Size=UDim2.new(0,46,0,46); av.Position=UDim2.new(0,2,0,4)
        av.BackgroundTransparency=1; av.Image="rbxassetid://77339698"
        coroutine.wrap(function()
            local id = LocalPlayer.UserId
            local img, isReady
            for _=1,6 do
                img, isReady = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isReady and typeof(img)=="string" and #img>0 then
                    av.Image = img
                    break
                end
                wait(0.23)
            end
        end)()
        local nm = Instance.new("TextLabel", uf)
        nm.Name="Username"; nm.Size=UDim2.new(1,-60,1,0); nm.Position=UDim2.new(0,54,0,0)
        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.Text=LocalPlayer.Name
        nm.TextSize=15; nm.TextColor3=COLORS.LabelText; nm.TextXAlignment=Enum.TextXAlignment.Left
        return uf
    end
    local userInfoFrame = renderUserInfo()
    userInfoFrame.Parent = sidebar

    -- Tabs
    local tabs = {}
    local tabContents = {}
    local tabOrder = 0

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
                tabContents[n].Position = UDim2.new(0,208,0,44)
                TweenService:Create(tabContents[n], TweenInfo.new(ANIM.TabMoveTime, Enum.EasingStyle.Quint), {BackgroundTransparency=0}):Play()
            else
                TweenService:Create(tabContents[n], TweenInfo.new(ANIM.TabMoveTime, Enum.EasingStyle.Quint), {BackgroundTransparency=1}):Play()
            end
        end
    end

    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = Instance.new("TextButton", sidebar)
        btn.Name = tabOpt.Name.."Btn"
        btn.Size = UDim2.new(1,-16,0,40)
        btn.BackgroundColor3 = COLORS.TabInactive
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = tabOrder
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
        tabs[tabOpt.Name] = btn
        local ct = makeRoundedFrame{
            Name = tabOpt.Name.."Content", Parent = window,
            Position = UDim2.new(0,208,0,44),
            Size = UDim2.new(1,-230,1,-66),
            BackgroundColor3 = COLORS.ContentBg,
            Visible = false
        }
        shadowEffect(ct, 12, 0.14)
        local contentList = Instance.new("UIListLayout", ct)
        contentList.Padding = UDim.new(0,18)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        ct.ClipsDescendants = true
        tabContents[tabOpt.Name] = ct
        btn.MouseButton1Click:Connect(function()
            selectTab(tabOpt.Name)
        end)
        if tabOrder == 1 then selectTab(tabOpt.Name) end

        local Tab = {}
        local sectionOrder = 0
        function Tab:AddSection(secOpt)
            sectionOrder = sectionOrder + 1
            local secFrame = makeRoundedFrame{
                Name = secOpt.Name.."Section", Parent = ct,
                Size = UDim2.new(1,-22,0,0),
                BackgroundColor3 = COLORS.SectionBg,
                LayoutOrder = sectionOrder
            }
            local sectionList = Instance.new("UIListLayout", secFrame)
            sectionList.Padding = UDim.new(0,11)
            sectionList.SortOrder = Enum.SortOrder.LayoutOrder
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            local secLbl = Instance.new("TextLabel", secFrame)
            secLbl.Size = UDim2.new(1,-14,0,23)
            secLbl.Position = UDim2.new(0,7,0,7)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 15
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            secLbl.LayoutOrder = 0

            local Section = {}
            function Section:AddButton(btnOpt)
                local btn = Instance.new("TextButton", secFrame)
                btn.Name = btnOpt.Name.."Btn"
                btn.Size = UDim2.new(0,145,0,32)
                btn.BackgroundColor3 = COLORS.ButtonBg
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.LayoutOrder = 10
                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.fromScale(1,1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = btnOpt.Name
                lbl.TextSize = 15
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                addBtnAnim(btn)
                btn.MouseButton1Click:Connect(function()
                    if btnOpt.Callback then btnOpt.Callback() end
                end)
            end
            function Section:AddSlider(slOpt)
                local sliderHolder = Instance.new("Frame", secFrame)
                sliderHolder.BackgroundTransparency = 1
                sliderHolder.Size = UDim2.new(1,0,0,47)
                sliderHolder.LayoutOrder = 20
                local sliderList = Instance.new("UIListLayout", sliderHolder)
                sliderList.Padding = UDim.new(0,0)
                sliderList.FillDirection = Enum.FillDirection.Horizontal
                sliderList.HorizontalAlignment = Enum.HorizontalAlignment.Left
                sliderList.SortOrder = Enum.SortOrder.LayoutOrder

                local labelHeight = 18
                local sliderW = 168
                local textboxW = (slOpt.WithTextbox and 54) or 0
                local gap = slOpt.WithTextbox and 12 or 0

                local lbl = Instance.new("TextLabel", sliderHolder)
                lbl.Name = "SliderLabel"
                lbl.Size = UDim2.new(0,sliderW+textboxW+gap,0,labelHeight)
                lbl.Position = UDim2.new(0,0,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = slOpt.Name
                lbl.TextSize = 14
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.LayoutOrder = 0

                local sliderBg = makeRoundedFrame{
                    Name = slOpt.Name.."Slider", Parent = sliderHolder,
                    Position = UDim2.new(0,0,0,labelHeight+7),
                    Size = UDim2.new(0,sliderW,0,13),
                    BackgroundColor3 = COLORS.SliderTrack
                }
                sliderBg.LayoutOrder = 1
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
                    textbox = Instance.new("TextBox", sliderHolder)
                    textbox.Size = UDim2.new(0,textboxW,0,labelHeight+11)
                    textbox.Position = UDim2.new(0,sliderW+gap,0,0)
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
                local toggleHolder = Instance.new("Frame", secFrame)
                toggleHolder.BackgroundTransparency = 1
                toggleHolder.Size = UDim2.new(1,0,0,toggleH+2)
                toggleHolder.LayoutOrder = 30
                local toggleBg = makeRoundedFrame{
                    Name = opt.Name.."ToggleBG", Parent = toggleHolder,
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
                    end
                end)
                local toggleLbl = Instance.new("TextLabel", toggleHolder)
                toggleLbl.Name = "ToggleLabel"
                toggleLbl.Position = UDim2.new(0,60,0,0)
                toggleLbl.Size = UDim2.new(0,180,0,toggleH)
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
