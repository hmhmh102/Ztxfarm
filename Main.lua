-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- SERVER HOP SETTINGS
local AUTO_SERVER_HOP = true
local SERVER_HOP_DELAY = 60
local LastServerHop = 0

-- LOAD GUARD
if getgenv().AutoKillLoaded then return end
getgenv().AutoKillLoaded = true

-- STATE
local Character, Humanoid, Hand, Punch
local Running = true
local StartTime = os.time()

-- KILL STATS
local TotalKills = 0
local SessionStartTime = os.clock()

-- SETTINGS
local WhitelistFriends = true
local KillOnlyWeaker = true

getgenv().WhitelistedPlayers = getgenv().WhitelistedPlayers or {}

-- SERVER HOP
local function ServerHop()
    local servers = {}
    local cursor = ""

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

-- DAMAGE
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

-- UPDATE CHAR
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

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- GUI
local Screen = Instance.new("ScreenGui", game.CoreGui)
Screen.ResetOnSpawn = false

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0,180,0,190)
Main.Position = UDim2.new(0.5,-90,0.1,0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,22)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Code
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 13
Title.Text = "Auto Kill Control"

local AvgLabel = Instance.new("TextLabel", Main)
AvgLabel.Position = UDim2.new(0,8,0,30)
AvgLabel.Size = UDim2.new(1,-10,0,18)
AvgLabel.BackgroundTransparency = 1
AvgLabel.Font = Enum.Font.Code
AvgLabel.TextColor3 = Color3.new(1,1,1)
AvgLabel.TextSize = 13
AvgLabel.TextXAlignment = Left
AvgLabel.Text = "avg: 0.00 / min"

local StartBtn = Instance.new("TextButton", Main)
StartBtn.Position = UDim2.new(0,8,0,60)
StartBtn.Size = UDim2.new(0,78,0,18)
StartBtn.Text = "Start"
StartBtn.Font = Enum.Font.Code
StartBtn.TextColor3 = Color3.fromRGB(0,255,0)

local StopBtn = Instance.new("TextButton", Main)
StopBtn.Position = UDim2.new(0,94,0,60)
StopBtn.Size = UDim2.new(0,78,0,18)
StopBtn.Text = "Stop"
StopBtn.Font = Enum.Font.Code
StopBtn.TextColor3 = Color3.fromRGB(255,0,0)

StartBtn.MouseButton1Click:Connect(function()
    Running = true
    TotalKills = 0
    SessionStartTime = os.clock()
end)

StopBtn.MouseButton1Click:Connect(function()
    Running = false
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not Running then return end

    -- AUTO SERVER HOP
    if AUTO_SERVER_HOP and os.clock() - LastServerHop >= SERVER_HOP_DELAY then
        LastServerHop = os.clock()
        ServerHop()
        return
    end

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

    -- AVG RATE
    local elapsed = os.clock() - SessionStartTime
    if elapsed > 1 then
        local avg = TotalKills / (elapsed / 60)
        AvgLabel.Text = string.format("avg: %.2f / min", avg)
    end
end)
