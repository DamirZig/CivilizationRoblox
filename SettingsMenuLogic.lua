-- �������� ������ �� ����������� ������� � �������
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui")

-- �������� SettingsUI � ��� ������ ��������
local settingsUI = playerGUI:WaitForChild("SettingsUI")
local backToGameSettings = settingsUI:WaitForChild("BackToGameSettings")

-- �������� PlayerHUD � ������ SettingsButton
local playerHUD = playerGUI:WaitForChild("PlayerHUD")
local settingsButton = playerHUD:WaitForChild("SettingsButton")

-- �������� �������� ��������
local mouseSensSliderBG = settingsUI:WaitForChild("MouseSensSliderBG")
local mouseSensSlider = mouseSensSliderBG:WaitForChild("MouseSensSlider") -- ��� ����� ���� TextButton ��� Frame
local mouseSensNumber = mouseSensSliderBG:WaitForChild("MouseSensNumber")

-- ��������� ����������������
local minSensitivity = 1
local maxSensitivity = 10
local defaultSensitivity = 2
local currentSensitivity = defaultSensitivity

-- ������� ��� ���������� ������� �������� �� ������ ������� ����������������
local function updateSliderPosition()
	local sliderWidth = mouseSensSliderBG.AbsoluteSize.X
	local sliderPosition = ((currentSensitivity - minSensitivity) / (maxSensitivity - minSensitivity)) * sliderWidth
	mouseSensSlider.Position = UDim2.new(0, sliderPosition, 0.5, 0)
	mouseSensNumber.Text = string.format("%.2f", currentSensitivity) -- ��������� �� ���� ������ ����� �������
end

-- ������� ��� ���������� ����������������
local function updateSensitivity(newSensitivity)
	currentSensitivity = math.clamp(newSensitivity, minSensitivity, maxSensitivity)
	updateSliderPosition()

	-- ����������� ���������������� ������ � �������� �������� (� ��� ���� ������)
	UserInputService.MouseDeltaSensitivity = currentSensitivity / 2
end

-- ������������� ��������
updateSensitivity(defaultSensitivity)

-- ������ �������������� ��������
local isDragging = false

-- ������� ��� ��������� ������ ��������������
mouseSensSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
	end
end)

-- ������� ��� ��������� ����������� ����
UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		-- �������� ������� ���� ������������ MouseSensSliderBG
		local mousePosition = input.Position.X - mouseSensSliderBG.AbsolutePosition.X
		local sliderWidth = mouseSensSliderBG.AbsoluteSize.X

		-- ������������ ������� �������� � �������� MouseSensSliderBG
		mousePosition = math.clamp(mousePosition, 0, sliderWidth)

		-- ��������� ������� ��������
		mouseSensSlider.Position = UDim2.new(0, mousePosition, 0.5, 0)

		-- ��������� ����� ����������������
		local newSensitivity = (mousePosition / sliderWidth) * (maxSensitivity - minSensitivity) + minSensitivity
		updateSensitivity(newSensitivity)
	end
end)

-- ������� ��� ��������� ��������� ��������������
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
	end
end)

-- �������� SettingsUI �� ���������
settingsUI.Enabled = false

-- ������� ��� ������ SettingsUI
local function showSettingsUI()
	settingsUI.Enabled = true
end

-- ������� ��� ������� SettingsUI
local function hideSettingsUI()
	settingsUI.Enabled = false
end

-- ���������� ������� � �������
settingsButton.MouseButton1Click:Connect(showSettingsUI)
backToGameSettings.MouseButton1Click:Connect(hideSettingsUI)