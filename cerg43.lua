--// Simple Tycoon GUI
--// LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- TYCOON SETUP
--==================================================

local tycoonMain = workspace:WaitForChild("TycoonMain")
local tycoons = tycoonMain:WaitForChild("Tycoons")

local plrTycoonName

repeat
	plrTycoonName = player:GetAttribute("TycoonOwned")
	task.wait(0.1)
until plrTycoonName ~= nil

print("Player Tycoon:", plrTycoonName)

local tycoon = tycoons:WaitForChild(plrTycoonName)

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 180)
Main.Position = UDim2.new(0.5, -150, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 65, 75)
Stroke.Thickness = 1
Stroke.Parent = Main

--==================================================
-- TITLE BAR
--==================================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Tycoon Automation"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

--==================================================
-- EXIT BUTTON
--==================================================

local Exit = Instance.new("TextButton")
Exit.Size = UDim2.new(0, 35, 0, 35)
Exit.Position = UDim2.new(1, -40, 0, 5)
Exit.BackgroundColor3 = Color3.fromRGB(190, 55, 55)
Exit.Text = "×"
Exit.TextColor3 = Color3.fromRGB(255, 255, 255)
Exit.TextSize = 22
Exit.Font = Enum.Font.GothamBold
Exit.BorderSizePixel = 0
Exit.Parent = TitleBar

local ExitCorner = Instance.new("UICorner")
ExitCorner.CornerRadius = UDim.new(0, 8)
ExitCorner.Parent = Exit

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 25)
Status.Position = UDim2.new(0, 15, 0, 125)
Status.BackgroundTransparency = 1
Status.Text = "Status: Idle"
Status.TextColor3 = Color3.fromRGB(150, 150, 155)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--==================================================
-- TOGGLE LABEL
--==================================================

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, -30, 0, 30)
ToggleLabel.Position = UDim2.new(0, 15, 0, 65)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Auto Buy"
ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ToggleLabel.TextSize = 16
ToggleLabel.Font = Enum.Font.Gotham
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = Main

--==================================================
-- TOGGLE BUTTON
--==================================================

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 75, 0, 35)
Toggle.Position = UDim2.new(1, -90, 0, 62)
Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 14
Toggle.Font = Enum.Font.GothamBold
Toggle.BorderSizePixel = 0
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

--==================================================
-- STATE
--==================================================

local Enabled = false

--==================================================
-- GET CURRENT TYCOON
--==================================================

local function getTycoon()

	plrTycoonName = player:GetAttribute("TycoonOwned")

	if not plrTycoonName then
		warn("TycoonOwned attribute not found")
		return nil
	end

	local currentTycoon = tycoons:WaitForChild(plrTycoonName)

	return currentTycoon

end

--==================================================
-- COLLECT MONEY
--==================================================

local function collectMoney()

	if not Enabled then
		return
	end

	Status.Text = "Status: Collecting money..."

	local currentTycoon = getTycoon()

	if not currentTycoon then
		return
	end

	local essentials = currentTycoon:WaitForChild("Essentials")
	local currencyCollector = essentials:WaitForChild("CurrencyCollector")
	local giver = currencyCollector:WaitForChild("Giver")

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	print("Collecting money")

	firetouchinterest(giver, root, 0)

	task.wait(0.1)

	firetouchinterest(giver, root, 1)

	task.wait(0.2)

end

--==================================================
-- REMOVE UNWANTED BUTTONS
--==================================================

local function removeTycoonButtons()

	if not Enabled then
		return
	end

	Status.Text = "Status: Removing unwanted pads..."

	local currentTycoon = getTycoon()

	if not currentTycoon then
		return
	end

	local buttons = currentTycoon:WaitForChild("Buttons")

	local buttonsToRemove = {
		"Buy 2x Cash",
		"Buy 3x Cash",
		"Buy Mercenary Pack",
		"Buy VIPDropper1",
		"Buy VIPUpgrader1",
		"Buy VIPDropper2",
		"Buy VIPUpgrader2"
	}

	for _, buttonName in ipairs(buttonsToRemove) do

		if not Enabled then
			return
		end

		local button = buttons:FindFirstChild(buttonName)

		if button then

			print("Removing:", buttonName)

			button:Destroy()

		end

	end

	task.wait(0.2)

end

--==================================================
-- BUY ALL BUTTONS
--==================================================

local function buyAllButtons()

	if not Enabled then
		return
	end

	Status.Text = "Status: Buying buttons..."

	local currentTycoon = getTycoon()

	if not currentTycoon then
		return
	end

	local buttons = currentTycoon:WaitForChild("Buttons")

	local purchased = {}

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	local noNewButtons = 0

	while Enabled and noNewButtons < 3 do

		local foundNewButton = false

		-- Make sure Buttons still exists
		buttons = currentTycoon:WaitForChild("Buttons")

		for _, object in ipairs(buttons:GetDescendants()) do

			if not Enabled then
				return
			end

			if object:IsA("TouchTransmitter") then

				local touchPart = object.Parent

				if touchPart
					and touchPart:IsA("BasePart")
					and not purchased[touchPart] then

					purchased[touchPart] = true
					foundNewButton = true

					print("Buying:", touchPart:GetFullName())

					-- Refresh character/root
					character = player.Character or player.CharacterAdded:Wait()
					root = character:WaitForChild("HumanoidRootPart")

					firetouchinterest(
						touchPart,
						root,
						0
					)

					task.wait(0.1)

					firetouchinterest(
						touchPart,
						root,
						1
					)

					task.wait(0.3)

				end

			end

		end

		if foundNewButton then

			noNewButtons = 0

		else

			noNewButtons += 1

			print(
				"No new buttons found:",
				noNewButtons,
				"/ 3"
			)

			task.wait(0.5)

		end

	end

	print("Finished buying buttons")

end

--==================================================
-- MAIN AUTOMATION LOOP
--==================================================

local function startAutomation()

	task.spawn(function()

		while Enabled do

			print("==============================")
			print("STARTING NEW CYCLE")
			print("==============================")


			--==========================================
			-- 1. COLLECT MONEY
			--==========================================

			collectMoney()

			if not Enabled then
				break
			end

			task.wait(0.5)


			--==========================================
			-- 2. REMOVE UNWANTED PADS
			--==========================================

			removeTycoonButtons()

			if not Enabled then
				break
			end

			task.wait(0.5)


			--==========================================
			-- 3. BUY ALL AVAILABLE BUTTONS
			--==========================================

			buyAllButtons()

			if not Enabled then
				break
			end


			--==========================================
			-- 4. FINISH CYCLE
			--==========================================

			Status.Text = "Status: Cycle complete"

			print("==============================")
			print("CYCLE COMPLETE")
			print("==============================")

			task.wait(1)

		end

		Status.Text = "Status: Idle"

	end)

end

--==================================================
-- TOGGLE
--==================================================

Toggle.MouseButton1Click:Connect(function()

	Enabled = not Enabled

	if Enabled then

		Toggle.Text = "ON"

		Toggle.BackgroundColor3 =
			Color3.fromRGB(55, 175, 90)

		Status.Text = "Status: Starting..."

		print("Automation enabled")

		startAutomation()

	else

		Toggle.Text = "OFF"

		Toggle.BackgroundColor3 =
			Color3.fromRGB(65, 65, 70)

		Status.Text = "Status: Stopping..."

		print("Automation disabled")

		task.wait(0.1)

		Status.Text = "Status: Idle"

	end

end)

--==================================================
-- EXIT
--==================================================

Exit.MouseButton1Click:Connect(function()

	Enabled = false

	print("GUI closed")

	ScreenGui:Destroy()

end)

--==================================================
-- DRAGGING
--==================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(input)

	local delta = input.Position - dragStart

	Main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)

end

TitleBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true

		dragStart = input.Position

		startPosition = Main.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then

				dragging = false

			end

		end)

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		updateDrag(input)

	end

end)
