-- ============================================
-- Blox Fruits Hub - Update 30
-- Using Ray Field UI Library
-- Version: 30.0
-- ============================================

-- Wrap entire script in pcall for error handling
local success, errorMessage = pcall(function()
    -- Wait for game to load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local Workspace = game:GetService("Workspace")

    -- Wait for player
    repeat task.wait() until LocalPlayer

    -- Load Ray Field UI
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    if not Rayfield then
        warn("[Hub] Failed to load Ray Field UI")
        return
    end

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Blox Fruits Hub",
    LoadingTitle = "Blox Fruits Hub",
    LoadingSubtitle = "by Developer",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxFruitsHub",
        FileName = "Config"
    },
    DisableLoading = false
})

-- ============================================
-- Game Functions
-- ============================================

-- Auto Farm
local autoFarmEnabled = false
local farmConnection
local targetEnemy = nil
local magnetEnabled = true

local function findNearestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local nearestEnemy = nil
    local nearestDistance = math.huge
    
    -- Look in Workspace.Enemies
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") then
                local humanoid = enemy.Humanoid
                local rootPart = enemy:FindFirstChild("HumanoidRootPart")
                
                if humanoid.Health > 0 and rootPart then
                    local distance = (rootPart.Position - humanoidRootPart.Position).Magnitude
                    if distance < nearestDistance and distance < 200 then
                        nearestDistance = distance
                        nearestEnemy = enemy
                    end
                end
            end
        end
    end
    
    return nearestEnemy
end

local function magnetEnemy(enemy)
    if not magnetEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local enemyRootPart = enemy:FindFirstChild("HumanoidRootPart")
    local enemyHumanoid = enemy:FindFirstChild("Humanoid")
    
    if enemyRootPart and enemyHumanoid then
        pcall(function()
            enemyHumanoid.PlatformStand = true
            enemyHumanoid.Sit = true
            enemyRootPart.CanCollide = false
            enemyRootPart.Size = Vector3.new(60, 60, 60)
            enemyRootPart.CFrame = rootPart.CFrame * CFrame.new(0, -15, 0)
        end)
    end
end

local function resetEnemy(enemy)
    local enemyRootPart = enemy:FindFirstChild("HumanoidRootPart")
    local enemyHumanoid = enemy:FindFirstChild("Humanoid")
    
    if enemyRootPart and enemyHumanoid then
        pcall(function()
            enemyHumanoid.PlatformStand = false
            enemyHumanoid.Sit = false
            enemyRootPart.CanCollide = true
            enemyRootPart.Size = Vector3.new(2, 2, 1)
        end)
    end
end

local function startAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    
    farmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        targetEnemy = findNearestEnemy()
        
        if targetEnemy then
            local enemyRootPart = targetEnemy:FindFirstChild("HumanoidRootPart")
            if enemyRootPart then
                local distance = (enemyRootPart.Position - rootPart.Position).Magnitude
                
                if distance > 15 then
                    -- Tween to enemy (safer than instant teleport)
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(rootPart, tweenInfo, {
                        CFrame = CFrame.new(enemyRootPart.Position + Vector3.new(0, 0, 5))
                    })
                    tween:Play()
                else
                    -- Magnet enemy to player
                    magnetEnemy(targetEnemy)
                    
                    -- Attack
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    else
                        VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                    end
                end
            end
        end
    end)
end

local function stopAutoFarm()
    autoFarmEnabled = false
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    targetEnemy = nil
end

-- Infinite Jump
local jumpConnection

local function enableInfiniteJump()
    if jumpConnection then return end
    
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if not LocalPlayer.Character then return end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
            humanoid:ChangeState("Jumping")
        end
    end)
end

local function disableInfiniteJump()
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
    end
end

-- Speed Boost
local walkSpeedConnection
local originalWalkSpeed = 16

local function enableSpeedBoost()
    if walkSpeedConnection then return end
    
    walkSpeedConnection = RunService.RenderStepped:Connect(function()
        if not LocalPlayer.Character then return end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end)
end

local function disableSpeedBoost()
    if walkSpeedConnection then
        walkSpeedConnection:Disconnect()
        walkSpeedConnection = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

-- Fly
local flyEnabled = false
local flyConnection
local flyVelocity

local function enableFly()
    if flyEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "FlyVelocity"
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.Parent = rootPart
    
    flyEnabled = true
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        
        character = LocalPlayer.Character
        if not character then return end
        
        rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            local camera = Workspace.CurrentCamera
            moveVector = camera.CFrame.LookVector * 50
        elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
            local camera = Workspace.CurrentCamera
            moveVector = -camera.CFrame.LookVector * 50
        elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then
            local camera = Workspace.CurrentCamera
            moveVector = -camera.CFrame.RightVector * 50
        elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
            local camera = Workspace.CurrentCamera
            moveVector = camera.CFrame.RightVector * 50
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = Vector3.new(0, 50, 0)
        end
        
        flyVelocity.Velocity = moveVector
    end)
end)

local function disableFly()
    flyEnabled = false
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local flyVel = rootPart:FindFirstChild("FlyVelocity")
            if flyVel then
                flyVel:Destroy()
            end
        end
    end
end

-- No Clip
local noClipEnabled = false
local noClipConnection

local function enableNoClip()
    if noClipEnabled then return end
    
    noClipEnabled = true
    
    noClipConnection = RunService.Stepped:Connect(function()
        if not noClipEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end)

local function disableNoClip()
    noClipEnabled = false
    
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Stats (using Blox Fruits CommF_ remote)
local autoStatsEnabled = false
local autoStatsConnection

local function addStats(statType, amount)
    local player = Players.LocalPlayer
    if not player then return end
    
    -- Use Blox Fruits CommF_ remote
    local commF = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
    if commF then
        pcall(function()
            commF:InvokeServer("AddPoint", statType, amount)
        end)
    end
end

local function maxStat(statType)
    for i = 1, 10 do
        addStats(statType, 10)
        task.wait(0.1)
    end
end

-- Auto Raid
local autoRaidEnabled = false
local raidConnection

local function enableAutoRaid()
    if raidConnection then return end
    
    raidConnection = RunService.Heartbeat:Connect(function()
        if not autoRaidEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        -- Look for raid entrance
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Raid") or obj.Name:find("raid") then
                if obj:IsA("Model") or obj:IsA("Folder") then
                    local distance = ((obj.PrimaryPart and obj.PrimaryPart.Position or obj.Position)
                                    - rootPart.Position).Magnitude
                    if distance < 50 then
                        for _, child in pairs(obj:GetDescendants()) do
                            if child:IsA("RemoteEvent") and child.Name:find("Start") then
                                pcall(function()
                                    child:FireServer()
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

local function disableAutoRaid()
    autoRaidEnabled = false
    if raidConnection then
        raidConnection:Disconnect()
        raidConnection = nil
    end
end

-- Auto Quest
local autoQuestEnabled = false
local questConnection

local function enableAutoQuest()
    if questConnection then return end
    
    questConnection = RunService.Heartbeat:Connect(function()
        if not autoQuestEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Check for quest NPCs in Workspace
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                local head = npc:FindFirstChild("Head")
                if head then
                    local distance = (head.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < 15 then
                        for _, child in pairs(npc:GetDescendants()) do
                            if child:IsA("RemoteEvent") or child:IsA("ProximityPrompt") then
                                pcall(function()
                                    if child:IsA("RemoteEvent") then
                                        child:FireServer()
                                    elseif child:IsA("ProximityPrompt") then
                                        if fireproximityprompt then
                                            fireproximityprompt(child)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

local function disableAutoQuest()
    autoQuestEnabled = false
    if questConnection then
        questConnection:Disconnect()
        questConnection = nil
    end
end

-- Auto Buy Fruits
local autoBuyEnabled = false
local buyConnection

local function enableAutoBuyFruits()
    if buyConnection then return end
    
    buyConnection = RunService.Heartbeat:Connect(function()
        if not autoBuyEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc.Name:find("Dealer") or npc.Name:find("Fruit") then
                if npc:IsA("Model") then
                    local head = npc:FindFirstChild("Head")
                    if head then
                        local distance = (head.Position - rootPart.Position).Magnitude
                        if distance < 15 then
                            for _, child in pairs(npc:GetDescendants()) do
                                if child:IsA("RemoteEvent") or child:IsA("ClickDetector") then
                                    pcall(function()
                                        if child:IsA("RemoteEvent") then
                                            child:FireServer("Buy", "Random")
                                        elseif child:IsA("ClickDetector") then
                                            if fireclickdetector then
                                                fireclickdetector(child)
                                            end
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

local function disableAutoBuyFruits()
    autoBuyEnabled = false
    if buyConnection then
        buyConnection:Disconnect()
        buyConnection = nil
    end
end

-- No Cooldown
local noCooldownEnabled = false
local cooldownConnection

local function enableNoCooldown()
    if cooldownConnection then return end
    
    cooldownConnection = RunService.RenderStepped:Connect(function()
        if not noCooldownEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local cooldown = tool:FindFirstChild("Cooldown")
                    if cooldown then
                        cooldown.Value = 0
                    end
                end
            end
        end
    end)
end)

local function disableNoCooldown()
    noCooldownEnabled = false
    if cooldownConnection then
        cooldownConnection:Disconnect()
        cooldownConnection = nil
    end
end

-- Infinite Range
local infiniteRangeEnabled = false
local rangeConnection

local function enableInfiniteRange()
    if rangeConnection then return end
    
    rangeConnection = RunService.RenderStepped:Connect(function()
        if not infiniteRangeEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    local range = tool:FindFirstChild("Range")
                    if range then
                        range.Value = 999
                    end
                end
            end
        end
    end)
end)

local function disableInfiniteRange()
    infiniteRangeEnabled = false
    if rangeConnection then
        rangeConnection:Disconnect()
        rangeConnection = nil
    end
end

-- Auto Dodge
local autoDodgeEnabled = false
local dodgeConnection

local function enableAutoDodge()
    if dodgeConnection then return end
    
    dodgeConnection = RunService.RenderStepped:Connect(function()
        if not autoDodgeEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        for _, projectile in pairs(Workspace:GetDescendants()) do
            if projectile:IsA("BasePart") and projectile:GetAttribute("Damage") then
                local distance = (projectile.Position - rootPart.Position).Magnitude
                if distance < 20 then
                    local dodgeDirection = (rootPart.Position - projectile.Position).Unit
                    local dodgePosition = rootPart.Position + dodgeDirection * 20
                    humanoid:MoveTo(dodgePosition)
                end
            end
        end
    end)
end)

local function disableAutoDodge()
    autoDodgeEnabled = false
    if dodgeConnection then
        dodgeConnection:Disconnect()
        dodgeConnection = nil
    end
end

-- Bring Enemies
local bringEnemiesEnabled = false
local bringConnection

local function enableBringEnemies()
    if bringConnection then return end
    
    bringConnection = RunService.Heartbeat:Connect(function()
        if not bringEnemiesEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local enemiesFolder = Workspace:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, enemy in pairs(enemiesFolder:GetDescendants()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                    local enemyRootPart = enemy.HumanoidRootPart
                    local distance = (enemyRootPart.Position - rootPart.Position).Magnitude
                    if distance < 50 then
                        magnetEnemy(enemy)
                    end
                end
            end
        end
    end)
end)

local function disableBringEnemies()
    bringEnemiesEnabled = false
    if bringConnection then
        bringConnection:Disconnect()
        bringConnection = nil
    end
end

-- Auto Attack
local autoAttackEnabled = false
local attackConnection

local function enableAutoAttack()
    if attackConnection then return end
    
    attackConnection = RunService.Heartbeat:Connect(function()
        if not autoAttackEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local target = findNearestEnemy()
        if target then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            else
                VirtualUser:Button1Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            end
        end
    end)
end)

local function disableAutoAttack()
    autoAttackEnabled = false
    if attackConnection then
        attackConnection:Disconnect()
        attackConnection = nil
    end
end

-- Teleport to Player
local teleportEnabled = false
local teleportConnection
local targetPlayerName = ""

local function setTeleportTarget(playerName)
    targetPlayerName = playerName
end

local function enableTeleportToPlayer()
    if teleportConnection then return end
    
    teleportConnection = RunService.Heartbeat:Connect(function()
        if not teleportEnabled or targetPlayerName == "" then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local targetPlayer = Players:FindFirstChild(targetPlayerName)
        if not targetPlayer then return end
        
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end
        
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not targetRootPart or not rootPart then return end
        
        rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 5)
    end)
end)

local function disableTeleportToPlayer()
    teleportEnabled = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
end

-- ============================================
-- Create Tabs
-- ============================================

local MainTab = Window:CreateTab("Main", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- ============================================
-- Main Tab Features
-- ============================================

MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        if Value then
            autoFarmEnabled = true
            startAutoFarm()
            Rayfield:Notify({
                Title = "Auto Farm",
                Content = "Enabled - Finds enemies in Workspace.Enemies",
                Duration = 3,
                Image = 4483362458
            })
        else
            stopAutoFarm()
            Rayfield:Notify({
                Title = "Auto Farm",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Raid",
    CurrentValue = false,
    Flag = "AutoRaid",
    Callback = function(Value)
        if Value then
            autoRaidEnabled = true
            enableAutoRaid()
            Rayfield:Notify({
                Title = "Auto Raid",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAutoRaid()
            Rayfield:Notify({
                Title = "Auto Raid",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Stats",
    CurrentValue = false,
    Flag = "AutoStats",
    Callback = function(Value)
        if Value then
            autoStatsEnabled = true
            task.spawn(function()
                while autoStatsEnabled do
                    maxStat("Melee")
                    task.wait(0.5)
                    maxStat("Defense")
                    task.wait(0.5)
                    maxStat("Sword")
                    task.wait(0.5)
                end
            end)
            Rayfield:Notify({
                Title = "Auto Stats",
                Content = "Enabled - Uses CommF_ remote",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Auto Stats",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Quest",
    CurrentValue = false,
    Flag = "AutoQuest",
    Callback = function(Value)
        if Value then
            autoQuestEnabled = true
            enableAutoQuest()
            Rayfield:Notify({
                Title = "Auto Quest",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAutoQuest()
            Rayfield:Notify({
                Title = "Auto Quest",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Buy Fruits",
    CurrentValue = false,
    Flag = "AutoBuyFruits",
    Callback = function(Value)
        if Value then
            autoBuyEnabled = true
            enableAutoBuyFruits()
            Rayfield:Notify({
                Title = "Auto Buy Fruits",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAutoBuyFruits()
            Rayfield:Notify({
                Title = "Auto Buy Fruits",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- ============================================
-- Stats Tab Features
-- ============================================

StatsTab:CreateButton({
    Name = "Max Melee",
    Callback = function()
        maxStat("Melee")
        Rayfield:Notify({
            Title = "Max Melee",
            Content = "Maxed!",
            Duration = 3,
            Image = 4483362458
        })
    end
})

StatsTab:CreateButton({
    Name = "Max Defense",
    Callback = function()
        maxStat("Defense")
        Rayfield:Notify({
            Title = "Max Defense",
            Content = "Maxed!",
            Duration = 3,
            Image = 4483362458
        })
    end
})

StatsTab:CreateButton({
    Name = "Max Sword",
    Callback = function()
        maxStat("Sword")
        Rayfield:Notify({
            Title = "Max Sword",
            Content = "Maxed!",
            Duration = 3,
            Image = 4483362458
        })
    end
})

StatsTab:CreateButton({
    Name = "Max Gun",
    Callback = function()
        maxStat("Gun")
        Rayfield:Notify({
            Title = "Max Gun",
            Content = "Maxed!",
            Duration = 3,
            Image = 4483362458
        })
    end
})

StatsTab:CreateButton({
    Name = "Max Fruit",
    Callback = function()
        maxStat("Demon Fruit")
        Rayfield:Notify({
            Title = "Max Fruit",
            Content = "Maxed!",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- ============================================
-- Combat Tab Features
-- ============================================

CombatTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = false,
    Flag = "AutoAttack",
    Callback = function(Value)
        if Value then
            autoAttackEnabled = true
            enableAutoAttack()
            Rayfield:Notify({
                Title = "Auto Attack",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAutoAttack()
            Rayfield:Notify({
                Title = "Auto Attack",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "Bring Enemies",
    CurrentValue = false,
    Flag = "BringEnemies",
    Callback = function(Value)
        if Value then
            bringEnemiesEnabled = true
            enableBringEnemies()
            Rayfield:Notify({
                Title = "Bring Enemies",
                Content = "Enabled - Magnet farming",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableBringEnemies()
            Rayfield:Notify({
                Title = "Bring Enemies",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "No Cooldown",
    CurrentValue = false,
    Flag = "NoCooldown",
    Callback = function(Value)
        if Value then
            noCooldownEnabled = true
            enableNoCooldown()
            Rayfield:Notify({
                Title = "No Cooldown",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableNoCooldown()
            Rayfield:Notify({
                Title = "No Cooldown",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "Infinite Range",
    CurrentValue = false,
    Flag = "InfiniteRange",
    Callback = function(Value)
        if Value then
            infiniteRangeEnabled = true
            enableInfiniteRange()
            Rayfield:Notify({
                Title = "Infinite Range",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableInfiniteRange()
            Rayfield:Notify({
                Title = "Infinite Range",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

CombatTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = false,
    Flag = "AutoDodge",
    Callback = function(Value)
        if Value then
            autoDodgeEnabled = true
            enableAutoDodge()
            Rayfield:Notify({
                Title = "Auto Dodge",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAutoDodge()
            Rayfield:Notify({
                Title = "Auto Dodge",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- ============================================
-- Teleport Tab Features
-- ============================================

TeleportTab:CreateToggle({
    Name = "Fly (WASD + Space)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        if Value then
            enableFly()
            Rayfield:Notify({
                Title = "Fly",
                Content = "Enabled - Use WASD + Space",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableFly()
            Rayfield:Notify({
                Title = "Fly",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        if Value then
            enableInfiniteJump()
            Rayfield:Notify({
                Title = "Infinite Jump",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableInfiniteJump()
            Rayfield:Notify({
                Title = "Infinite Jump",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedBoost",
    Callback = function(Value)
        if Value then
            enableSpeedBoost()
            Rayfield:Notify({
                Title = "Speed Boost",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableSpeedBoost()
            Rayfield:Notify({
                Title = "Speed Boost",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "Teleport to Player",
    CurrentValue = false,
    Flag = "TeleportToPlayer",
    Callback = function(Value)
        if Value then
            teleportEnabled = true
            local character = LocalPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local nearestPlayer = nil
                    local nearestDist = math.huge
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local targetChar = player.Character
                            if targetChar then
                                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                if targetRoot then
                                    local dist = (targetRoot.Position - rootPart.Position).Magnitude
                                    if dist < nearestDist then
                                        nearestDist = dist
                                        nearestPlayer = player.Name
                                    end
                                end
                            end
                        end
                    end
                    
                    if nearestPlayer then
                        setTeleportTarget(nearestPlayer)
                        enableTeleportToPlayer()
                        Rayfield:Notify({
                            Title = "Teleport",
                            Content = "Teleporting to " .. nearestPlayer,
                            Duration = 3,
                            Image = 4483362458
                        })
                    else
                        Rayfield:Notify({
                            Title = "Teleport",
                            Content = "No players found",
                            Duration = 3,
                            Image = 4483362458
                        })
                    end
                end
            end
        else
            disableTeleportToPlayer()
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

TeleportTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        if Value then
            enableNoClip()
            Rayfield:Notify({
                Title = "No Clip",
                Content = "Enabled",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableNoClip()
            Rayfield:Notify({
                Title = "No Clip",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- ============================================
-- Cleanup on script unload
-- ============================================

local function cleanup()
    autoFarmEnabled = false
    autoStatsEnabled = false
    autoRaidEnabled = false
    autoQuestEnabled = false
    autoBuyEnabled = false
    noCooldownEnabled = false
    infiniteRangeEnabled = false
    autoDodgeEnabled = false
    bringEnemiesEnabled = false
    autoAttackEnabled = false
    teleportEnabled = false
    flyEnabled = false
    noClipEnabled = false
    
    stopAutoFarm()
    disableAutoRaid()
    disableAutoQuest()
    disableAutoBuyFruits()
    disableInfiniteJump()
    disableSpeedBoost()
    disableFly()
    disableNoClip()
    disableNoCooldown()
    disableInfiniteRange()
    disableAutoDodge()
    disableBringEnemies()
    disableAutoAttack()
    disableTeleportToPlayer()
    
    -- Note: autoStats thread will naturally exit when autoStatsEnabled is false
end

Rayfield:Load()

print("[Hub] Blox Fruits Hub loaded successfully!")
print("[Hub] Using Ray Field UI")
print("[Hub] All features ready")
print("[Hub] Auto Farm now targets Workspace.Enemies")
print("[Hub] Stats use CommF_ remote event")

end)

if not success then
    warn("[Hub] Error: " .. tostring(errorMessage))
    warn("[Hub] Script failed to load. Please try again.")
end