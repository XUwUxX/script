-- KevinzHub UI Library (Mobile/Desktop, Responsive, Improved Drag, Notif Transparency, Button/Slider/Close/Min Mobile Support)
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
    SliderKnob    = Color3.fromRGB(122,122,135),
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
    SectionBg     = Color3.fromRGB(32,33,40)
}

local ANIM = {
    FadeTime     = 0.17,
    TweenTime    = 0.19,
    TabMoveTime  = 0.13,
    PressTime    = 0.07,
    NotifFadeIn  = 0.22,
    NotifFadeOut = 0.32,
}

local CLICK_SOUND_ID = "rbxassetid://535716488"
local KEVINZHUB_VERSION = "2"

local KevinzHub = {}
local _ui = {}

local function playClickSound(parent)
    local snd = Instance.new("Sound")
    snd.SoundId = CLICK_SOUND_ID
    snd.Volume = 1
    snd.PlayOnRemove = true
    snd.Name = "KevinzHubClickSound"
    snd.Parent = parent or (PlayerGui or workspace)
    snd:Destroy()
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
            playClickSound(btn)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            outAnim()
        end
    end)
end

-- Notification: more transparent, blurred glass look
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
        notifFrame.Position = UDim2.new(1,-22,0,34)
        notifFrame.Size = UDim2.new(0, 320, 0, 0)
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
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = COLORS.NotifBg,
        LayoutOrder = os.clock()*1000
    }
    notif.BackgroundTransparency = 0.36 -- More transparent, glass effect
    notif.ZIndex = 201

    -- Blur (glass) effect
    local blur = Instance.new("ImageLabel", notif)
    blur.Name = "GlassBlur"
    blur.Size = UDim2.new(1,0,1,0)
    blur.Position = UDim2.new(0,0,0,0)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://13378641210" -- Glass blur texture
    blur.ImageTransparency = 0.72
    blur.ZIndex = 200

    local stroke = notif:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Thickness = 2 stroke.Color = Color3.fromRGB(110,210,160) stroke.Transparency = 0.05 end

    local icon = Instance.new("ImageLabel", notif)
    icon.Name = "NotifIcon"
    icon.Size = UDim2.new(0,22,0,22)
    icon.Position = UDim2.new(0,11,0,12)
    icon.BackgroundTransparency = 1
    icon.Image = opt.Image or "rbxassetid://77339698"
    icon.ZIndex = 203

    local lbl = Instance.new("TextLabel", notif)
    lbl.Name = "NotifText"
    lbl.Position = UDim2.new(0,39,0,3)
    lbl.Size = UDim2.new(1,-49,1,-6)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = (opt.Name and (opt.Name.."\n") or "") .. (opt.Content or "")
    lbl.TextSize = 15
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextStrokeTransparency = 0.75
    lbl.TextStrokeColor3 = Color3.fromRGB(60,80,90)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 204

    notif.Position = UDim2.new(1,48,0,0)
    notif.BackgroundTransparency = 1
    notif.Visible = true

    TweenService:Create(notif, TweenInfo.new(ANIM.NotifFadeIn, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 0.36
    }):Play()
    TweenService:Create(blur, TweenInfo.new(ANIM.NotifFadeIn, Enum.EasingStyle.Quint), {ImageTransparency = 0.72}):Play()
    TweenService:Create(lbl, TweenInfo.new(ANIM.NotifFadeIn, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    local duration = opt.Time or 2.5
    task.spawn(function()
        wait(duration)
        TweenService:Create(notif, TweenInfo.new(ANIM.NotifFadeOut, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1,48,0,0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(lbl, TweenInfo.new(ANIM.NotifFadeOut, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(ANIM.NotifFadeOut, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        wait(ANIM.NotifFadeOut)
        notif:Destroy()
    end)
end

-- Responsive size helper
local function getWindowSize()
    local scr = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local w, h = 540, 380
    if scr.X <= 700 or scr.Y <= 500 then
        w, h = math.max(scr.X*0.96, 260), math.max(scr.Y*0.89, 260)
        w = math.clamp(w, 240, scr.X-8)
        h = math.clamp(h, 200, scr.Y-18)
    end
    return w, h
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
        BackgroundColor3 = COLORS.WindowBg,
    })
    _ui.window = window

    local function setWindowSize()
        local w, h = getWindowSize()
        window.Size = UDim2.new(0, w, 0, h)
    end
    setWindowSize()
    local viewportCon; viewportCon = RunService.RenderStepped:Connect(setWindowSize)
    screenGui.AncestryChanged:Connect(function()
        if not screenGui.Parent and viewportCon then
            viewportCon:Disconnect()
        end
    end)

    local topBar = makeRoundedFrame({
        Name = "TopBar",
        Parent = window,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = COLORS.TopBarBg,
    })
    topBar.ClipsDescendants = true

    local icon = Instance.new("ImageLabel", topBar)
    icon.Name = "GameIcon"
    icon.Size = UDim2.new(0,22,0,22)
    icon.Position = UDim2.new(0,10,0.5,-11)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://9158926514"

    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Name = "Title"
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.Position = UDim2.new(0, 40, 0.5, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = opt.Name or "KevinzHub"
    titleLabel.TextSize = 17
    titleLabel.TextColor3 = COLORS.LabelText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local versionBadge = Instance.new("Frame")
    versionBadge.Name = "VersionBadge"
    versionBadge.Parent = topBar
    versionBadge.BackgroundColor3 = Color3.fromRGB(40, 48, 38)
    versionBadge.BackgroundTransparency = 0.15
    versionBadge.Size = UDim2.new(0, 0, 0, 18)
    versionBadge.AnchorPoint = Vector2.new(0, 0.5)
    versionBadge.Position = UDim2.new(0, 0, 0.5, 0)
    versionBadge.ZIndex = 2
    local badgeCorner = Instance.new("UICorner", versionBadge)
    badgeCorner.CornerRadius = UDim.new(0, 8)

    local versionLabel = Instance.new("TextLabel", versionBadge)
    versionLabel.Name = "Version"
    versionLabel.BackgroundTransparency = 1
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.Text = "v"..KEVINZHUB_VERSION
    versionLabel.TextSize = 12
    versionLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
    versionLabel.TextXAlignment = Enum.TextXAlignment.Center
    versionLabel.TextYAlignment = Enum.TextYAlignment.Center
    versionLabel.Size = UDim2.new(1, -10, 1, 0)
    versionLabel.Position = UDim2.new(0, 5, 0, 0)
    versionLabel.ZIndex = 3

    local badgeOutline = Instance.new("UIStroke", versionBadge)
    badgeOutline.Color = Color3.fromRGB(90, 255, 140)
    badgeOutline.Thickness = 1.2
    badgeOutline.Transparency = 0.2

    task.spawn(function()
        local t = 0
        while versionBadge.Parent do
            t = t + RunService.RenderStepped:Wait()
            local pulse = 0.9 + 0.35 * math.sin(t * 2.5)
            badgeOutline.Color = Color3.fromHSV(0.33, 0.3 + 0.2 * pulse, 1)
            badgeOutline.Thickness = 1.1 + 0.5 * pulse
            badgeOutline.Transparency = 0.15 + 0.2 * (1-pulse)
        end
    end)
    local function updateVersionBadge()
        local titleRight = titleLabel.Position.X.Offset + titleLabel.TextBounds.X
        local badgeWidth = versionLabel.TextBounds.X + 18
        versionBadge.Size = UDim2.new(0, badgeWidth, 0, 18)
        versionBadge.Position = UDim2.new(0, titleRight + 7, 0.5, 0)
    end
    titleLabel:GetPropertyChangedSignal("Text"):Connect(updateVersionBadge)
    versionLabel:GetPropertyChangedSignal("Text"):Connect(updateVersionBadge)
    RunService.RenderStepped:Connect(updateVersionBadge)
    task.defer(updateVersionBadge)

    -- Min/Close (mobile: TouchTap & InputBegan)
    local function buttonInput(btn, callback)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                callback(i)
            end
        end)
        if UserInputService.TouchEnabled then
            btn.TouchTap:Connect(function()
                callback({UserInputType=Enum.UserInputType.Touch})
            end)
        end
    end

    local btnMin = makeRoundedFrame{
        Name = "MinimizeButton", Parent = topBar,
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(1,-56,0.5,-13),
        BackgroundColor3 = COLORS.ButtonBg
    }
    local btnClose = makeRoundedFrame{
        Name = "CloseButton", Parent = topBar,
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(1,-26,0.5,-13),
        BackgroundColor3 = COLORS.ButtonBg
    }
    local btnMinLbl = Instance.new("TextLabel", btnMin)
    btnMinLbl.Size = UDim2.fromScale(1,1)
    btnMinLbl.BackgroundTransparency = 1
    btnMinLbl.Font = Enum.Font.GothamBold
    btnMinLbl.Text = "–"
    btnMinLbl.TextSize = 18
    btnMinLbl.TextColor3 = COLORS.LabelText
    btnMinLbl.TextXAlignment = Enum.TextXAlignment.Center
    btnMinLbl.TextYAlignment = Enum.TextYAlignment.Center
    local btnCloseLbl = Instance.new("TextLabel", btnClose)
    btnCloseLbl.Size = UDim2.fromScale(1,1)
    btnCloseLbl.BackgroundTransparency = 1
    btnCloseLbl.Font = Enum.Font.GothamBold
    btnCloseLbl.Text = "X"
    btnCloseLbl.TextSize = 18
    btnCloseLbl.TextColor3 = COLORS.LabelText
    btnCloseLbl.TextXAlignment = Enum.TextXAlignment.Center
    btnCloseLbl.TextYAlignment = Enum.TextYAlignment.Center
    addBtnAnim(btnClose); addBtnAnim(btnMin)
    buttonInput(btnClose, function()
        playClickSound(btnClose)
        KevinzHub:Destroy()
    end)
    buttonInput(btnMin, function()
        playClickSound(btnMin)
        window.Visible = false
        local rb = makeRoundedFrame{
            Name = "Restore", Parent = screenGui,
            Size = UDim2.new(0,26,0,26),
            Position = UDim2.new(0,14,0,14),
            BackgroundColor3 = COLORS.ButtonBg
        }
        local rbl = Instance.new("ImageLabel", rb)
        rbl.Size = UDim2.fromScale(1,1)
        rbl.BackgroundTransparency = 1
        rbl.Image = "rbxassetid://1912438810"
        rbl.ImageColor3 = COLORS.LabelText
        rbl.ScaleType = Enum.ScaleType.Fit
        addBtnAnim(rb)
        buttonInput(rb, function()
            playClickSound(rb)
            window.Visible=true; rb:Destroy()
        end)
    end)

    -- Drag logic (all window, both mouse & touch)
    do
        local dragging, dragInput, startPos, dragStart
        local function beginDrag(i)
            dragging=true
            dragStart = i.Position
            startPos = window.Position
        end
        local function endDrag()
            dragging=false
        end
        window.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                beginDrag(i); dragInput = i
            end
        end)
        window.InputEnded:Connect(function(i)
            if i == dragInput then endDrag() end
        end)
        window.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                window.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Sidebar + Tabs responsive (unchanged)
    local function getSidebarW() return math.max(54, math.floor(window.AbsoluteSize.X * 0.25)) end
    local sidebarHolder = Instance.new("Frame", window)
    sidebarHolder.Name = "SidebarHolder"
    sidebarHolder.Position = UDim2.new(0,0,0,34)
    sidebarHolder.Size = UDim2.new(0,getSidebarW(),1,-34)
    sidebarHolder.BackgroundTransparency = 1
    sidebarHolder.ClipsDescendants = true
    local sidebar = makeRoundedFrame{
        Name = "Sidebar", Parent = sidebarHolder,
        Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = COLORS.SidebarBg
    }
    sidebar.ClipsDescendants = true
    local pad = Instance.new("UIPadding", sidebar)
    pad.PaddingTop, pad.PaddingLeft = UDim.new(0,8), UDim.new(0,6)
    pad.PaddingRight, pad.PaddingBottom = UDim.new(0,6), UDim.new(0,6)
    window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        sidebarHolder.Size = UDim2.new(0,getSidebarW(),1,-34)
    end)
    local searchBar = Instance.new("TextBox")
    searchBar.Parent = sidebar
    searchBar.Size = UDim2.new(1,-12,0,22)
    searchBar.Position = UDim2.new(0,6,0,3)
    searchBar.PlaceholderText = "Tìm tab..."
    searchBar.Text = ""
    searchBar.BackgroundColor3 = COLORS.ParagraphBg
    searchBar.TextColor3 = COLORS.LabelText
    searchBar.ClearTextOnFocus = true
    searchBar.Font = Enum.Font.Gotham
    searchBar.TextSize = 13
    searchBar.BorderSizePixel = 0
    searchBar.ZIndex = 2
    local searchCorner = Instance.new("UICorner", searchBar)
    searchCorner.CornerRadius = UDim.new(0,6)
    local list = Instance.new("UIListLayout", sidebar)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,6)
    list.Parent = sidebar

    local function renderUserInfo()
        local uf = Instance.new("Frame")
        uf.Name = "UserInfo"
        uf.BackgroundTransparency=1
        uf.AnchorPoint = Vector2.new(0,1)
        uf.Position = UDim2.new(0,6,1,-14)
        uf.Size = UDim2.new(1,-12,0,40)
        uf.Parent = sidebar
        local thumb = ""
        local thumbReady = false
        local av = Instance.new("ImageLabel", uf)
        av.Name="Avatar"; av.Size=UDim2.new(0,28,0,28); av.Position=UDim2.new(0,0,0,3)
        av.BackgroundTransparency=1; av.Image="rbxassetid://77339698"
        coroutine.wrap(function()
            local id = LocalPlayer.UserId
            local img, isReady
            for _=1,10 do
                img, isReady = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                if isReady and typeof(img)=="string" and #img>0 then
                    thumb = img
                    thumbReady = true
                    break
                end
                wait(0.2)
            end
            if thumbReady then av.Image = thumb end
        end)()
        local nm = Instance.new("TextLabel", uf)
        nm.Name="Username"; nm.Size=UDim2.new(1,-34,1,0); nm.Position=UDim2.new(0,32,0,0)
        nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.Text=LocalPlayer.Name
        nm.TextSize=13; nm.TextColor3=COLORS.LabelText; nm.TextXAlignment=Enum.TextXAlignment.Left
        return uf
    end
    local userInfoFrame = renderUserInfo()
    userInfoFrame.LayoutOrder = 1e9
    local tabs = {}
    local tabContents = {}
    local tabOrder = 0
    local scrolling = 0
    local function updateSidebarScroll()
        RunService.Heartbeat:Wait()
        local absContent = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 4
        local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 10
        if absContent > visible then
            sidebar.Position = UDim2.new(0,0,0,-scrolling)
        else
            sidebar.Position = UDim2.new(0,0,0,0)
            scrolling = 0
        end
        userInfoFrame.Position = UDim2.new(0,6,1,-userInfoFrame.Size.Y.Offset-6)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarScroll)
    sidebarHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarScroll)
    sidebarHolder.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local absContent = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset + searchBar.Size.Y.Offset + 4
            local visible = sidebarHolder.AbsoluteSize.Y - userInfoFrame.Size.Y.Offset - 10
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
            tabContents[n].Visible = active
            if active then
                tabContents[n].Position = tabContents[n].Position + UDim2.new(0,0,0,6)
                TweenService:Create(tabContents[n], TweenInfo.new(ANIM.TabMoveTime, Enum.EasingStyle.Quint), {Position=UDim2.new(0,getSidebarW(),0,38)}):Play()
            end
        end
    end

    local Window = {}
    function Window:MakeTab(tabOpt)
        tabOrder = tabOrder + 1
        local btn = makeRoundedFrame{
            Name = tabOpt.Name.."Btn", Parent = sidebar,
            Size = UDim2.new(1,-10,0,36), LayoutOrder = tabOrder,
            BackgroundColor3 = COLORS.TabInactive
        }
        local icon = Instance.new("ImageLabel", btn)
        icon.Name = "TabIcon"
        icon.Size = UDim2.new(0,18,0,18)
        icon.Position = UDim2.new(0,7,0.5,-9)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://11718192673"
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1,-30,1,0)
        lbl.Position = UDim2.new(0,30,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = tabOpt.Name
        lbl.TextSize = 13
        lbl.TextColor3 = COLORS.LabelText
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        addBtnAnim(btn)
        local ct = makeRoundedFrame{
            Name = tabOpt.Name.."Content", Parent = window,
            Position = UDim2.new(0,getSidebarW(),0,38),
            Size = UDim2.new(1,-getSidebarW()-16,1,-46),
            BackgroundColor3 = COLORS.ContentBg,
            Visible = false
        }
        ct.ClipsDescendants = true
        local sectionList = Instance.new("UIListLayout", ct)
        sectionList.SortOrder = Enum.SortOrder.LayoutOrder
        sectionList.Padding = UDim.new(0, 14)
        sectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sectionList.VerticalAlignment = Enum.VerticalAlignment.Top
        tabs[tabOpt.Name], tabContents[tabOpt.Name] = btn, ct
        local function tabClick()
            playClickSound(btn)
            selectTab(tabOpt.Name)
        end
        btn.InputBegan:Connect(function(i)
            if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
                tabClick()
            end
        end)
        if UserInputService.TouchEnabled then
            btn.TouchTap:Connect(tabClick)
        end
        if tabOrder == 1 then selectTab(tabOpt.Name) end
        window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            ct.Position = UDim2.new(0,getSidebarW(),0,38)
            ct.Size = UDim2.new(1,-getSidebarW()-16,1,-46)
        end)
        local Tab = {}
        local sectionOrder = 0
        function Tab:AddSection(secOpt)
            sectionOrder = sectionOrder + 1
            local secFrame = makeRoundedFrame{
                Name = secOpt.Name.."Section", Parent = ct,
                Size = UDim2.new(1,-20,0,0),
                BackgroundColor3 = COLORS.SectionBg,
                LayoutOrder = sectionOrder
            }
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            local itemsList = Instance.new("UIListLayout", secFrame)
            itemsList.SortOrder = Enum.SortOrder.LayoutOrder
            itemsList.Padding = UDim.new(0, 8)
            itemsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
            itemsList.VerticalAlignment = Enum.VerticalAlignment.Top
            local secLbl = Instance.new("TextLabel", secFrame)
            secLbl.Size = UDim2.new(1,-9,0,20)
            secLbl.Position = UDim2.new(0,5,0,4)
            secLbl.BackgroundTransparency = 1
            secLbl.Font = Enum.Font.GothamBold
            secLbl.Text = secOpt.Name
            secLbl.TextSize = 13
            secLbl.TextColor3 = COLORS.LabelText
            secLbl.TextXAlignment = Enum.TextXAlignment.Left
            secLbl.LayoutOrder = 0

            local Section = {}
            local itemOrder = 1
            function Section:AddButton(btnOpt)
                local btn = makeRoundedFrame{
                    Name = btnOpt.Name.."Btn", Parent = secFrame,
                    Size = UDim2.new(0,110,0,26),
                    BackgroundColor3 = COLORS.ButtonBg,
                    LayoutOrder = itemOrder
                }
                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.fromScale(1,1)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = btnOpt.Name
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                addBtnAnim(btn)
                local function btnCallback()
                    playClickSound(btn)
                    if btnOpt.Callback then btnOpt.Callback() end
                end
                btn.InputBegan:Connect(function(i)
                    if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
                        btnCallback()
                    end
                end)
                if UserInputService.TouchEnabled then
                    btn.TouchTap:Connect(btnCallback)
                end
                itemOrder = itemOrder + 1
            end

            function Section:AddSlider(slOpt)
                local sliderW, sliderH = 110, 10
                local labelHeight = 14
                local textboxW = (slOpt.WithTextbox and 36) or 0
                local gap = slOpt.WithTextbox and 7 or 0

                local container = Instance.new("Frame", secFrame)
                container.Name = "SliderContainer"
                container.Size = UDim2.new(1,0,0,sliderH+labelHeight+7)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder

                local lbl = Instance.new("TextLabel", container)
                lbl.Name = "SliderLabel"
                lbl.Size = UDim2.new(1,0,0,labelHeight)
                lbl.Position = UDim2.new(0,0,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = slOpt.Name
                lbl.TextSize = 12
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local sliderBg = makeRoundedFrame{
                    Name = slOpt.Name.."Slider", Parent = container,
                    Position = UDim2.new(0,0,0,labelHeight+1),
                    Size = UDim2.new(0,sliderW,0,sliderH),
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
                sliderKnob.Size = UDim2.new(0,12,0,12)
                sliderKnob.Position = UDim2.new(0,0,0,-1)
                sliderKnob.BackgroundColor3 = COLORS.SliderKnob
                sliderKnob.BorderSizePixel = 0
                local corner = Instance.new("UICorner", sliderKnob)
                corner.CornerRadius = UDim.new(0, 5)
                local val = slOpt.Default or slOpt.Min or 0

                local textbox
                if slOpt.WithTextbox then
                    textbox = Instance.new("TextBox", container)
                    textbox.Size = UDim2.new(0,textboxW,0,labelHeight+7)
                    textbox.Position = UDim2.new(0,sliderW+gap,0,labelHeight)
                    textbox.BackgroundColor3 = COLORS.TextboxBg
                    textbox.TextColor3 = COLORS.LabelText
                    textbox.Font = Enum.Font.Gotham
                    textbox.TextSize = 12
                    textbox.Text = tostring(val)
                    textbox.ClearTextOnFocus = true
                    textbox.PlaceholderText = ""
                    textbox.TextXAlignment = Enum.TextXAlignment.Center
                    textbox.BorderSizePixel = 0
                    local corner = Instance.new("UICorner", textbox)
                    corner.CornerRadius = UDim.new(0,5)
                end

                local function setSlider(v, updateTextboxAndSlider)
                    v = math.clamp(tonumber(v) or slOpt.Min, slOpt.Min, slOpt.Max)
                    val = v
                    local percent = (v-slOpt.Min)/(slOpt.Max-slOpt.Min)
                    sliderFill.Size = UDim2.new(0, percent*sliderBg.Size.X.Offset, 1, 0)
                    sliderKnob.Position = UDim2.new(0, percent*sliderBg.Size.X.Offset-6, 0, -1)
                    if slOpt.WithTextbox and textbox then
                        textbox.Text = tostring(math.floor(v))
                    end
                    if slOpt.Callback then slOpt.Callback(v) end
                end
                setSlider(val,true)
                local draggingSlider = false

                local function sliderInputStart(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        playClickSound(sliderKnob)
                    end
                end
                local function sliderInputEnd(i)
                    if i.UserInputState == Enum.UserInputState.End then
                        draggingSlider = false
                    end
                end
                local function sliderInputChanged(i)
                    if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        local x = math.clamp(i.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                        local v = math.floor(slOpt.Min + (x/sliderBg.AbsoluteSize.X)*(slOpt.Max-slOpt.Min))
                        setSlider(v,true)
                    end
                end
                local function sliderInputClick(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        local x = math.clamp(i.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                        local v = math.floor(slOpt.Min + (x/sliderBg.AbsoluteSize.X)*(slOpt.Max-slOpt.Min))
                        setSlider(v,true)
                        playClickSound(sliderBg)
                    end
                end

                sliderKnob.InputBegan:Connect(sliderInputStart)
                sliderBg.InputEnded:Connect(sliderInputEnd)
                sliderBg.InputChanged:Connect(sliderInputChanged)
                sliderBg.InputBegan:Connect(sliderInputClick)
                if UserInputService.TouchEnabled then
                    sliderKnob.TouchTap:Connect(function()
                        draggingSlider = true
                        playClickSound(sliderKnob)
                    end)
                    sliderBg.TouchTap:Connect(function()
                        local x = math.clamp(UserInputService:GetMouseLocation().X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                        local v = math.floor(slOpt.Min + (x/sliderBg.AbsoluteSize.X)*(slOpt.Max-slOpt.Min))
                        setSlider(v,true)
                        playClickSound(sliderBg)
                    end)
                end

                if slOpt.WithTextbox and textbox then
                    textbox.FocusLost:Connect(function(enter)
                        if enter then
                            setSlider(textbox.Text,true)
                            playClickSound(textbox)
                        end
                    end)
                end

                itemOrder = itemOrder + 1
            end

            function Section:AddToggle(opt)
                local toggleW, toggleH = 32, 16

                local container = Instance.new("Frame", secFrame)
                container.Name = "ToggleContainer"
                container.Size = UDim2.new(1,0,0,toggleH)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder

                local toggleBg = makeRoundedFrame{
                    Name = opt.Name.."ToggleBG", Parent = container,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(0,toggleW,0,toggleH),
                    BackgroundColor3 = COLORS.ToggleBg
                }
                local knob = makeRoundedFrame{
                    Name = "Knob", Parent = toggleBg,
                    Position = UDim2.new(0,2,0,2),
                    Size = UDim2.new(0,12,0,12),
                    BackgroundColor3 = COLORS.ToggleOff
                }
                local on = opt.Default or false
                local function updateAppearance(animated)
                    local targetX = on and (toggleBg.Size.X.Offset - knob.Size.X.Offset - 2) or 2
                    if animated then
                        TweenService:Create(knob, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint), {Position=UDim2.new(0,targetX,0,2)}):Play()
                        TweenService:Create(toggleBg, TweenInfo.new(ANIM.TweenTime, Enum.EasingStyle.Quint),
                            {BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleBg}
                        ):Play()
                    else
                        knob.Position = UDim2.new(0,targetX,0,2)
                        toggleBg.BackgroundColor3 = on and COLORS.ToggleOn or COLORS.ToggleBg
                    end
                    knob.BackgroundColor3 = on and COLORS.ToggleKnobOn or COLORS.ToggleOff
                end
                updateAppearance(false)
                local function toggleInput()
                    on = not on
                    updateAppearance(true)
                    playClickSound(toggleBg)
                    if opt.Callback then opt.Callback(on) end
                end
                toggleBg.InputBegan:Connect(function(i)
                    if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
                        toggleInput()
                    end
                end)
                if UserInputService.TouchEnabled then
                    toggleBg.TouchTap:Connect(toggleInput)
                end
                local toggleLbl = Instance.new("TextLabel", container)
                toggleLbl.Name = "ToggleLabel"
                toggleLbl.Position = UDim2.new(0,toggleW+8,0,0)
                toggleLbl.Size = UDim2.new(0,120,0,toggleH)
                toggleLbl.BackgroundTransparency = 1
                toggleLbl.Font = Enum.Font.Gotham
                toggleLbl.Text = opt.Name
                toggleLbl.TextSize = 13
                toggleLbl.TextColor3 = COLORS.LabelText
                toggleLbl.TextXAlignment = Enum.TextXAlignment.Left

                itemOrder = itemOrder + 1
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
