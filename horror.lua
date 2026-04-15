local p, l, r, u, t, c = game:GetService("Players").LocalPlayer, game:GetService("Lighting"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("CoreGui")
local s, o = {f = false, n = false, s = false, j = false}, {b = l.Brightness, c = l.ClockTime, g = l.GlobalShadows, a = l.Ambient}

local g = Instance.new("ScreenGui", c)
local b = Instance.new("Frame", g)
b.Size, b.Position, b.BackgroundColor3, b.BackgroundTransparency = UDim2.fromScale(0, 0), UDim2.fromScale(.5, .5), Color3.new(0, 0, 0), .2
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
Instance.new("UIListLayout", b).Padding = UDim.new(0, 5)

local function x(v, k)
    local f = Instance.new("TextButton", b)
    f.Size, f.BackgroundTransparency, f.Text, f.TextColor3, f.Font = UDim2.new(1, -20, 0, 30), .8, v, Color3.new(1, 1, 1), 3
    f.MouseButton1Click:Connect(function() 
        s[k] = not s[k] 
        f.TextColor3 = s[k] and Color3.new(0, 1, 0) or Color3.new(1, 1, 1) 
    end)
end

local function m(v)
    t:Create(b, TweenInfo.new(.3), {
        Size = v and UDim2.new(0, 180, 0, 150) or UDim2.new(0, 0, 0, 0), 
        Position = v and UDim2.new(.5, -90, .5, -75) or UDim2.new(.5, 0, .5, 0)
    }):Play()
end

-- Khởi tạo nút với Key mapping
local cmds = {["SÁNG (F)"] = "f", ["BÓNG (N)"] = "n", ["TỐC ĐỘ (S)"] = "s", ["NHẢY (J)"] = "j"}
for n, k in pairs(cmds) do x(n, k) end

-- Tư duy ngược: Chỉ cập nhật khi cần hoặc dùng logic đảo
r.RenderStepped:Connect(function()
    l.Brightness = s.f and 2 or o.b
    l.ClockTime = s.f and 14 or o.c
    l.Ambient = s.f and Color3.new(1, 1, 1) or o.a
    l.GlobalShadows = not s.n and o.g or false
    
    local h = p.Character and p.Character:FindFirstChild("Humanoid")
    if h then h.WalkSpeed = s.s and 30 or 16 end
end)

u.JumpRequest:Connect(function() 
    local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if s.j and h then h:ChangeState(3) end 
end)

u.InputBegan:Connect(function(i, processed) 
    if not processed and i.KeyCode == Enum.KeyCode.RightControl then 
        g.Enabled = not g.Enabled 
        m(g.Enabled)
    end 
end)

m(true)
