-- �������� ������ �� ����������� ������� � �������
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- �������� ������ �� ������ � ��� ������
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- �������� ��������� ������ � ��� Humanoid
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ����������� �������� ������
local normalSpeed = humanoid.WalkSpeed

-- ������������� ������ � ����� "�� ������� ����"
player.CameraMode = Enum.CameraMode.LockFirstPerson

-- ��������� ��� ������
player.CameraMaxZoomDistance = 0
player.CameraMinZoomDistance = 0

-- �������� ������ ���� �� ���������
UserInputService.MouseIconEnabled = false
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

-- �������� ����������� �������� ���������� Roblox
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

-- �������� ������ ��� ����������� ��������, ������ � �������
local playerGUI = player:WaitForChild("PlayerGui")
local playerHUD = playerGUI:WaitForChild("PlayerHUD")
local playerHPText = playerHUD:WaitForChild("PlayerHPText")
local playerHungerText = playerHUD:WaitForChild("PlayerHungerText")
local playerStaminaText = playerHUD:WaitForChild("PlayerStaminaText")

-- ��������� ������ � �������
local maxHunger = 100
local currentHunger = maxHunger
local maxStamina = 100
local currentStamina = maxStamina
local isRunning = false
local canRun = true
local isJumping = false
local jumpCooldown = false
local lastJumpTime = 0 -- ������ ���������� ������
local staminaDepleted = false -- ����, �����������, ��� ������� �������� ����

-- ������� ���������� ����������
local function updateHealth()
	playerHPText.Text = "Health: " .. math.floor(humanoid.Health)
end

local function updateHunger()
	playerHungerText.Text = "Hunger: " .. math.floor(currentHunger)
end

local function updateStamina()
	playerStaminaText.Text = "Stamina: " .. math.floor(currentStamina)
	playerStaminaText.TextColor3 = currentStamina < 20 and Color3.new(1,0,0) or Color3.new(0,0,0)
end

-- ����������� �������
humanoid.HealthChanged:Connect(updateHealth)
updateHealth()
updateHunger()
updateStamina()

-- ������� ������
coroutine.wrap(function()
	while true do
		wait(15)
		currentHunger = math.clamp(currentHunger - 1, 0, maxHunger)
		updateHunger()
	end
end)()

-- �������������� ��������
coroutine.wrap(function()
	while true do
		wait(3)
		if humanoid.Health < 100 and currentHunger >= 90 then
			humanoid.Health += 0.2
		end
	end
end)()

-- ��������� ����
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift and canRun and currentStamina > 0 then
		isRunning = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isRunning = false
		humanoid.WalkSpeed = normalSpeed
	end
end)

-- ���������� ������
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.F then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end)

-- ���������� ������� �������
local JUMP_COOLDOWN = 0.5 -- ����������� �������
local MIN_JUMP_STAMINA = 20

UserInputService.JumpRequest:Connect(function()
	if jumpCooldown or currentStamina < MIN_JUMP_STAMINA then return end
	if not humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping) then return end

	local state = humanoid:GetState()
	local groundStates = {
		Enum.HumanoidStateType.Running,
		Enum.HumanoidStateType.RunningNoPhysics,
		Enum.HumanoidStateType.Landed
	}

	if table.find(groundStates, state) then
		-- �������� �������� ����� �������
		if (os.clock() - lastJumpTime) > JUMP_COOLDOWN then
			isJumping = true
			currentStamina = math.clamp(currentStamina - 10, 0, maxStamina)
			updateStamina()
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

			-- ��������� ��������
			jumpCooldown = true
			lastJumpTime = os.clock()
			task.delay(JUMP_COOLDOWN, function()
				jumpCooldown = false
			end)
		end
	end
end)

-- ������� �������� �����������
coroutine.wrap(function()
	while true do
		if isJumping and humanoid.FloorMaterial ~= Enum.Material.Air then
			isJumping = false
		end
		task.wait(0.05)
	end
end)()

-- ���������� ���������� �������
humanoid.StateChanged:Connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		if currentStamina < MIN_JUMP_STAMINA then
			humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
	end
end)

-- ��������� ������
RunService.RenderStepped:Connect(function()
	if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end)

-- ������� �������
coroutine.wrap(function()
	while true do
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, currentStamina >= MIN_JUMP_STAMINA)

		if isRunning then
			if currentStamina > 0 then
				currentStamina = math.clamp(currentStamina - 0.6, 0, maxStamina)
				humanoid.WalkSpeed = currentStamina < 20 and (normalSpeed * 1.5) or (normalSpeed * 2)
			else
				isRunning = false
				canRun = false
				staminaDepleted =	 true -- ������� �������� ����
				humanoid.WalkSpeed = normalSpeed
			end
		else
			local recoveryRate = currentStamina < 20 and 0.075 or 0.15
			currentStamina = math.clamp(currentStamina + recoveryRate, 0, maxStamina)

			-- ���� ������� �������������� �� 20 ��� ������, ������� ���������� ����
			if staminaDepleted and currentStamina >= 20 then
				canRun = true
				staminaDepleted = false
			end
		end

		updateStamina()
		task.wait(0.1)
	end
end)()