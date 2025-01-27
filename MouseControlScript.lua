-- Получаем ссылки на необходимые сервисы и объекты
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Функция для показа/скрытия курсора и заморозки управления камерой
local function toggleMouseAndCamera()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
		-- Показываем курсор и разблокируем управление мышью
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	else
		-- Скрываем курсор и блокируем управление мышью
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end

-- Постоянно проверяем состояние клавиши Ctrl
RunService.RenderStepped:Connect(toggleMouseAndCamera)