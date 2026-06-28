-- KevinzHub UI v3.2 - Fix AddLog & tối ưu
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local C = {
    Bg      = Color3.fromRGB(18,18,22), Top = Color3.fromRGB(24,24,30),
    Side    = Color3.fromRGB(22,23,28), Cont = Color3.fromRGB(20,22,26),
    Stroke  = Color3.fromRGB(40,40,55), Text = Color3.fromRGB(220,220,235),
    SecBg   = Color3.fromRGB(28,30,36), BtnBg = Color3.fromRGB(38,40,50),
    BtnHov  = Color3.fromRGB(55,60,80), BtnPrs = Color3.fromRGB(35,40,75),
    TogOn   = Color3.fromRGB(52,199,89), TogOff = Color3.fromRGB(58,58,70),
    SlTr    = Color3.fromRGB(50,52,62), SlFill = Color3.fromRGB(52,199,89),
    TabAct  = Color3.fromRGB(52,199,89), TabIn = Color3.fromRGB(35,37,44),
    LogBg   = Color3.fromRGB(26,28,34), Gold = Color3.fromRGB(255,215,0)
}
local V = "3.2"
local T = {Fade=0.15, Tween=0.18, Press=0.06}

local function Rounded(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k] = v end
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", f).Color, Instance.new("UIStroke", f).Thickness = C.Stroke, 1.2
    return f
end

local function iOSBtn(btn, bg, hov, prs)
    local hl = Instance.new("Frame", btn)
    hl.BackgroundTransparency, hl.Size, hl.ZIndex = 1, UDim2.new(1,0,1,0), 99
    Instance.new("UICorner", hl).CornerRadius = UDim.new(0,10)
    local function anim(to, tr)
        TweenService:Create(btn, TweenInfo.new(T.Fade, Enum.EasingStyle.Quint), {BackgroundColor3=to}):Play()
        TweenService:Create(hl, TweenInfo.new(T.Fade, Enum.EasingStyle.Quint), {BackgroundTransparency=tr}):Play()
    end
    btn.MouseEnter:Connect(function() anim(hov or bg, 0.88) end)
    btn.MouseLeave:Connect(function() anim(bg, 1) end)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            anim(prs, 0.75)
            local snd = Instance.new("Sound"); snd.SoundId = "rbxassetid://535716488"; snd.Volume = 1; snd.Parent = btn; snd:Play()
            task.delay(0.1, function() snd:Destroy() end)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            anim(bg, 1)
        end
    end)
end

local function dragify(obj)
    local drag, start, pos, input
    obj.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag, start, pos, input = true, i.Position, obj.Position, i
        end
    end)
    obj.InputEnded:Connect(function(i) if i==input then drag=false end end)
    obj.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - start
            obj.Position = UDim2.new(pos.X.Scale, pos.X.Offset+d.X, pos.Y.Scale, pos.Y.Offset+d.Y)
        end
    end)
end

local KevinzHub = {}
local UI = {}

local function createMiniConsole(sidebar)
    local con = Rounded{
        Name="Console", Parent=sidebar, Size=UDim2.new(1,-8,0,24), BackgroundColor3=C.LogBg,
        Position=UDim2.new(0,4,1,-30), LayoutOrder=999
    }
    local logs = {}
    local open = false
    local scroll = Rounded{
        Name="LogScroll", Parent=con, Visible=false, Size=UDim2.new(1,-4,0,100), Position=UDim2.new(0,2,0,26),
        BackgroundColor3=C.LogBg, ClipsDescendants=true, ZIndex=5
    }
    local list = Instance.new("UIListLayout", scroll)
    list.SortOrder, list.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,2)

    local toggle = Instance.new("TextButton", con)
    toggle.Text, toggle.Font, toggle.TextSize, toggle.TextColor3 = "▼ Console", Enum.Font.GothamBold, 12, C.Text
    toggle.BackgroundTransparency, toggle.Size, toggle.Position = 1, UDim2.new(1,-20,0,24), UDim2.new(0,4,0,0)
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    local arrow = Instance.new("ImageLabel", con)
    arrow.Image, arrow.BackgroundTransparency, arrow.Size, arrow.Position = "rbxassetid://6034818371", 1, UDim2.new(0,14,0,14), UDim2.new(1,-18,0.5,-7)
    arrow.ImageColor3 = C.Text

    toggle.MouseButton1Click:Connect(function()
        open = not open
        scroll.Visible = open
        arrow.Rotation = open and 180 or 0
        con.Size = open and UDim2.new(1,-8,0,24+math.min(#logs*22+8, 120)) or UDim2.new(1,-8,0,24)
    end)

    -- Trả về table có AddLog
    local consoleObj = {}
    function consoleObj:AddLog(text, color)
        table.insert(logs, text)
        local lbl = Instance.new("TextLabel", scroll)
        lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = text, Enum.Font.Code, 11, color or C.Text
        lbl.BackgroundTransparency, lbl.Size, lbl.TextXAlignment = 1, UDim2.new(1,0,0,22), Enum.TextXAlignment.Left
        lbl.LayoutOrder = #logs
        if open then
            con.Size = UDim2.new(1,-8,0,24+math.min(#logs*22+8, 120))
        end
    end
    consoleObj.Frame = con
    return consoleObj
end

function KevinzHub:MakeWindow(opt)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior, gui.Parent = "KevinzHubUI", false, Enum.ZIndexBehavior.Global, PlayerGui
    UI.screenGui = gui

    local win = Rounded{
        Name="Main", Parent=gui, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.new(0,560,0,390), BackgroundColor3=C.Bg
    }
    UI.window = win
    dragify(win)

    local top = Rounded{Name="Top", Parent=win, Size=UDim2.new(1,0,0,36), BackgroundColor3=C.Top}
    local title = Instance.new("TextLabel", top)
    title.Text, title.Font, title.TextSize, title.TextColor3 = opt.Name or "KevinzHub", Enum.Font.GothamBold, 18, C.Text
    title.BackgroundTransparency, title.Position, title.Size = 1, UDim2.new(0,44,0.5,-10), UDim2.new(0,200,0,20)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local badge = Rounded{
        Name="Version", Parent=top, Size=UDim2.new(0,0,0,20), Position=UDim2.new(0,44,0.5,-10),
        BackgroundColor3=C.Gold, BackgroundTransparency=0.25
    }
    local badgeTxt = Instance.new("TextLabel", badge)
    badgeTxt.Text, badgeTxt.Font, badgeTxt.TextSize, badgeTxt.TextColor3 = "v"..V, Enum.Font.GothamBold, 11, C.Gold
    badgeTxt.BackgroundTransparency, badgeTxt.Size, badgeTxt.TextXAlignment = 1, UDim2.new(1,-6,1,0), Enum.TextXAlignment.Center
    badgeTxt.Position = UDim2.new(0,3,0,0)
    local shimmer = Instance.new("Frame", badge)
    shimmer.BackgroundColor3, shimmer.BorderSizePixel = Color3.fromRGB(255,255,200), 0
    shimmer.Size, shimmer.Position, shimmer.BackgroundTransparency = UDim2.new(0,8,1,0), UDim2.new(0,-10,0,0), 0.7
    Instance.new("UICorner", shimmer).CornerRadius = UDim.new(0,4)
    task.spawn(function()
        while badge.Parent do
            shimmer.Position = UDim2.new(0,-10,0,0)
            TweenService:Create(shimmer, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {Position=UDim2.new(0,badge.Size.X.Offset+10,0,0)}):Play()
            task.wait(0.8)
        end
    end)
    title:GetPropertyChangedSignal("Text"):Connect(function()
        badge.Position = UDim2.new(0, title.Position.X.Offset + title.TextBounds.X + 8, 0.5, -10)
        badge.Size = UDim2.new(0, badgeTxt.TextBounds.X + 14, 0, 20)
    end)

    local function topBtn(text, posX, cb)
        local btn = Rounded{Name=text, Parent=top, Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,posX,0.5,-14), BackgroundColor3=C.BtnBg}
        local lbl = Instance.new("TextLabel", btn)
        lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = text, Enum.Font.GothamBold, 16, C.Text
        lbl.BackgroundTransparency, lbl.Size, lbl.TextXAlignment, lbl.TextYAlignment = 1, UDim2.fromScale(1,1), Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
        iOSBtn(btn, C.BtnBg, C.BtnHov, C.BtnPrs)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then cb() end
        end)
        if UserInputService.TouchEnabled then btn.TouchTap:Connect(cb) end
        return btn
    end
    topBtn("–", -62, function()
        win.Visible = false
        local rest = Rounded{Name="Restore", Parent=gui, Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,12,0,12), BackgroundColor3=C.BtnBg}
        local img = Instance.new("ImageLabel", rest)
        img.Image, img.BackgroundTransparency, img.Size, img.ScaleType = "rbxassetid://1912438810", 1, UDim2.fromScale(1,1), Enum.ScaleType.Fit
        img.ImageColor3 = C.Text
        iOSBtn(rest, C.BtnBg, C.BtnHov, C.BtnPrs); dragify(rest)
        rest.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then win.Visible=true rest:Destroy() end
        end)
        if UserInputService.TouchEnabled then rest.TouchTap:Connect(function() win.Visible=true rest:Destroy() end) end
    end)
    topBtn("✕", -30, function()
        KevinzHub:Destroy()
        print("[KevinzHub] UI Destroyed | Version "..V)
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="KevinzHub", Text="UI da tat hoan toan", Duration=2, Icon="rbxassetid://11836181348"})
    end)

    local sbHolder = Instance.new("Frame", win)
    sbHolder.Name, sbHolder.BackgroundTransparency, sbHolder.Position, sbHolder.Size = "SidebarHolder", 1, UDim2.new(0,0,0,36), UDim2.new(0,160,1,-36)
    local sidebar = Rounded{Name="Sidebar", Parent=sbHolder, Size=UDim2.new(1,0,1,0), BackgroundColor3=C.Side}
    sidebar.ClipsDescendants = true
    local pad = Instance.new("UIPadding", sidebar)
    pad.PaddingTop, pad.PaddingLeft, pad.PaddingRight = UDim.new(0,8), UDim.new(0,6), UDim.new(0,6)
    local sList = Instance.new("UIListLayout", sidebar)
    sList.SortOrder, sList.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,6)

    local userFrame = Instance.new("Frame", sidebar)
    userFrame.Name, userFrame.BackgroundTransparency, userFrame.Size, userFrame.LayoutOrder = "User", 1, UDim2.new(1,0,0,40), 0
    local avatar = Instance.new("ImageLabel", userFrame)
    avatar.Name, avatar.Size, avatar.Position = "Avatar", UDim2.new(0,32,0,32), UDim2.new(0,0,0,4)
    avatar.BackgroundTransparency, avatar.Image = 1, "rbxassetid://77339698"
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(0,16)
    task.spawn(function()
        local ok, img = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        if ok and img then avatar.Image = img end
    end)
    local username = Instance.new("TextLabel", userFrame)
    username.Text, username.Font, username.TextSize, username.TextColor3 = LocalPlayer.Name, Enum.Font.GothamBold, 13, C.Text
    username.BackgroundTransparency, username.Position, username.Size = 1, UDim2.new(0,38,0,10), UDim2.new(1,-44,0,20)
    username.TextXAlignment = Enum.TextXAlignment.Left

    local search = Instance.new("TextBox", sidebar)
    search.Name, search.PlaceholderText, search.Text = "Search", "  🔍  Tim tab...", ""
    search.Size, search.LayoutOrder = UDim2.new(1,-8,0,24), 1
    search.BackgroundColor3, search.TextColor3, search.Font, search.TextSize = C.SecBg, C.Text, Enum.Font.Gotham, 13
    search.ClearTextOnFocus, search.BorderSizePixel = false, 0
    Instance.new("UICorner", search).CornerRadius = UDim.new(0,8)

    -- Gán console table, không phải Frame
    UI.console = createMiniConsole(sidebar)

    -- Tự log (bây giờ an toàn)
    KevinzHub:Log("System", "KevinzHub UI v"..V.." da san sang", Color3.fromRGB(144,238,144))
    KevinzHub:Log("Core", "Keo tha & responsive hoat dong", Color3.fromRGB(173,216,230))

    local tabs, contents = {}, {}
    local activeTab = nil
    local function selectTab(name)
        for n,btn in pairs(tabs) do
            local isActive = (n==name)
            TweenService:Create(btn, TweenInfo.new(T.Tween, Enum.EasingStyle.Quint), {BackgroundColor3 = isActive and C.TabAct or C.TabIn}):Play()
            if contents[n] then contents[n].Visible = isActive end
        end
        activeTab = name
    end
    search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = search.Text:lower()
        for n,btn in pairs(tabs) do btn.Visible = (q=="" or n:lower():find(q,1,true)) end
    end)

    local contentArea = Instance.new("Frame", win)
    contentArea.Name, contentArea.BackgroundTransparency, contentArea.ClipsDescendants = "ContentArea", 1, true
    contentArea.Position, contentArea.Size = UDim2.new(0,164,0,38), UDim2.new(1,-172,1,-46)

    local Window = {}
    function Window:MakeTab(tabOpt)
        local btn = Rounded{Name=tabOpt.Name.."Tab", Parent=sidebar, Size=UDim2.new(1,-8,0,32), LayoutOrder=#tabs+2, BackgroundColor3=C.TabIn}
        iOSBtn(btn, C.TabIn, C.TabAct, C.TabAct)
        local lbl = Instance.new("TextLabel", btn)
        lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = tabOpt.Name, Enum.Font.GothamBold, 13, C.Text
        lbl.BackgroundTransparency, lbl.Size, lbl.Position, lbl.TextXAlignment = 1, UDim2.new(1,-30,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Left
        local icon = Instance.new("ImageLabel", btn)
        icon.Image, icon.BackgroundTransparency, icon.Size, icon.Position = "rbxassetid://11718192673", 1, UDim2.new(0,16,0,16), UDim2.new(1,-22,0.5,-8)
        icon.ImageColor3 = C.Text

        local page = Rounded{Name=tabOpt.Name.."Page", Parent=contentArea, Size=UDim2.new(1,0,1,0), BackgroundColor3=C.Cont, Visible=false}
        page.ClipsDescendants = true
        local sList = Instance.new("UIListLayout", page)
        sList.SortOrder, sList.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,10)
        sList.HorizontalAlignment, sList.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top
        tabs[tabOpt.Name], contents[tabOpt.Name] = btn, page

        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then selectTab(tabOpt.Name) end
        end)
        if UserInputService.TouchEnabled then btn.TouchTap:Connect(function() selectTab(tabOpt.Name) end) end
        if #tabs==1 then selectTab(tabOpt.Name) end

        local Tab = {}
        function Tab:AddSection(secOpt)
            local sec = Rounded{Name=secOpt.Name.."Section", Parent=page, Size=UDim2.new(1,-16,0,0), BackgroundColor3=C.SecBg, LayoutOrder=#tabs+1}
            sec.AutomaticSize = Enum.AutomaticSize.Y
            local items = Instance.new("UIListLayout", sec)
            items.SortOrder, items.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,8)
            local secTitle = Instance.new("TextLabel", sec)
            secTitle.Text, secTitle.Font, secTitle.TextSize, secTitle.TextColor3 = secOpt.Name, Enum.Font.GothamBold, 13, C.Text
            secTitle.BackgroundTransparency, secTitle.Size, secTitle.Position = 1, UDim2.new(1,-10,0,22), UDim2.new(0,6,0,4)
            secTitle.TextXAlignment = Enum.TextXAlignment.Left
            secTitle.LayoutOrder = 0

            local Section = {Frame=sec}
            local order = 1

            function Section:AddButton(opt)
                local btn = Rounded{Name=opt.Name.."Btn", Parent=sec, Size=UDim2.new(0,120,0,30), BackgroundColor3=C.BtnBg, LayoutOrder=order}
                order += 1
                local lbl = Instance.new("TextLabel", btn)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Name, Enum.Font.GothamBold, 13, C.Text
                lbl.BackgroundTransparency, lbl.Size, lbl.TextXAlignment = 1, UDim2.fromScale(1,1), Enum.TextXAlignment.Center
                iOSBtn(btn, C.BtnBg, C.BtnHov, C.BtnPrs)
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        if opt.Callback then opt.Callback() end
                    end
                end)
                if UserInputService.TouchEnabled then btn.TouchTap:Connect(function() if opt.Callback then opt.Callback() end end) end
                return btn
            end

            function Section:AddToggle(opt)
                local container = Instance.new("Frame", sec)
                container.BackgroundTransparency, container.Size, container.LayoutOrder = 1, UDim2.new(1,0,0,28), order
                order += 1
                local bg = Rounded{Name="ToggleBG", Parent=container, Size=UDim2.new(0,44,0,26), Position=UDim2.new(0,0,0.5,-13), BackgroundColor3=opt.Default and C.TogOn or C.TogOff}
                local knob = Rounded{Name="Knob", Parent=bg, Size=UDim2.new(0,22,0,22), Position=UDim2.new(0,1,0,1), BackgroundColor3=Color3.fromRGB(255,255,255)}
                local state = opt.Default or false
                local function update(anim)
                    local targetX = state and (bg.Size.X.Offset - knob.Size.X.Offset - 1) or 1
                    if anim then
                        TweenService:Create(knob, TweenInfo.new(T.Tween, Enum.EasingStyle.Quart), {Position=UDim2.new(0,targetX,0,1)}):Play()
                        TweenService:Create(bg, TweenInfo.new(T.Tween, Enum.EasingStyle.Quart), {BackgroundColor3=state and C.TogOn or C.TogOff}):Play()
                    else
                        knob.Position, bg.BackgroundColor3 = UDim2.new(0,targetX,0,1), state and C.TogOn or C.TogOff
                    end
                end
                update(false)
                local lbl = Instance.new("TextLabel", container)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Name, Enum.Font.Gotham, 13, C.Text
                lbl.BackgroundTransparency, lbl.Position, lbl.Size, lbl.TextXAlignment = 1, UDim2.new(0,52,0,0), UDim2.new(0,120,1,0), Enum.TextXAlignment.Left
                bg.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        state = not state; update(true)
                        if opt.Callback then opt.Callback(state) end
                    end
                end)
                if UserInputService.TouchEnabled then bg.TouchTap:Connect(function() state = not state; update(true); if opt.Callback then opt.Callback(state) end end) end
                return container
            end

            function Section:AddSlider(opt)
                local w, h = 130, 8
                local container = Instance.new("Frame", sec)
                container.BackgroundTransparency, container.Size, container.LayoutOrder = 1, UDim2.new(1,0,0,28), order
                order += 1
                local lbl = Instance.new("TextLabel", container)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Name, Enum.Font.Gotham, 12, C.Text
                lbl.BackgroundTransparency, lbl.Size, lbl.Position = 1, UDim2.new(0,100,0,10), UDim2.new(0,0,0,0)
                local track = Rounded{Name="Track", Parent=container, Size=UDim2.new(0,w,0,h), Position=UDim2.new(0,0,0,14), BackgroundColor3=C.SlTr}
                local fill = Rounded{Name="Fill", Parent=track, Size=UDim2.new(0,0,1,0), BackgroundColor3=C.SlFill}
                local knob = Rounded{Name="Knob", Parent=track, Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,0,-3), BackgroundColor3=C.Text}
                local min, max, val = opt.Min or 0, opt.Max or 100, opt.Default or 0
                local function set(v)
                    v = math.clamp(v, min, max)
                    val = v
                    local p = (v-min)/(max-min)
                    fill.Size = UDim2.new(p,0,1,0)
                    knob.Position = UDim2.new(p, -7, 0, -3)
                end
                set(val)
                local dragging = false
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging = true
                        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        set(min + (x/track.AbsoluteSize.X)*(max-min))
                        if opt.Callback then opt.Callback(val) end
                    end
                end)
                track.InputEnded:Connect(function() dragging = false end)
                track.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                        set(min + (x/track.AbsoluteSize.X)*(max-min))
                        if opt.Callback then opt.Callback(val) end
                    end
                end)
                return container
            end

            function Section:AddTextbox(opt)
                local container = Instance.new("Frame", sec)
                container.BackgroundTransparency, container.Size, container.LayoutOrder = 1, UDim2.new(1,0,0,30), order
                order += 1
                local lbl = Instance.new("TextLabel", container)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Name or "", Enum.Font.Gotham, 12, C.Text
                lbl.BackgroundTransparency, lbl.Size, lbl.Position = 1, UDim2.new(0,80,1,0), UDim2.new(0,0,0,0)
                local tb = Instance.new("TextBox", container)
                tb.Text, tb.Font, tb.TextSize, tb.TextColor3 = opt.Default or "", Enum.Font.Gotham, 13, C.Text
                tb.BackgroundColor3, tb.BorderSizePixel = C.SecBg, 0
                tb.PlaceholderText, tb.ClearTextOnFocus = opt.Placeholder or "", false
                tb.Size, tb.Position = UDim2.new(0,120,0,26), UDim2.new(0,86,0.5,-13)
                Instance.new("UICorner", tb).CornerRadius = UDim.new(0,6)
                tb.FocusLost:Connect(function(enter) if enter and opt.Callback then opt.Callback(tb.Text) end end)
                return container
            end

            function Section:AddDropdown(opt)
                local container = Instance.new("Frame", sec)
                container.BackgroundTransparency, container.Size, container.LayoutOrder = 1, UDim2.new(1,0,0,30), order
                order += 1
                local main = Rounded{Name="DropMain", Parent=container, Size=UDim2.new(0,140,0,26), Position=UDim2.new(0,0,0,0), BackgroundColor3=C.BtnBg}
                iOSBtn(main, C.BtnBg, C.BtnHov, C.BtnPrs)
                local lbl = Instance.new("TextLabel", main)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Default or (opt.Values[1] or ""), Enum.Font.Gotham, 13, C.Text
                lbl.BackgroundTransparency, lbl.Size, lbl.Position, lbl.TextXAlignment = 1, UDim2.new(1,-20,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Left
                local arr = Instance.new("ImageLabel", main)
                arr.Image, arr.BackgroundTransparency, arr.Size, arr.Position = "rbxassetid://6034818371", 1, UDim2.new(0,14,0,14), UDim2.new(1,-18,0.5,-7)
                arr.ImageColor3 = C.Text
                local menu = Rounded{Name="Menu", Parent=container, Size=UDim2.new(0,140,0,0), Position=UDim2.new(0,0,1,2), BackgroundColor3=C.SecBg, Visible=false, ZIndex=10}
                menu.AutomaticSize = Enum.AutomaticSize.Y; menu.ClipsDescendants = true
                local selected = opt.Default or (opt.Values[1] or "")
                local function buildMenu(vals)
                    menu:ClearAllChildren()
                    for _,v in ipairs(vals) do
                        local item = Instance.new("TextButton", menu)
                        item.Text, item.Font, item.TextSize, item.TextColor3 = tostring(v), Enum.Font.Gotham, 13, C.Text
                        item.BackgroundTransparency, item.Size, item.AutoButtonColor = 1, UDim2.new(1,0,0,24), false
                        item.TextXAlignment = Enum.TextXAlignment.Left
                        Instance.new("UIPadding", item).PaddingLeft = UDim.new(0,8)
                        item.MouseButton1Click:Connect(function()
                            selected = tostring(v); lbl.Text = selected; menu.Visible = false
                            if opt.Callback then opt.Callback(selected) end
                        end)
                    end
                end
                buildMenu(opt.Values)
                main.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        menu.Visible = not menu.Visible
                    end
                end)
                if UserInputService.TouchEnabled then main.TouchTap:Connect(function() menu.Visible = not menu.Visible end) end
                return container
            end

            return Section
        end
        return Tab
    end

    function Window:Destroy() KevinzHub:Destroy() end
    return Window
end

function KevinzHub:Log(module, msg, color)
    if UI.console and UI.console.AddLog then
        UI.console:AddLog("["..module.."] "..msg, color)
    end
    print("[KevinzHub:"..module.."] "..msg)
end

function KevinzHub:Destroy()
    if UI.screenGui then UI.screenGui:Destroy() end
    UI = {}
end

return KevinzHub
