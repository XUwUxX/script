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

-- LOGIC NHẬN DIỆN THÔNG MINH
local function GetRoleColor(player)
    local char = player.Character
    if not char then return Color3.fromRGB(200, 200, 200) end

    -- Ưu tiên kiểm tra Murder (Knife)
    if player.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
        return Color3.fromRGB(255, 0, 0) -- Đỏ
    end

    -- Kiểm tra Gun (Sheriff vs Hero)
    local gun = player.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
    if gun then
        -- Logic: MM2 đặt Sheriff có thuộc tính 'Sheriff' trong Folder dữ liệu
        -- Nếu không có, kẻ cầm súng chắc chắn là Hero (Innocent nhặt súng)
        if player:FindFirstChild("TempRole") and player.TempRole.Value == "Sheriff" then
            return Color3.fromRGB(0, 100, 255) -- Xanh dương
        elseif player:FindFirstChild("Role") and player.Role.Value == "Sheriff" then
            return Color3.fromRGB(0, 100, 255) -- Xanh dương
        else
            return Color3.fromRGB(255, 255, 0) -- Vàng
        end
    end

    return Color3.fromRGB(200, 200, 200) -- Innocent
end

-- CẬP NHẬT HIGHLIGHT
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
            
            -- Nếu chưa có highlight hoặc highlight cũ bị kẹt (sang ván mới char mới)
            if not highlight or highlight.Adornee ~= char then
                if highlight then highlight:Destroy() end
                highlight = Instance.new("Highlight")
                highlight.Parent = CoreGui
                highlight.Adornee = char
                highlights[p] = highlight
            end
            
            local color = GetRoleColor(p)
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.5
        else
            if highlights[p] then
                highlights[p]:Destroy()
                highlights[p] = nil
            end
        end
    end
end

-- EVENT
toggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    toggleBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)
end)

-- Vòng lặp tối ưu
task.spawn(function()
    while task.wait(0.3) do -- Tăng tốc độ nhận diện lên 0.3s
        if espActive then
            UpdateESP()
        end
    end
end)
