local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local AUTO_SERVER_HOP = true
local SERVER_HOP_DELAY = 60 -- seconds
local LastServerHop = 0

if getgenv().AutoKillLoaded then return end
getgenv().AutoKillLoaded = true

local Character, Humanoid, Hand, Punch, Animator
local LastAttack, LastRespawn, LastCheck = 0, 0, 0
local Running = true
local StartTime = os.time()
local WhitelistFriends = true
local KillOnlyWeaker = true

getgenv().WhitelistedPlayers = getgenv().WhitelistedPlayers or {}
getgenv().TempWhitelistStronger = getgenv().TempWhitelistStronger or {}

local BlockedAnimations = {
    ["rbxassetid://3638729053"] = true,
    ["rbxassetid://3638749874"] = true,
    ["rbxassetid://3638767427"] = true,
    ["rbxassetid://102357151005774"] = true
}

local function ServerHop()
    local PlaceId = game.PlaceId
    local Servers = {}
    local Cursor = ""

    repeat
        local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if Cursor ~= "" then
            Url ..="&cursor="..Cursor
        end

        local Data = HttpService:JSONDecode(game:HttpGet(Url))
        for _, Server in ipairs(Data.data) do
            if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                table.insert(Servers, Server.id)
            end
        end
        Cursor = Data.nextPageCursor or ""
    until Cursor == "" or #Servers > 0

    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, Servers[math.random(#Servers)], LocalPlayer)
    end
end

local function GetPlayerStatValue(Player, Names)
    for _, Name in ipairs(Names) do
        local Attr = Player:GetAttribute(Name)
        if Attr then return tonumber(Attr) end
    end
    local stats = Player:FindFirstChild("leaderstats")
    if stats then
        for _, Name in ipairs(Names) do
            local v = stats:FindFirstChild(Name)
            if v then return tonumber(v.Value) end
        end
    end
    return nil
end

local function GetLocalPlayerDamage()
    return GetPlayerStatValue(LocalPlayer, {"Damage","DMG","Attack","Strength","Str"}) or 1
end

local function GetTargetHealth(Player)
    local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
    return hum and hum.MaxHealth or 100
end

local function UpdateWhitelist()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p:IsFriendsWith(LocalPlayer.UserId) then
            table.insert(getgenv().WhitelistedPlayers, p.Name)
        end
    end
end

local function IsWhitelisted(p)
    for _, n in ipairs(getgenv().WhitelistedPlayers) do
        if n:lower() == p.Name:lower() then
            return true
        end
    end
    return false
end

local function ShouldKillPlayer(p)
    if not KillOnlyWeaker then return true end
    local dmg = GetLocalPlayerDamage()
    local hp = GetTargetHealth(p)
    return math.ceil(hp / dmg) <= 5
end

local function UpdateAll()
    Character = LocalPlayer.Character
    Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    Hand = Character and (Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm"))
    Punch = Character and Character:FindFirstChild("Punch")
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

UpdateAll()
UpdateWhitelist()

RunService.RenderStepped:Connect(function()
    if not Running then return end

    if AUTO_SERVER_HOP and os.clock() - LastServerHop >= SERVER_HOP_DELAY then
        LastServerHop = os.clock()
        ServerHop()
        return
    end

    if not Character or not Humanoid then
        UpdateAll()
        return
    end

    if not Punch then
        local tool = LocalPlayer.Backpack:FindFirstChild("Punch")
        if tool then Humanoid:EquipTool(tool) end
        return
    end

    Punch.attackTime.Value = 0
    Punch:Activate()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not IsWhitelisted(p) and ShouldKillPlayer(p) then
            local c = p.Character
            if c then
                local h = c:FindFirstChild("Humanoid")
                local head = c:FindFirstChild("Head")
                local root = c:FindFirstChild("HumanoidRootPart")
                if h and head and root and h.Health > 0 then
                    root.Anchored = true
                    firetouchinterest(head, Hand, 0)
                    firetouchinterest(head, Hand, 1)
                    root.Anchored = false
                end
            end
        end
    end
end)
