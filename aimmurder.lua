local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local aimActive = false

-- 1. THÔNG BÁO (NOTIFICATION)
local function Notify(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "MM2 Aimlock",
        Text = msg,
        Duration = 2
    })
end

-- 2. TÌM MỤC TIÊU (MURDER) - TƯ DUY NGƯỢC
local function GetMurder()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Kiểm tra dao trong Inventory hoặc trên tay
            local hasKnife = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
            if hasKnife then
                return char.HumanoidRootPart
            end
        end
    end
    return nil
end

-- 3. LOGIC AIMLOCK (SHIFT LOCK STYLE)
RunService:BindToRenderStep("MM2_Aimlock", Enum.RenderPriority.Camera.Value + 1, function()
    -- Kiểm tra nếu đang cầm súng (Gun)
    local char = localPlayer.Character
    local holdingGun = char and char:FindFirstChild("Gun")
    
    if holdingGun then
        local target = GetMurder()
        if target then
            if not aimActive then
                aimActive = true
                Notify("Đã khóa mục tiêu: MURDER")
            end
            
            -- Xử lý Camera hướng thẳng vào mục tiêu
            local lookAt = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = lookAt
        else
            if aimActive then
                aimActive = false
                Notify("Mất dấu Murder...")
            end
        end
    else
        aimActive = false
    end
end)
