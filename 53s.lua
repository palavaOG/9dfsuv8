

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Libraries/main/Shaman/Library.lua'))()
local Flags = Library.Flags

local function Notify(text, duration)
    duration = duration or 3

    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleNotify"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 50)
    frame.Position = UDim2.new(0.5, -140, 0, -60) -- starts off-screen
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Slide in
    game:GetService("TweenService"):Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -140, 0, 20)
    }):Play()

    task.delay(duration, function()
        -- Slide out
        local tween = game:GetService("TweenService"):Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Position = UDim2.new(0.5, -140, 0, -60)
        })
        tween:Play()
        tween.Completed:Wait()
        screenGui:Destroy()
    end)
end

local plrteam = game.Players.LocalPlayer.Team.Name
local plrname = game.Players.LocalPlayer.Name

if not plrteam then
    game.Players.LocalPlayer:Kick("Ensure you're fully loaded in or not in any menus before executing")
    return
end

local tycoon = workspace.Tycoon.Tycoons:FindFirstChild(plrteam)

if not tycoon or not tycoon:FindFirstChild("Essentials") 
    or not tycoon.Essentials:FindFirstChild("CollectorParts")
    or not tycoon.Essentials.CollectorParts:FindFirstChild("Collector") then

    game.Players.LocalPlayer:Kick("Ensure you're fully loaded in or not in any menus before executing")
    return
end

local Window = Library:Window({
    Text = "War Tycoon - " .. plrname .. " - Team " .. plrteam
})

local Tab1 = Window:Tab({
    Text = "Local Player"
})

local Tab2 = Window:Tab({
    Text = "Players"
})

local Tab3 = Window:Tab({
    Text = "Visual"
})

local Tab4 = Window:Tab({
    Text = "Operation Helper"
})


-- LP
local lpSection = Tab1:Section({
    Text = "Player",
    Side = "Left"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Persistent settings
local currentWalkSpeed = 16
local currentJumpHeight = 7.2
local noclipEnabled = false
local flightEnabled = false
local flySpeed = 50

local noclipConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local originalCollide = {}

-- ====================== APPLY FUNCTIONS ======================

local function applyWalkSpeed(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentWalkSpeed
    end
end

local function applyJumpHeight(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpHeight = currentJumpHeight
    end
end

local function enableNoclip(character)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    table.clear(originalCollide)

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCollide[part] = part.CanCollide
        end
    end

    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        for part, _ in pairs(originalCollide) do
            if part and part.Parent then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    for part, canCollide in pairs(originalCollide) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
    table.clear(originalCollide)
end

local function enableFlight(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Clean old ones just in case
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.Parent = root

    task.spawn(function()
        while flightEnabled and character and character.Parent do
            local cam = workspace.CurrentCamera
            local move = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                move = move + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                move = move - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                move = move - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                move = move + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                move = move + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                move = move - Vector3.new(0, 1, 0)
            end

            if bodyVelocity then
                bodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
            end
            if bodyGyro then
                bodyGyro.CFrame = cam.CFrame
            end

            task.wait()
        end
    end)
end

local function disableFlight()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

-- ====================== CHARACTER HANDLER ======================

local function onCharacterAdded(character)
    -- Wait for Humanoid
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    -- Apply persistent values
    applyWalkSpeed(character)
    applyJumpHeight(character)

    -- Re-enable features if they were on
    if noclipEnabled then
        task.wait(0.1) -- small delay so parts exist
        enableNoclip(character)
    end

    if flightEnabled then
        task.wait(0.1)
        enableFlight(character)
    end
end

-- Connect to current + future characters
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- ====================== UI ======================

lpSection:Toggle({
    Text = "Noclip",
    Default = false,
    Callback = function(v)
        noclipEnabled = v
        local character = LocalPlayer.Character
        if not character then return end

        if v then
            enableNoclip(character)
        else
            disableNoclip()
        end
    end
})

lpSection:Toggle({
    Text = "Flight",
    Default = false,
    Callback = function(v)
        flightEnabled = v
        local character = LocalPlayer.Character
        if not character then return end

        if v then
            enableFlight(character)
        else
            disableFlight()
        end
    end
})

lpSection:Slider({
    Text = "Flight Speed",
    Default = 50,
    Minimum = 0,
    Maximum = 1000,
    Flag = "FlightSpeed",
    Callback = function(v)
        flySpeed = v
    end
})

lpSection:Label({
    Text = "Walkspeed",
    Color = Color3.fromRGB(255, 255, 255),
    Tooltip = "Change Your Walk Speed"
})

lpSection:Input({
    Placeholder = "default is 16",
    Flag = "WalkSpeedInput",
    Callback = function(v)
        if v == "" then
            currentWalkSpeed = 16
        else
            currentWalkSpeed = tonumber(v) or 16
        end

        local character = LocalPlayer.Character
        if character then
            applyWalkSpeed(character)
        end
    end
})

lpSection:Label({
    Text = "Jump Power",
    Color = Color3.fromRGB(255, 255, 255),
    Tooltip = "Change Your Jump Power"
})

lpSection:Input({
    Placeholder = "default is 7.2",
    Flag = "JumpPowerInput",
    Callback = function(v)
        if v == "" then
            currentJumpHeight = 7.2
        else
            currentJumpHeight = tonumber(v) or 7.2
        end

        local character = LocalPlayer.Character
        if character then
            applyJumpHeight(character)
        end
    end
})

lpSection:Button({
    Text = "Modify Rocket Launcher",
    Tooltip = "Mods any rocket launcher in the game",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local backpack = player:WaitForChild("Backpack")

        local allowedNames = {
            ["RPG"] = true,
            ["Stinger"] = true
        }

        local toolsToMod = {}

        -- Check equipped tools
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and allowedNames[item.Name] then
                table.insert(toolsToMod, item)
            end
        end

        -- Check backpack tools
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and allowedNames[item.Name] then
                table.insert(toolsToMod, item)
            end
        end

        if #toolsToMod > 0 then
            for _, tool in ipairs(toolsToMod) do
                local tname = tool.Name
                local current = require(game:GetService("ReplicatedStorage").Configurations.ACS_Guns[tname].Settings)
                current.Bullets = 50
                current.FireRate = 99999
                current.Ammo = 99999999999
                current.RecoilPunch = 0
                current.FireModes.Auto = true
                current.FireModes.Burst = false
                current.FireModes.Semi = false
            end
            Notify("Weapon(s) have been modded", 5)
        else
            warn("No valid tools found")
            Notify("No RPG / Stinger Rocket Launcher found", 5)
        end
    end
})

local baseSection = Tab1:Section({
    Text = "Base",
    Side = "Right"
})

local collector = workspace.Tycoon.Tycoons[plrteam].Essentials.CollectorParts.Collector
local autoCollect = false

-- Remove unnecessary stuff
if collector:FindFirstChild("UI") then
    collector.UI:Destroy()
end
if collector:FindFirstChild("Effect") then
    collector.Effect:Destroy()
end

-- Loop
task.spawn(function()
    while true do
        if autoCollect then
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local randomRot = CFrame.Angles(
                    math.rad(math.random(0, 360)),
                    math.rad(math.random(0, 360)),
                    math.rad(math.random(0, 360))
                )
                collector.CFrame = CFrame.new(hrp.Position) * randomRot
            end
        end
        task.wait(0.5)
    end
end)

-- Toggle
baseSection:Toggle({
    Text = "Auto Collect",
    Default = false,
    Callback = function(v)
        autoCollect = v
    end
})

baseSection:Button({
    Text = "Teleport to Base",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(workspace.Tycoon.Tycoons[plrteam].Essentials["Spawn Visualizer"].Position + Vector3.new(0, 5, 0))
        end
    end
})

baseSection:Button({
    Text = "Get Loadout",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if not hrp then return end

        local tycoon = workspace.Tycoon.Tycoons:FindFirstChild(plrteam)
        local neon = tycoon
            and tycoon:FindFirstChild("PurchasedObjects")
            and tycoon.PurchasedObjects:FindFirstChild("Loadout")
            and tycoon.PurchasedObjects.Loadout:FindFirstChild("Neon")

        if not neon then return end

        local prepos = hrp.CFrame

        hrp.CFrame = neon.CFrame
        task.wait(0.5)

        local args = {1}

        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("LoadoutService")
            :WaitForChild("RF")
            :WaitForChild("EquipLoadout")
            :InvokeServer(unpack(args))
            
        task.wait(0.5)
        hrp.CFrame = prepos
    end
})

local rsSection = Tab1:Section({
    Text = "Drone Spawner",
    Side = "Left"
})

rsSection:Button({
    Text = "Recon Drone",
    Tooltip = "Spawn a Recon Drone",
    Callback = function()
        local args = {
        	"Recon Drone"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
    end
})

rsSection:Button({
    Text = "Machine Gun Drone",
    Tooltip = "Spawn a Machine Gun Drone",
    Callback = function()
        local args = {
        	"Machine Gun Drone"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
    end
})

rsSection:Button({
    Text = "Grenade Drone",
    Tooltip = "Spawn a Grenade Drone",
    Callback = function()
        local args = {
        	"Grenade Drone"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
    end
})

rsSection:Button({
    Text = "Rocket Drone",
    Tooltip = "Spawn a Rocket Drone",
    Callback = function()
        local args = {
        	"Rocket Drone"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
    end
})

rsSection:Button({
    Text = "Destroyer Drone",
    Tooltip = "Spawn a Destroyer Drone",
    Callback = function()
        local args = {
        	"Destroyer Drone"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
    end
})


--

-- Players

local hbSection = Tab2:Section({
    Text = "Hitbox Expander",
    Side = "Left"
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Settings
local hitboxEnabled = false
local hitboxSize = 30
local hitboxTransparency = 0
local hitboxPart = "HumanoidRootPart"
local teamCheck = true
local hitboxColor = Color3.fromRGB(255, 0, 0)
local flickerEnabled = false
local flickerState = false -- used to switch between big/normal

-- Main loop
task.spawn(function()
    while true do
        if hitboxEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        local character = player.Character
                        if not character then return end

                        local part = character:FindFirstChild(hitboxPart)
                        if not part or not part:IsA("BasePart") then return end

                        -- Team check
                        if teamCheck and player.Team == LocalPlayer.Team then
                            part.Size = Vector3.new(2, 2, 1)
                            part.Transparency = 1
                            part.CanCollide = true
                        else
                            if flickerEnabled then
                                -- Flicker between big and normal
                                if flickerState then
                                    part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                                else
                                    part.Size = Vector3.new(2, 2, 1)
                                end
                            else
                                -- Normal expanded
                                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            end

                            part.Transparency = hitboxTransparency
                            part.CanCollide = false
                            part.Color = hitboxColor
                            part.Material = Enum.Material.ForceField
                        end
                    end)
                end
            end

            -- Toggle the flicker state every loop
            if flickerEnabled then
                flickerState = not flickerState
            end
        else
            -- Reset when disabled
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        local character = player.Character
                        if not character then return end
                        local part = character:FindFirstChild(hitboxPart)
                        if part then
                            part.Size = Vector3.new(2, 2, 1)
                            part.Transparency = 1
                            part.CanCollide = true
                        end
                    end)
                end
            end
        end

        -- Faster wait when flickering so it looks rapid
        if flickerEnabled and hitboxEnabled then
            task.wait(0.4)
        else
            task.wait(0.5)
        end
    end
end)

-- ====================== UI ======================

hbSection:Toggle({
    Text = "Enable Hitbox Expander",
    Default = false,
    Callback = function(v)
        hitboxEnabled = v
    end
})

hbSection:Toggle({
    Text = "Flicker Bypass",
    Tooltip = "Meant to fix vehicles not moving while hitbox expander is active",
    Default = false,
    Callback = function(v)
        flickerEnabled = v
    end
})

hbSection:Slider({
    Text = "Size",
    Default = 30,
    Minimum = 3,
    Maximum = 300,
    Callback = function(v)
        hitboxSize = v
    end
})

hbSection:Slider({
    Text = "Transparency",
    Default = 0,
    Minimum = 0,
    Maximum = 1,
    Callback = function(v)
        hitboxTransparency = v
    end
})

hbSection:RadioButton({
    Text = "Target Part",
    Options = {"HumanoidRootPart", "Head"},
    Callback = function(v)
        hitboxPart = v
    end
})

hbSection:Label({
    Text = "Warning",
    Tooltip = "Using this feature can bug people in vehicles",
    Color = Color3.fromRGB(255, 100, 100)
})
--

-- Visuals

_G.chamsEnabled = true -- set to false if it crashes

local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/ESP-Library/main/nomercy.rip/source.lua"))()
end)

if not success then
    warn("Failed to load ESP library:", result)
    return
end

local esp, esp_renderstep, framework = result

-- Default settings
esp.Settings.Enabled = false
esp.Settings.Box.Enabled = false
esp.Settings.Box_Outline.Enabled = false
esp.Settings.Name.Enabled = false
esp.Settings.Maximal_Distance = 500
esp.Settings.Name.Position = "Top"

-- ===== Player Connections (this was missing) =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function addPlayer(player)
    if player == LocalPlayer then return end
    esp:Player(player)
end

local function removePlayer(player)
    local obj = esp:GetObject(player)
    if obj then
        obj:Destroy()
    end
end

-- Add existing players
for _, player in ipairs(Players:GetPlayers()) do
    addPlayer(player)
end

-- Handle new / leaving players
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

-- ===== UI =====
local espSection = Tab3:Section({
    Text = "Esp",
    Side = "Left"
})

-- Master
espSection:Toggle({
    Text = "ESP Master Switch",
    Default = false,
    Callback = function(v)
        esp.Settings.Enabled = v
    end
})

-- Visuals
espSection:Toggle({
    Text = "2D Box",
    Default = false,
    Callback = function(v)
        esp.Settings.Box.Enabled = v
    end
})

espSection:Toggle({
    Text = "Box Outline",
    Default = false,
    Callback = function(v)
        esp.Settings.Box_Outline.Enabled = v
    end
})

espSection:Toggle({
    Text = "Names",
    Default = false,
    Callback = function(v)
        esp.Settings.Name.Enabled = v
    end
})

espSection:Toggle({
    Text = "Distance",
    Default = false,
    Callback = function(v)
        esp.Settings.Distance.Enabled = v
    end
})

espSection:Toggle({
    Text = "Healthbar",
    Default = false,
    Callback = function(v)
        esp.Settings.Healthbar.Enabled = v
    end
})

espSection:Toggle({
    Text = "Health Text",
    Default = false,
    Callback = function(v)
        esp.Settings.Health.Enabled = v
    end
})

espSection:Toggle({
    Text = "Held Tool",
    Default = false,
    Callback = function(v)
        esp.Settings.Tool.Enabled = v
    end
})

espSection:Toggle({
    Text = "Chams",
    Default = false,
    Callback = function(v)
        esp.Settings.Chams.Enabled = v
    end
})

-- Settings
espSection:Slider({
    Text = "Max Distance",
    Default = 500,
    Minimum = 100,
    Maximum = 5000,
    Callback = function(v)
        esp.Settings.Maximal_Distance = v
    end
})

espSection:RadioButton({
    Text = "Name Position",
    Options = {"Top", "Bottom"},
    Callback = function(v)
        esp.Settings.Name.Position = v
    end
})

espSection:RadioButton({
    Text = "Healthbar Position",
    Options = {"Left", "Right"},
    Callback = function(v)
        esp.Settings.Healthbar.Position = v
    end
})

-- ==================== CUSTOMISATION ====================
local espSection2 = Tab3:Section({
    Text = "Customisation",
    Side = "Right"
})

-- Extra Options
espSection2:Toggle({
    Text = "Team Check",
    Default = false,
    Callback = function(v)
        esp.Settings.Team_Check = v
    end
})

espSection2:Toggle({
    Text = "Bold Text",
    Default = false,
    Callback = function(v)
        esp.Settings.Bold_Text = v
    end
})

-- Box Color
espSection2:Label({ Text = "Box Color" })

local BoxR, BoxG, BoxB = 255, 255, 255

espSection2:Slider({
    Text = "R",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        BoxR = v
        esp.Settings.Box.Color = Color3.fromRGB(BoxR, BoxG, BoxB)
    end
})

espSection2:Slider({
    Text = "G",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        BoxG = v
        esp.Settings.Box.Color = Color3.fromRGB(BoxR, BoxG, BoxB)
    end
})

espSection2:Slider({
    Text = "B",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        BoxB = v
        esp.Settings.Box.Color = Color3.fromRGB(BoxR, BoxG, BoxB)
    end
})

-- Name Color
espSection2:Label({ Text = "Name Color" })

local NameR, NameG, NameB = 255, 255, 255

espSection2:Slider({
    Text = "R",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        NameR = v
        esp.Settings.Name.Color = Color3.fromRGB(NameR, NameG, NameB)
    end
})

espSection2:Slider({
    Text = "G",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        NameG = v
        esp.Settings.Name.Color = Color3.fromRGB(NameR, NameG, NameB)
    end
})

espSection2:Slider({
    Text = "B",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        NameB = v
        esp.Settings.Name.Color = Color3.fromRGB(NameR, NameG, NameB)
    end
})

-- Chams Color
espSection2:Label({ Text = "Chams Color" })

local ChamsR, ChamsG, ChamsB = 255, 255, 255

espSection2:Slider({
    Text = "R",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        ChamsR = v
        esp.Settings.Chams.Color = Color3.fromRGB(ChamsR, ChamsG, ChamsB)
    end
})

espSection2:Slider({
    Text = "G",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        ChamsG = v
        esp.Settings.Chams.Color = Color3.fromRGB(ChamsR, ChamsG, ChamsB)
    end
})

espSection2:Slider({
    Text = "B",
    Default = 255,
    Minimum = 0,
    Maximum = 255,
    Callback = function(v)
        ChamsB = v
        esp.Settings.Chams.Color = Color3.fromRGB(ChamsR, ChamsG, ChamsB)
    end
})

--

-- Operation Helper

local apfSection = Tab4:Section({
    Text = "Auto Parts",
    Side = "Left"
})

local autoTankRunning = false

apfSection:Toggle({
    Text = "Auto Spawn Tank",
    Default = false,
    Callback = function(v)
        autoTankRunning = v

        if v then
            task.spawn(function()
                while autoTankRunning do
                    local args = {
                    	"M4 Sherman"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
                    task.wait(0.1)
                end
            end)
        end
    end
})

apfSection:Toggle({
    Text = "Auto Spawn Vehicle",
    Default = false,
    Callback = function(v)
        autoTankRunning = v

        if v then
            task.spawn(function()
                while autoTankRunning do
                    local args = {
                    	"Gurkha MPV"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
                    task.wait(0.1)
                end
            end)
        end
    end
})

apfSection:Toggle({
    Text = "Auto Spawn Plane",
    Default = false,
    Callback = function(v)
        autoTankRunning = v

        if v then
            task.spawn(function()
                while autoTankRunning do
                    local args = {
                    	"P-51 Mustang"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
                    task.wait(0.1)
                end
            end)
        end
    end
})

apfSection:Toggle({
    Text = "Auto Spawn Helicopter",
    Default = false,
    Callback = function(v)
        autoTankRunning = v

        if v then
            task.spawn(function()
                while autoTankRunning do
                    local args = {
                    	"UH-72B Lakota"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
                    task.wait(0.1)
                end
            end)
        end
    end
})

apfSection:Toggle({
    Text = "Auto Spawn Boat",
    Default = false,
    Callback = function(v)
        autoTankRunning = v

        if v then
            task.spawn(function()
                while autoTankRunning do
                    local args = {
                    	"Fairmile"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MountService"):WaitForChild("RE"):WaitForChild("SpawnMount"):FireServer(unpack(args))
                    task.wait(0.1)
                end
            end)
        end
    end
})

apfSection:Label({
    Text = "Required Vehicles",
    Color = Color3.fromRGB(255, 100, 100),
    Tooltip = "P-51 Mustang (plane) - m4 sherman (tank) - Gurkha MPV (vehicle) - UH-72B Lakota (helicopter) - Fairmile (boat)"
})


--


ESP:Init()
a:Set(true)
