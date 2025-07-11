-- StarterPlayerScripts/UltraSmartAimlock.lua

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local Workspace   = game:GetService("Workspace")
local StarterGui  = game:GetService("StarterGui")

local player   = Players.LocalPlayer
local camera   = Workspace.CurrentCamera
local mouse    = player:GetMouse()

-- 🆕 FOV & WalkSpeed
camera.FieldOfView = 90
local function onChar(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 17
end
if player.Character then onChar(player.Character) end
player.CharacterAdded:Connect(onChar)

-- ⚙️ Cấu hình
local MAX_DIST        = 120
local BULLET_SPEED    = 900
local OVERPREDICT     = 1.9
local ALPHA           = 0.7
local ANGLE_SNAP      = 3
local VEL_Y_THRESHOLD = 1.5
local FOV_LIMIT_DEG   = 60
local CLOSE_DIST      = 10    -- nâng lên 10 studs để xử lý gần tốt hơn
local SWITCH_DELAY    = 0.1

-- 🔘 State
local aimEnabled     = false
local emaVel         = Vector3.new()
local prevEmaVel     = Vector3.new()
local velInit        = false
local lastTime       = tick()
local lastTarget     = nil
local lastSwitchTime = 0

-- 🎯 Vòng tròn đỏ
local aimDot = Instance.new("Part")
aimDot.Name, aimDot.Anchored, aimDot.CanCollide, aimDot.Size, aimDot.Transparency =
"__AimDot", true, false, Vector3.new(0.1,0.1,0.1), 1
aimDot.Parent = Workspace

local bb = Instance.new("BillboardGui", aimDot)
bb.Size, bb.AlwaysOnTop, bb.Name, bb.Enabled =
UDim2.new(0,12,0,12), true, "AimIndicator", false
local frame = Instance.new("Frame", bb)
frame.Size, frame.BackgroundTransparency, frame.BorderSizePixel =
UDim2.new(1,0,1,0), 1, 0
frame.AnchorPoint, frame.Position = Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0)
Instance.new("UICorner", frame).CornerRadius = UDim.new(1,0)
local stroke = Instance.new("UIStroke", frame)
stroke.Color, stroke.Thickness = Color3.new(1,0,0), 1.8

StarterGui:SetCore("SendNotification", {
    Title = "Ultra Aimlock",
    Text  = "Loaded ✓",
    Duration = 3,
})

-- 🔄 Toggle aim
mouse.Button2Down:Connect(function()
    aimEnabled = true
    bb.Enabled  = true
end)
mouse.Button2Up:Connect(function()
    aimEnabled = false
    bb.Enabled  = false
end)

-- 🧠 EMA & store prev
local function updateEMA(part)
    local now = tick()
    local dt  = now - lastTime
    lastTime  = now

    local v = part.AssemblyLinearVelocity
    if dt > 0.5 or not velInit then
        emaVel, prevEmaVel = v, v
        velInit = true
    else
        prevEmaVel = emaVel
        emaVel = emaVel * (1 - ALPHA) + v * ALPHA
    end
    return dt
end

-- 📍 Prediction second-order
local function getPred(part)
    local dt = updateEMA(part)
    local camPos = camera.CFrame.Position
    local toP    = part.Position - camPos
    local dist   = toP.Magnitude

    if dist < CLOSE_DIST then
        return part.Position
    end

    local dir    = toP.Unit
    local travel = dist / BULLET_SPEED
    local accel  = (emaVel - prevEmaVel) / math.max(dt, 0.001)
    local lead1  = emaVel * travel
    local lead2  = accel * 0.5 * travel * travel
    local offset = (lead1 + lead2) * OVERPREDICT
    local base   = part.Position + offset

    local jumping= math.abs(emaVel.Y) > VEL_Y_THRESHOLD
    local lowC   = Workspace:Raycast(part.Position, Vector3.new(0,5,0)) ~= nil
    local y = (jumping or lowC or dist < CLOSE_DIST*1.25)
        and part.Position.Y
        or (part.Position.Y + emaVel.Y * travel * OVERPREDICT)

    return Vector3.new(base.X, y, base.Z)
end

-- 🎯 Chọn target body
local function getTarget()
    local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local best, bestScore = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl~=player and pl.Character then
            local part = pl.Character:FindFirstChild("LowerTorso")
                      or pl.Character:FindFirstChild("HumanoidRootPart")
            local hum  = pl.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health>0 then
                local d = (part.Position - myHRP.Position).Magnitude
                if d<=MAX_DIST then
                    local sp, onS = camera:WorldToViewportPoint(part.Position)
                    if onS then
                        local dx = math.abs(sp.X - camera.ViewportSize.X/2)
                        local dy = math.abs(sp.Y - camera.ViewportSize.Y/2)
                        local score = d + math.sqrt(dx*dx + dy*dy) * 0.6
                        if score<bestScore then
                            best, bestScore = part, score
                        end
                    end
                end
            end
        end
    end
    return best
end

-- 🔄 RenderStep (snap)
RunService:BindToRenderStep("UltraAim", Enum.RenderPriority.Camera.Value, function()
    if not aimEnabled then return end

    local now = tick()
    if not lastTarget or now - lastSwitchTime > SWITCH_DELAY then
        lastTarget, lastSwitchTime = getTarget(), now
    end
    if not lastTarget then return end

    local pred = getPred(lastTarget)
    local camPos= camera.CFrame.Position

    -- Nếu quá gần, snap vào vị trí body trực tiếp
    local dist = (lastTarget.Position - camPos).Magnitude
    if dist < CLOSE_DIST then
        camera.CFrame = CFrame.new(camPos, lastTarget.Position)
        aimDot.Position = lastTarget.Position
        return
    end

    -- Bình thường: second-order prediction
    local want = (pred - camPos).Unit
    camera.CFrame = CFrame.new(camPos, camPos + want)
    aimDot.Position = pred
end)
