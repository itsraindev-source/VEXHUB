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
local currentTween = nil

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

local function tweenToPosition(cframe)
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Cancel existing tween
    if currentTween then
        currentTween:Cancel()
    end
    
    -- Calculate duration based on distance (anti-cheat safe)
    local distance = (cframe.Position - rootPart.Position).Magnitude
    local duration = distance / 200  -- Speed of 200 studs per second
    
    -- Create tween with linear easing for smooth movement
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(rootPart, tweenInfo, {CFrame = cframe})
    currentTween:Play()
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
                    -- Tween to enemy (safer than instant teleport, anti-cheat friendly)
                    tweenToPosition(enemyRootPart.CFrame * CFrame.new(0, 0, 5))
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

local function acceptQuest(questName, questNumber)
    local commF = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
    if commF then
        pcall(function()
            commF:InvokeServer("StartQuest", questName, questNumber)
        end)
    end
end

local function checkQuestUI()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    local mainGui = playerGui:FindFirstChild("Main")
    if not mainGui then return false end
    
    local questGui = mainGui:FindFirstChild("Quest")
    if not questGui then return false end
    
    return questGui.Visible
end

local function enableAutoQuest()
    if questConnection then return end
    
    questConnection = RunService.Heartbeat:Connect(function()
        if not autoQuestEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Try to accept quest from CommF_ remote if available
        local commF = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("CommF_")
        if commF then
            -- Try common quest names based on level
            local level = LocalPlayer:FindFirstChild("Data"):FindFirstChild("Level")
            if level then
                local lvl = level.Value
                local questName = "BanditQuest1"
                local questNum = 1
                
                if lvl >= 10 and lvl < 50 then
                    questName = "JungleQuest"
                elseif lvl >= 50 and lvl < 100 then
                    questName = "BuggyQuest1"
                elseif lvl >= 100 and lvl < 150 then
                    questName = "SnowQuest1"
                elseif lvl >= 150 and lvl < 200 then
                    questName = "MarineQuest1"
                elseif lvl >= 200 and lvl < 250 then
                    questName = "SkyQuest1"
                elseif lvl >= 250 and lvl < 300 then
                    questName = "ColosseumQuest1"
                elseif lvl >= 300 and lvl < 350 then
                    questName = "FireSideQuest1"
                elseif lvl >= 350 and lvl < 400 then
                    questName = "DungeonQuest1"
                elseif lvl >= 400 and lvl < 450 then
                    questName = "ArlongQuest1"
                elseif lvl >= 450 and lvl < 500 then
                    questName = "SkyQuest2"
                elseif lvl >= 500 and lvl < 550 then
                    questName = "FountainQuest1"
                elseif lvl >= 550 and lvl < 600 then
                    questName = "BuggyQuest2"
                elseif lvl >= 600 and lvl < 650 then
                    questName = "CursedShipQuest1"
                elseif lvl >= 650 and lvl < 700 then
                    questName = "FactoryQuest1"
                elseif lvl >= 700 and lvl < 750 then
                    questName = "SeaBeastQuest1"
                elseif lvl >= 750 and lvl < 800 then
                    questName = "HauntedShipQuest1"
                elseif lvl >= 800 and lvl < 850 then
                    questName = "IceCastleQuest1"
                elseif lvl >= 850 and lvl < 900 then
                    questName = "ForgottenQuest1"
                elseif lvl >= 900 and lvl < 950 then
                    questName = "CyborgQuest1"
                elseif lvl >= 950 and lvl < 1000 then
                    questName = "CakeQuest1"
                elseif lvl >= 1000 and lvl < 1050 then
                    questName = "LegendarySwordQuest1"
                elseif lvl >= 1050 and lvl < 1100 then
                    questName = "PirateRaidQuest1"
                elseif lvl >= 1100 and lvl < 1150 then
                    questName = "IceQuest1"
                elseif lvl >= 1150 and lvl < 1200 then
                    questName = "BountyQuest1"
                elseif lvl >= 1200 and lvl < 1250 then
                    questName = "RipIndraQuest1"
                elseif lvl >= 1250 and lvl < 1300 then
                    questName = "DoughQuest1"
                elseif lvl >= 1300 and lvl < 1350 then
                    questName = "CakeQuest2"
                elseif lvl >= 1350 and lvl < 1400 then
                    questName = "TushitaQuest1"
                elseif lvl >= 1400 and lvl < 1450 then
                    questName = "PoleQuest1"
                elseif lvl >= 1450 and lvl < 1500 then
                    questName = "PoleQuest2"
                elseif lvl >= 1500 and lvl < 1550 then
                    questName = "PaleHeartQuest1"
                elseif lvl >= 1550 and lvl < 1600 then
                    questName = "EliteHunterQuest1"
                elseif lvl >= 1600 and lvl < 1650 then
                    questName = "DarkbeardQuest1"
                elseif lvl >= 1650 and lvl < 1700 then
                    questName = "AwakeningQuest1"
                elseif lvl >= 1700 and lvl < 1750 then
                    questName = "RipIndraQuest2"
                elseif lvl >= 1750 and lvl < 1800 then
                    questName = "CakeQuest3"
                elseif lvl >= 1800 and lvl < 1850 then
                    questName = "TushitaQuest2"
                elseif lvl >= 1850 and lvl < 1900 then
                    questName = "SoulReaperQuest1"
                elseif lvl >= 1900 and lvl < 1950 then
                    questName = "RaceV4Quest1"
                elseif lvl >= 1950 and lvl < 2000 then
                    questName = "GodhumanQuest1"
                elseif lvl >= 2000 and lvl < 2050 then
                    questName = "MirrorFractalQuest1"
                elseif lvl >= 2050 and lvl < 2100 then
                    questName = "ThunderGodQuest1"
                elseif lvl >= 2100 and lvl < 2150 then
                    questName = "SoulGuitarQuest1"
                elseif lvl >= 2150 and lvl < 2200 then
                    questName = "CDKQuest1"
                elseif lvl >= 2200 and lvl < 2250 then
                    questName = "AngelQuest1"
                elseif lvl >= 2250 and lvl < 2300 then
                    questName = "TrueTripleKatanaQuest1"
                elseif lvl >= 2300 and lvl < 2350 then
                    questName = "BuddySwordQuest1"
                elseif lvl >= 2350 and lvl < 2400 then
                    questName = "RengokuQuest1"
                elseif lvl >= 2400 and lvl < 2450
                    questName = "SpikeyTridentQuest1"
                elseif lvl >= 2450 and lvl < 2500
                    questName = "DarkLegionQuest1"
                elseif lvl >= 2500 and lvl < 2550
                    questName = "CanvanderQuest1"
                elseif lvl >= 2550 and lvl < 2600
                    questName = "BuddySwordQuest2"
                elseif lvl >= 2600 and lvl < 2650
                    questName = "SpikeyTridentQuest2"
                elseif lvl >= 2650 and lvl < 2700
                    questName = "DarkLegionQuest2"
                elseif lvl >= 2700 and lvl < 2750
                    questName = "CanvanderQuest2"
                elseif lvl >= 2750 and lvl < 2800
                    questName = "BuddySwordQuest3"
                elseif lvl >= 2800 and lvl < 2850
                    questName = "SpikeyTridentQuest3"
                elseif lvl >= 2850 and lvl < 2900
                    questName = "DarkLegionQuest3"
                elseif lvl >= 2900 and lvl < 2950
                    questName = "CanvanderQuest3"
                elseif lvl >= 2950 and lvl < 3000
                    questName = "BuddySwordQuest4"
                elseif lvl >= 3000 and lvl < 3050
                    questName = "SpikeyTridentQuest4"
                elseif lvl >= 3050 and lvl < 3100
                    questName = "DarkLegionQuest4"
                elseif lvl >= 3100 and lvl < 3150
                    questName = "CanvanderQuest4"
                elseif lvl >= 3150 and lvl < 3200
                    questName = "BuddySwordQuest5"
                elseif lvl >= 3200 and lvl < 3250
                    questName = "SpikeyTridentQuest5"
                elseif lvl >= 3250 and lvl < 3300
                    questName = "DarkLegionQuest5"
                elseif lvl >= 3300 and lvl < 3350
                    questName = "CanvanderQuest5"
                elseif lvl >= 3350 and lvl < 3400
                    questName = "BuddySwordQuest6"
                elseif lvl >= 3400 and lvl < 3450
                    questName = "SpikeyTridentQuest6"
                elseif lvl >= 3450 and lvl < 3500
                    questName = "DarkLegionQuest6"
                elseif lvl >= 3500 and lvl < 3550
                    questName = "CanvanderQuest6"
                elseif lvl >= 3550 and lvl < 3600
                    questName = "BuddySwordQuest7"
                elseif lvl >= 3600 and lvl < 3650
                    questName = "SpikeyTridentQuest7"
                elseif lvl >= 3650 and lvl < 3700
                    questName = "DarkLegionQuest7"
                elseif lvl >= 3700 and lvl < 3750
                    questName = "CanvanderQuest7"
                elseif lvl >= 3750 and lvl < 3800
                    questName = "BuddySwordQuest8"
                elseif lvl >= 3800 and lvl < 3850
                    questName = "SpikeyTridentQuest8"
                elseif lvl >= 3850 and lvl < 3900
                    questName = "DarkLegionQuest8"
                elseif lvl >= 3900 and lvl < 3950
                    questName = "CanvanderQuest8"
                elseif lvl >= 3950 and lvl < 4000
                    questName = "BuddySwordQuest9"
                elseif lvl >= 4000 and lvl < 4050
                    questName = "SpikeyTridentQuest9"
                elseif lvl >= 4050 and lvl < 4100
                    questName = "DarkLegionQuest9"
                elseif lvl >= 4100 and lvl < 4150
                    questName = "CanvanderQuest9"
                elseif lvl >= 4150 and lvl < 4200
                    questName = "BuddySwordQuest10"
                elseif lvl >= 4200 and lvl < 4250
                    questName = "SpikeyTridentQuest10"
                elseif lvl >= 4250 and lvl < 4300
                    questName = "DarkLegionQuest10"
                elseif lvl >= 4300 and lvl < 4350
                    questName = "CanvanderQuest10"
                elseif lvl >= 4350 and lvl < 4400
                    questName = "BuddySwordQuest11"
                elseif lvl >= 4400 and lvl < 4450
                    questName = "SpikeyTridentQuest11"
                elseif lvl >= 4450 and lvl < 4500
                    questName = "DarkLegionQuest11"
                elseif lvl >= 4500 and lvl < 4550
                    questName = "CanvanderQuest11"
                elseif lvl >= 4550 and lvl < 4600
                    questName = "BuddySwordQuest12"
                elseif lvl >= 4600 and lvl < 4650
                    questName = "SpikeyTridentQuest12"
                elseif lvl >= 4650 and lvl < 4700
                    questName = "DarkLegionQuest12"
                elseif lvl >= 4700 and lvl < 4750
                    questName = "CanvanderQuest12"
                elseif lvl >= 4750 and lvl < 4800
                    questName = "BuddySwordQuest13"
                elseif lvl >= 4800 and lvl < 4850
                    questName = "SpikeyTridentQuest13"
                elseif lvl >= 4850 and lvl < 4900
                    questName = "DarkLegionQuest13"
                elseif lvl >= 4900 and lvl < 4950
                    questName = "CanvanderQuest13"
                elseif lvl >= 4950 and lvl < 5000
                    questName = "BuddySwordQuest14"
                elseif lvl >= 5000 and lvl < 5050
                    questName = "SpikeyTridentQuest14"
                elseif lvl >= 5050 and lvl < 5100
                    questName = "DarkLegionQuest14"
                elseif lvl >= 5100 and lvl < 5150
                    questName = "CanvanderQuest14"
                elseif lvl >= 5150 and lvl < 5200
                    questName = "BuddySwordQuest15"
                elseif lvl >= 5200 and lvl < 5250
                    questName = "SpikeyTridentQuest15"
                elseif lvl >= 5250 and lvl < 5300
                    questName = "DarkLegionQuest15"
                elseif lvl >= 5300 and lvl < 5350
                    questName = "CanvanderQuest15"
                elseif lvl >= 5350 and lvl < 5400
                    questName = "BuddySwordQuest16"
                elseif lvl >= 5400 and lvl < 5450
                    questName = "SpikeyTridentQuest16"
                elseif lvl >= 5450 and lvl < 5500
                    questName = "DarkLegionQuest16"
                elseif lvl >= 5500 and lvl < 5550
                    questName = "CanvanderQuest16"
                elseif lvl >= 5550 and lvl < 5600
                    questName = "BuddySwordQuest17"
                elseif lvl >= 5600 and lvl < 5650
                    questName = "SpikeyTridentQuest17"
                elseif lvl >= 5650 and lvl < 5700
                    questName = "DarkLegionQuest17"
                elseif lvl >= 5700 and lvl < 5750
                    questName = "CanvanderQuest17"
                elseif lvl >= 5750 and lvl < 5800
                    questName = "BuddySwordQuest18"
                elseif lvl >= 5800 and lvl < 5850
                    questName = "SpikeyTridentQuest18"
                elseif lvl >= 5850 and lvl < 5900
                    questName = "DarkLegionQuest18"
                elseif lvl >= 5900 and lvl < 5950
                    questName = "CanvanderQuest18"
                elseif lvl >= 5950 and lvl < 6000
                    questName = "BuddySwordQuest19"
                elseif lvl >= 6000 and lvl < 6050
                    questName = "SpikeyTridentQuest19"
                elseif lvl >= 6050 and lvl < 6100
                    questName = "DarkLegionQuest19"
                elseif lvl >= 6100 and lvl < 6150
                    questName = "CanvanderQuest19"
                elseif lvl >= 6150 and lvl < 6200
                    questName = "BuddySwordQuest20"
                elseif lvl >= 6200 and lvl < 6250
                    questName = "SpikeyTridentQuest20"
                elseif lvl >= 6250 and lvl < 6300
                    questName = "DarkLegionQuest20"
                elseif lvl >= 6300 and lvl < 6350
                    questName = "CanvanderQuest20"
                elseif lvl >= 6350 and lvl < 6400
                    questName = "BuddySwordQuest21"
                elseif lvl >= 6400 and lvl < 6450
                    questName = "SpikeyTridentQuest21"
                elseif lvl >= 6450 and lvl < 6500
                    questName = "DarkLegionQuest21"
                elseif lvl >= 6500 and lvl < 6550
                    questName = "CanvanderQuest21"
                elseif lvl >= 6550 and lvl < 6600
                    questName = "BuddySwordQuest22"
                elseif lvl >= 6600 and lvl < 6650
                    questName = "SpikeyTridentQuest22"
                elseif lvl >= 6650 and lvl < 6700
                    questName = "DarkLegionQuest22"
                elseif lvl >= 6700 and lvl < 6750
                    questName = "CanvanderQuest22"
                elseif lvl >= 6750 and lvl < 6800
                    questName = "BuddySwordQuest23"
                elseif lvl >= 6800 and lvl < 6850
                    questName = "SpikeyTridentQuest23"
                elseif lvl >= 6850 and lvl < 6900
                    questName = "DarkLegionQuest23"
                elseif lvl >= 6900 and lvl < 6950
                    questName = "CanvanderQuest23"
                elseif lvl >= 6950 and lvl < 7000
                    questName = "BuddySwordQuest24"
                elseif lvl >= 7000 and lvl < 7050
                    questName = "SpikeyTridentQuest24"
                elseif lvl >= 7050 and lvl < 7100
                    questName = "DarkLegionQuest24"
                elseif lvl >= 7100 and lvl < 7150
                    questName = "CanvanderQuest24"
                elseif lvl >= 7150 and lvl < 7200
                    questName = "BuddySwordQuest25"
                elseif lvl >= 7200 and lvl < 7250
                    questName = "SpikeyTridentQuest25"
                elseif lvl >= 7250 and lvl < 7300
                    questName = "DarkLegionQuest25"
                elseif lvl >= 7300 and lvl < 7350
                    questName = "CanvanderQuest25"
                elseif lvl >= 7350 and lvl < 7400
                    questName = "BuddySwordQuest26"
                elseif lvl >= 7400 and lvl < 7450
                    questName = "SpikeyTridentQuest26"
                elseif lvl >= 7450 and lvl < 7500
                    questName = "DarkLegionQuest26"
                elseif lvl >= 7500 and lvl < 7550
                    questName = "CanvanderQuest26"
                elseif lvl >= 7550 and lvl < 7600
                    questName = "BuddySwordQuest27"
                elseif lvl >= 7600 and lvl < 7650
                    questName = "SpikeyTridentQuest27"
                elseif lvl >= 7650 and lvl < 7700
                    questName = "DarkLegionQuest27"
                elseif lvl >= 7700 and lvl < 7750
                    questName = "CanvanderQuest27"
                elseif lvl >= 7750 and lvl < 7800
                    questName = "BuddySwordQuest28"
                elseif lvl >= 7800 and lvl < 7850
                    questName = "SpikeyTridentQuest28"
                elseif lvl >= 7850 and lvl < 7900
                    questName = "DarkLegionQuest28"
                elseif lvl >= 7900 and lvl < 7950
                    questName = "CanvanderQuest28"
                elseif lvl >= 7950 and lvl < 8000
                    questName = "BuddySwordQuest29"
                elseif lvl >= 8000 and lvl < 8050
                    questName = "SpikeyTridentQuest29"
                elseif lvl >= 8050 and lvl < 8100
                    questName = "DarkLegionQuest29"
                elseif lvl >= 8100 and lvl < 8150
                    questName = "CanvanderQuest29"
                elseif lvl >= 8150 and lvl < 8200
                    questName = "BuddySwordQuest30"
                elseif lvl >= 8200 and lvl < 8250
                    questName = "SpikeyTridentQuest30"
                elseif lvl >= 8250 and lvl < 8300
                    questName = "DarkLegionQuest30"
                elseif lvl >= 8300 and lvl < 8350
                    questName = "CanvanderQuest30"
                elseif lvl >= 8350 and lvl < 8400
                    questName = "BuddySwordQuest31"
                elseif lvl >= 8400 and lvl < 8450
                    questName = "SpikeyTridentQuest31"
                elseif lvl >= 8450 and lvl < 8500
                    questName = "DarkLegionQuest31"
                elseif lvl >= 8500 and lvl < 8550
                    questName = "CanvanderQuest31"
                elseif lvl >= 8550 and lvl < 8600
                    questName = "BuddySwordQuest32"
                elseif lvl >= 8600 and lvl < 8650
                    questName = "SpikeyTridentQuest32"
                elseif lvl >= 8650 and lvl < 8700
                    questName = "DarkLegionQuest32"
                elseif lvl >= 8700 and lvl < 8750
                    questName = "CanvanderQuest32"
                elseif lvl >= 8750 and lvl < 8800
                    questName = "BuddySwordQuest33"
                elseif lvl >= 8800 and lvl < 8850
                    questName = "SpikeyTridentQuest33"
                elseif lvl >= 8850 and lvl < 8900
                    questName = "DarkLegionQuest33"
                elseif lvl >= 8900 and lvl < 8950
                    questName = "CanvanderQuest33"
                elseif lvl >= 8950 and lvl < 9000
                    questName = "BuddySwordQuest34"
                elseif lvl >= 9000 and lvl < 9050
                    questName = "SpikeyTridentQuest34"
                elseif lvl >= 9050 and lvl < 9100
                    questName = "DarkLegionQuest34"
                elseif lvl >= 9100 and lvl < 9150
                    questName = "CanvanderQuest34"
                elseif lvl >= 9150 and lvl < 9200
                    questName = "BuddySwordQuest35"
                elseif lvl >= 9200 and lvl < 9250
                    questName = "SpikeyTridentQuest35"
                elseif lvl >= 9250 and lvl < 9300
                    questName = "DarkLegionQuest35"
                elseif lvl >= 9300 and lvl < 9350
                    questName = "CanvanderQuest35"
                elseif lvl >= 9350 and lvl < 9400
                    questName = "BuddySwordQuest36"
                elseif lvl >= 9400 and lvl < 9450
                    questName = "SpikeyTridentQuest36"
                elseif lvl >= 9450 and lvl < 9500
                    questName = "DarkLegionQuest36"
                elseif lvl >= 9500 and lvl < 9550
                    questName = "CanvanderQuest36"
                elseif lvl >= 9550 and lvl < 9600
                    questName = "BuddySwordQuest37"
                elseif lvl >= 9600 and lvl < 9650
                    questName = "SpikeyTridentQuest37"
                elseif lvl >= 9650 and lvl < 9700
                    questName = "DarkLegionQuest37"
                elseif lvl >= 9700 and lvl < 9750
                    questName = "CanvanderQuest37"
                elseif lvl >= 9750 and lvl < 9800
                    questName = "BuddySwordQuest38"
                elseif lvl >= 9800 and lvl < 9850
                    questName = "SpikeyTridentQuest38"
                elseif lvl >= 9850 and lvl < 9900
                    questName = "DarkLegionQuest38"
                elseif lvl >= 9900 and lvl < 9950
                    questName = "CanvanderQuest38"
                elseif lvl >= 9950 and lvl < 10000
                    questName = "BuddySwordQuest39"
                elseif lvl >= 10000
                    questName = "MaxLevelQuest1"
                end
                
                acceptQuest(questName, questNum)
            end
        end
        
        -- Also check for NPC proximity prompts
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                local head = npc:FindFirstChild("Head")
                if head then
                    local distance = (head.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < 15 then
                        for _, child in pairs(npc:GetDescendants()) do
                            if child:IsA("ProximityPrompt") then
                                pcall(function()
                                    if fireproximityprompt then
                                        fireproximityprompt(child)
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
-- PvP Functions
-- ============================================

-- Aimbot
local aimbotEnabled = false
local aimbotConnection
local aimbotTarget = nil

local function findNearestPlayer()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetCharacter = player.Character
            if targetCharacter then
                local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
                local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                
                if targetHumanoid and targetHumanoid.Health > 0 and targetRootPart then
                    local distance = (targetRootPart.Position - humanoidRootPart.Position).Magnitude
                    if distance < nearestDistance and distance < 500 then
                        nearestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    
    return nearestPlayer
end

local function enableAimbot()
    if aimbotConnection then return end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local targetPlayer = findNearestPlayer()
        if not targetPlayer then return end
        
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end
        
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRootPart then return end
        
        local camera = Workspace.CurrentCamera
        if camera then
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetRootPart.Position)
        end
    end)
end

local function disableAimbot()
    aimbotEnabled = false
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- Kill Aura
local killAuraEnabled = false
local killAuraConnection

local function enableKillAura()
    if killAuraConnection then return end
    
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not killAuraEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if not tool then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetCharacter = player.Character
                if targetCharacter then
                    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
                    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                    
                    if targetHumanoid and targetHumanoid.Health > 0 and targetRootPart then
                        local distance = (targetRootPart.Position - rootPart.Position).Magnitude
                        if distance < 30 then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end)
end)

local function disableKillAura()
    killAuraEnabled = false
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
end

-- Target Lock
local targetLockEnabled = false
local targetLockConnection
local lockedTarget = nil

local function enableTargetLock()
    if targetLockConnection then return end
    
    targetLockConnection = RunService.RenderStepped:Connect(function()
        if not targetLockEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        if not lockedTarget or not lockedTarget.Character then
            lockedTarget = findNearestPlayer()
        end
        
        if lockedTarget and lockedTarget.Character then
            local targetCharacter = lockedTarget.Character
            local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
            
            if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 then
                local camera = Workspace.CurrentCamera
                if camera then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetRootPart.Position)
                end
            else
                lockedTarget = nil
            end
        end
    end)
end)

local function disableTargetLock()
    targetLockEnabled = false
    lockedTarget = nil
    if targetLockConnection then
        targetLockConnection:Disconnect()
        targetLockConnection = nil
    end
end

-- Reach
local reachEnabled = false
local reachConnection

local function enableReach()
    if reachConnection then return end
    
    reachConnection = RunService.RenderStepped:Connect(function()
        if not reachEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local reach = tool:FindFirstChild("Range")
                if reach then
                    reach.Value = 50
                end
            end
        end
    end)
end)

local function disableReach()
    reachEnabled = false
    if reachConnection then
        reachConnection:Disconnect()
        reachConnection = nil
    end
end

-- Velocity Changer (Anti-KB)
local velocityEnabled = false
local velocityConnection

local function enableVelocity()
    if velocityConnection then return end
    
    velocityConnection = RunService.Stepped:Connect(function()
        if not velocityEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)
end)

local function disableVelocity()
    velocityEnabled = false
    if velocityConnection then
        velocityConnection:Disconnect()
        velocityConnection = nil
    end
end

-- Auto Clicker
local autoClickerEnabled = false
local autoClickerConnection

local function enableAutoClicker()
    if autoClickerConnection then return end
    
    autoClickerConnection = RunService.RenderStepped:Connect(function()
        if not autoClickerEnabled then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end)

local function disableAutoClicker()
    autoClickerEnabled = false
    if autoClickerConnection then
        autoClickerConnection:Disconnect()
        autoClickerConnection = nil
    end
end

-- Silent Aim
local silentAimEnabled = false
local silentAimConnection

local function enableSilentAim()
    if silentAimConnection then return end
    
    silentAimConnection = RunService.RenderStepped:Connect(function()
        if not silentAimEnabled then return end
        
        local targetPlayer = findNearestPlayer()
        if not targetPlayer then return end
        
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end
        
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRootPart then return end
        
        -- Modify mouse hit silently
        local mouse = LocalPlayer:GetMouse()
        if mouse then
            mouse.Hit = CFrame.new(targetRootPart.Position)
        end
    end)
end)

local function disableSilentAim()
    silentAimEnabled = false
    if silentAimConnection then
        silentAimConnection:Disconnect()
        silentAimConnection = nil
    end
end

-- ============================================
-- Create Tabs
-- ============================================

local MainTab = Window:CreateTab("Main", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local PvPTab = Window:CreateTab("PvP", 4483362458)

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
-- PvP Tab Features
-- ============================================

PvPTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        if Value then
            aimbotEnabled = true
            enableAimbot()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Enabled - Locks to nearest player",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAimbot()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

PvPTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        if Value then
            killAuraEnabled = true
            enableKillAura()
            Rayfield:Notify({
                Title = "Kill Aura",
                Content = "Enabled - Attacks nearby players",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableKillAura()
            Rayfield:Notify({
                Title = "Kill Aura",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

PvPTab:CreateToggle({
    Name = "Target Lock",
    CurrentValue = false,
    Flag = "TargetLock",
    Callback = function(Value)
        if Value then
            targetLockEnabled = true
            enableTargetLock()
            Rayfield:Notify({
                Title = "Target Lock",
                Content = "Enabled - Locks to single target",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableTargetLock()
            Rayfield:Notify({
                Title = "Target Lock",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

PvPTab:CreateToggle({
    Name = "Reach",
    CurrentValue = false,
    Flag = "Reach",
    Callback = function(Value)
        if Value then
            reachEnabled = true
            enableReach()
            Rayfield:Notify({
                Title = "Reach",
                Content = "Enabled - Extended attack range",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableReach()
            Rayfield:Notify({
                Title = "Reach",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

PvPTab:CreateToggle({
    Name = "Anti-KB (Velocity)",
    CurrentValue = false,
    Flag = "AntiKB",
    Callback = function(Value)
        if Value then
            velocityEnabled = true
            enableVelocity()
            Rayfield:Notify({
                Title = "Anti-KB",
                Content = "Enabled - No knockback",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableVelocity()
            Rayfield:Notify({
                Title = "Anti-KB",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

PvPTab:CreateToggle({
    Name = "Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClicker",
    Callback = function(Value)
        if Value then
            autoClickerEnabled = true
            enableAutoClicker()
            Rayfield:Notify({
                Title = "Auto Clicker",
                Content = "Enabled - Auto attacks",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableAutoClicker()
            Rayfield:Notify({
                Title = "Auto Clicker",
                Content = "Disabled",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

PvPTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value)
        if Value then
            silentAimEnabled = true
            enableSilentAim()
            Rayfield:Notify({
                Title = "Silent Aim",
                Content = "Enabled - Invisible aim assist",
                Duration = 3,
                Image = 4483362458
            })
        else
            disableSilentAim()
            Rayfield:Notify({
                Title = "Silent Aim",
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
    aimbotEnabled = false
    killAuraEnabled = false
    targetLockEnabled = false
    reachEnabled = false
    velocityEnabled = false
    autoClickerEnabled = false
    silentAimEnabled = false
    
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
    disableAimbot()
    disableKillAura()
    disableTargetLock()
    disableReach()
    disableVelocity()
    disableAutoClicker()
    disableSilentAim()
    
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