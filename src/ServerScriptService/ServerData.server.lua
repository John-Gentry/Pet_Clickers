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
	CurrentEgg.Value = "Rabbit"

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
		--Called "PlayerData" under a folder called "Data"
		--Full string:
		--[691.1999999999999,100800,8,["Rabbit","Dog"],[[10,18,200],[7,19,140]],"Rabbit"]
	--[[
		1: XP value, 2: Maximum XP, 3: Level, 4: Pets obtained, 5: List in order of pet (XP, Level, MaxXP), 6: Current pet open 8: per click
	]]
	table.insert(DataTable,0)
	table.insert(DataTable,20)
	table.insert(DataTable,1)
	table.insert(DataTable,{"Rabbit"})
	table.insert(DataTable,{{1,0,20}})
	table.insert(DataTable,"Rabbit")
	table.insert(DataTable,0)
	table.insert(DataTable,1)
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
		--LevelGui.BoosterButton.Text = "Level "..tostring(Database.Pull(PlayerDataStore)[3])
		LevelGui.XPBarBackground.TextLabel.Text = "0/"..tostring(Database.Pull(PlayerDataStore)[2])
	else
		print("Failed to load player data. Caused by new player entered or corrupted data.")
	end
end)

--[[ Save player data on remove (redundant until game release) ]]
game.Players.PlayerRemoving:Connect(function(Player)
    local PlayerData = Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value
	
	local success, err = pcall(function()
		PlayerDataStore:SetAsync(Player,PlayerData)
	end)
	if success then
		print("Player data saved.")
	else
		print(err)
	end
end)

function isInTable(tableValue, toFind)
	local found = false
	for _,v in pairs(tableValue) do
		if v==toFind then
			found = true
            break;
		end
	end
	return found
end

function GivePets(Level,Player)
	local pet = PetConfig.DeterminePet()
	local PlayerData = Player:FindFirstChild("Data"):WaitForChild("PlayerData")
	local PlayerTable = Database.Pull(PlayerData.Value)
	if isInTable(PlayerTable[4],pet) == false then
		table.insert(PlayerTable[4],pet)
	end
	PlayerData.Value = Database.Convert(PlayerTable)
	return pet
end

--[[ Player level up ]]
LevelUp.OnServerEvent:Connect(function(Player,CurrentPet,Data)
	local PlayerData = Data
	local LevelGui = Player:WaitForChild("PlayerGui"):WaitForChild("MainGui").Level
	local PlayerTable = Database.Pull(PlayerData)
    local XP = tonumber(PlayerTable[1])
    local GoalXP = tonumber(PlayerTable[2])
	local Level = tonumber(PlayerTable[3])
	PlayerTable[1]=0
	PlayerTable[2]=(GoalXP*Level)
	PlayerTable[3]=Level+1

 	for i,v in pairs(PlayerTable[4]) do
		if v == CurrentPet then
			if PlayerTable[5][i] == nil then
				table.insert(PlayerTable[5],{1,0,10})
			end
--[[ 			local PetLevel = PlayerTable[5][i][1]
			local PetXP = PlayerTable[5][i][2]
			local PetGoalXP = PlayerTable[5][i][3]
			PlayerTable[5][i][2] = PlayerTable[5][i][2]+10
			if PetGoalXP <= PlayerTable[5][i][2] then
				PlayerTable[5][i][2] = 0
				PlayerTable[5][i][1] = PlayerTable[5][i][1] + 1
				PlayerTable[5][i][3] = PlayerTable[5][i][3]*PlayerTable[5][i][1]
			end ]]
		end
	end

	Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerTable)
	LevelGui.XPBarBackground.TextLabel.Text = "0/"..tostring(GoalXP)
--[[ 	PlayerDataStore:SetAsync(Player,PlayerData.Value) ]]
	GivePet:FireClient(Player,GivePets(Level+1,Player))
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
	PlayerTable[4]={"Rabbit"}
	PlayerTable[5]={{1,0,20}}
	PlayerTable[6]="Rabbit"
	PlayerTable[7]=0
	PlayerTable[8]=1
	PlayerData.Value = Database.Convert(PlayerTable)
	PlayerDataStore:SetAsync(Player,PlayerData.Value)
end)
