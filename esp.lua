local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local espActive = false
local highlights = {}

-- UI
local screenGui = Instance.new("ScreenGui", CoreGui)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "ESP"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Draggable = true

-- LOGIC NHẬN DIỆN VAI TRÒ (REVERSE SNIFFER)
local function GetRoleColor(p)
    local char = p.Character
    if not char then return nil end

    -- MM2 lưu Role trong Backpack hoặc trực tiếp trong Player object
    local roleValue = p:FindFirstChild("Role") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Role"))
    
    if roleValue and roleValue:IsA("StringValue") then
        local r = roleValue.Value
        if r == "Murderer" then return Color3.fromRGB(255, 0, 0) end
        if r == "Sheriff" then return Color3.fromRGB(0, 120, 255) end
        if r == "Hero" then return Color3.fromRGB(255, 255, 0) end
    end

    -- Dự phòng (Tư duy ngược qua vật phẩm thực tế)
    local backpack = p:FindFirstChild("Backpack")
    if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 0, 0)
    end
    
    local gun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    if gun then
        -- Nếu có súng mà không có tag Sheriff/Hero cụ thể từ StringValue, mặc định là Hero
        return Color3.fromRGB(255, 255, 0)
    end

    return Color3.fromRGB(255, 255, 255) -- Innocent
end

-- QUẢN LÝ ESP
local function UpdateESP()
    if not espActive then
        for _, h in pairs(highlights) do h:Destroy() end
        table.clear(highlights)
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local highlight = highlights[p]
            
            -- Tạo mới hoặc cập nhật Adornee nếu nhân vật thay đổi
            if not highlight or highlight.Parent == nil or highlight.Adornee ~= char then
                if highlight then highlight:Destroy() end
                highlight = Instance.new("Highlight")
                highlight.Parent = CoreGui
                highlights[p] = highlight
            end
            
            local color = GetRoleColor(p)
            highlight.Adornee = char
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
        else
            if highlights[p] then
                highlights[p]:Destroy()
                highlights[p] = nil
            end
        end
    end
end

-- XỬ LÝ SỰ KIỆN
toggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    toggleBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)
    if not espActive then UpdateESP() end
end)

-- Vòng lặp tối ưu: Quét nhanh khi bắt đầu ván, quét chậm khi đang chơi
task.spawn(function()
    while true do
        UpdateESP()
        -- Nếu đang bật ESP, quét liên tục 0.3s để bắt kịp tốc độ đổi Role của MM2
        task.wait(espActive and 0.3 or 1)
    end
end)
