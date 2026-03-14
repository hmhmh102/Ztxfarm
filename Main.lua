local library
if _G.scpLibrary then
    library = _G.scpLibrary
else
    library = loadstring(game:HttpGet("https://raw.githubusercontent.com/imhenne187/SilenceElerium/refs/heads/main/src/SilenceEleriumLibrary.luau", true))()
    _G.scpLibrary = library
end

-- SCP LOGO INJECTOR
local injectSCPLogo = _G.injectSCPLogo or function(wFrame)
    task.spawn(function()
        -- Wait up to 3 seconds for Bar to exist
        local bar
        for i=1,60 do
            bar = wFrame:FindFirstChild("Bar")
            if bar then break end
            task.wait(0.05)
        end
        if not bar then return end
        local tog
        for i=1,20 do
            tog = bar:FindFirstChild("Toggle")
            if tog then break end
            task.wait(0.05)
        end
        if not tog then return end
        pcall(function()
            tog.Image="rbxassetid://3926305904"
            tog.ImageColor3=Color3.fromRGB(180,80,255)
            tog.Size=UDim2.new(0,18,0,18)
            local ex=bar:FindFirstChild("SCPLogo"); if ex then ex:Destroy() end
            local lbl=Instance.new("TextLabel")
            lbl.Name="SCPLogo"; lbl.Size=UDim2.new(0,32,0,14)
            lbl.Position=UDim2.new(0,22,0,2); lbl.BackgroundTransparency=1
            lbl.Text="SCP"; lbl.TextColor3=Color3.fromRGB(160,60,240)
            lbl.TextSize=11; lbl.Font=Enum.Font.FredokaOne
            lbl.ZIndex=tog.ZIndex+1; lbl.Parent=bar
        end)
    end)
end

local Players=game:GetService("Players"); local RunSvc=game:GetService("RunService")
local UIS=game:GetService("UserInputService"); local SG=game:GetService("StarterGui")
local LP=Players.LocalPlayer
repeat task.wait() until LP and LP.Character
local function notify(t,m,d) pcall(function() SG:SetCore("SendNotification",{Title=t,Text=m,Duration=d or 3}) end) end
local function findPlayer(q) if not q or q==""then return LP end; local l=q:lower(); for _,p in ipairs(Players:GetPlayers())do if p.Name:lower()==l or p.DisplayName:lower()==l then return p end end; for _,p in ipairs(Players:GetPlayers())do if p.Name:lower():find(l,1,true)then return p end end end

local KEY_URL="https://pastebin.com/raw/n7UWskEA"
local function getKeys() local ok,res=pcall(function()return game:HttpGet(KEY_URL)end); if not ok then return{}end; local k={}; for v in res:gmatch("[^\n]+")do local t=v:match("^%s*(.-)%s*$"); if t~=""then table.insert(k,t)end end; return k end
local function checkKey(e) for _,v in pairs(getKeys())do if v==e then return true end end; return false end

-- KEY SYSTEM (required every execution)
local keyPassed=false
local kW,kF=library:AddWindow("🔑 SCP HUB — Key",{main_color=Color3.fromRGB(100,20,180),title_bar={Color3.fromRGB(110,25,200),Color3.fromRGB(55,5,100)},background={Color3.fromRGB(10,5,18)},background_transparency=0,min_size=Vector2.new(440,150),can_resize=false})
local kt,_=kW:AddTab("🔑  Key"); kt:AddLabel("⚡  SCP HUB  •  Rivals  •  TEJAZ"); kt:AddLabel("🔑  Get key at  discord.gg/KDx3D8hARN")
local stL=kt:AddLabel("📋  Paste key below then press Enter")
kt:AddTextBox("Paste key here...",function(v) if checkKey(v)then stL.Text="✅ Accepted! Loading..."; keyPassed=true else stL.Text="❌ Wrong key! discord.gg/KDx3D8hARN" end end,{clear=true})
kt:AddButton("💬  Copy Discord",function() setclipboard("https://discord.gg/KDx3D8hARN"); notify("SCP","✅ Copied!",3) end)
kt:AddButton("🔑  Get Free Key", function() setclipboard("https://discord.gg/KDx3D8hARN"); notify("SCP","🔑 Discord copied! Join to get key 👑",4) end)
injectSCPLogo(kF)
kt:Show()
repeat task.wait(0.5) until keyPassed; kF:Destroy()

local WIN_CFG={main_color=Color3.fromRGB(100,20,180),title_bar={Color3.fromRGB(110,25,200),Color3.fromRGB(55,5,100)},background={Color3.fromRGB(10,5,18)},background_transparency=0,min_size=Vector2.new(600,280),toggle_key=Enum.KeyCode.RightShift,can_resize=true}
local win,winF=library:AddWindow("⚡ SCP HUB  |  Rivals  |  TEJAZ",WIN_CFG)
task.defer(function() injectSCPLogo(winF) end)

-- INFO TAB
local infoTab,_=win:AddTab("📋  Info")
infoTab:AddLabel("━━━━━━━  ⚡  SCP HUB  •  RIVALS  ━━━━━━━")
infoTab:AddLabel("👑  Author   TEJAZ"); infoTab:AddLabel("💎  Version   4.5"); infoTab:AddLabel("🔄  Toggle   RightShift")
infoTab:AddLabel("💬  Discord  discord.gg/KDx3D8hARN")
infoTab:AddLabel("━━━━━━━  📊 SERVER INFO  ━━━━━━━")
local plrCount=infoTab:AddLabel("🌐  Players: "..#Players:GetPlayers())
local pingLbl=infoTab:AddLabel("📶  Ping: calculating...")
task.spawn(function() while task.wait(2)do pcall(function() plrCount.Text="🌐  Players: "..#Players:GetPlayers(); local s=tick(); RunSvc.Heartbeat:Wait(); pingLbl.Text="📶  Ping: "..math.floor((tick()-s)*1000).."ms" end) end end)
infoTab:AddButton("💬  Copy Discord",function() setclipboard("https://discord.gg/KDx3D8hARN"); notify("SCP","✅ Copied!",3) end)

-- AIMBOT TAB
local aimTab,_=win:AddTab("🎯  Aimbot")
local aimbotOn=false; local fov=150; local aimPart="Head"
aimTab:AddLabel("━━━━━━━  🎯 AIMBOT  ━━━━━━━")
local fovLbl=aimTab:AddLabel("📐  FOV: 150")
aimTab:AddSwitch("🎯  Aimbot (Hold Right Click)",function(v)
    aimbotOn=v; if v then task.spawn(function() while aimbotOn do
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)then
            local closest,cd=nil,fov; local cam=workspace.CurrentCamera
            for _,p in ipairs(Players:GetPlayers())do if p~=LP and p.Character and p.Character:FindFirstChild(aimPart)then
                local part=p.Character[aimPart]; local sp,onS=cam:WorldToScreenPoint(part.Position)
                if onS then local mp=UIS:GetMouseLocation(); local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude; if d<cd then cd=d; closest=part end end
            end end
            if closest then local t=cam:WorldToScreenPoint(closest.Position); local mp=UIS:GetMouseLocation(); local np=mp:Lerp(Vector2.new(t.X,t.Y),0.35); mousemoverel(np.X-mp.X,np.Y-mp.Y) end
        end; task.wait()
    end end) end
end)
aimTab:AddSwitch("👻  Silent Aim",function(v) getgenv().scpSilent=v end)
aimTab:AddSwitch("🔮  Prediction (Lead Target)",function(v) getgenv().scpPredict=v end)
aimTab:AddButton("➕  FOV +25",function() fov=math.min(fov+25,500); fovLbl.Text="📐  FOV: "..fov end)
aimTab:AddButton("➖  FOV -25",function() fov=math.max(fov-25,25); fovLbl.Text="📐  FOV: "..fov end)
aimTab:AddLabel("━━━━━━━  🎯 AIM PART  ━━━━━━━")
aimTab:AddButton("🧠  Head",function() aimPart="Head"; notify("SCP","Aim: Head",2) end)
aimTab:AddButton("⬛  HumanoidRootPart",function() aimPart="HumanoidRootPart"; notify("SCP","Aim: HRP",2) end)
aimTab:AddButton("🟫  UpperTorso",function() aimPart="UpperTorso"; notify("SCP","Aim: Torso",2) end)

-- PLAYER TAB
local plrTab,_=win:AddTab("👤  Player")
plrTab:AddLabel("━━━━━━━  🏃 MOVEMENT  ━━━━━━━")
plrTab:AddSwitch("⚡  Speed (100)",function(v) if LP.Character and LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid.WalkSpeed=v and 100 or 16 end end)
plrTab:AddSwitch("🚀  Ultra Speed (250)",function(v) if LP.Character and LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid.WalkSpeed=v and 250 or 16 end end)
plrTab:AddSwitch("🦘  High Jump",function(v) if LP.Character and LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid.JumpPower=v and 100 or 50 end end)
plrTab:AddSwitch("♾️  Infinite Jump",function(v) getgenv().scpIJ=v; if v then getgenv().scpIJC=UIS.JumpRequest:Connect(function() if getgenv().scpIJ and LP.Character and LP.Character:FindFirstChild("Humanoid")then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)end end) elseif getgenv().scpIJC then getgenv().scpIJC:Disconnect()end end)
plrTab:AddSwitch("👻  Noclip",function(v) getgenv().scpNC=v; if v then getgenv().scpNCC=RunSvc.Stepped:Connect(function() if getgenv().scpNC and LP.Character then for _,p in pairs(LP.Character:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end end) elseif getgenv().scpNCC then getgenv().scpNCC:Disconnect()end end)
plrTab:AddSwitch("🌀  Spin Anti-Aim",function(v) getgenv().scpSpin=v; if v then task.spawn(function() while getgenv().scpSpin do if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")then LP.Character.HumanoidRootPart.CFrame=LP.Character.HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(10),0)end; task.wait(0.05)end end)end end)
plrTab:AddSwitch("🌌  Low Gravity",function(v) workspace.Gravity=v and 50 or 196.2 end)
plrTab:AddSwitch("🔆  Fullbright",function(v) game.Lighting.Brightness=v and 10 or 2; game.Lighting.GlobalShadows=not v end)
plrTab:AddSwitch("🖥️  Low Graphics",function(v) game.Lighting.GlobalShadows=not v; settings().Rendering.QualityLevel=v and"Level01"or"Level21" end)

-- VISUALS TAB
local visTab,_=win:AddTab("👁️  Visuals")
visTab:AddLabel("━━━━━━━  👁️ ESP  ━━━━━━━")
visTab:AddSwitch("📦  Box ESP",function(v)
    getgenv().scpBoxESP=v; if v then task.spawn(function() while getgenv().scpBoxESP do
        for _,p in ipairs(Players:GetPlayers())do if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")and not p.Character.HumanoidRootPart:FindFirstChild("SCPBox")then
            local b=Instance.new("BoxHandleAdornment"); b.Name="SCPBox"; b.Adornee=p.Character.HumanoidRootPart; b.Size=Vector3.new(4,6,2); b.Color3=Color3.fromRGB(220,45,45); b.Transparency=0.4; b.AlwaysOnTop=true; b.ZIndex=5; b.Parent=p.Character.HumanoidRootPart
        end end; task.wait(0.5)
    end end) else for _,p in ipairs(Players:GetPlayers())do if p.Character and p.Character:FindFirstChild("HumanoidRootPart")then local b=p.Character.HumanoidRootPart:FindFirstChild("SCPBox"); if b then b:Destroy()end end end end
end)
visTab:AddSwitch("✨  Player Chams",function(v)
    getgenv().scpChams=v; if v then task.spawn(function() while getgenv().scpChams do
        for _,p in ipairs(Players:GetPlayers())do if p~=LP and p.Character and not p.Character:FindFirstChild("SCPChams")then
            local s=Instance.new("SelectionBox"); s.Name="SCPChams"; s.Adornee=p.Character; s.Color3=Color3.fromRGB(185,30,30); s.SurfaceTransparency=0.65; s.LineThickness=0.05; s.Parent=p.Character
        end end; task.wait(0.5)
    end end) else for _,p in ipairs(Players:GetPlayers())do if p.Character then local c=p.Character:FindFirstChild("SCPChams"); if c then c:Destroy()end end end end
end)
visTab:AddSwitch("🏷️  Name + HP Tags",function(v)
    getgenv().scpTags=v; if v then task.spawn(function() while getgenv().scpTags do
        for _,p in ipairs(Players:GetPlayers())do if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")and not p.Character.HumanoidRootPart:FindFirstChild("SCPTag")then
            local hrp=p.Character.HumanoidRootPart
            local bb=Instance.new("BillboardGui"); bb.Name="SCPTag"; bb.Adornee=hrp; bb.Size=UDim2.new(0,120,0,44); bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true; bb.Parent=hrp
            local nl=Instance.new("TextLabel",bb); nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1; nl.Text=p.Name; nl.TextColor3=Color3.new(1,1,1); nl.TextSize=13; nl.Font=Enum.Font.GothamBlack; nl.TextStrokeTransparency=0
            local hl=Instance.new("TextLabel",bb); hl.Size=UDim2.new(1,0,0.5,0); hl.Position=UDim2.new(0,0,0.5,0); hl.BackgroundTransparency=1; hl.TextSize=10; hl.Font=Enum.Font.GothamBold; hl.TextStrokeTransparency=0; hl.TextColor3=Color3.fromRGB(0,210,80)
            local hum=p.Character:FindFirstChild("Humanoid"); if hum then hl.Text="❤️ "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
        end end; task.wait(0.25)
    end end) else for _,p in ipairs(Players:GetPlayers())do if p.Character and p.Character:FindFirstChild("HumanoidRootPart")then local t2=p.Character.HumanoidRootPart:FindFirstChild("SCPTag"); if t2 then t2:Destroy()end end end end
end)
visTab:AddSwitch("🔆  Fullbright",function(v) game.Lighting.Brightness=v and 10 or 2; game.Lighting.GlobalShadows=not v end)

-- KILL TAB
local killTab,_=win:AddTab("⚔️  Kill")
local wl2={}
killTab:AddLabel("━━━━━━━  ⚔️ KILL OPTIONS  ━━━━━━━")
killTab:AddTextBox("➕ Whitelist name",function(v) if table.find(wl2,v)then for i,n in ipairs(wl2)do if n==v then table.remove(wl2,i);break end end; notify("SCP","Removed "..v,2) else table.insert(wl2,v); notify("SCP","Added "..v,2)end end,{clear=true})
killTab:AddSwitch("☠️  Kill All",function(v) getgenv().scpKA=v; if v then task.spawn(function() while getgenv().scpKA do for _,p in ipairs(Players:GetPlayers())do if p~=LP and not table.find(wl2,p.Name)and p.Character and p.Character:FindFirstChild("Humanoid")then pcall(function()p.Character.Humanoid.Health=0 end)end end; task.wait(0.5)end end)end end)
local kTgt=""
killTab:AddTextBox("Kill specific player",function(v) kTgt=v end,{clear=false})
killTab:AddSwitch("🎯  Kill Specific",function(v) getgenv().scpKO=v; if v then task.spawn(function() while getgenv().scpKO do local p=findPlayer(kTgt); if p and p~=LP and not table.find(wl2,p.Name)and p.Character and p.Character:FindFirstChild("Humanoid")then pcall(function()p.Character.Humanoid.Health=0 end)end; task.wait(0.5)end end)end end)
local scN=""
killTab:AddTextBox("Spy camera target",function(v) scN=v end,{clear=false})
killTab:AddSwitch("📹  Spy Camera",function(v) if v then getgenv().scpSC=true; task.spawn(function() while getgenv().scpSC do local p=findPlayer(scN); if p and p.Character and p.Character:FindFirstChild("Humanoid")then workspace.CurrentCamera.CameraSubject=p.Character.Humanoid end; task.wait(0.25)end end) else getgenv().scpSC=false; if LP.Character and LP.Character:FindFirstChild("Humanoid")then workspace.CurrentCamera.CameraSubject=LP.Character.Humanoid end end end)

-- SETTINGS TAB
local setTab,_=win:AddTab("⚙️  Settings")
setTab:AddLabel("━━━━━━━  ⚙️ OPTIONS  ━━━━━━━")
setTab:AddSwitch("🖥️  Low Graphics",function(v) game.Lighting.GlobalShadows=not v; game.Lighting.FogEnd=v and 9e9 or 1e5; settings().Rendering.QualityLevel=v and"Level01"or"Level21" end)
setTab:AddButton("🛡️  Anti AFK",function() pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()end); notify("SCP","🛡️ ON",3) end)
setTab:AddButton("💬  Copy Discord",function() setclipboard("https://discord.gg/KDx3D8hARN"); notify("SCP","✅ Copied!",3) end)
setTab:AddButton("🗑️  Clear Saved Key",function() if writefile then writefile("SCP_HUB/key.txt","")end; notify("SCP","🗑️ Key cleared",3) end)

infoTab:Show()
notify("SCP HUB","⚔️ Rivals Loaded! RShift to toggle 👑",5)