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

-- LOGIC NHẬN DIỆN VAI TRÒ (FIXED FOR ROUND RESET)
local function GetRoleColor(player)
    local char = player.Character
    if not char then return Color3.fromRGB(200, 200, 200) end

    -- Ưu tiên 1: Kiểm tra vật phẩm đang cầm trên tay (Thực tế nhất)
    local tool = char:FindFirstChildOfClass("Tool")
    local backpack = player:FindFirstChild("Backpack")
    
    local hasKnife = (tool and tool.Name == "Knife") or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (tool and tool.Name == "Gun") or (backpack and backpack:FindFirstChild("Gun"))

    if hasKnife then 
        return Color3.fromRGB(255, 0, 0) -- Murder
    end

    if hasGun then
        -- Tư duy ngược: Kiểm tra danh hiệu thực tế trong Game
        -- Trong MM2, Sheriff thật luôn có thuộc tính đặc biệt trong PlayerGui hoặc bảng điểm
        local isOfficialSheriff = player:FindFirstChild("Status") and player.Status:FindFirstChild("Role") and player.Status.Role.Value == "Sheriff"
        
        if isOfficialSheriff then
            return Color3.fromRGB(0, 120, 255) -- Sheriff
        else
            return Color3.fromRGB(255, 255, 0) -- Hero (Innocent cầm súng)
        end
    end

    return Color3.fromRGB(255, 255, 255) -- Innocent
end

-- QUẢN LÝ HIGHLIGHTS
local function CleanHighlights()
    for _, h in pairs(highlights) do h:Destroy() end
    table.clear(highlights)
end

local function UpdateESP()
    if not espActive then 
        CleanHighlights()
        return 
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local highlight = highlights[p]
            
            -- Nếu highlight cũ bị lỗi hoặc nhân vật mới (ván mới), tạo lại
            if not highlight or highlight.Adornee ~= char then
                if highlight then highlight:Destroy() end
                highlight = Instance.new("Highlight")
                highlight.Parent = CoreGui
                highlight.Name = "ESP_" .. p.Name
                highlights[p] = highlight
            end
            
            local color = GetRoleColor(p)
            highlight.Adornee = char
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 0
        else
            if highlights[p] then
                highlights[p]:Destroy()
                highlights[p] = nil
            end
        end
    end
end

-- TỰ ĐỘNG RESET KHI VÀO VÁN MỚI (Dựa trên việc túi đồ bị dọn dẹp)
localPlayer.Backpack.ChildRemoved:Connect(function()
    task.wait(1) -- Chờ server cấp role mới
    UpdateESP()
end)

toggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    toggleBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)
    if not espActive then CleanHighlights() end
end)

-- Vòng lặp tối ưu
task.spawn(function()
    while true do
        if espActive then UpdateESP() end
        task.wait(0.5) 
    end
end)
