-- �������
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- �������� ����������� �������� (Baseplate � SpawnLocations)
if Workspace:FindFirstChild("Baseplate") then
	Workspace.Baseplate:Destroy()
end

for _, spawn in ipairs(Workspace:GetChildren()) do
	if spawn:IsA("SpawnLocation") then
		spawn:Destroy()
	end
end

-- ������������
local WORLD_SIZE = 64
local MAX_HEIGHT = 32
local BLOCK_SIZE = 4
local CHUNK_SIZE = 16
local RENDER_DISTANCE = 3

-- ��������� ���������� ���� ��� ��������� ����
local seed = math.random(1, 1000000)
math.randomseed(seed)
print("������������ ��� ���������:", seed)

-- ������������� ������� �����
local BlockTemplate = Instance.new("Part")
BlockTemplate.Name = "BlockTemplate"
BlockTemplate.Size = Vector3.new(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
BlockTemplate.Anchored = true
BlockTemplate.Color = Color3.new(0.4, 0.8, 0.2)
BlockTemplate.Parent = ReplicatedStorage

-- ���������� ����������
local chunks = {} -- ������ ��� ��������������� �����
local currentChunks = {} -- ����������� �������� �����
local activePlayer = nil -- ����������� ��������� ������

-- ������� ��� ��������� ������ � �������������� ���� �������
local function getHeight(x, z)
	local scale = 30
	local octaves = 3
	local persistence = 0.5
	local lacunarity = 2.0

	local amplitude = 1
	local frequency = 1
	local height = 0

	for i = 1, octaves do
		local sampleX = x / scale * frequency
		local sampleZ = z / scale * frequency

		local perlinValue = math.noise(sampleX, sampleZ, seed)
		height = height + perlinValue * amplitude

		amplitude = amplitude * persistence
		frequency = frequency * lacunarity
	end

	return math.floor(math.clamp(height * 15 + 10, 5, MAX_HEIGHT))
end

-- ������� ��� �������� ����� �� �������� �����������
local function createChunk(cx, cz)
	if chunks[cx] and chunks[cx][cz] then return end

	local chunk = Instance.new("Model")
	chunk.Name = string.format("Chunk_%d_%d", cx, cz)

	local startX = cx * CHUNK_SIZE
	local startZ = cz * CHUNK_SIZE

	for x = startX, startX + CHUNK_SIZE - 1 do
		for z = startZ, startZ + CHUNK_SIZE - 1 do
			local height = getHeight(x, z)

			for y = 0, height do
				local block = BlockTemplate:Clone()
				block.Position = Vector3.new(
					x * BLOCK_SIZE + BLOCK_SIZE / 2,
					y * BLOCK_SIZE + BLOCK_SIZE / 2,
					z * BLOCK_SIZE + BLOCK_SIZE / 2
				)
				block.Parent = chunk
			end
		end
	end

	if not chunks[cx] then chunks[cx] = {} end
	chunks[cx][cz] = chunk
	chunk.Parent = Workspace
end

-- ��������� ���������� ����� � ������ ����
local function generateInitialChunk()
	local centerCX = math.floor((WORLD_SIZE / 2) / CHUNK_SIZE)
	local centerCZ = math.floor((WORLD_SIZE / 2) / CHUNK_SIZE)
	createChunk(centerCX, centerCZ)
end

-- �������� ��������� ��������� � ������������ ��� � ����� �����
local function waitForCharacter(player)
	if not player then return end

	local function handleCharacter(char)
		if char then
			local rootPart = char:WaitForChild("HumanoidRootPart")

			-- ������������ � ����� �����
			local spawnX = (WORLD_SIZE / 2) * BLOCK_SIZE + BLOCK_SIZE / 2
			local spawnZ = (WORLD_SIZE / 2) * BLOCK_SIZE + BLOCK_SIZE / 2
			local spawnY = (getHeight(WORLD_SIZE / 2, WORLD_SIZE / 2) + 1) * BLOCK_SIZE
			rootPart.CFrame = CFrame.new(spawnX, spawnY, spawnZ)

			return true
		end
		return false
	end

	if player.Character then
		handleCharacter(player.Character)
	end

	player.CharacterAdded:Connect(handleCharacter)
end

-- �������� ����� �� �������� �����������
local function removeChunk(cx, cz)
	if chunks[cx] and chunks[cx][cz] then
		chunks[cx][cz]:Destroy()
		chunks[cx][cz] = nil
	end
end

-- ���������� ������ � ����������� �� ������� ������
local function updateChunks()
	if not activePlayer or not activePlayer.Character then return end

	local rootPart = activePlayer.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local pos = rootPart.Position
	local currentCX = math.floor(pos.X / (CHUNK_SIZE * BLOCK_SIZE))
	local currentCZ = math.floor(pos.Z / (CHUNK_SIZE * BLOCK_SIZE))

	local newChunks = {}

	-- �������� ������ � �������� ��������� ����������
	for dx = -RENDER_DISTANCE, RENDER_DISTANCE do
		for dz = -RENDER_DISTANCE, RENDER_DISTANCE do
			local cx = currentCX + dx
			local cz = currentCZ + dz

			if cx >= 0 and cx < (WORLD_SIZE / CHUNK_SIZE)
				and cz >= 0 and cz < (WORLD_SIZE / CHUNK_SIZE) then
				newChunks[cx] = newChunks[cx] or {}
				newChunks[cx][cz] = true

				if not currentChunks[cx] or not currentChunks[cx][cz] then
					createChunk(cx, cz)
				end
			end
		end
	end

	-- �������� ������ �� ��������� ��������� ����������
	for cx, czList in pairs(currentChunks) do
		for cz, _ in pairs(czList) do
			if not newChunks[cx] or not newChunks[cx][cz] then
				removeChunk(cx, cz)
			end
		end
	end

	currentChunks = newChunks
end

-- ������������� ������ � ��������� ��������� ���������
local function initializePlayer(player)
	activePlayer = player
	waitForCharacter(player)

	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Humanoid").Died:Connect(function()
			waitForCharacter(player)
		end)
	end)
end

-- �������� �������������
generateInitialChunk()
Players.PlayerAdded:Connect(initializePlayer)

-- ������� ���� ��� �������������� ���������� ������
while true do
	updateChunks()
	task.wait(0.1)
end