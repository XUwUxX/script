local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Tốc độ đạn súng trong MM2 (Có thể tinh chỉnh. Khoảng 200-300 studs/sec)
local BULLET_SPEED = 250 

StarterGui:SetCore("SendNotification", {
    Title = "MM2 Aim V2",
    Text = "Active: Dynamic Prediction & Raycast",
    Duration = 3
})

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == localPlayer then continue end
        local char = p.Character
        if not char then continue end

        -- Lọc Role (Sniffer) hoặc Item
        local roleValue = p:FindFirstChild("Role") or (p:FindFirstChild("Backpack") and p:FindFirstChild("Backpack"):FindFirstChild("Role"))
        local isMurderer = (roleValue and roleValue.Value == "Murderer") or char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")

        if isMurderer then
            -- Tối ưu Hitbox: Ưu tiên Torso thực tế thay vì HumanoidRootPart ảo
            local targetPart = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if targetPart and hum and hum.Health > 0 then
                -- Tư duy ngược: Kiểm tra vật cản bằng Raycast
                local origin = camera.CFrame.Position
                local direction = (targetPart.Position - origin)
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {localPlayer.Character, char}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.IgnoreWater = true

                local hit = Workspace:Raycast(origin, direction, raycastParams)
                
                -- Nếu không có vật cản (đường đạn sạch), trả về mục tiêu
                if not hit then
                    return targetPart
                end
            end
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if tool and tool.Name == "Gun" then
        local targetPart = GetMurderer()
        
        if targetPart then
            local origin = camera.CFrame.Position
            local distance = (targetPart.Position - origin).Magnitude
            
            -- Tính thời gian bay của đạn để lấy hệ số Prediction chuẩn xác
            local timeToHit = distance / BULLET_SPEED
            
            -- Tính vị trí tương lai
            local predictedPos = targetPart.Position + (targetPart.AssemblyLinearVelocity * timeToHit)
            
            -- Tối ưu góc bắn: Hạ tọa độ Y xuống 0.5 stud vào vùng bụng/chân
            -- Chặn tỷ lệ hụt khi đối thủ thực hiện spam Space (Nhảy liên tục)
            predictedPos = predictedPos - Vector3.new(0, 0.5, 0)

            -- Xoay camera mượt (Lerp) - Giảm thiểu rủi ro bị phát hiện
            -- Hệ số 0.4: Tốc độ bám mục tiêu (1 là snap tức thì, 0.1 là rất chậm)
            local targetCFrame = CFrame.new(origin, predictedPos)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.4)
        end
    end
end)
