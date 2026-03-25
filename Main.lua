https://raw.githubusercontent.com/x2Swiftz/UI-Library/refs/heads/main/Libraries/PRIV9%20-%20Example.lua
-- // ═══════════════════════════════════════════════
-- //         AimCore VoidSpam | Auto-Execute
-- //         Execute ONCE — persists every match
-- // ═══════════════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- // ─────────────────────────────────────────
-- //   PREVENT DOUBLE-EXECUTION IN SAME SESSION
-- // ─────────────────────────────────────────

if _G.AimCoreVoidSpamLoaded then
    return
end
_G.AimCoreVoidSpamLoaded = true

-- // ─────────────────────────────────────────
-- //         CONFIG
-- // ─────────────────────────────────────────

local MIN_DIST        = 14000000000   -- 14 billion studs
local MAX_DIST        = 15000000000   -- 15 billion studs
local BASE_INTERVAL   = 0.2
local GLITCH_INTERVAL = 0.1

-- // ─────────────────────────────────────────
-- //         STATE
-- // ─────────────────────────────────────────

local VoidSpamActive   = false
local VoidSpamConn     = nil
local LastTeleportTime = 0
local TeleportPhase    = 0
local ZigZagDirection  = 1
local MethodIndex      = 0

-- // ─────────────────────────────────────────
-- //         TELEPORT METHODS
-- // ─────────────────────────────────────────

local function GetRandomDist()
    return math.random(MIN_DIST, MAX_DIST)
end

local function TeleportRandom()
    local dist   = GetRandomDist()
    local angle1 = math.random() * math.pi * 2
    local angle2 = math.random() * math.pi * 2
    return Vector3.new(
        math.cos(angle1) * math.cos(angle2) * dist,
        math.sin(angle2) * dist,
        math.sin(angle1) * math.cos(angle2) * dist
    )
end

local function TeleportZigZag()
    local dist = GetRandomDist()
    TeleportPhase   = TeleportPhase + (math.pi / 4)
    ZigZagDirection = ZigZagDirection * -1
    return Vector3.new(
        math.cos(TeleportPhase) * dist * ZigZagDirection,
        math.sin(TeleportPhase * 0.5) * (dist * 0.3),
        math.sin(TeleportPhase) * dist
    )
end

local function TeleportUnpredictable()
    local dist  = GetRandomDist()
    local chaos = math.random(1, 6)
    if chaos == 1 then
        return Vector3.new(dist, math.random(-1000000, 1000000), math.random(-dist, dist))
    elseif chaos == 2 then
        return Vector3.new(-dist, math.random(0, dist), math.random(-dist, dist))
    elseif chaos == 3 then
        return Vector3.new(math.random(-dist, dist), dist, math.random(-dist, dist))
    elseif chaos == 4 then
        return Vector3.new(math.random(-dist, dist), -dist * 0.5, math.random(-dist, dist))
    elseif chaos == 5 then
        return Vector3.new(dist * math.random() * ZigZagDirection, math.random(-dist, dist), dist * math.random())
    else
        return Vector3.new(-dist * math.random(), dist * math.random(), -dist * math.random())
    end
end

local function TeleportGlitch()
    local dist = GetRandomDist()
    return Vector3.new(
        (math.random() > 0.5 and 1 or -1) * math.random(MIN_DIST, MAX_DIST),
        (math.random() > 0.5 and 1 or -1) * math.random(0, math.floor(dist * 0.4)),
        (math.random() > 0.5 and 1 or -1) * math.random(MIN_DIST, MAX_DIST)
    )
end

local function GetNextPosition()
    MethodIndex = (MethodIndex + 1) % 4
    if MethodIndex == 0 then
        return TeleportRandom(), BASE_INTERVAL
    elseif MethodIndex == 1 then
        return TeleportZigZag(), BASE_INTERVAL
    elseif MethodIndex == 2 then
        return TeleportUnpredictable(), BASE_INTERVAL
    else
        return TeleportGlitch(), GLITCH_INTERVAL
    end
end

-- // ─────────────────────────────────────────
-- //         CORE TELEPORT LOOP
-- // ─────────────────────────────────────────

local function DoTeleport(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
end

local function StartLoop()
    if VoidSpamConn then
        VoidSpamConn:Disconnect()
        VoidSpamConn = nil
    end

    local NextInterval = BASE_INTERVAL

    VoidSpamConn = RunService.Heartbeat:Connect(function()
        if not VoidSpamActive then return end
        local now = tick()
        if now - LastTeleportTime >= NextInterval then
            LastTeleportTime = now
            local pos, interval = GetNextPosition()
            NextInterval = interval
            pcall(DoTeleport, pos)
        end
    end)
end

-- // ─────────────────────────────────────────
-- //         GUI BUILDER
-- // ─────────────────────────────────────────

local function BuildGUI()
    local old = LocalPlayer.PlayerGui:FindFirstChild("AimCoreVoidSpam")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "AimCoreVoidSpam"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder   = 999
    ScreenGui.Parent         = LocalPlayer.PlayerGui

    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Name             = "MainFrame"
    Frame.Size             = UDim2.new(0, 130, 0, 68)
    Frame.Position         = UDim2.new(1, -148, 0, 16)
    Frame.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
    Frame.BorderSizePixel  = 0
    Frame.Active           = true
    Frame.Parent           = ScreenGui

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 8)
    FrameCorner.Parent = Frame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color     = Color3.fromRGB(120, 60, 220)
    FrameStroke.Thickness = 1.5
    FrameStroke.Parent    = Frame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name             = "TitleBar"
    TitleBar.Size             = UDim2.new(1, 0, 0, 22)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 10, 38)
    TitleBar.BorderSizePixel  = 0
    TitleBar.Parent           = Frame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    local TitleFix = Instance.new("Frame")
    TitleFix.Size             = UDim2.new(1, 0, 0.5, 0)
    TitleFix.Position         = UDim2.new(0, 0, 0.5, 0)
    TitleFix.BackgroundColor3 = Color3.fromRGB(20, 10, 38)
    TitleFix.BorderSizePixel  = 0
    TitleFix.Parent           = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size                  = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text                  = "⚡ VOIDSPAM"
    TitleLabel.Font                  = Enum.Font.GothamBold
    TitleLabel.TextSize              = 11
    TitleLabel.TextColor3            = Color3.fromRGB(180, 100, 255)
    TitleLabel.TextXAlignment        = Enum.TextXAlignment.Center
    TitleLabel.Parent                = TitleBar

    -- ON/OFF Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name            = "ToggleBtn"
    ToggleBtn.Size            = UDim2.new(1, -16, 0, 30)
    ToggleBtn.Position        = UDim2.new(0, 8, 0, 28)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 14, 50)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text            = "ON / OFF"
    ToggleBtn.Font            = Enum.Font.GothamBold
    ToggleBtn.TextSize        = 12
    ToggleBtn.TextColor3      = Color3.fromRGB(160, 80, 255)
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent          = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color     = Color3.fromRGB(100, 40, 200)
    BtnStroke.Thickness = 1.2
    BtnStroke.Parent    = ToggleBtn

    -- Status Dot
    local StatusDot = Instance.new("Frame")
    StatusDot.Size             = UDim2.new(0, 7, 0, 7)
    StatusDot.Position         = UDim2.new(0, 8, 0, 30)
    StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    StatusDot.BorderSizePixel  = 0
    StatusDot.Parent           = Frame

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = StatusDot

    -- // Visual sync — carries over ON state through match teleports
    local function SyncVisual()
        if VoidSpamActive then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
            ToggleBtn.TextColor3       = Color3.fromRGB(200, 120, 255)
            BtnStroke.Color            = Color3.fromRGB(160, 60, 255)
            StatusDot.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 14, 50)
            ToggleBtn.TextColor3       = Color3.fromRGB(100, 60, 160)
            BtnStroke.Color            = Color3.fromRGB(60, 20, 120)
            StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end

    local function SetActive(state)
        VoidSpamActive = state
        if state then LastTeleportTime = 0 end
        SyncVisual()
    end

    -- Sync button visuals to current state on every re-inject
    SyncVisual()

    ToggleBtn.MouseButton1Click:Connect(function()
        SetActive(not VoidSpamActive)
    end)

    ToggleBtn.MouseEnter:Connect(function()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(50, 20, 90)
        }):Play()
    end)

    ToggleBtn.MouseLeave:Connect(function()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = VoidSpamActive
                and Color3.fromRGB(40, 0, 80)
                or  Color3.fromRGB(28, 14, 50)
        }):Play()
    end)

    -- // Draggable (PC + Mobile + Tablet)
    local dragging = false
    local dragInput, dragStart, startPos

    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            UpdateDrag(input)
        end
    end)
end

-- // ─────────────────────────────────────────
-- //   TELEPORT DETECTION + AUTO RE-INJECT
-- // ─────────────────────────────────────────

local LastPlaceId = game.PlaceId

local function ReInject(reason)
    print("[AimCore] Re-injecting — Reason:", reason)
    task.wait(0.8)
    BuildGUI()
    StartLoop()
    print("[AimCore] VoidSpam re-injected | PlaceId:", game.PlaceId)
end

-- Catches Rivals matchmaking teleport arrivals
pcall(function()
    TeleportService.LocalPlayerArrivedFromTeleport:Connect(function()
        ReInject("Arrived from teleport")
    end)
end)

-- Catches in-match respawns — also watches for missing GUI
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if not LocalPlayer.PlayerGui:FindFirstChild("AimCoreVoidSpam") then
        ReInject("GUI missing after respawn")
    else
        -- GUI exists — just reset the spam timer if active
        if VoidSpamActive then
            LastTeleportTime = 0
        end
    end
end)

-- Heartbeat watchdog — silently re-injects if GUI disappears for any reason
task.spawn(function()
    while true do
        task.wait(3)
        if not LocalPlayer.PlayerGui:FindFirstChild("AimCoreVoidSpam") then
            ReInject("Watchdog: GUI missing")
        end
        if VoidSpamActive and not VoidSpamConn then
            StartLoop()
        end
    end
end)

-- // ─────────────────────────────────────────
-- //         INITIAL BOOT
-- // ─────────────────────────────────────────

BuildGUI()
StartLoop()

print("[AimCore] VoidSpam loaded | 14-15B studs | Auto-Execute ACTIVE")
print("[AimCore] Execute ONCE — persists through every Rivals match teleport.")
