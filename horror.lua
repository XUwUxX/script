local p = game:GetService("Players").LocalPlayer
local l = game:GetService("Lighting")
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local t = game:GetService("TweenService")
local c = game:GetService("CoreGui")

local s = {f = false, n = false, s = false, j = false}
local o = {b = l.Brightness, c = l.ClockTime, g = l.GlobalShadows, a = l.Ambient}

local g = Instance.new("ScreenGui", c)
local b = Instance.new("Frame", g)
b.Size, b.Position, b.BackgroundColor3, b.BackgroundTransparency = UDim2.new(0,0,0,0), UDim2.new(.5,0,.5,0), Color3.new(0,0,0), .2
Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)

local function x(v)
    local f = Instance.new("TextButton", b)
    f.Size, f.BackgroundTransparency, f.Text, f.TextColor3, f.Font = UDim2.new(1,-20,0,30), .8, v, Color3.new(1,1,1), 3
    Instance.new("UIListLayout", b).Padding = UDim.new(0,5)
    return f
end

local function m(v)
    t:Create(b, TweenInfo.new(.3), {Size = v and UDim2.new(0,180,0,160) or UDim2.new(0,0,0,0), Position = v and UDim2.new(.5,-90,.5,-80) or UDim2.new(.5,0,.5,0)}):Play()
end

local h = x("FULLBRIGHT")
local n = x("NO SHADOW")
local w = x("SPEED")
local j = x("INF JUMP")

h.MouseButton1Click:Connect(function() s.f = not s.f h.TextColor3 = s.f and Color3.new(0,1,0) or Color3.new(1,1,1) end)
n.MouseButton1Click:Connect(function() s.n = not s.n n.TextColor3 = s.n and Color3.new(0,1,0) or Color3.new(1,1,1) end)
w.MouseButton1Click:Connect(function() s.s = not s.s w.TextColor3 = s.s and Color3.new(0,1,0) or Color3.new(1,1,1) end)
j.MouseButton1Click:Connect(function() s.j = not s.j j.TextColor3 = s.j and Color3.new(0,1,0) or Color3.new(1,1,1) end)

r.RenderStepped:Connect(function()
    if s.f then l.Brightness, l.ClockTime, l.Ambient = 2, 14, Color3.new(1,1,1) else l.Brightness, l.ClockTime, l.Ambient = o.b, o.c, o.a end
    l.GlobalShadows = not s.n and o.g or false
    if p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.WalkSpeed = s.s and 30 or 16 end
end)

u.JumpRequest:Connect(function() if s.j and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then p.Character:FindFirstChildOfClass("Humanoid"):ChangeState(3) end end)
u.InputBegan:Connect(function(i, q) if not q and i.KeyCode == Enum.KeyCode.RightControl then g.Enabled = not g.Enabled if g.Enabled then m(true) end end end)

m(true)
