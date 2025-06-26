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

-- addTextboxToSection and all other controls will be injected later

-- UI/UX Utilities for Section
local function applyDefaultPadding(frame, pad)
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingTop = UDim.new(0, pad or 6)
    padding.PaddingBottom = UDim.new(0, pad or 6)
    padding.PaddingLeft = UDim.new(0, pad or 8)
    padding.PaddingRight = UDim.new(0, pad or 8)
end

local function createLabel(text, size, color, align, bold, parent)
    local lbl = Instance.new("TextLabel", parent)
    lbl.BackgroundTransparency = 1
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.Text = text
    lbl.TextSize = size or 13
    lbl.TextColor3 = color or COLORS.LabelText
    lbl.TextXAlignment = align or Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Size = UDim2.new(1, 0, 0, size and size+6 or 19)
    return lbl
end

local function renderDropdownMenu(container, items, callback, currentIdx)
    local menu = Instance.new("Frame", container)
    menu.Name = "DropdownMenu"
    menu.BackgroundColor3 = COLORS.DropdownBG
    menu.Size = UDim2.new(1, 0, 0, math.min(#items, 6)*28 + 8)
    menu.Position = UDim2.new(0, 0, 1, 4)
    menu.ZIndex = 16
    menu.BorderSizePixel = 0
    menu.Visible = false
    local corner = Instance.new("UICorner", menu)
    corner.CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", menu)
    stroke.Color = COLORS.Outline
    stroke.Thickness = 1
    local list = Instance.new("UIListLayout", menu)
    list.Padding = UDim.new(0, 2)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local function select(idx)
        callback(items[idx], idx)
        menu.Visible = false
    end

    for i, v in ipairs(items) do
        local btn = Instance.new("TextButton", menu)
        btn.Size = UDim2.new(1, -8, 0, 26)
        btn.BackgroundColor3 = i == currentIdx and COLORS.DropdownPress or COLORS.DropdownBG
        btn.Text = tostring(v)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextColor3 = COLORS.LabelText
        btn.BackgroundTransparency = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = i
        local bcorner = Instance.new("UICorner", btn)
        bcorner.CornerRadius = UDim.new(0, 6)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = COLORS.DropdownHover
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = i == currentIdx and COLORS.DropdownPress or COLORS.DropdownBG
        end)
        btn.MouseButton1Click:Connect(function()
            playClickSound(btn)
            select(i)
        end)
    end
    return menu
end

-- Section controls
local Section = {}

-- AddDropdown
function Section:AddDropdown(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "Dropdown").."Container"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = itemOrder

    local lbl = createLabel(opt.Name or "Dropdown", 13, COLORS.LabelText, Enum.TextXAlignment.Left, true, container)
    lbl.Size = UDim2.new(0, 90, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    local currentIdx = 1
    local currentVal = opt.Items and opt.Items[1] or ""
    local dropdownBtn = makeRoundedFrame{
        Name = "DropdownBtn",
        Parent = container,
        Size = UDim2.new(0, 120, 0, 28),
        Position = UDim2.new(0, 100, 0.5, -14),
        BackgroundColor3 = COLORS.DropdownBG,
    }
    local dropdownLbl = createLabel(currentVal, 13, COLORS.LabelText, Enum.TextXAlignment.Left, false, dropdownBtn)
    dropdownLbl.Size = UDim2.new(1, -24, 1, 0)
    dropdownLbl.Position = UDim2.new(0, 8, 0, 0)
    local arrow = Instance.new("TextLabel", dropdownBtn)
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "▼"
    arrow.TextSize = 13
    arrow.TextColor3 = COLORS.TabIconTint

    addBtnAnim(dropdownBtn)
    local menu = renderDropdownMenu(dropdownBtn, opt.Items or {}, function(val, idx)
        currentVal, currentIdx = val, idx
        dropdownLbl.Text = tostring(val)
        if opt.Callback then opt.Callback(val, idx) end
    end, currentIdx)
    dropdownBtn.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)
    self._itemOrder = itemOrder + 1
    self._dropdowns = self._dropdowns or {}
    self._dropdowns[opt.Name or ("Dropdown"..itemOrder)] = {btn = dropdownBtn, lbl = dropdownLbl, menu = menu, items = opt.Items or {}, idx = function() return currentIdx end}
    return container
end

function Section:AddLabel(opt)
    local itemOrder = self._itemOrder or 1
    local lbl = createLabel(opt.Text or opt.Name or "Label", opt.TextSize or 13, opt.Color or COLORS.LabelText, Enum.TextXAlignment.Left, opt.Bold, self._frame)
    lbl.LayoutOrder = itemOrder
    self._itemOrder = itemOrder + 1
    self._labels = self._labels or {}
    self._labels[opt.Name or ("Label"..itemOrder)] = lbl
    return lbl
end

function Section:AddParagraph(opt)
    local itemOrder = self._itemOrder or 1
    local pFrame = Instance.new("Frame", self._frame)
    pFrame.Name = (opt.Name or "Paragraph").."Container"
    pFrame.Size = UDim2.new(1, 0, 0, 48)
    pFrame.BackgroundColor3 = COLORS.ParagraphBg
    pFrame.LayoutOrder = itemOrder
    local corner = Instance.new("UICorner", pFrame)
    corner.CornerRadius = UDim.new(0, 6)
    applyDefaultPadding(pFrame, 8)
    local para = createLabel(opt.Text or "Paragraph", 13, COLORS.ParagraphText, Enum.TextXAlignment.Left, false, pFrame)
    para.Size = UDim2.new(1, 0, 1, 0)
    para.TextWrapped = true
    para.TextYAlignment = Enum.TextYAlignment.Top
    self._itemOrder = itemOrder + 1
    self._paragraphs = self._paragraphs or {}
    self._paragraphs[opt.Name or ("Paragraph"..itemOrder)] = para
    return pFrame
end

function Section:AddColorPicker(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "ColorPicker").."Container"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = itemOrder

    local lbl = createLabel(opt.Name or "Color", 13, COLORS.LabelText, Enum.TextXAlignment.Left, true, container)
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    local colorBox = Instance.new("Frame", container)
    colorBox.Size = UDim2.new(0, 30, 0, 30)
    colorBox.Position = UDim2.new(0, 90, 0.5, -15)
    colorBox.BackgroundColor3 = opt.Default or Color3.new(1,1,1)
    local corner = Instance.new("UICorner", colorBox)
    corner.CornerRadius = UDim.new(0, 6)
    local inputs = {}
    local function updateColor()
        local r = tonumber(inputs.R.Text) or 0
        local g = tonumber(inputs.G.Text) or 0
        local b = tonumber(inputs.B.Text) or 0
        colorBox.BackgroundColor3 = Color3.fromRGB(r, g, b)
        if opt.Callback then opt.Callback(Color3.fromRGB(r, g, b)) end
    end
    local xoff = 130
    for _, c in ipairs({"R","G","B"}) do
        local tb = Instance.new("TextBox", container)
        tb.Size = UDim2.new(0, 30, 0, 30)
        tb.Position = UDim2.new(0, xoff, 0.5, -15)
        tb.BackgroundColor3 = COLORS.TextboxBg
        tb.TextColor3 = COLORS.LabelText
        tb.Text = tostring(opt.Default and math.floor((opt.Default[c:lower()] or 0)*255) or (c=="R" and 255 or 0))
        tb.Font = Enum.Font.Gotham
        tb.TextSize = 13
        tb.ClearTextOnFocus = true
        tb.TextXAlignment = Enum.TextXAlignment.Center
        tb.BorderSizePixel = 0
        local tcorner = Instance.new("UICorner", tb)
        tcorner.CornerRadius = UDim.new(0, 5)
        tb.FocusLost:Connect(updateColor)
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            if #tb.Text > 3 then tb.Text = string.sub(tb.Text, 1, 3) end
        end)
        inputs[c] = tb
        xoff = xoff + 34
    end
    self._itemOrder = itemOrder + 1
    self._colorpickers = self._colorpickers or {}
    self._colorpickers[opt.Name or ("ColorPicker"..itemOrder)] = {box = colorBox, inputs = inputs}
    return container
end

function Section:AddImage(opt)
    local itemOrder = self._itemOrder or 1
    local img = Instance.new("ImageLabel", self._frame)
    img.Name = opt.Name or "Image"
    img.Size = UDim2.new(0, opt.Width or 64, 0, opt.Height or 64)
    img.BackgroundTransparency = 1
    img.Image = opt.Image or "rbxassetid://77339698"
    img.LayoutOrder = itemOrder
    self._itemOrder = itemOrder + 1
    self._images = self._images or {}
    self._images[opt.Name or ("Image"..itemOrder)] = img
    return img
end

function Section:AddKeybind(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "Keybind").."Container"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = itemOrder

    local lbl = createLabel(opt.Name or "Keybind", 13, COLORS.LabelText, Enum.TextXAlignment.Left, true, container)
    lbl.Size = UDim2.new(0, 90, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    local keyBox = Instance.new("TextButton", container)
    keyBox.Size = UDim2.new(0, 80, 0, 28)
    keyBox.Position = UDim2.new(0, 100, 0.5, -14)
    keyBox.BackgroundColor3 = COLORS.ButtonBg
    keyBox.TextColor3 = COLORS.LabelText
    keyBox.Text = opt.Default or "None"
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 13
    keyBox.AutoButtonColor = false
    keyBox.BorderSizePixel = 0
    local corner = Instance.new("UICorner", keyBox)
    corner.CornerRadius = UDim.new(0, 6)
    addBtnAnim(keyBox)
    local waiting = false
    keyBox.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        keyBox.Text = "..."
        local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                keyBox.Text = input.KeyCode.Name
                if opt.Callback then opt.Callback(input.KeyCode.Name) end
                conn:Disconnect()
                waiting = false
            end
        end)
    end)
    self._itemOrder = itemOrder + 1
    self._keybinds = self._keybinds or {}
    self._keybinds[opt.Name or ("Keybind"..itemOrder)] = keyBox
    return container
end

function Section:AddListbox(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "Listbox").."Container"
    container.Size = UDim2.new(1, 0, 0, 80)
    container.BackgroundColor3 = COLORS.ParagraphBg
    container.LayoutOrder = itemOrder
    container.BorderSizePixel = 0
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 6)
    local list = Instance.new("UIListLayout", container)
    list.Padding = UDim.new(0, 2)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    local items = opt.Items or {}
    for i, v in ipairs(items) do
        local item = Instance.new("TextButton", container)
        item.Size = UDim2.new(1, -8, 0, 24)
        item.BackgroundColor3 = COLORS.ButtonBg
        item.Text = tostring(v)
        item.Font = Enum.Font.Gotham
        item.TextSize = 13
        item.TextColor3 = COLORS.LabelText
        item.AutoButtonColor = false
        local icorner = Instance.new("UICorner", item)
        icorner.CornerRadius = UDim.new(0, 5)
        addBtnAnim(item)
        item.MouseButton1Click:Connect(function()
            playClickSound(item)
            if opt.Callback then opt.Callback(v, i) end
        end)
    end
    self._itemOrder = itemOrder + 1
    self._listboxes = self._listboxes or {}
    self._listboxes[opt.Name or ("Listbox"..itemOrder)] = container
    return container
end

function Section:AddTable(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "Table").."Container"
    local nRows = #opt.Data
    local nCols = #(opt.Headers or (opt.Data[1] or {}))
    container.Size = UDim2.new(1, 0, 0, 24 + nRows*24)
    container.BackgroundColor3 = COLORS.ParagraphBg
    container.LayoutOrder = itemOrder
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 6)
    local grid = Instance.new("UIGridLayout", container)
    grid.CellPadding = UDim2.new(0,2,0,2)
    grid.CellSize = UDim2.new(1/nCols, -4, 0, 24)
    grid.FillDirectionMaxCells = nCols
    grid.StartCorner = Enum.StartCorner.TopLeft
    grid.FillDirection = Enum.FillDirection.Horizontal

    for _, h in ipairs(opt.Headers or {}) do
        local head = Instance.new("TextLabel", container)
        head.BackgroundTransparency = 1
        head.Font = Enum.Font.GothamBold
        head.Text = tostring(h)
        head.TextSize = 13
        head.TextColor3 = COLORS.LabelText
        head.TextXAlignment = Enum.TextXAlignment.Center
    end
    for _, row in ipairs(opt.Data or {}) do
        for _, val in ipairs(row) do
            local cell = Instance.new("TextLabel", container)
            cell.BackgroundTransparency = 1
            cell.Font = Enum.Font.Gotham
            cell.Text = tostring(val)
            cell.TextSize = 13
            cell.TextColor3 = COLORS.LabelText
            cell.TextXAlignment = Enum.TextXAlignment.Center
        end
    end
    self._itemOrder = itemOrder + 1
    self._tables = self._tables or {}
    self._tables[opt.Name or ("Table"..itemOrder)] = container
    return container
end

function Section:AddRadio(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "Radio").."Container"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = itemOrder

    local lbl = createLabel(opt.Name or "Radio", 13, COLORS.LabelText, Enum.TextXAlignment.Left, true, container)
    lbl.Size = UDim2.new(0, 90, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    local group = {}
    local curr = 1
    for i, v in ipairs(opt.Items or {}) do
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.Position = UDim2.new(0, 100 + (i-1)*36, 0.5, -12)
        btn.BackgroundColor3 = COLORS.ButtonBg
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        local circle = Instance.new("UICorner", btn)
        circle.CornerRadius = UDim.new(1, 0)
        local sel = Instance.new("Frame", btn)
        sel.Size = UDim2.new(0.5, 0, 0.5, 0)
        sel.Position = UDim2.new(0.25, 0, 0.25, 0)
        sel.BackgroundColor3 = COLORS.ToggleOn
        sel.BackgroundTransparency = (i == curr) and 0 or 1
        local scorner = Instance.new("UICorner", sel)
        scorner.CornerRadius = UDim.new(1, 0)
        btn.MouseButton1Click:Connect(function()
            for j, b in ipairs(group) do
                b[2].BackgroundTransparency = 1
            end
            sel.BackgroundTransparency = 0
            curr = i
            playClickSound(btn)
            if opt.Callback then opt.Callback(v, i) end
        end)
        table.insert(group, {btn, sel})
    end
    self._itemOrder = itemOrder + 1
    self._radios = self._radios or {}
    self._radios[opt.Name or ("Radio"..itemOrder)] = {group = group, curr = function() return curr end}
    return container
end

function Section:AddProgressbar(opt)
    local itemOrder = self._itemOrder or 1
    local container = Instance.new("Frame", self._frame)
    container.Name = (opt.Name or "Progressbar").."Container"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.LayoutOrder = itemOrder
    local bg = makeRoundedFrame{
        Name = "ProgressBarBG",
        Parent = container,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0.8, 0, 0, 16),
        BackgroundColor3 = COLORS.SliderTrack,
    }
    local fill = makeRoundedFrame{
        Name = "ProgressBarFill",
        Parent = bg,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(math.clamp(opt.Value or 0, 0, 1), 0, 1, 0),
        BackgroundColor3 = COLORS.SliderFill,
    }
    local lbl = createLabel(opt.Label or "", 12, COLORS.LabelText, Enum.TextXAlignment.Left, false, container)
    lbl.Position = UDim2.new(0.82, 8, 0.5, -7)
    self._itemOrder = itemOrder + 1
    self._progressbars = self._progressbars or {}
    self._progressbars[opt.Name or ("Progressbar"..itemOrder)] = {fill = fill, bg = bg, label = lbl}
    return container
end

-- Update/utility methods
function Section:UpdateLabel(name, text)
    if self._labels and self._labels[name] then
        self._labels[name].Text = text
    end
end
function Section:UpdateDropdown(name, items, idx)
    if self._dropdowns and self._dropdowns[name] then
        local dd = self._dropdowns[name]
        dd.menu:Destroy()
        local newMenu = renderDropdownMenu(dd.btn, items, function(val, i)
            dd.lbl.Text = tostring(val)
            dd.items = items
            if dd.callback then dd.callback(val, i) end
        end, idx or 1)
        dd.menu = newMenu
        dd.lbl.Text = tostring(items[idx or 1])
    end
end
function Section:UpdateImage(name, img)
    if self._images and self._images[name] then
        self._images[name].Image = img
    end
end
function Section:SetVisible(name, visible)
    if self._frame:FindFirstChild(name) then
        self._frame[name].Visible = visible
    end
end

-- Section constructor wrapper
local function injectSection(section, frame)
    section._frame = frame
    section._itemOrder = 1
    for k, v in pairs(Section) do
        section[k] = v
    end
end

-- Patch Tab/Section creation logic to inject new methods
local origMakeTab = nil
origMakeTab = function(tabOpt)
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

        local SectionObj = {}
        injectSection(SectionObj, secFrame)
        return SectionObj
    end
    return Tab
end

function KevinzHub:MakeWindow(opt)
    -- [ ... all the previous MakeWindow logic ... ]
    -- Replace the Tab constructor in MakeWindow with above origMakeTab (patch)
    -- Patch code must be here
    Window = {}
    Window.MakeTab = origMakeTab
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
