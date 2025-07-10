-- StarterPlayerScripts/UltraSmartAimlock.lua (LocalScript)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace        = game:GetService("Workspace")

local player    = Players.LocalPlayer
local camera    = workspace.CurrentCamera
local mouse     = player:GetMouse()

-- ==== CẤU HÌNH ====
local MAX_TARGET_DIST      = 120        -- studs
local BULLET_SPEED         = 600        -- studs/s
local INIT_PREDICT_FACTOR  = 1.1
local MIN_SMOOTH           = 0.2        -- smoothing khi target rất nhanh
local MAX_SMOOTH           = 0.8        -- smoothing khi target chậm
local ANGLE_IMMEDIATE_DEG  = 3          -- nếu lệch <3° thì set thẳng
local ADAPT_RATE           = 0.02       -- tốc độ tune predictFactor
local VERT_VEL_THRESHOLD   = 1.5        -- ngưỡng Y để xem là nhảy
-- ==========================

local aimEnabled    = false
local predictFactor = INIT_PREDICT_FACTOR
local lastTargetPos, lastPredictedPos, lastTravelTime

mouse.Button2Down:Connect(function() aimEnabled = true end)
mouse.Button2Up:Connect(function() aimEnabled = false end)

-- Tìm mục tiêu gần nhất
local function getClosestHRP()
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local best, bestDist = nil, math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl~=player and pl.Character then
            local o = pl.Character:FindFirstChild("HumanoidRootPart")
            if o then
                local d = (o.Position - hrp.Position).Magnitude
                if d < bestDist and d<=MAX_TARGET_DIST then
                    bestDist, best = d, o
                end
            end
        end
    end
    return best
end

-- Tính vị trí dự đoán “thông minh”
local function getSmartPredictedPos(part)
    local vel        = part.AssemblyLinearVelocity
    local dist       = (part.Position - camera.CFrame.Position).Magnitude
    local travelTime = dist / BULLET_SPEED
    lastTravelTime   = travelTime

    -- chọn Y-mode
    local useFullY = math.abs(vel.Y) <= VERT_VEL_THRESHOLD
    local horizVel = Vector3.new(vel.X, 0, vel.Z)
    local base     = part.Position + horizVel * travelTime * predictFactor

    local yComp = useFullY and (part.Position.Y + vel.Y * travelTime * predictFactor) or part.Position.Y
    return Vector3.new(base.X, yComp, base.Z)
end

-- Tính smoothing factor động
local function calcSmooth(vel)
    local speedXZ = Vector3.new(vel.X,0,vel.Z).Magnitude
    -- map speedXZ in [0, maxSpeed] to [MAX_SMOOTH, MIN_SMOOTH]
    local maxSpeed = 50
    local t = math.clamp(speedXZ / maxSpeed, 0, 1)
    return MAX_SMOOTH*(1-t) + MIN_SMOOTH*t
end

RunService.RenderStepped:Connect(function()
    if not aimEnabled then return end

    local target = getClosestHRP()
    if not target then return end

    -- compute predicted and desired direction
    local predPos    = getSmartPredictedPos(target)
    local camPos     = camera.CFrame.Position
    local desiredDir = (predPos - camPos).Unit
    local currDir    = camera.CFrame.LookVector

    -- angle between
    local angleDeg = math.deg(math.acos(math.clamp(currDir:Dot(desiredDir), -1,1)))

    -- smoothing factor based on target speed
    local smooth = calcSmooth(target.AssemblyLinearVelocity)

    if angleDeg < ANGLE_IMMEDIATE_DEG then
        camera.CFrame = CFrame.new(camPos, camPos + desiredDir)
    else
        local newDir = currDir:Lerp(desiredDir, smooth)
        camera.CFrame = CFrame.new(camPos, camPos + newDir)
    end

    -- adaptive tuning predictFactor
    if lastTargetPos and lastPredictedPos and lastTravelTime then
        local actualMove = (target.Position - lastTargetPos)
        local idealMove  = (lastPredictedPos - lastTargetPos)
        local errorDist  = (idealMove - actualMove).Magnitude
        local sign       = (actualMove.Magnitude > idealMove.Magnitude) and 1 or -1
        predictFactor    = math.clamp(predictFactor + ADAPT_RATE * sign * (errorDist / lastTravelTime), 0.8, 1.5)
    end

    lastTargetPos    = target.Position
    lastPredictedPos = predPos
end)
