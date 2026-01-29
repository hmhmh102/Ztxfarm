local farmTab = mainGuiWindow:AddTab("Farm");
    local killTab = mainGuiWindow:AddTab("Kill");
    local teleportTab = mainGuiWindow:AddTab("Teleport");
    local miscTab = mainGuiWindow:AddTab("Misc");
    local creditTab = mainGuiWindow:AddTab("Credit");
    local avatarTab = mainGuiWindow:AddTab("Avatar");
    
    killTab:AddSwitch("Auto Kill", function(state)
        getgenv().AutoKill = state;
    end);
    
    spawn(function()
        while task.wait() do
            if getgenv().AutoKill then
                pcall(function()
                    local localCharacter = game.Players.LocalPlayer.Character;
                    for _, player in ipairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character and not getgenv()[player.Name] then
                            local targetCharacter = player.Character;
                            do
                                local targetCharacterModel = targetCharacter;
                                if targetCharacterModel then
                                    targetCharacterModel.Head.Anchored = true;
                                    targetCharacterModel.Head.CanCollide = false;
                                    
                                    pcall(function()
                                        if targetCharacterModel.Head:FindFirstChild("Neck") and targetCharacterModel.Head:FindFirstChild("nameGui") then
                                            targetCharacterModel.Head.nameGui:Clone().Parent = targetCharacterModel.UpperTorso;
                                            targetCharacterModel.Head.Neck:Destroy();
                                            targetCharacterModel.Head.nameGui:Destroy();
                                            targetCharacterModel.Head.Transparency = 1;
                                            targetCharacterModel.Head.Face:Destroy();
                                        end;
                                    end);
                                    
                                    pcall(function()
                                        local punchLeft = {
                                            [1] = "punch", 
                                            [2] = "leftHand"
                                        };
                                        game:GetService("Players").LocalPlayer.muscleEvent:FireServer(unpack(punchLeft));
                                        
                                        local punchRight = {
                                            [1] = "punch", 
                                            [2] = "rightHand"
                                        };
                                        game:GetService("Players").LocalPlayer.muscleEvent:FireServer(unpack(punchRight));
                                        
                                        task.wait();
                                        targetCharacterModel.Head.Position = Vector3.new(localCharacter.LeftHand.Position.X, localCharacter.LeftHand.Position.Y, localCharacter.LeftHand.Position.Z);
                                    end);
                                end;
                            end;
                        end;
                    end;
                end);
            end;
        end;
    end);
    
    miscTab:AddButton("Anti Afk", function()
        game:GetService("Players").LocalPlayer.Idled:connect(function()
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame);
            task.wait(1);
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame);
        end);
    end);
end;

if isClientAllowed == false then
    game.Players.LocalPlayer:Kick("Message in kick");
end;