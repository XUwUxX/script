-- Kevinz Hub: GUI chỉnh WalkSpeed với layout list như hình ví dụ
-- Yêu cầu: chạy client-side
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Theo dõi Humanoid để lấy defaultSpeed
local humanoid
local defaultSpeed = 16
local switchOn = false

local function setupHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    defaultSpeed = humanoid.WalkSpeed or 16
    -- Nếu switch đang bật khi respawn, áp dụng giá trị hiện tại trong input (nếu hợp lệ), 
    -- hoặc reset về default nếu input không hợp lệ
    if switchOn then
        local num = tonumber(speedInput.Text)
        if num and num >= 0 then
            humanoid.WalkSpeed = num
        else
            humanoid.WalkSpeed = defaultSpeed
            speedInput.Text = tostring(defaultSpeed)
        end
    else
        humanoid.WalkSpeed = defaultSpeed
        -- đồng bộ input nếu muốn, nhưng giữ nguyên input khi switch tắt để người dùng chỉnh trước
    end
end

-- Lắng nghe respawn
player.CharacterAdded:Connect(function()
    -- Đợi GUI đã khởi tạo xong
    setupHumanoid()
end)

-- ===== Tạo GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "KevinzHubSpeed"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Container chính
local container = Instance.new("Frame")
container.Name = "MainContainer"
container.Size = UDim2.new(0, 360, 0, 0) -- cao sẽ tự động qua UIListLayout + AutomaticSize
container.Position = UDim2.new(0.5, -180, 0.5, -150)
container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
container.BackgroundTransparency = 0
container.ClipsDescendants = true
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.AutomaticSize = Enum.AutomaticSize.Y
container.Parent = gui

local containerCorner = Instance.new("UICorner", container)
containerCorner.CornerRadius = UDim.new(0, 12)

-- Layout: dàn hàng dọc
local layout = Instance.new("UIListLayout", container)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Header: Frame chứa back + title
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1
header.LayoutOrder = 1
header.Parent = container

-- Back button
local backBtn = Instance.new("TextButton")
backBtn.Name = "BackButton"
backBtn.Size = UDim2.new(0, 40, 1, 0)
backBtn.Position = UDim2.new(0, 8, 0, 0)
backBtn.BackgroundTransparency = 1
backBtn.Text = "<"
backBtn.Font = Enum.Font.GothamBold
backBtn.TextSize = 24
backBtn.TextColor3 = Color3.new(1, 1, 1)
backBtn.Parent = header

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -56, 1, 0)
titleLabel.Position = UDim2.new(0, 56, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Speed Settings"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, -16, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Điều chỉnh tốc độ di chuyển"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.LayoutOrder = 2
subtitle.Parent = container
subtitle.Position = UDim2.new(0, 16, 0, 0)

-- ===== Mục 1: Switch bật/tắt tính năng =====
local switchFrame = Instance.new("Frame")
switchFrame.Name = "SwitchFrame"
switchFrame.Size = UDim2.new(1, -32, 0, 40)
switchFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
switchFrame.LayoutOrder = 3
switchFrame.Parent = container

local switchCorner = Instance.new("UICorner", switchFrame)
switchCorner.CornerRadius = UDim.new(0, 8)

-- Label
local switchLabel = Instance.new("TextLabel")
switchLabel.Name = "Label"
switchLabel.Size = UDim2.new(0.6, 0, 1, 0)
switchLabel.Position = UDim2.new(0, 8, 0, 0)
switchLabel.BackgroundTransparency = 1
switchLabel.Text = "Kích hoạt speed"
switchLabel.Font = Enum.Font.Gotham
switchLabel.TextSize = 16
switchLabel.TextColor3 = Color3.new(1, 1, 1)
switchLabel.TextXAlignment = Enum.TextXAlignment.Left
switchLabel.Parent = switchFrame

-- Switch button: background + circle
local switchBtn = Instance.new("TextButton")
switchBtn.Name = "SwitchBtn"
switchBtn.Size = UDim2.new(0, 50, 0, 24)
switchBtn.Position = UDim2.new(1, -58, 0.5, -12)
switchBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
switchBtn.AutoButtonColor = false
switchBtn.Text = ""
switchBtn.Parent = switchFrame

local switchBtnCorner = Instance.new("UICorner", switchBtn)
switchBtnCorner.CornerRadius = UDim.new(0, 12)

-- Circle inside
local circle = Instance.new("Frame")
circle.Name = "Circle"
circle.Size = UDim2.new(0, 20, 0, 20)
circle.Position = UDim2.new(0, 2, 0.5, -10)
circle.BackgroundColor3 = Color3.new(1, 1, 1)
circle.Parent = switchBtn

local circleCorner = Instance.new("UICorner", circle)
circleCorner.CornerRadius = UDim.new(1, 0)

-- ===== Mục 2: Input số tốc độ =====
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, -32, 0, 40)
inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
inputFrame.LayoutOrder = 4
inputFrame.Parent = container

local inputCorner = Instance.new("UICorner", inputFrame)
inputCorner.CornerRadius = UDim.new(0, 8)

-- Label
local inputLabel = Instance.new("TextLabel")
inputLabel.Name = "Label"
inputLabel.Size = UDim2.new(0.4, 0, 1, 0)
inputLabel.Position = UDim2.new(0, 8, 0, 0)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "Speed"
inputLabel.Font = Enum.Font.Gotham
inputLabel.TextSize = 16
inputLabel.TextColor3 = Color3.new(1, 1, 1)
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Parent = inputFrame

-- TextBox để nhập số
local speedInput = Instance.new("TextBox")
speedInput.Name = "SpeedInput"
speedInput.Size = UDim2.new(0.4, 0, 0.8, 0)
speedInput.Position = UDim2.new(1, - (0.4 * inputFrame.AbsoluteSize.X) - 16, 0.1, 0)
-- Lưu ý: vì AbsoluteSize chưa có ngay, ta sẽ điều chỉnh Position sau khi GUI load xong
speedInput.AnchorPoint = Vector2.new(1, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedInput.Text = ""
speedInput.PlaceholderText = "Nhập..."
speedInput.ClearTextOnFocus = false
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 16
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.TextXAlignment = Enum.TextXAlignment.Center
speedInput.Parent = inputFrame

local speedInputCorner = Instance.new("UICorner", speedInput)
speedInputCorner.CornerRadius = UDim.new(0, 6)

-- ===== Mục 3: Dropdown preset tốc độ =====
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.Size = UDim2.new(1, -32, 0, 40)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownFrame.LayoutOrder = 5
dropdownFrame.Parent = container

local dropdownCorner = Instance.new("UICorner", dropdownFrame)
dropdownCorner.CornerRadius = UDim.new(0, 8)

-- Label
local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Name = "Label"
dropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
dropdownLabel.Position = UDim2.new(0, 8, 0, 0)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.Text = "Preset"
dropdownLabel.Font = Enum.Font.Gotham
dropdownLabel.TextSize = 16
dropdownLabel.TextColor3 = Color3.new(1, 1, 1)
dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
dropdownLabel.Parent = dropdownFrame

-- Button hiển thị lựa chọn
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Name = "DropdownBtn"
dropdownBtn.Size = UDim2.new(0.5, 0, 0.8, 0)
dropdownBtn.Position = UDim2.new(1, - (0.5 * dropdownFrame.AbsoluteSize.X) - 8, 0.1, 0)
dropdownBtn.AnchorPoint = Vector2.new(1, 0)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
dropdownBtn.Text = "Chọn..."
dropdownBtn.Font = Enum.Font.Gotham
dropdownBtn.TextSize = 16
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
dropdownBtn.Parent = dropdownFrame

local dropdownBtnCorner = Instance.new("UICorner", dropdownBtn)
dropdownBtnCorner.CornerRadius = UDim.new(0, 6)

-- Frame chứa list item, ẩn ban đầu
local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.Size = UDim2.new(0, dropdownFrame.Size.X.Offset, 0, 0)
listFrame.Position = UDim2.new(0, 16, 0, 0) -- tạm, sẽ đặt bên dưới dropdownFrame
listFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
listFrame.Visible = false
listFrame.ClipsDescendants = true
listFrame.Parent = container

local listCorner = Instance.new("UICorner", listFrame)
listCorner.CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Các preset mẫu. Bạn có thể chỉnh list này theo ý:
local presets = {
    {name = "Mặc định", value = nil}, -- giữ giá trị defaultSpeed
    {name = "50", value = 50},
    {name = "100", value = 100},
    {name = "0", value = 0},
}

-- ===== Mục 4: Button Khôi phục =====
local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "ButtonFrame"
buttonFrame.Size = UDim2.new(1, -32, 0, 40)
buttonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonFrame.LayoutOrder = 6
buttonFrame.Parent = container

local buttonCorner = Instance.new("UICorner", buttonFrame)
buttonCorner.CornerRadius = UDim.new(0, 8)

local applyBtn = Instance.new("TextButton")
applyBtn.Name = "RestoreBtn"
applyBtn.Size = UDim2.new(0.5, 0, 0.8, 0)
applyBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
applyBtn.AnchorPoint = Vector2.new(0.5, 0)
applyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
applyBtn.Text = "Khôi phục"
applyBtn.Font = Enum.Font.Gotham
applyBtn.TextSize = 16
applyBtn.TextColor3 = Color3.new(1, 1, 1)
applyBtn.Parent = buttonFrame

local applyBtnCorner = Instance.new("UICorner", applyBtn)
applyBtnCorner.CornerRadius = UDim.new(0, 6)

-- ===== Điều chỉnh Position các TextBox, Button dựa trên AbsoluteSize sau khi parent đã render =====
-- Chờ 1 frame để GUI đo size, rồi set Position cho speedInput và dropdownBtn
task.defer(function()
    -- InputFrame
    speedInput.Position = UDim2.new(1, - (inputFrame.AbsoluteSize.X * 0.4) - 8, 0.1, 0)
    -- DropdownFrame
    dropdownBtn.Position = UDim2.new(1, - (dropdownFrame.AbsoluteSize.X * 0.5) - 8, 0.1, 0)
    -- ListFrame bên dưới dropdownFrame
    listFrame.Position = UDim2.new(0, 16, 0, dropdownFrame.AbsolutePosition.Y + dropdownFrame.AbsoluteSize.Y - container.AbsolutePosition.Y)
    listFrame.Size = UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, 0)
end)

-- ===== Logic Back Button =====
backBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ===== Logic Switch =====
local function updateSwitchUI(on)
    if on then
        switchBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        circle:TweenPosition(UDim2.new(1, -22, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    else
        switchBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        circle:TweenPosition(UDim2.new(0, 2, 0.5, -10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end
end

switchBtn.MouseButton1Click:Connect(function()
    switchOn = not switchOn
    updateSwitchUI(switchOn)
    if switchOn then
        -- bật: lấy giá trị từ input (nếu hợp lệ) hoặc default
        local num = tonumber(speedInput.Text)
        if num and num >= 0 then
            humanoid.WalkSpeed = num
        else
            humanoid.WalkSpeed = defaultSpeed
            speedInput.Text = tostring(defaultSpeed)
        end
    else
        -- tắt: reset về default
        humanoid.WalkSpeed = defaultSpeed
    end
end)

-- Khởi tạo vị trí switch OFF
updateSwitchUI(false)

-- ===== Logic Input =====
-- Khi GUI load, gán giá trị defaultSpeed vào input
speedInput.Text = tostring(defaultSpeed)

-- Khi người dùng enter hoặc out focus
speedInput.FocusLost:Connect(function(enterPressed)
    local text = speedInput.Text
    local num = tonumber(text)
    if num and num >= 0 then
        -- hợp lệ
        if switchOn then
            humanoid.WalkSpeed = num
        end
    else
        -- không hợp lệ: reset hiển thị về defaultSpeed hoặc 0
        speedInput.Text = tostring(defaultSpeed)
        if switchOn then
            humanoid.WalkSpeed = defaultSpeed
        end
    end
end)

-- ===== Logic Dropdown =====
local dropdownOpen = false
dropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        -- show listFrame: tính chiều cao = số item * 30 + padding
        listFrame.Visible = true
        -- xóa nếu có sẵn
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        -- tạo các option
        for i, info in ipairs(presets) do
            local btn = Instance.new("TextButton")
            btn.Name = "Opt"..i
            btn.Size = UDim2.new(1, -16, 0, 30)
            btn.Position = UDim2.new(0, 8, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.Text = info.name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.LayoutOrder = i
            btn.Parent = listFrame

            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                -- Khi chọn:
                if info.value then
                    speedInput.Text = tostring(info.value)
                else
                    speedInput.Text = tostring(defaultSpeed)
                end
                dropdownBtn.Text = info.name
                -- ẩn list
                dropdownOpen = false
                -- Tween xẹp height về 0
                listFrame:TweenSize(UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true, function()
                    listFrame.Visible = false
                end)
                -- Áp dụng luôn nếu switchOn
                local num = tonumber(speedInput.Text)
                if switchOn and num and num >= 0 then
                    humanoid.WalkSpeed = num
                end
            end)
        end
        -- Tween mở ra: height = (#presets * 30) + padding trên/dưới
        local total = #presets * 30 + 8
        listFrame.Size = UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, 0)
        listFrame.Position = UDim2.new(0, 16, 0, dropdownFrame.AbsolutePosition.Y + dropdownFrame.AbsoluteSize.Y - container.AbsolutePosition.Y)
        listFrame:TweenSize(UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, total), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    else
        -- đóng dropdown
        dropdownBtn.Text = dropdownBtn.Text -- giữ text
        listFrame:TweenSize(UDim2.new(0, dropdownFrame.AbsoluteSize.X, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true, function()
            listFrame.Visible = false
        end)
    end
end)

-- ===== Logic Khôi phục =====
applyBtn.MouseButton1Click:Connect(function()
    speedInput.Text = tostring(defaultSpeed)
    dropdownBtn.Text = "Chọn..."
    if switchOn then
        humanoid.WalkSpeed = defaultSpeed
    end
end)

-- ===== Khởi tạo lần đầu =====
-- Đảm bảo humanoid đã sẵn sàng, sau đó set default vào input
if player.Character then
    setupHumanoid()
else
    player.CharacterAdded:Wait()
    setupHumanoid()
end

-- Kéo draggable toàn bộ container khi cần
container.Active = true
container.Draggable = true

