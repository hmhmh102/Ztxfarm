-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- LOAD GUARD
if getgenv().AutoKillLoaded then return end
getgenv().AutoKillLoaded = true

-- STATE
local Character, Humanoid, Hand, Punch
local Running = false

-- SETTINGS (UI controlled)
local AUTO_KILL = false
local AUTO_SERVER_HOP = false
local SERVER_HOP_DELAY = 60
local LastServerHop = 0
local KillOnlyWeaker = true
local WhitelistFriends = true

-- STATS
local TotalKills = 0
local SessionStartTime = os.clock()

getgenv().WhitelistedPlayers = {}

-- ======================
-- UTILS
-- ======================

local function UpdateChar()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        Hand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
        Punch = Character:FindFirstChild("Punch")
    end
end
UpdateChar()
LocalPlayer.CharacterAdded:Connect(UpdateChar)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local function GetLocalDamage()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        for _, n in ipairs({"Damage","DMG","Strength","Attack","Str"}) do
            local v = stats:FindFirstChild(n)
            if v then return v.Value end
        end
    end
    return 1
end

local function CanKill(p)
    if not KillOnlyWeaker then return true end
    local h = p.Character and p.Character:FindFirstChild("Humanoid")
    if not h then return false end
    return math.ceil(h.MaxHealth / GetLocalDamage()) <= 5
end

-- ======================
-- SERVER HOP
-- ======================
local function ServerHop()
    local servers, cursor = {}, ""
    repeat
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        if cursor ~= "" then url ..="&cursor="..cursor end
        local data = HttpService:JSONDecode(game:HttpGet(url))
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
        cursor = data.nextPageCursor or ""
    until cursor == "" or #servers > 0

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(#servers)], LocalPlayer)
    end
end

-- ======================
-- SIMPLE UI
-- ======================
local Screen = Instance.new("ScreenGui", game.CoreGui)
Screen.ResetOnSpawn = false

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0,200,0,240)
Main.Position = UDim2.new(0.5,-100,0.15,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,24)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Code
Title.Text = "Auto Kill UI"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 14

local function MakeButton(text, y)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(1,-16,0,20)
    b.Position = UDim2.new(0,8,0,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.Font = Enum.Font.Code
    b.TextSize = 13
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    return b
end

local AutoKillBtn   = MakeButton("Auto Kill: OFF", 32)
local ServerHopBtn  = MakeButton("Server Hop: OFF", 56)
local WeakerBtn     = MakeButton("Kill Weaker Only: ON", 80)
local FriendBtn     = MakeButton("Whitelist Friends: ON", 104)

local StartBtn = MakeButton("START", 136)
StartBtn.TextColor3 = Color3.fromRGB(0,255,0)

local StopBtn = MakeButton("STOP", 160)
StopBtn.TextColor3 = Color3.fromRGB(255,0,0)

local AvgLabel = Instance.new("TextLabel", Main)
AvgLabel.Position = UDim2.new(0,8,0,192)
AvgLabel.Size = UDim2.new(1,-16,0,20)
AvgLabel.BackgroundTransparency = 1
AvgLabel.Font = Enum.Font.Code
AvgLabel.TextSize = 13
AvgLabel.TextColor3 = Color3.new(1,1,1)
AvgLabel.Text = "avg: 0.00 / min"

-- ======================
-- BUTTON LOGIC
-- ======================
AutoKillBtn.MouseButton1Click:Connect(function()
    AUTO_KILL = not AUTO_KILL
    AutoKillBtn.Text = "Auto Kill: " .. (AUTO_KILL and "ON" or "OFF")
end)

ServerHopBtn.MouseButton1Click:Connect(function()
    AUTO_SERVER_HOP = not AUTO_SERVER_HOP
    ServerHopBtn.Text = "Server Hop: " .. (AUTO_SERVER_HOP and "ON" or "OFF")
end)

WeakerBtn.MouseButton1Click:Connect(function()
    KillOnlyWeaker = not KillOnlyWeaker
    WeakerBtn.Text = "Kill Weaker Only: " .. (KillOnlyWeaker and "ON" or "OFF")
end)

FriendBtn.MouseButton1Click:Connect(function()
    WhitelistFriends = not WhitelistFriends
    FriendBtn.Text = "Whitelist Friends: " .. (WhitelistFriends and "ON" or "OFF")
end)

StartBtn.MouseButton1Click:Connect(function()
    Running = true
    TotalKills = 0
    SessionStartTime = os.clock()
end)

StopBtn.MouseButton1Click:Connect(function()
    Running = false
end)

-- ======================
-- MAIN LOOP
-- ======================
RunService.RenderStepped:Connect(function()
    if not Running then return end

    if AUTO_SERVER_HOP and os.clock() - LastServerHop >= SERVER_HOP_DELAY then
        LastServerHop = os.clock()
        ServerHop()
        return
    end

    if not AUTO_KILL then return end

    UpdateChar()
    if not Character or not Humanoid or not Hand then return end

    if not Punch then
        local t = LocalPlayer.Backpack:FindFirstChild("Punch")
        if t then Humanoid:EquipTool(t) end
        return
    end

    Punch.attackTime.Value = 0
    Punch:Activate()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and CanKill(p) then
            local c = p.Character
            if c then
                local h = c:FindFirstChild("Humanoid")
                local head = c:FindFirstChild("Head")
                local root = c:FindFirstChild("HumanoidRootPart")
                if h and head and root and h.Health > 0 then
                    h.Died:Once(function()
                        TotalKills += 1
                    end)
                    root.Anchored = true
                    firetouchinterest(head, Hand, 0)
                    firetouchinterest(head, Hand, 1)
                    root.Anchored = false
                end
            end
        end
    end

    local elapsed = os.clock() - SessionStartTime
    if elapsed > 1 then
        AvgLabel.Text = string.format("avg: %.2f / min", TotalKills / (elapsed / 60))
    end
end)
