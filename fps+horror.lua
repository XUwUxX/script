-- LocalScript (đặt trong StarterPlayerScripts)
local Players          = game:GetService("Players")
local Debris           = game:GetService("Debris")
local player           = Players.LocalPlayer
local camera           = workspace.CurrentCamera

-- Khi character load xong, tạo GUI
local function makeGUI()
    -- dọn nếu GUI cũ còn sót
    local old = player:FindFirstChild("PlayerGui"):FindFirstChild("SelfFlingGUI")
    if old then old:Destroy() end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name   = "SelfFlingGUI"
    screenGui.Parent = player.PlayerGui

    -- Frame
    local frame = Instance.new("Frame", screenGui)
    frame.Size              = UDim2.new(0, 200, 0, 140)
    frame.Position          = UDim2.new(0.8, 0, 0.3, 0)
    frame.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel   = 0

    -- GIẢN LƯỢC drag bằng Draggable
    frame.Active    = true
    frame.Draggable = true

    -- Move & Close không còn cần logic drag/close
    local btnClose = Instance.new("TextButton", frame)
    btnClose.Text           = "Close"
    btnClose.Size           = UDim2.new(0, 80, 0, 25)
    btnClose.Position       = UDim2.new(0.55, 0, 0, 5)
    btnClose.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btnClose.TextColor3       = Color3.new(1,1,1)
    btnClose.BorderSizePixel  = 0
    btnClose.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Fling button
    local btnFling = Instance.new("TextButton", frame)
    btnFling.Text            = "Fling!"
    btnFling.Size            = UDim2.new(1, -10, 0, 40)
    btnFling.Position        = UDim2.new(0, 5, 0, 40)
    btnFling.BackgroundColor3= Color3.fromRGB(100, 0, 0)
    btnFling.TextColor3      = Color3.new(1,1,1)
    btnFling.BorderSizePixel = 0

    -- Strength textbox
    local txtStrength = Instance.new("TextBox", frame)
    txtStrength.PlaceholderText = "Strength"
    txtStrength.Text            = "200"
    txtStrength.Size            = UDim2.new(1, -10, 0, 25)
    txtStrength.Position        = UDim2.new(0, 5, 0, 90)
    txtStrength.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    txtStrength.TextColor3       = Color3.new(1,1,1)
    txtStrength.BorderSizePixel  = 0
    txtStrength.ClearTextOnFocus = false

    -- Xử lý Self‑Fling
    btnFling.MouseButton1Click:Connect(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- bật ragdoll
        humanoid.PlatformStand = true

        -- đọc strength
        local strength = tonumber(txtStrength.Text) or 200
        local horizFactor = 0.4  -- tỉ lệ lực ngang
        local upForce     = strength

        -- lực ngang: trái/phải ngẫu nhiên
        local sign = (math.random() < 0.5) and -1 or 1
        local horizontalDir = camera.CFrame.RightVector * strength * horizFactor * sign
        local verticalDir   = Vector3.new(0, upForce, 0)
        local flingVector   = horizontalDir + verticalDir

        -- BodyVelocity
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Velocity = flingVector
        bv.Parent   = hrp

        -- BodyAngularVelocity để xoay tít
        local bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque       = Vector3.new(1e5,1e5,1e5)
        bav.AngularVelocity = Vector3.new(
            math.random(-10,10),
            math.random(-10,10),
            math.random(-10,10)
        )
        bav.Parent = hrp

        -- dọn dẹp và trả humanoid về bình thường
        delay(0.3, function()
            bv:Destroy()
            bav:Destroy()
            if humanoid and humanoid.Parent then
                humanoid.PlatformStand = false
            end
        end)
    end)
end

-- Khi respawn hoặc lần đầu, gọi makeGUI
player.CharacterAdded:Connect(makeGUI)
if player.Character then
    makeGUI()
end
