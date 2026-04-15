local p, l, r, u, t, c = game:GetService("Players").LocalPlayer, game:GetService("Lighting"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("CoreGui")
local s, o = {f = false, n = false, s = false, j = false}, {b = l.Brightness, c = l.ClockTime, g = l.GlobalShadows, a = l.Ambient}

local g = Instance.new("ScreenGui", c)
local b = Instance.new("Frame", g)
b.Size, b.Position, b.BackgroundColor3, b.BorderSizePixel, b.ClipsDescendants = UDim2.fromOffset(450, 300), UDim2.fromScale(.5, .5), Color3.fromRGB(22, 22, 26), 0, true
b.AnchorPoint = Vector2.new(.5, .5)
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

-- Sidebar (Thanh bên)
local sb = Instance.new("Frame", b)
sb.Size, sb.BackgroundColor3, sb.BorderSizePixel = UDim2.new(0, 130, 1, 0), Color3.fromRGB(28, 29, 34), 0

local tit = Instance.new("TextLabel", sb)
tit.Size, tit.Text, tit.TextColor3, tit.Font, tit.TextSize, tit.BackgroundTransparency = UDim2.new(1, 0, 0, 40), "KEVINZ STYLE", Color3.fromRGB(0, 200, 255), 4, 14, 1

-- Nút đóng (X)
local cl = Instance.new("TextButton", b)
cl.Size, cl.Position, cl.BackgroundTransparency, cl.Text, cl.TextColor3, cl.Font, cl.TextSize = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), 1, "×", Color3.new(1, 0, 0), 3, 25
cl.ZIndex = 5
cl.MouseButton1Click:Connect(function() g.Enabled = false end)

-- Container (Nội dung bên phải)
local ct = Instance.new("ScrollingFrame", b)
ct.Size, ct.Position, ct.BackgroundTransparency, ct.BorderSizePixel, ct.ScrollBarThickness = UDim2.new(1, -140, 1, -50), UDim2.new(0, 140, 0, 40), 1, 0, 0
local lyt = Instance.new("UIListLayout", ct)
lyt.Padding = UDim.new(0, 6)

local function x(v, i, k)
    local f = Instance.new("TextButton", ct)
    f.Size, f.BackgroundColor3, f.Text, f.TextColor3, f.Font, f.TextSize, f.AutoButtonColor = UDim2.new(1, -10, 0, 35), Color3.fromRGB(35, 36, 42), "  " .. i .. " " .. v, Color3.new(.8, .8, .8), 3, 13, false
    f.TextXAlignment = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local ind = Instance.new("Frame", f)
    ind.Size, ind.Position, ind.BackgroundColor3, ind.BorderSizePixel = UDim2.new(0, 4, 1, 0), UDim2.new(1, -4, 0, 0), Color3.fromRGB(45, 45, 50), 0
    Instance.new("UICorner", ind)

    f.MouseButton1Click:Connect(function() 
        s[k] = not s[k] 
        t:Create(ind, TweenInfo.new(.2), {BackgroundColor3 = s[k] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(45, 45, 50)}):Play()
        f.TextColor3 = s[k] and Color3.new(1, 1, 1) or Color3.new(.8, .8, .8)
    end)
end

local function m(v)
    t:Create(b, TweenInfo.new(.4, 6), {Size = v and UDim2.fromOffset(450, 300) or UDim2.fromOffset(0, 0)}):Play()
end

-- Danh sách tính năng với Icon
local cmds = {{"FullBright", "☀", "f"}, {"No Shadows", "🌑", "n"}, {"Speed Hack", "⚡", "s"}, {"Infinite Jump", "🦘", "j"}}
for _, v in ipairs(cmds) do x(v[1], v[2], v[3]) end

-- Logic vận hành (Tư duy ngược)
r.RenderStepped:Connect(function()
    l.Brightness, l.ClockTime, l.Ambient = s.f and 2 or o.b, s.f and 14 or o.c, s.f and Color3.new(1, 1, 1) or o.a
    l.GlobalShadows = not s.n and o.g or false
    local c = p.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s.s and 35 or 16 end
end)

u.JumpRequest:Connect(function() 
    local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if s.j and h then h:ChangeState(3) end 
end)

u.InputBegan:Connect(function(i, p) 
    if not p and i.KeyCode == Enum.KeyCode.RightControl then g.Enabled = not g.Enabled m(g.Enabled) end 
end)

m(true)
