local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

if _G.FlingActive then
    _G.FlingActive = false
    if _G.FlingPart then _G.FlingPart:Destroy() end
    return
end

_G.FlingActive = true

local function CreateFlingPart()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local flinger = Instance.new("Part")
    flinger.Name = "FlingMechanism"
    flinger.Size = Vector3.new(2, 2, 2)
    flinger.Transparency = 1
    flinger.CanCollide = true
    flinger.CanTouch = true
    flinger.Massless = true
    flinger.Parent = char

    local attachment = Instance.new("Attachment", flinger)
    local angularVelocity = Instance.new("AngularVelocity", flinger)
    angularVelocity.Attachment0 = attachment
    angularVelocity.MaxTorque = math.huge
    angularVelocity.AngularVelocity = Vector3.new(99999, 99999, 99999) -- Lực xoay cực đại

    local weld = Instance.new("Weld", flinger)
    weld.Part0 = flinger
    weld.Part1 = hrp
    weld.C0 = CFrame.new(0, 0, 0)

    -- Tránh va chạm với chính mình
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local noCollide = Instance.new("NoCollisionConstraint", flinger)
            noCollide.Part0 = flinger
            noCollide.Part1 = part
        end
    end

    _G.FlingPart = flinger
end

CreateFlingPart()

_G.FlingConnection = RunService.PostSimulation:Connect(function()
    if not _G.FlingActive then
        if _G.FlingConnection then _G.FlingConnection:Disconnect() end
        return
    end
    
    if _G.FlingPart and _G.FlingPart.Parent then
        _G.FlingPart.AssemblyLinearVelocity = Vector3.new(9999, 9999, 9999)
    else
        CreateFlingPart()
    end
end)
