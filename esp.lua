local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local espActive = false
local highlights = {}

-- 1. XỬ LÝ GIAO DIỆN (UI)
local screenGui = Instance.new("ScreenGui", CoreGui)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "ESP"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Draggable = true -- Cho phép kéo thả nút

-- 2. LOGIC PHÂN LOẠI VAI TRÒ (TƯ DUY NGƯỢC)
local function GetRoleColor(player)
    if not player or not player.Character then return nil end
    
    -- Kiểm tra từ Inventory (Backpack) hoặc trên tay (Character)
    local items = {}
    for _, item in ipairs(player.Backpack:GetChildren()) do table.insert(items, item.Name) end
    for _, item in ipairs(player.Character:GetChildren()) do table.insert(items, item.Name) end
    
    for _, name in ipairs(items) do
        if name == "Knife" then return Color3.fromRGB(255, 0, 0) end -- Murder (Đỏ)
        if name == "Gun" then
            -- Hero (Vàng) nếu không phải Sheriff gốc (Tư duy ngược: Sheriff chỉ có ở đầu game)
            -- Trong MM2, Hero thường là người nhặt súng sau khi Sheriff chết
            local isSheriff = player:FindFirstChild("Role") and player.Role.Value == "Sheriff"
            return isSheriff and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 255, 0)
        end
    end
    return Color3.fromRGB(200, 200, 200) -- Innocent (Xám)
end

-- 3. HÀM CẬP NHẬT ESP (OPTIMIZED)
local function UpdateESP()
    if not espActive then
        for _, h in pairs(highlights) do h:Destroy() end
        table.clear(highlights)
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        if char then
            local highlight = highlights[p]
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Parent = CoreGui
                highlight.Adornee = char
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlights[p] = highlight
            end
            
            highlight.Adornee = char
            highlight.FillColor = GetRoleColor(p)
            highlight.OutlineColor = GetRoleColor(p)
        end
    end
end

-- 4. EVENT HANDLING
toggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    toggleBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)
    if not espActive then UpdateESP() end
end)

-- Chạy mỗi 0.5s để tiết kiệm CPU thay vì mỗi frame
task.spawn(function()
    while true do
        UpdateESP()
        task.wait(0.5)
    end
end)

-- Xóa highlight khi người chơi thoát
Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then
        highlights[p]:Destroy()
        highlights[p] = nil
    end
end)
