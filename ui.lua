--[[
    KHub UI v5.0 - Đã sửa lỗi kéo thả, scroll, mobile, loại bỏ badge
    - Kéo cửa sổ chỉ qua topbar, không xung đột với các thành phần khác.
    - Sidebar dùng ScrollingFrame, cuộn mượt cảm ứng & chuột.
    - Hỗ trợ đầy đủ mobile touch (kéo, bấm, trượt).
    - Nhẹ, không crash, không lag.
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Colors
local C = {
    WinBg   = Color3.fromRGB(18,18,22),
    TopBg   = Color3.fromRGB(22,22,28),
    SideBg  = Color3.fromRGB(22,23,28),
    ContBg  = Color3.fromRGB(20,22,26),
    Stroke  = Color3.fromRGB(42,42,56),
    Text    = Color3.fromRGB(225,225,240),
    SecBg   = Color3.fromRGB(28,30,36),
    BtnBg   = Color3.fromRGB(38,40,50),
    BtnHov  = Color3.fromRGB(58,62,82),
    BtnPrs  = Color3.fromRGB(32,34,68),
    TogOn   = Color3.fromRGB(52,199,89),
    TogOff  = Color3.fromRGB(58,58,70),
    SlTr    = Color3.fromRGB(50,52,62),
    SlFill  = Color3.fromRGB(52,199,89),
    TabAct  = Color3.fromRGB(52,199,89),
    TabIn   = Color3.fromRGB(35,37,44),
    LogBg   = Color3.fromRGB(26,28,34),
}
local VERSION = "5.0"
local T = {Fade=0.15, Tween=0.18, Press=0.06}

-- Helper tạo Frame bo góc + viền
local function Frame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k] = v end
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke", f)
    s.Color, s.Thickness = C.Stroke, 1.2
    return f
end

-- Hiệu ứng nút iOS 18
local function iOSButton(btn, bg, hov, prs)
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

-- Mini console (table)
local function CreateConsole(parent)
    local con = Frame{
        Name="Console", Parent=parent, Size=UDim2.new(1,-8,0,24), BackgroundColor3=C.LogBg,
        LayoutOrder=999
    }
    local logs, open = {}, false
    local scroll = Frame{
        Name="Scroll", Parent=con, Visible=false, Size=UDim2.new(1,-4,0,100), Position=UDim2.new(0,2,0,26),
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

    local console = {}
    function console:AddLog(text, color)
        table.insert(logs, text)
        local lbl = Instance.new("TextLabel", scroll)
        lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = text, Enum.Font.Code, 11, color or C.Text
        lbl.BackgroundTransparency, lbl.Size, lbl.TextXAlignment = 1, UDim2.new(1,0,0,22), Enum.TextXAlignment.Left
        lbl.LayoutOrder = #logs
        if open then
            con.Size = UDim2.new(1,-8,0,24+math.min(#logs*22+8, 120))
        end
    end
    console.Frame = con
    return console
end

local KHub = {}
local UI = {}

function KHub:MakeWindow(opt)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior, gui.Parent = "KHubUI", false, Enum.ZIndexBehavior.Global, PlayerGui
    UI.screenGui = gui

    local win = Frame{
        Name="Main", Parent=gui, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.new(0,560,0,390), BackgroundColor3=C.WinBg
    }
    UI.window = win

    -- ===== TOP BAR (kéo thả) =====
    local topBar = Frame{Name="Top", Parent=win, Size=UDim2.new(1,0,0,36), BackgroundColor3=C.TopBg}
    local title = Instance.new("TextLabel", topBar)
    title.Text, title.Font, title.TextSize, title.TextColor3 = opt.Name or "KHub", Enum.Font.GothamBold, 18, C.Text
    title.BackgroundTransparency, title.Position, title.Size = 1, UDim2.new(0,44,0.5,-10), UDim2.new(0,200,0,20)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Nút Min/Close
    local function topBtn(text, posX, cb)
        local btn = Frame{Name=text, Parent=topBar, Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,posX,0.5,-14), BackgroundColor3=C.BtnBg}
        local lbl = Instance.new("TextLabel", btn)
        lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = text, Enum.Font.GothamBold, 16, C.Text
        lbl.BackgroundTransparency, lbl.Size, lbl.TextXAlignment, lbl.TextYAlignment = 1, UDim2.fromScale(1,1), Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
        iOSButton(btn, C.BtnBg, C.BtnHov, C.BtnPrs)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then cb() end
        end)
        if UserInputService.TouchEnabled then btn.TouchTap:Connect(cb) end
        return btn
    end
    topBtn("–", -62, function()
        win.Visible = false
        local rest = Frame{Name="Restore", Parent=gui, Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,12,0,12), BackgroundColor3=C.BtnBg}
        local img = Instance.new("ImageLabel", rest)
        img.Image, img.BackgroundTransparency, img.Size, img.ScaleType = "rbxassetid://1912438810", 1, UDim2.fromScale(1,1), Enum.ScaleType.Fit
        img.ImageColor3 = C.Text
        iOSButton(rest, C.BtnBg, C.BtnHov, C.BtnPrs)
        -- Kéo restore button
        local drag, start, pos
        rest.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                drag, start, pos = true, i.Position, rest.Position
            end
        end)
        rest.InputEnded:Connect(function() drag=false end)
        rest.InputChanged:Connect(function(i)
            if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local delta = i.Position - start
                rest.Position = UDim2.new(pos.X.Scale, pos.X.Offset+delta.X, pos.Y.Scale, pos.Y.Offset+delta.Y)
            end
        end)
        rest.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                if not drag then win.Visible = true; rest:Destroy() end
            end
        end)
        if UserInputService.TouchEnabled then rest.TouchTap:Connect(function() win.Visible = true; rest:Destroy() end) end
    end)
    topBtn("✕", -30, function()
        KHub:Destroy()
        print("[KHub] UI closed | v"..VERSION)
        game:GetService("StarterGui"):SetCore("SendNotification", {Title="KHub", Text="UI đã tắt", Duration=2, Icon="rbxassetid://11836181348"})
    end)

    -- ===== KÉO CỬA SỔ CHỈ QUA TOPBAR =====
    local dragging, dragStart, startPos
    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = win.Position
            input.Changed:Wait()
        end
    end
    local function onDragEnd(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end
    local function onDragMove(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    topBar.InputBegan:Connect(onDragStart)
    topBar.InputEnded:Connect(onDragEnd)
    UserInputService.InputChanged:Connect(onDragMove) -- để nhận cả mouse movement và touch movement
    -- Ngăn kéo khi nhấn vào nút
    for _, btn in ipairs(topBar:GetChildren()) do
        if btn:IsA("Frame") and btn.Name ~= "Top" then -- các nút Min/Close
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false -- hủy kéo nếu bấm nút
                end
            end)
        end
    end

    -- ===== SIDEBAR (ScrollingFrame) =====
    local sbHolder = Instance.new("Frame", win)
    sbHolder.Name, sbHolder.BackgroundTransparency, sbHolder.Position, sbHolder.Size = "SBHolder", 1, UDim2.new(0,0,0,36), UDim2.new(0,160,1,-36)
    local sidebar = Frame{Name="Sidebar", Parent=sbHolder, Size=UDim2.new(1,0,1,0), BackgroundColor3=C.SideBg}
    -- Dùng ScrollingFrame để scroll mượt
    local sf = Instance.new("ScrollingFrame", sidebar)
    sf.Name, sf.Size, sf.Position = "Scroll", UDim2.new(1,-2,1,-2), UDim2.new(0,1,0,1)
    sf.BackgroundTransparency, sf.BorderSizePixel, sf.ScrollBarThickness = 1, 0, 4
    sf.ScrollBarImageColor3 = C.Stroke
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    sf.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    sf.ClipsDescendants = true
    local sfList = Instance.new("UIListLayout", sf)
    sfList.SortOrder, sfList.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,6)
    local sfPad = Instance.new("UIPadding", sf)
    sfPad.PaddingTop, sfPad.PaddingLeft, sfPad.PaddingRight = UDim.new(0,8), UDim.new(0,6), UDim.new(0,6)

    -- User info (avatar + name)
    local userFrame = Instance.new("Frame", sf)
    userFrame.Name, userFrame.BackgroundTransparency, userFrame.Size, userFrame.LayoutOrder = "User", 1, UDim2.new(1,0,0,40), 0
    local av = Instance.new("ImageLabel", userFrame)
    av.Name, av.Size, av.Position = "Avatar", UDim2.new(0,32,0,32), UDim2.new(0,0,0,4)
    av.BackgroundTransparency, av.Image = 1, "rbxassetid://77339698"
    Instance.new("UICorner", av).CornerRadius = UDim.new(0,16)
    task.spawn(function()
        local ok, img = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        if ok and img then av.Image = img end
    end)
    local uname = Instance.new("TextLabel", userFrame)
    uname.Text, uname.Font, uname.TextSize, uname.TextColor3 = LocalPlayer.Name, Enum.Font.GothamBold, 13, C.Text
    uname.BackgroundTransparency, uname.Position, uname.Size = 1, UDim2.new(0,38,0,10), UDim2.new(1,-44,0,20)
    uname.TextXAlignment = Enum.TextXAlignment.Left

    -- Search bar
    local search = Instance.new("TextBox", sf)
    search.Name, search.PlaceholderText, search.Text = "Search", "🔍 Tìm tab...", ""
    search.Size, search.LayoutOrder = UDim2.new(1,-8,0,24), 1
    search.BackgroundColor3, search.TextColor3, search.Font, search.TextSize = C.SecBg, C.Text, Enum.Font.Gotham, 13
    search.ClearTextOnFocus, search.BorderSizePixel = false, 0
    Instance.new("UICorner", search).CornerRadius = UDim.new(0,8)

    -- Console
    UI.console = CreateConsole(sf)

    -- Tự log
    KHub:Log("System", "KHub UI v"..VERSION.." sẵn sàng", Color3.fromRGB(144,238,144))
    KHub:Log("Core", "Kéo thả & scroll mượt", Color3.fromRGB(173,216,230))

    -- Hệ thống tab
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

    -- Content area (bên phải)
    local contentArea = Instance.new("Frame", win)
    contentArea.Name, contentArea.BackgroundTransparency, contentArea.ClipsDescendants = "Content", 1, true
    contentArea.Position, contentArea.Size = UDim2.new(0,164,0,38), UDim2.new(1,-172,1,-46)

    local Window = {}
    function Window:MakeTab(tabOpt)
        local btn = Frame{
            Name=tabOpt.Name.."Tab", Parent=sf, Size=UDim2.new(1,-8,0,32), LayoutOrder=#tabs+2,
            BackgroundColor3=C.TabIn
        }
        iOSButton(btn, C.TabIn, C.TabAct, C.TabAct)
        local lbl = Instance.new("TextLabel", btn)
        lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = tabOpt.Name, Enum.Font.GothamBold, 13, C.Text
        lbl.BackgroundTransparency, lbl.Size, lbl.Position, lbl.TextXAlignment = 1, UDim2.new(1,-30,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Left
        local icon = Instance.new("ImageLabel", btn)
        icon.Image, icon.BackgroundTransparency, icon.Size, icon.Position = "rbxassetid://11718192673", 1, UDim2.new(0,16,0,16), UDim2.new(1,-22,0.5,-8)
        icon.ImageColor3 = C.Text

        local page = Frame{
            Name=tabOpt.Name.."Page", Parent=contentArea, Size=UDim2.new(1,0,1,0), BackgroundColor3=C.ContBg,
            Visible=false
        }
        page.ClipsDescendants = true
        -- Dùng ScrollingFrame cho nội dung nếu nhiều
        local pageScroll = Instance.new("ScrollingFrame", page)
        pageScroll.Size, pageScroll.Position = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0)
        pageScroll.BackgroundTransparency, pageScroll.BorderSizePixel = 1, 0
        pageScroll.ScrollBarThickness = 4
        pageScroll.ScrollBarImageColor3 = C.Stroke
        pageScroll.CanvasSize = UDim2.new(0,0,0,0)
        pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pageScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        pageScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
        pageScroll.ClipsDescendants = true
        local pList = Instance.new("UIListLayout", pageScroll)
        pList.SortOrder, pList.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0,10)
        pList.HorizontalAlignment, pList.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top

        tabs[tabOpt.Name], contents[tabOpt.Name] = btn, page

        btn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                selectTab(tabOpt.Name)
            end
        end)
        if UserInputService.TouchEnabled then btn.TouchTap:Connect(function() selectTab(tabOpt.Name) end) end
        if #tabs==1 then selectTab(tabOpt.Name) end

        local Tab = {}
        function Tab:AddSection(secOpt)
            local sec = Frame{
                Name=secOpt.Name.."Sec", Parent=pageScroll, Size=UDim2.new(1,-16,0,0), BackgroundColor3=C.SecBg,
                LayoutOrder=#tabs+1
            }
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
                local btn = Frame{
                    Name=opt.Name.."Btn", Parent=sec, Size=UDim2.new(0,120,0,30), BackgroundColor3=C.BtnBg,
                    LayoutOrder=order
                }
                order += 1
                local lbl = Instance.new("TextLabel", btn)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Name, Enum.Font.GothamBold, 13, C.Text
                lbl.BackgroundTransparency, lbl.Size, lbl.TextXAlignment = 1, UDim2.fromScale(1,1), Enum.TextXAlignment.Center
                iOSButton(btn, C.BtnBg, C.BtnHov, C.BtnPrs)
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
                local bg = Frame{
                    Name="Tog", Parent=container, Size=UDim2.new(0,44,0,26), Position=UDim2.new(0,0,0.5,-13),
                    BackgroundColor3=opt.Default and C.TogOn or C.TogOff
                }
                local knob = Frame{
                    Name="Knob", Parent=bg, Size=UDim2.new(0,22,0,22), Position=UDim2.new(0,1,0,1),
                    BackgroundColor3=Color3.fromRGB(255,255,255)
                }
                local state = opt.Default or false
                local function setState(anim)
                    local targetX = state and (bg.Size.X.Offset - knob.Size.X.Offset - 1) or 1
                    if anim then
                        TweenService:Create(knob, TweenInfo.new(T.Tween, Enum.EasingStyle.Quart), {Position=UDim2.new(0,targetX,0,1)}):Play()
                        TweenService:Create(bg, TweenInfo.new(T.Tween, Enum.EasingStyle.Quart), {BackgroundColor3=state and C.TogOn or C.TogOff}):Play()
                    else
                        knob.Position, bg.BackgroundColor3 = UDim2.new(0,targetX,0,1), state and C.TogOn or C.TogOff
                    end
                end
                setState(false)
                local lbl = Instance.new("TextLabel", container)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Name, Enum.Font.Gotham, 13, C.Text
                lbl.BackgroundTransparency, lbl.Position, lbl.Size, lbl.TextXAlignment = 1, UDim2.new(0,52,0,0), UDim2.new(0,120,1,0), Enum.TextXAlignment.Left
                bg.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        state = not state; setState(true)
                        if opt.Callback then opt.Callback(state) end
                    end
                end)
                if UserInputService.TouchEnabled then bg.TouchTap:Connect(function() state = not state; setState(true); if opt.Callback then opt.Callback(state) end end) end
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
                local track = Frame{Name="Track", Parent=container, Size=UDim2.new(0,w,0,h), Position=UDim2.new(0,0,0,14), BackgroundColor3=C.SlTr}
                local fill = Frame{Name="Fill", Parent=track, Size=UDim2.new(0,0,1,0), BackgroundColor3=C.SlFill}
                local knob = Frame{Name="Knob", Parent=track, Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,0,-3), BackgroundColor3=C.Text}
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
                local main = Frame{
                    Name="Drop", Parent=container, Size=UDim2.new(0,140,0,26), Position=UDim2.new(0,0,0,0),
                    BackgroundColor3=C.BtnBg
                }
                iOSButton(main, C.BtnBg, C.BtnHov, C.BtnPrs)
                local lbl = Instance.new("TextLabel", main)
                lbl.Text, lbl.Font, lbl.TextSize, lbl.TextColor3 = opt.Default or (opt.Values[1] or ""), Enum.Font.Gotham, 13, C.Text
                lbl.BackgroundTransparency, lbl.Size, lbl.Position, lbl.TextXAlignment = 1, UDim2.new(1,-20,1,0), UDim2.new(0,8,0,0), Enum.TextXAlignment.Left
                local arr = Instance.new("ImageLabel", main)
                arr.Image, arr.BackgroundTransparency, arr.Size, arr.Position = "rbxassetid://6034818371", 1, UDim2.new(0,14,0,14), UDim2.new(1,-18,0.5,-7)
                arr.ImageColor3 = C.Text
                local menu = Frame{
                    Name="Menu", Parent=container, Size=UDim2.new(0,140,0,0), Position=UDim2.new(0,0,1,2),
                    BackgroundColor3=C.SecBg, Visible=false, ZIndex=10, ClipsDescendants=true
                }
                menu.AutomaticSize = Enum.AutomaticSize.Y
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

            function Section:AddLabel(text)
                local lbl = Instance.new("Frame", sec)
                lbl.BackgroundTransparency, lbl.Size, lbl.LayoutOrder = 1, UDim2.new(1,0,0,20), order
                order += 1
                local t = Instance.new("TextLabel", lbl)
                t.Text, t.Font, t.TextSize, t.TextColor3 = text, Enum.Font.GothamBold, 13, C.Text
                t.BackgroundTransparency, t.Size = 1, UDim2.fromScale(1,1)
                t.TextXAlignment = Enum.TextXAlignment.Left
                return lbl
            end

            function Section:AddParagraph(text)
                local para = Frame{
                    Name="Para", Parent=sec, BackgroundColor3=C.SecBg, Size=UDim2.new(1,-10,0,0), LayoutOrder=order,
                    AutomaticSize=Enum.AutomaticSize.Y
                }
                order += 1
                local t = Instance.new("TextLabel", para)
                t.Text, t.Font, t.TextSize, t.TextColor3 = text, Enum.Font.Gotham, 12, C.Text
                t.BackgroundTransparency, t.Size, t.Position = 1, UDim2.new(1,-8,1,-8), UDim2.new(0,4,0,4)
                t.TextWrapped, t.TextXAlignment = true, Enum.TextXAlignment.Left
                return para
            end

            return Section
        end
        return Tab
    end

    function Window:Destroy()
        KHub:Destroy()
    end

    return Window
end

function KHub:Log(module, msg, color)
    if UI.console and UI.console.AddLog then
        UI.console:AddLog("["..module.."] "..msg, color)
    end
    print("[KHub:"..module.."] "..msg)
end

function KHub:Destroy()
    if UI.screenGui then UI.screenGui:Destroy() end
    UI = {}
end

return KHub
