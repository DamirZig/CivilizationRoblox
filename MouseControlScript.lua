-- �������� ������ �� ����������� ������� � �������
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ������� ��� ������/������� ������� � ��������� ���������� �������
local function toggleMouseAndCamera()
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
		-- ���������� ������ � ������������ ���������� �����
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	else
		-- �������� ������ � ��������� ���������� �����
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end

-- ��������� ��������� ��������� ������� Ctrl
RunService.RenderStepped:Connect(toggleMouseAndCamera)