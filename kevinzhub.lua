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

-- Notification: chỉ dùng notification mặc định Roblox, hỗ trợ truyền icon tùy chọn, mặc định là 11836181348
function KevinzHub:MakeNotification(opt)
    if pcall(function() return game:GetService("StarterGui"):SetCore("SendNotification",{}) end) then
        pcall(function()
            local iconValue = opt.Image
            if iconValue then
                if tostring(iconValue):find("rbxassetid://") then
                    iconValue = tostring(iconValue)
                else
                    iconValue = "rbxassetid://" .. tostring(iconValue)
                end
            else
                iconValue = "rbxassetid://11836181348"
            end
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = opt.Name or "Kevinzhub",
                Text = opt.Content or "",
                Duration = opt.Time or 2.5,
                Icon = iconValue
            })
        end)
    end
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

-- AddTextbox method for Section
local function addTextboxToSection(secFrame, itemOrder, opt)
    local container = Instance.new("Frame", secFrame)
    container.Name = (opt.Name or "Textbox").."Container"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = itemOrder

    local lbl = Instance.new("TextLabel", container)
    lbl.Name = "TextboxLabel"
    lbl.Size = UDim2.new(0, 90, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = opt.Name or "Textbox"
    lbl.TextSize = 13
    lbl.TextColor3 = COLORS.LabelText
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local textbox = Instance.new("TextBox", container)
    textbox.Name = "Textbox"
    textbox.Size = UDim2.new(0, 120, 0, 28)
    textbox.Position = UDim2.new(0, 100, 0.5, -14)
    textbox.BackgroundColor3 = COLORS.TextboxBg
    textbox.TextColor3 = COLORS.LabelText
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 13
    textbox.Text = opt.Default or ""
    textbox.ClearTextOnFocus = true
    textbox.PlaceholderText = opt.PlaceholderText or ""
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.BorderSizePixel = 0
    local corner = Instance.new("UICorner", textbox)
    corner.CornerRadius = UDim.new(0, 6)

    textbox.FocusLost:Connect(function(enter)
        if enter and opt.Callback then
            playClickSound(textbox)
            opt.Callback(textbox.Text)
        end
    end)
    return container
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

    -- Minimize window and show dragable restore button
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
        
        -- Make restore button draggable
        local dragging, dragInput, startPos, dragStart
        rb.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = i.Position
                startPos = rb.Position
                dragInput = i
            end
        end)
        rb.InputEnded:Connect(function(i)
            if i == dragInput then dragging = false end
        end)
        rb.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                rb.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        buttonInput(rb, function()
            playClickSound(rb)
            window.Visible = true
            rb:Destroy()
        end)
    end)
    buttonInput(btnClose, function()
        playClickSound(btnClose)
        KevinzHub:Destroy()
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

            function Section:AddTextbox(opt)
                addTextboxToSection(secFrame, itemOrder, opt)
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

            -- BẮT ĐẦU CÁC HÀM MỚI ADDITIONAL
            function Section:AddLabel(opt)
                local labelFrame = Instance.new("Frame", secFrame)
                labelFrame.Name = "LabelContainer"
                labelFrame.BackgroundTransparency = 1
                labelFrame.Size = UDim2.new(1, 0, 0, 22)
                labelFrame.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local lbl = Instance.new("TextLabel", labelFrame)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamBold
                lbl.Text = typeof(opt)=="table" and (opt.Text or opt) or tostring(opt)
                lbl.TextSize = 13
                lbl.TextColor3 = COLORS.LabelText
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextYAlignment = Enum.TextYAlignment.Center
                lbl.Size = UDim2.new(1, 0, 1, 0)
                return labelFrame
            end

            function Section:AddParagraph(opt)
                local paraFrame = makeRoundedFrame({
                    Parent = secFrame,
                    Name = "Paragraph",
                    BackgroundColor3 = COLORS.ParagraphBg,
                    Size = UDim2.new(1, -10, 0, 48),
                    LayoutOrder = itemOrder
                })
                paraFrame.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local lbl = Instance.new("TextLabel", paraFrame)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.Gotham
                lbl.Text = typeof(opt)=="table" and (opt.Text or opt) or tostring(opt)
                lbl.TextSize = 12
                lbl.TextColor3 = COLORS.ParagraphText
                lbl.TextWrapped = true
                lbl.TextYAlignment = Enum.TextYAlignment.Top
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Size = UDim2.new(1, -8, 1, -8)
                lbl.Position = UDim2.new(0, 4, 0, 4)
                paraFrame.AutomaticSize = Enum.AutomaticSize.Y
                return paraFrame
            end

            function Section:AddDropdown(opt)
                local open = false
                local values = opt.Values or {}
                local selected = opt.Default or values[1]
                local callback = opt.Callback

                local container = Instance.new("Frame", secFrame)
                container.Name = (opt.Name or "Dropdown").."Dropdown"
                container.Size = UDim2.new(0, 180, 0, 36)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1

                if opt.Name then
                    local nameLabel = Instance.new("TextLabel", container)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Font = Enum.Font.Gotham
                    nameLabel.Text = opt.Name
                    nameLabel.TextSize = 13
                    nameLabel.TextColor3 = COLORS.LabelText
                    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    nameLabel.Size = UDim2.new(1, 0, 0, 16)
                    nameLabel.Position = UDim2.new(0, 0, 0, -18)
                end

                local mainBtn = makeRoundedFrame{
                    Name = "DropdownMain", Parent = container,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = COLORS.DropdownBG
                }
                addBtnAnim(mainBtn)

                local label = Instance.new("TextLabel", mainBtn)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.Text = tostring(selected)
                label.TextSize = 14
                label.TextColor3 = COLORS.LabelText
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextYAlignment = Enum.TextYAlignment.Center
                label.Size = UDim2.new(1, -32, 1, 0)
                label.Position = UDim2.new(0, 8, 0, 0)
                label.ClipsDescendants = false

                local arrow = Instance.new("ImageLabel", mainBtn)
                arrow.Image = "rbxassetid://6034818371"
                arrow.BackgroundTransparency = 1
                arrow.Size = UDim2.new(0,16,0,16)
                arrow.Position = UDim2.new(1, -22, 0.5, -8)
                arrow.ImageColor3 = COLORS.LabelText

                local menu = makeRoundedFrame{
                    Name = "DropdownMenu", Parent = container,
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = COLORS.DropdownBG,
                    Visible = false
                }
                menu.Position = UDim2.new(0,0,1,2)
                menu.ZIndex = 10
                menu.ClipsDescendants = true
                menu.AutomaticSize = Enum.AutomaticSize.Y

                local list = Instance.new("UIListLayout", menu)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Padding = UDim.new(0, 6)

                local function updateDropdownItems(newVals)
                    values = newVals or values
                    for _,c in pairs(menu:GetChildren()) do
                        if c:IsA("Frame") then c:Destroy() end
                    end
                    for idx, v in ipairs(values) do
                        local item = makeRoundedFrame{
                            Name = tostring(v).."Item", Parent = menu,
                            Size = UDim2.new(1,0,0,32),
                            BackgroundColor3 = COLORS.DropdownBG
                        }
                        addBtnAnim(item)

                        local padding = Instance.new("UIPadding", item)
                        padding.PaddingLeft = UDim.new(0, 12)
                        padding.PaddingRight = UDim.new(0, 8)

                        local lbl = Instance.new("TextLabel", item)
                        lbl.BackgroundTransparency = 0 -- ĐẢM BẢO LABEL HIỆN
                        lbl.Font = Enum.Font.Gotham
                        lbl.Text = tostring(v)
                        lbl.TextSize = 14
                        lbl.TextColor3 = COLORS.LabelText
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.TextYAlignment = Enum.TextYAlignment.Center
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.Position = UDim2.new(0, 0, 0, 0)
                        lbl.ClipsDescendants = false

                        item.LayoutOrder = idx

                        item.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                                selected = v
                                label.Text = tostring(v)
                                menu.Visible = false
                                open = false
                                if callback then callback(selected) end
                                playClickSound(item)
                            end
                        end)
                    end
                end

                updateDropdownItems(values)

                local function toggleMenu(state)
                    open = (state ~= nil) and state or not open
                    menu.Visible = open
                    TweenService:Create(mainBtn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {
                        BackgroundColor3 = open and COLORS.DropdownHover or COLORS.DropdownBG
                    }):Play()
                    TweenService:Create(arrow, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {
                        Rotation = open and 180 or 0
                    }):Play()
                end

                mainBtn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        toggleMenu()
                        playClickSound(mainBtn)
                    end
                end)
                if UserInputService.TouchEnabled then
                    mainBtn.TouchTap:Connect(function()
                        toggleMenu()
                        playClickSound(mainBtn)
                    end)
                end

                local function dismissMenuOnClick()
                    if not open then return end
                    menu.Visible = false
                    open = false
                    TweenService:Create(mainBtn, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {
                        BackgroundColor3 = COLORS.DropdownBG
                    }):Play()
                    TweenService:Create(arrow, TweenInfo.new(ANIM.FadeTime, Enum.EasingStyle.Quint), {
                        Rotation = 0
                    }):Play()
                end
                UserInputService.InputBegan:Connect(function(input, isProcessed)
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UserInputService:GetMouseLocation()
                        local absPos = menu.AbsolutePosition
                        local absSize = menu.AbsoluteSize
                        if mouse.X < absPos.X or mouse.X > absPos.X + absSize.X or mouse.Y < absPos.Y or mouse.Y > absPos.Y + absSize.Y then
                            dismissMenuOnClick()
                        end
                    end
                end)

                local dropdown = {}
                dropdown.Container = container
                function dropdown:GetSelected()
                    return selected
                end
                function dropdown:UpdateValues(newVals)
                    updateDropdownItems(newVals)
                end
                setmetatable(dropdown, {__index = container})
                return dropdown
            end
            
            function Section:AddColorPicker(opt)
                local container = Instance.new("Frame", secFrame)
                container.Name = "ColorPickerContainer"
                container.Size = UDim2.new(0, 150, 0, 36)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1

                local label = Instance.new("TextLabel", container)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.Text = opt.Name or "Color"
                label.TextSize = 13
                label.TextColor3 = COLORS.LabelText
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Size = UDim2.new(0.65, 0, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)

                local colorBtn = makeRoundedFrame{
                    Name = "ColorButton", Parent = container,
                    Size = UDim2.new(0,36,0,28),
                    Position = UDim2.new(1,-40,0.5,-14),
                    BackgroundColor3 = opt.Default or Color3.new(1,1,1)
                }
                addBtnAnim(colorBtn)
                local curColor = opt.Default or Color3.new(1,1,1)
                local callback = opt.Callback

                colorBtn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        -- Đơn giản chỉ đổi màu, có thể thay bằng popup ColorPicker nâng cao nếu cần
                        local nextColor = Color3.fromRGB(
                            math.random(0,255),
                            math.random(0,255),
                            math.random(0,255)
                        )
                        colorBtn.BackgroundColor3 = nextColor
                        curColor = nextColor
                        if callback then callback(nextColor) end
                        playClickSound(colorBtn)
                    end
                end)
                return container
            end

            function Section:AddImage(opt)
                local container = Instance.new("Frame", secFrame)
                container.Name = "ImageContainer"
                container.BackgroundTransparency = 1
                container.Size = UDim2.new(0, opt.Width or 80, 0, opt.Height or 80)
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local img = Instance.new("ImageLabel", container)
                img.Name = "Image"
                img.Size = UDim2.new(1, 0, 1, 0)
                img.BackgroundTransparency = 1
                img.Image = opt.Image or "rbxassetid://77339698"
                img.ImageColor3 = opt.ImageColor3 or Color3.new(1,1,1)
                img.ScaleType = Enum.ScaleType.Fit
                return container
            end

            function Section:AddKeybind(opt)
                local container = Instance.new("Frame", secFrame)
                container.Name = "KeybindContainer"
                container.Size = UDim2.new(0, 130, 0, 26)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local label = Instance.new("TextLabel", container)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.Text = opt.Name or "Keybind"
                label.TextSize = 13
                label.TextColor3 = COLORS.LabelText
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Size = UDim2.new(0.6, 0, 1, 0)

                local btn = makeRoundedFrame{
                    Name = "KeybindBtn", Parent = container,
                    Size = UDim2.new(0,54,1,0),
                    Position = UDim2.new(1,-56,0,0),
                    BackgroundColor3 = COLORS.ButtonBg
                }
                local btnLbl = Instance.new("TextLabel", btn)
                btnLbl.BackgroundTransparency = 1
                btnLbl.Font = Enum.Font.Gotham
                btnLbl.Text = "[None]"
                btnLbl.TextSize = 12
                btnLbl.TextColor3 = COLORS.LabelText
                btnLbl.TextXAlignment = Enum.TextXAlignment.Center
                btnLbl.Size = UDim2.fromScale(1,1)
                local binding = false
                local key = opt.Default
                local callback = opt.Callback

                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        binding = true
                        btnLbl.Text = "[...]"
                        playClickSound(btn)
                    end
                end)
                UserInputService.InputBegan:Connect(function(i,gp)
                    if binding and not gp then
                        binding = false
                        key = i.KeyCode
                        btnLbl.Text = "["..(key.Name or tostring(key)).."]"
                        if callback then callback(key) end
                    elseif not binding and key and i.KeyCode==key and not gp then
                        if callback then callback(key, true) end
                    end
                end)
                return container
            end

            function Section:AddListbox(opt)
                local container = Instance.new("Frame", secFrame)
                container.Name = "ListboxContainer"
                container.Size = UDim2.new(0, opt.Width or 140, 0, opt.Height or 84)
                container.BackgroundColor3 = COLORS.ParagraphBg
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local list = Instance.new("UIListLayout", container)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Padding = UDim.new(0,2)
                for i,v in ipairs(opt.Items or {}) do
                    local it = Instance.new("TextLabel", container)
                    it.BackgroundTransparency = 1
                    it.Font = Enum.Font.Gotham
                    it.Text = tostring(v)
                    it.TextSize = 12
                    it.TextColor3 = COLORS.ParagraphText
                    it.TextXAlignment = Enum.TextXAlignment.Left
                    it.LayoutOrder = i
                    it.Size = UDim2.new(1,0,0,20)
                end
                return container
            end

            function Section:AddTable(opt)
                local rows = opt.Rows or {}
                local cols = opt.Columns or {}
                local container = Instance.new("Frame", secFrame)
                container.Name = "TableContainer"
                container.Size = UDim2.new(0, opt.Width or 200, 0, 24 + #rows*24)
                container.BackgroundColor3 = COLORS.ParagraphBg
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local head = Instance.new("Frame", container)
                head.Name = "Header"
                head.Size = UDim2.new(1,0,0,24)
                head.BackgroundTransparency = 1
                for i,c in ipairs(cols) do
                    local col = Instance.new("TextLabel", head)
                    col.BackgroundTransparency = 1
                    col.Font = Enum.Font.GothamBold
                    col.Text = tostring(c)
                    col.TextSize = 12
                    col.TextColor3 = COLORS.LabelText
                    col.TextXAlignment = Enum.TextXAlignment.Left
                    col.Size = UDim2.new(1/#cols, -4, 1, 0)
                    col.Position = UDim2.new((i-1)/#cols, 2, 0, 0)
                end
                for r, row in ipairs(rows) do
                    local rowFrame = Instance.new("Frame", container)
                    rowFrame.Name = "Row"..r
                    rowFrame.Size = UDim2.new(1,0,0,22)
                    rowFrame.Position = UDim2.new(0,0,0,24*r)
                    rowFrame.BackgroundTransparency = 1
                    for i,c in ipairs(cols) do
                        local cell = Instance.new("TextLabel", rowFrame)
                        cell.BackgroundTransparency = 1
                        cell.Font = Enum.Font.Gotham
                        cell.Text = tostring(row[i] or "")
                        cell.TextSize = 12
                        cell.TextColor3 = COLORS.ParagraphText
                        cell.TextXAlignment = Enum.TextXAlignment.Left
                        cell.Size = UDim2.new(1/#cols, -4, 1, 0)
                        cell.Position = UDim2.new((i-1)/#cols, 2, 0, 0)
                        cell.TextWrapped = true
                    end
                end
                return container
            end

            function Section:AddRadio(opt)
                local values = opt.Values or {}
                local default = opt.Default or 1
                local callback = opt.Callback
                local container = Instance.new("Frame", secFrame)
                container.Name = "RadioContainer"
                container.Size = UDim2.new(0, 145, 0, 18 + #values*26)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local sel = default
                for i, v in ipairs(values) do
                    local btn = makeRoundedFrame{
                        Parent = container, Name = "Radio"..i,
                        Size = UDim2.new(0,18,0,18),
                        BackgroundColor3 = COLORS.ButtonBg,
                        Position = UDim2.new(0, 0, 0, 20+(i-1)*26)
                    }
                    addBtnAnim(btn)
                    local dot = Instance.new("Frame", btn)
                    dot.Name = "Dot"
                    dot.Size = UDim2.new(0.6,0,0.6,0)
                    dot.Position = UDim2.new(0.2,0,0.2,0)
                    dot.BackgroundColor3 = COLORS.TabActive
                    dot.BackgroundTransparency = (i==sel) and 0 or 1
                    dot.BorderSizePixel = 0
                    local lbl = Instance.new("TextLabel", container)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.Gotham
                    lbl.Text = tostring(v)
                    lbl.TextSize = 13
                    lbl.TextColor3 = COLORS.LabelText
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Position = UDim2.new(0, 24, 0, 20+(i-1)*26)
                    lbl.Size = UDim2.new(1, -26, 0, 18)
                    btn.InputBegan:Connect(function(ev)
                        if ev.UserInputType == Enum.UserInputType.MouseButton1 or ev.UserInputType == Enum.UserInputType.Touch then
                            sel = i
                            for j,child in ipairs(container:GetChildren()) do
                                if child:IsA("Frame") and child:FindFirstChild("Dot") then
                                    child.Dot.BackgroundTransparency = (j-1)==sel and 0 or 1
                                end
                            end
                            if callback then callback(i, v) end
                            playClickSound(btn)
                        end
                    end)
                end
                return container
            end

            function Section:AddProgressbar(opt)
                local width = opt.Width or 120
                local height = opt.Height or 12
                local value = opt.Value or 0
                local min, max = opt.Min or 0, opt.Max or 100
                local container = Instance.new("Frame", secFrame)
                container.Name = "ProgressbarContainer"
                container.Size = UDim2.new(0, width, 0, height+12)
                container.BackgroundTransparency = 1
                container.LayoutOrder = itemOrder
                itemOrder = itemOrder + 1
                local bg = makeRoundedFrame{
                    Parent=container, Size=UDim2.new(1,0,0,height), Position=UDim2.new(0,0,0,6),
                    BackgroundColor3 = COLORS.SliderTrack
                }
                local fill = makeRoundedFrame{
                    Parent=bg, Size=UDim2.new((value-min)/(max-min),0,1,0), Position=UDim2.new(0,0,0,0),
                    BackgroundColor3 = COLORS.TabActive
                }
                fill.Name = "Fill"
                local percentLbl = Instance.new("TextLabel", container)
                percentLbl.BackgroundTransparency = 1
                percentLbl.Font = Enum.Font.Gotham
                percentLbl.Text = string.format("%d%%", (value-min)*100/(max-min))
                percentLbl.TextSize = 11
                percentLbl.TextColor3 = COLORS.LabelText
                percentLbl.Size = UDim2.new(1,0,0,10)
                percentLbl.Position = UDim2.new(0,0,0,0)
                function container:SetValue(v)
                    v = math.clamp(v, min, max)
                    fill.Size = UDim2.new((v-min)/(max-min),0,1,0)
                    percentLbl.Text = string.format("%d%%", (v-min)*100/(max-min))
                end
                return container
            end

            function Section:UpdateLabel(labelFrame, newText)
                if labelFrame and labelFrame:IsA("Frame") then
                    local lbl = labelFrame:FindFirstChildWhichIsA("TextLabel")
                    if lbl then lbl.Text = newText end
                end
            end

            function Section:UpdateDropdown(dropdownFrame, newValues)
                if dropdownFrame and typeof(dropdownFrame.UpdateValues)=="function" then
                    dropdownFrame:UpdateValues(newValues)
                end
            end

            function Section:UpdateImage(imgFrame, newUrl)
                if imgFrame and imgFrame:IsA("Frame") then
                    local img = imgFrame:FindFirstChild("Image")
                    if img then img.Image = newUrl end
                end
            end

            function Section:SetVisible(item, vis)
                if typeof(item)=="Instance" then
                    item.Visible = (vis==nil and true) or vis
                end
            end
            -- KẾT THÚC CÁC HÀM MỚI ADDITIONAL

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
