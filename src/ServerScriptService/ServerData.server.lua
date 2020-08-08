local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local XPDataStore = DataStoreService:GetDataStore("XP")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")
local GoalXPDataStore = DataStoreService:GetDataStore("GoalXP")
local LevelDataStore = DataStoreService:GetDataStore("Level")
local LevelUp = ReplicatedStorage.RemoteEvents:WaitForChild("LevelUp")
local EraseData = ReplicatedStorage.RemoteEvents:WaitForChild("EraseData")
local GivePet = ReplicatedStorage.RemoteEvents:WaitForChild("GivePet")
local PetConfig = require(script.Parent.PetConfig)
Database = require(ReplicatedStorage.Modules.Data)
game.Players.PlayerAdded:Connect(function(Player)
	local DataTable = {}
	local LevelGui = Player:WaitForChild("PlayerGui"):WaitForChild("MainGui").Level
	--[[ Main folder that contains all of the player data ]]
	local Data = Instance.new("Folder", Player)
	Data.Name = "Data"

	--[[ Current egg the player is on ]]
	local CurrentEgg = Instance.new("StringValue", Data)
	CurrentEgg.Name = "CurrentEgg"
	CurrentEgg.Value = "StarterEgg"

	--[[ Current pet ]]
	local CurrentEgg = Instance.new("StringValue", Data)
	CurrentEgg.Name = "CurrentPet"
	CurrentEgg.Value = ""

	--[[ Will become a variable that stores all of the player pets in a list. Format: Pet1,Pet2,Pet3,Pet4 ]]
	local Pets = Instance.new("StringValue", Data)
	Pets.Name = "Pets"
	Pets.Value = ""

	--[[ Determines if the player is Playing in "clicker" mode ]]
	local Playing = Instance.new("BoolValue", Data)
	Playing.Name = "Playing"
	Playing.Value = false

	--[[ Redundant variable I need to remove later ]]
	local PlayerView = Instance.new("BoolValue", Data)
	PlayerView.Name = "PlayerView"
	PlayerView.Value = false

	--[[ To be removed ]]
	local Toggle = Instance.new("BoolValue", Data)
	Toggle.Name = "Toggle"
	Toggle.Value = false


	--[[ Condensed data into single string ]]
	table.insert(DataTable,0)
	table.insert(DataTable,20)
	table.insert(DataTable,1)
	table.insert(DataTable,{})
	local PlayerData = Instance.new("StringValue", Data)
	PlayerData.Name = "PlayerData"
	PlayerData.Value = Database.Convert(DataTable)

	local success, PlayerDataStore = pcall(function()
		return PlayerDataStore:GetAsync(Player)
	end)

	if success and PlayerDataStore ~= nil then
		print(PlayerDataStore)
		if type(PlayerDataStore)=="table" then PlayerDataStore=Database.Convert(PlayerDataStore) end
		PlayerData.Value = PlayerDataStore
		LevelGui.BoosterButton.Text = "Level "..tostring(Database.Pull(PlayerDataStore)[3])
		LevelGui.XPBarBackground.TextLabel.Text = "0/"..tostring(Database.Pull(PlayerDataStore)[2])
	else
		print("Failed to load player data. Caused by new player entered or corrupted data.")
	end
end)

--[[ Save player data on remove (redundant until game release) ]]
game.Players.PlayerRemoving:Connect(function(Player)
    local PlayerData = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
	
	local success, err = pcall(function()
		XPDataStore:SetAsync(Player,PlayerData)
	end)
	if success then
		print("Player data saved.")
	else
		print(err)
	end
end)

function GivePets(Level)
	return PetConfig.DeterminePet()
end

--[[ Player level up ]]
LevelUp.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data"):WaitForChild("PlayerData")
	local LevelGui = Player:WaitForChild("PlayerGui"):WaitForChild("MainGui").Level
    local PlayerTable = Database.Pull(PlayerData.Value)
    local XP = tonumber(PlayerTable[1])
    local GoalXP = tonumber(PlayerTable[2])
	local Level = tonumber(PlayerTable[3])
	PlayerTable[1]=0
	PlayerTable[2]=(GoalXP*Level)
	PlayerTable[3]=Level+1
	PlayerData.Value = Database.Convert(PlayerTable)
	LevelGui.XPBarBackground.TextLabel.Text = "0/"..tostring(GoalXP)
	PlayerDataStore:SetAsync(Player,PlayerData.Value)
	GivePet:FireClient(Player,GivePets(Level+1))
end)

EraseData.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data"):WaitForChild("PlayerData")
    local PlayerTable = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
    local XP = tonumber(PlayerTable[1])
    local GoalXP = tonumber(PlayerTable[2])
    local Level = tonumber(PlayerTable[3])
	PlayerTable[3]=1
	PlayerTable[1]=0
	PlayerTable[2]=20
	PlayerTable[4]={}
	PlayerData.Value = Database.Convert(PlayerTable)
	PlayerDataStore:SetAsync(Player,PlayerData.Value)
end)
