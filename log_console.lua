local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local ts = os.clock()
local spinner = {"|", "/", "-", "\\"}
local successCount = 0
local failCount = 0

--// Game Name
local gameName = "Game"
pcall(function()
	gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

--// FPS Monitor
local fps = 0
do
	local count = 0
	local lastTime = os.clock()
	RunService.RenderStepped:Connect(function()
		count += 1
		local now = os.clock()
		if now - lastTime >= 1 then
			fps = count
			count = 0
			lastTime = now
		end
	end)
end

--// Progress Bar
local function progressBar(percent)
	local total = 20
	local filled = math.floor(total * percent)
	local empty = total - filled
	local bar = string.rep("█", filled) .. string.rep("░", empty)
	return string.format("[%-20s] %3d%%", bar, math.floor(percent * 100))
end

--// Spinner Loading
print("\n\n\n\n\n\n")
print("[ ⚙️  KevinzHub's Lib Loading for \"" .. gameName .. "\" ]\n")
task.wait(2)

for i = 0, 20 do
	local p = i / 20
	local spinChar = spinner[(i % #spinner) + 1]
	print("  " .. spinChar .. " " .. progressBar(p))
	task.wait(0.05)
end

print()
task.wait(0.5)

--// Module loading (with pcall)
local modules = {
	"Frame",
	"Window",
	"Icon",
    "Hook Json",
	"Ban List Json",
    "Web API data",
	"Anti Cheat module",
	"Optimize",
	"Players",
	"User Whitelist",
	"KevinzHub UI"
}

for _, name in ipairs(modules) do
	local success, result = pcall(function()
		if name == "Lol" then
			error("Simulated failure") -- giả lập lỗi
		end
	end)

	if success then
		warn("[+] Loaded " .. name)
		successCount += 1
	else
		warn("[x] Failed to load " .. name .. ": " .. result)
		failCount += 1
	end

	task.wait(0.1)
end

--// Final stats
task.wait(0.3)
print()
print("[✅] Run finished in " .. string.format("%.2f", os.clock() - ts) .. "s")
print("[📦] Modules Loaded: " .. successCount)
print("[❌] Modules Failed: " .. failCount)
print("[👤] Username: " .. player.Name)
print("[🌍] Players in Server: " .. #Players:GetPlayers())
print("[⚙️] FPS: ~" .. fps)


if failCount == 0 then
	local signature = [[
>>=============================================================<<
||.-. .-')    ('-.        (`-.                .-') _    .-') _ ||
||\  ( OO ) _(  OO)     _(OO  )_             ( OO ) )  (  OO) )||
||,--. ,--.(,------.,--(_/   ,. \ ,-.-') ,--./ ,--,' ,(_)----. ||
|||  .'   / |  .---'\   \   /(__/ |  |OO)|   \ |  |\ |       | ||
|||      /, |  |     \   \ /   /  |  |  \|    \|  | )'--.   /  ||
|||     ' _||  '--.   \   '   /,  |  |(_/|  .     |/ (_/   /   ||
|||  .   \  |  .--'    \     /__),|  |_.'|  |\    |   /   /___ ||
|||  |\   \ |  `---.    \   /   (_|  |   |  | \   |  |        |||
||`--' '--' `------'     `-'      `--'   `--'  `--'  `--------'|| 
>>=============================================================<<
]]
	print("\n" .. signature)
end
