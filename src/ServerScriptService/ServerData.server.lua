local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local XPDataStore = DataStoreService:GetDataStore("XP")
local GoalXPDataStore = DataStoreService:GetDataStore("GoalXP")
local LevelDataStore = DataStoreService:GetDataStore("Level")
local LevelUp = ReplicatedStorage:WaitForChild("LevelUp")
local GivePet = ReplicatedStorage:WaitForChild("GivePet")
local PetConfig = require(script.Parent.PetConfig)

game.Players.PlayerAdded:Connect(function(Player)
	local Data = Instance.new("Folder", Player)
	Data.Name = "Data"
	
	local CurrentEgg = Instance.new("StringValue", Data)
	CurrentEgg.Name = "CurrentEgg"
	CurrentEgg.Value = "StarterEgg"

	local CurrentEgg = Instance.new("StringValue", Data)
	CurrentEgg.Name = "CurrentPet"
	CurrentEgg.Value = ""

	local CurrentEgg = Instance.new("StringValue", Data)
	CurrentEgg.Name = "Pets"
	CurrentEgg.Value = ""
	print("running")
	local Playing = Instance.new("BoolValue", Data)
	Playing.Name = "Playing"
	Playing.Value = false

	local PlayerView = Instance.new("BoolValue", Data)
	PlayerView.Name = "PlayerView"
	PlayerView.Value = false

	local Toggle = Instance.new("BoolValue", Data)
	Toggle.Name = "Toggle"
	Toggle.Value = false

	local XP = Instance.new("IntValue",Data)
	XP.Name = "XP"
	local success, XPDataStore = pcall(function()
		return XPDataStore:GetAsync(Player)
	end)
	if success then
		print(XPDataStore)
	else
		print("New player detected")
		XP.Value = 0
	end

	local GoalXP = Instance.new("IntValue",Data)
	GoalXP.Name = "GoalXP"
	local success, GoalXPDataStore = pcall(function()
		return GoalXPDataStore:GetAsync(Player)
	end)
	if success then
		print(GoalXPDataStore)
		if GoalXPDataStore == "0" or GoalXPDataStore == 0 or GoalXPDataStore == nil or GoalXP.Value == 0 then
			GoalXP.Value = 20
		end
	else
		print("New player detected")
		GoalXP.Value = 20
	end

	local Level = Instance.new("IntValue",Data)
	Level.Name = "Level"
	local success, LevelDataStore = pcall(function()
		return LevelDataStore:GetAsync(Player)
	end)
	if success then
		print(LevelDataStore)
		if tostring(LevelDataStore) == "0" or LevelDataStore == nil or Level.Value == 0 then
			Level.Value = 1
		end
	else
		print("New player detected")
		Level.Value = 1
	end

end)

game.Players.PlayerRemoving:Connect(function(Player)
	local XP = Player:FindFirstChild("Data"):FindFirstChild("XP")
	local GoalXP = Player:FindFirstChild("Data"):FindFirstChild("GoalXP")
	local Level = Player:FindFirstChild("Data"):FindFirstChild("Level")
	local success, err = pcall(function()
		XPDataStore:SetAsync(Player,XP.Value)
		GoalXPDataStore:SetAsync(Player,GoalXP.Value)
		LevelDataStore:SetAsync(Player,Level.Value)
	end)
	if success then
		print("Player data loaded.")
	else
		print(err)
	end
end)

function GivePets(Level)
	return PetConfig.DeterminePet()
end

LevelUp.OnServerEvent:Connect(function(Player)
	print("level up")
	local Level = Player:FindFirstChild("Data"):FindFirstChild("Level")
	local XP = Player:FindFirstChild("Data"):FindFirstChild("XP")
	local GoalXP = Player:FindFirstChild("Data"):FindFirstChild("GoalXP")
	XPDataStore:SetAsync(Player,0)
	GoalXPDataStore:SetAsync(Player,GoalXP.Value)
	LevelDataStore:SetAsync(Player,Level.Value+1)
	GivePet:FireClient(Player,GivePets(Level.Value+1))
end)


