-- Получаем ссылки на необходимые сервисы и объекты
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGUI = player:WaitForChild("PlayerGui")

-- Получаем SettingsUI и его кнопку закрытия
local settingsUI = playerGUI:WaitForChild("SettingsUI")
local backToGameSettings = settingsUI:WaitForChild("BackToGameSettings")

-- Получаем PlayerHUD и кнопку SettingsButton
local playerHUD = playerGUI:WaitForChild("PlayerHUD")
local settingsButton = playerHUD:WaitForChild("SettingsButton")

-- Получаем элементы слайдера
local mouseSensSliderBG = settingsUI:WaitForChild("MouseSensSliderBG")
local mouseSensSlider = mouseSensSliderBG:WaitForChild("MouseSensSlider") -- Это может быть TextButton или Frame
local mouseSensNumber = mouseSensSliderBG:WaitForChild("MouseSensNumber")

-- Настройки чувствительности
local minSensitivity = 1
local maxSensitivity = 10
local defaultSensitivity = 2
local currentSensitivity = defaultSensitivity

-- Функция для обновления позиции слайдера на основе текущей чувствительности
local function updateSliderPosition()
	local sliderWidth = mouseSensSliderBG.AbsoluteSize.X
	local sliderPosition = ((currentSensitivity - minSensitivity) / (maxSensitivity - minSensitivity)) * sliderWidth
	mouseSensSlider.Position = UDim2.new(0, sliderPosition, 0.5, 0)
	mouseSensNumber.Text = string.format("%.2f", currentSensitivity) -- Округляем до двух знаков после запятой
end

-- Функция для обновления чувствительности
local function updateSensitivity(newSensitivity)
	currentSensitivity = math.clamp(newSensitivity, minSensitivity, maxSensitivity)
	updateSliderPosition()

	-- Привязываем чувствительность камеры к значению слайдера (в два раза меньше)
	UserInputService.MouseDeltaSensitivity = currentSensitivity / 2
end

-- Инициализация слайдера
updateSensitivity(defaultSensitivity)

-- Логика перетаскивания слайдера
local isDragging = false

-- Функция для обработки начала перетаскивания
mouseSensSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
	end
end)

-- Функция для обработки перемещения мыши
UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		-- Получаем позицию мыши относительно MouseSensSliderBG
		local mousePosition = input.Position.X - mouseSensSliderBG.AbsolutePosition.X
		local sliderWidth = mouseSensSliderBG.AbsoluteSize.X

		-- Ограничиваем позицию слайдера в пределах MouseSensSliderBG
		mousePosition = math.clamp(mousePosition, 0, sliderWidth)

		-- Обновляем позицию слайдера
		mouseSensSlider.Position = UDim2.new(0, mousePosition, 0.5, 0)

		-- Вычисляем новую чувствительность
		local newSensitivity = (mousePosition / sliderWidth) * (maxSensitivity - minSensitivity) + minSensitivity
		updateSensitivity(newSensitivity)
	end
end)

-- Функция для обработки окончания перетаскивания
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
	end
end)

-- Скрываем SettingsUI по умолчанию
settingsUI.Enabled = false

-- Функция для показа SettingsUI
local function showSettingsUI()
	settingsUI.Enabled = true
end

-- Функция для скрытия SettingsUI
local function hideSettingsUI()
	settingsUI.Enabled = false
end

-- Подключаем функции к кнопкам
settingsButton.MouseButton1Click:Connect(showSettingsUI)
backToGameSettings.MouseButton1Click:Connect(hideSettingsUI)