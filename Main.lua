local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local username = localPlayer.Name
local userId = localPlayer.UserId

local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local muscleEvent = Player:WaitForChild("muscleEvent")
local antiAFKConnection



local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library//main/Library", true))()

local window = library:AddWindow("SCPxMLG | KTA ON BOTTOM", {
    main_color = Color3.fromRGB(180, 0, 0),
    min_size = Vector2.new(600, 630),
    can_resize = false,
})

local function setupAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
    end

    antiAFKConnection = Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
setupAntiAFK()

local function removePortals()
    for _, portal in pairs(game:GetDescendants()) do
        if portal.Name == "RobloxForwardPortals" then
            portal:Destroy()
        end
    end
    if _G.AdRemovalConnection then
        _G.AdRemovalConnection:Disconnect()
    end

    _G.AdRemovalConnection = game.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "RobloxForwardPortals" then
            descendant:Destroy()
        end
    end)
end
removePortals()

ReplicatedStorage.ChildAdded:Connect(function(child)
    if table.find(blockedFrames, child.Name) and child:IsA("GuiObject") then
        child.Visible = false
    end
end)

local MainTab = window:AddTab("Main")
local KillingTab = window:AddTab("Killing")
local SpecsTab = window:AddTab("Specs")
local FarmingTab = window:AddTab("Farming")
local InventoryTab = window:AddTab("Inventory")
local PetsTab = window:AddTab("Pet Shop")
local TeleportTab = window:AddTab("Teleports")
local StatsTab = window:AddTab("Stats")
local infoTab = window:AddTab("Info")
KillingTab:Show()
local farmTab = window:AddTab("rebirthing")

infoTab:AddLabel("Made by TEJAZ").TextSize = 20
infoTab:AddLabel("Official Discord: https://discord.gg/nDSy4jdVDc ")
infoTab:AddButton("Copy Discord Invite", function()
    local link = "https://discord.gg/9eFf93Kg8D"
    if setclipboard then
        setclipboard(link)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Link Copied!";
            Text = "You can continue to Discord now.";
            Duration = 3;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error!";
            Text = "Not Supported.";
            Duration = 3;
        })
    end
end)

infoTab:AddLabel("")
local wLabel = infoTab:AddLabel("VERSION//2.0.0")
wLabel.TextSize = 30
wLabel.Font = Enum.Font.Arcade

MainTab:AddLabel("Settings:").TextSize = 22

local changeSpeedSizeRemote = ReplicatedStorage.rEvents.changeSpeedSizeRemote

local userSize = 2
local sizeActive = false

MainTab:AddTextBox("Size", function(text)
        text = string.gsub(text, "%s+", "")
        local value = tonumber(text)
        if value and value > 0 then
                userSize = value
        end
end)

local setsizeswitch = MainTab:AddSwitch("Set Size", function(bool)
        sizeActive = bool
end)

setsizeswitch:Set(false)

task.spawn(function()
        while true do
                if sizeActive then
                        local character = Players.LocalPlayer.Character
                        if character then
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                        changeSpeedSizeRemote:InvokeServer("changeSize", userSize)
                                end
                        end
                end
                task.wait(0.15)
        end
end)

local userSpeed = 120
local speedActive = false

MainTab:AddTextBox("Speed", function(text)
        text = string.gsub(text, "%s+", "")
        local value = tonumber(text)
        if value and value > 0 then
                userSpeed = value
        end
end)

local setspeedswitch = MainTab:AddSwitch("Set Speed", function(bool)
        speedActive = bool
end)

setspeedswitch:Set(false)

task.spawn(function()
        while true do
                if speedActive then
                        local character = Players.LocalPlayer.Character
                        if character then
                                local humanoid = character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                        changeSpeedSizeRemote:InvokeServer("changeSpeed", userSpeed)
                                end
                        end
                end
                task.wait(0.15)
        end
end)

MainTab:AddLabel("Important:").TextSize = 22

local antiKnockbackSwitch = MainTab:AddSwitch("Anti Fling", function(bool)
    if bool then
        local playerName = game.Players.LocalPlayer.Name
        local character = game.Workspace:FindFirstChild(playerName)
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.P = 1250
                bodyVelocity.Parent = rootPart
            end
        end
    else
        local playerName = game.Players.LocalPlayer.Name
        local character = game.Workspace:FindFirstChild(playerName)
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
                if existingVelocity and existingVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
                    existingVelocity:Destroy()
                end
            end
        end
    end
end)
antiKnockbackSwitch:Set(true)

local lockRunning = false
local lockThread = nil

local lockSwitch = MainTab:AddSwitch("Lock Position", function(state)
    lockRunning = state
    if lockRunning then
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local lockPosition = hrp.Position

        lockThread = coroutine.create(function()
            while lockRunning do
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = CFrame.new(lockPosition)
                wait(0.05) 
            end
        end)

        coroutine.resume(lockThread)
    end
end)
lockSwitch:Set(false)

local showpetsswitch = MainTab:AddSwitch("Show Pets", function(bool)
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("hidePets") then
        player.hidePets.Value = bool
    end
end)
showpetsswitch:Set(false)

local showotherpetsswitch = MainTab:AddSwitch("Show Other Pets", function(bool)
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("showOtherPetsOn") then
        player.showOtherPetsOn.Value = bool
    end
end)
showotherpetsswitch:Set(false)



MainTab:AddLabel("Misc:").TextSize = 22

MainTab:AddSwitch("Infinite Jump", function(bool)
    _G.InfiniteJump = bool

    if bool then
        local InfiniteJumpConnection
        InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            if _G.InfiniteJump then
                game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            else
                InfiniteJumpConnection:Disconnect()
            end
        end)
    end
end)


local parts = {}
local partSize = 2048
local totalDistance = 50000
local startPosition = Vector3.new(-2, -9.5, -2)

local function createAllParts()
    local numberOfParts = math.ceil(totalDistance / partSize)

    for x = 0, numberOfParts - 1 do
        for z = 0, numberOfParts - 1 do
            local function createPart(pos, name)
                local part = Instance.new("Part")
                part.Size = Vector3.new(partSize, 1, partSize)
                part.Position = pos
                part.Anchored = true
                part.Transparency = 1
                part.CanCollide = true
                part.Name = name
                part.Parent = workspace
                return part
            end

            table.insert(parts, createPart(startPosition + Vector3.new(x*partSize,0,z*partSize), "Part_Side_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(-x*partSize,0,z*partSize), "Part_LeftRight_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(-x*partSize,0,-z*partSize), "Part_UpLeft_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(x*partSize,0,-z*partSize), "Part_UpRight_"..x.."_"..z))
        end
    end
end
task.spawn(createAllParts)

local walkonwaterSwicth =MainTab:AddSwitch("Walk on Water", function(bool)
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = bool
        end
    end
end)
walkonwaterSwicth:Set(true)


local spinwheelSwitch = MainTab:AddSwitch("Spin Fortune Wheel", function(bool)
    _G.AutoSpinWheel = bool

    if bool then
        spawn(function()
            while _G.AutoSpinWheel and wait(1) do
                game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", game:GetService("ReplicatedStorage").fortuneWheelChances["Fortune Wheel"])
            end
        end)
    end
end)

local timeDropdown = MainTab:AddDropdown("Change Time", function(selection)
    local lighting = game:GetService("Lighting")

    if selection == "Night" then
        lighting.ClockTime = 0
    elseif selection == "Day" then
        lighting.ClockTime = 12
    elseif selection == "Midnight" then
        lighting.ClockTime = 6
    end
end)

timeDropdown:Add("Night")
timeDropdown:Add("Day")
timeDropdown:Add("Midnight")

SpecsTab:AddLabel("Player Stats:").TextSize = 24

local playerToInspect = nil

local emojiMap = {
    ["Time"] = utf8.char(0x1F55B),
    ["Stats"] = utf8.char(0x1F4CA),
    ["Strength"] = utf8.char(0x1F4AA),
    ["Rebirths"] = utf8.char(0x1F504),
    ["Durability"] = utf8.char(0x1F6E1),
    ["Kills"] = utf8.char(0x1F480),
    ["Agility"] = utf8.char(0x1F3C3),
    ["Evil Karma"] = utf8.char(0x1F608),
    ["Good Karma"] = utf8.char(0x1F607),
    ["Brawls"] = utf8.char(0x1F94A)
}

local statDefinitions = {
    { name = "Strength", statName = "Strength" },
    { name = "Rebirths", statName = "Rebirths" },
    { name = "Durability", statName = "Durability" },
    { name = "Agility", statName = "Agility" },
    { name = "Kills", statName = "Kills" },
    { name = "Evil Karma", statName = "evilKarma" },
    { name = "Good Karma", statName = "goodKarma" },
    { name = "Brawls", statName = "Brawls" }
}

local function getCurrentPlayers()
    local playersList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(playersList, p)
    end
    return playersList
end

local specdropdown = SpecsTab:AddDropdown("Choose Player", function(text) 
    for _, player in ipairs(getCurrentPlayers()) do
        local optionText = player.DisplayName .. " | " .. player.Name
        if text == optionText then
            playerToInspect = player
            updateStatLabels(playerToInspect)
            break
        end
    end
end)

for _, player in ipairs(getCurrentPlayers()) do
    specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end

Players.PlayerAdded:Connect(function(player)
    specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    specdropdown:Clear()
    for _, p in ipairs(getCurrentPlayers()) do
        specdropdown:Add(p.DisplayName .. " | " .. p.Name)
    end
end)

local playerNameLabel = SpecsTab:AddLabel("Name: N/A")
playerNameLabel.TextSize = 20

local playerUsernameLabel = SpecsTab:AddLabel("Username: N/A")
playerUsernameLabel.TextSize = 20

local statLabels = {}
for _, info in ipairs(statDefinitions) do
    statLabels[info.name] = SpecsTab:AddLabel(emojiMap[info.name] .. " " .. info.name .. ": 0 (0)")
    statLabels[info.name].TextSize = 20
end

local function formatNumber(n)
    if n >= 1e15 then
        return string.format("%.1fqa", n/1e15)
    elseif n >= 1e12 then
        return string.format("%.1ft", n/1e12)
    elseif n >= 1e9 then
        return string.format("%.1fb", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.1fm", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n/1e3)
    else
        return tostring(n)
    end
end

local function formatWithCommas(n)
    local formatted = tostring(math.floor(n))
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end


local function updateStatLabels(targetPlayer)
    if not targetPlayer then return end

    playerNameLabel.Text = "Name: " .. targetPlayer.DisplayName
    playerUsernameLabel.Text = "Username: " .. targetPlayer.Name

    local leaderstats = targetPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return end

    for _, info in ipairs(statDefinitions) do
        local statObject

        if leaderstats:FindFirstChild(info.statName) then
            statObject = leaderstats:FindFirstChild(info.statName)
        elseif targetPlayer:FindFirstChild(info.statName) then
            statObject = targetPlayer:FindFirstChild(info.statName)
        end

        if statObject then
            local value = statObject.Value
            local emoji = emojiMap[info.name] or ""
            statLabels[info.name].Text = string.format(
                "%s %s: %s (%s)",
                emoji,
                info.name,
                formatNumber(value),
                formatWithCommas(value)
            )
        else
            statLabels[info.name].Text = emojiMap[info.name] .. " " .. info.name .. ": 0 (0)"
        end
    end
end

task.spawn(function()
    while true do
        if playerToInspect then
            updateStatLabels(playerToInspect)
        end
        task.wait(0.2)
    end
end)

SpecsTab:AddLabel("————————————————————————————")

SpecsTab:AddLabel("Advanced Stats:").TextSize = 24

local enemyHealthLabel = SpecsTab:AddLabel("Enemy Health: N/A")
enemyHealthLabel.TextSize = 20
enemyHealthLabel.TextColor3 = Color3.fromRGB(0, 140, 255)

local playerDamageLabel = SpecsTab:AddLabel("Your Damage: N/A")
playerDamageLabel.TextSize = 20
playerDamageLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

local hitsToKillLabel = SpecsTab:AddLabel("Hits to Kill: N/A")
hitsToKillLabel.TextSize = 20
hitsToKillLabel.TextColor3 = Color3.fromRGB(255, 0, 0)



local function calculateEnemyHealth(targetPlayer)
    if not targetPlayer then return 0 end

    local baseDura = 0
    local durabilityStat = targetPlayer:FindFirstChild("Durability") 
        or (targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Durability"))
    if durabilityStat then
        baseDura = durabilityStat.Value
    end

    local totalMultiplier = 1

    local ultFolder = targetPlayer:FindFirstChild("ultimatesFolder")
    if ultFolder then
        local infernalHealth = ultFolder:FindFirstChild("Infernal Health")
        if infernalHealth then
            local upgrades = infernalHealth.Value or 0
            totalMultiplier = totalMultiplier + 0.15 * upgrades
        end
    end

    local equippedPetsFolder = targetPlayer:FindFirstChild("equippedPets")
    if equippedPetsFolder then
        local petBonus = 0
        for _, petValue in ipairs(equippedPetsFolder:GetChildren()) do
            if petValue:IsA("ObjectValue") and petValue.Value then
                local petNameLower = string.lower(petValue.Value.Name)
                if petNameLower:match("mighty") and petNameLower:match("monster") then
                    petBonus = petBonus + 0.5
                end
            end
        end
        totalMultiplier = totalMultiplier + petBonus
    end

    local totalHealth = baseDura * totalMultiplier
    return totalHealth
end

local function calculateLocalPlayerDamage()
    local strengthStat = nil
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        strengthStat = leaderstats:FindFirstChild("Strength")
    end
    if not strengthStat then return 0 end

    local baseDamage = strengthStat.Value * 0.0667
    local totalMultiplier = 1

    local ultFolder = Player:FindFirstChild("ultimatesFolder")
    if ultFolder then
        local demonDamage = ultFolder:FindFirstChild("Demon Damage")
        if demonDamage then
            local upgrades = demonDamage.Value or 0
            totalMultiplier = totalMultiplier + 0.1 * upgrades
        end
    end

    local equippedPetsFolder = Player:FindFirstChild("equippedPets")
    if equippedPetsFolder then
        local petBonus = 0
        for _, petValue in ipairs(equippedPetsFolder:GetChildren()) do
            if petValue:IsA("ObjectValue") and petValue.Value then
                local petNameLower = string.lower(petValue.Value.Name)
                if petNameLower:match("wild") and petNameLower:match("wizard") then
                    petBonus = petBonus + 0.5
                end
            end
        end
        totalMultiplier = totalMultiplier + petBonus
    end

    baseDamage = baseDamage * totalMultiplier
    return baseDamage
end



local function calculateHitsToKill(health, damage)
    if damage <= 0 then return "∞" end
    local hits = math.ceil(health / damage)
    if hits > 100 then
        return "∞"
    elseif hits < 1 then
        return 1
    else
        return hits
    end
end

local function updateAdvancedStats(targetPlayer)
    if not targetPlayer then
        enemyHealthLabel.Text = "Enemy Health: N/A"
        playerDamageLabel.Text = "Your Damage: N/A"
        hitsToKillLabel.Text = "Hits to Kill: N/A"
        return
    end
    local enemyHealth = calculateEnemyHealth(targetPlayer)
    local playerDamage = calculateLocalPlayerDamage()
    local hitsToKill = calculateHitsToKill(enemyHealth, playerDamage)
    enemyHealthLabel.Text = string.format("Enemy Health: %s (%s)", formatNumber(enemyHealth), formatWithCommas(enemyHealth))
    playerDamageLabel.Text = string.format("Your Damage: %s (%s)", formatNumber(playerDamage), formatWithCommas(playerDamage))
    hitsToKillLabel.Text = string.format("Hits to Kill: %s", tostring(hitsToKill))
end

task.spawn(function()
    while true do
        if playerToInspect then
            updateAdvancedStats(playerToInspect)
        else
            updateAdvancedStats(nil)
        end
        task.wait(0.1)
    end
end)

local function checkCharacter()
    if not game.Players.LocalPlayer.Character then
        repeat task.wait() until game.Players.LocalPlayer.Character
    end
    return game.Players.LocalPlayer.Character
end

local function gettool()
    for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "Punch" and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
        end
    end
    game.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
    game.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end

local function isPlayerAlive(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")