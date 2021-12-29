local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local XPDataStore = DataStoreService:GetDataStore("XP")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")
local GoalXPDataStore = DataStoreService:GetDataStore("GoalXP")
local LevelDataStore = DataStoreService:GetDataStore("Level")
local LevelUp = ReplicatedStorage.RemoteEvents:WaitForChild("LevelUp")
local EraseData = ReplicatedStorage.RemoteEvents:WaitForChild("EraseData")
local GivePet = ReplicatedStorage.RemoteEvents:WaitForChild("GivePet")
local RewardPrompt = ReplicatedStorage.RemoteEvents:WaitForChild("RewardPrompt")
local LastDataStoreValue = 14

local PetConfig = require(script.Parent.PetConfig)
Database = require(ReplicatedStorage.Modules.Data)

local StarterDataSet =   {
	[1] = 0, -- XP value
	[2] = 1000, -- Maximum XP value
	[3] = 1, -- level (redundant)
	[4] =  { -- Pets owned (in order)
	   [1] = "Cat"
	},
	[5] =  { -- Pet levels (in order)
	   [1] =  {
		  [1] = 1,
		  [2] = 0,
		  [3] = 20
	   }
	},
	[6] = "Cat", -- Current pet open
	[7] = 0, -- Total clicks
	[8] = 1, -- Per click power
	[9] = 0, -- Coins
	[10] = "", -- Last reward given (Will contain a time/date)
	[11] = "StarterEgg", -- Current egg open
	[12] = 10, -- Gems
	[13] =  { -- List of islands unlocked (Player will default spawn at highest unlocked)
	   [1] =  {
		  [1] = "StarterIsland"
	   }
	},
	[14] =  { -- List of eggs unlocked
	   [1] =  {
		  [1] = "StarterEgg"
	   }
	},
	[15] = "StarterIsland" -- Current map open
 }

function UpdateDataStore(PlayerDataJSON)
	for i = 1, #StarterDataSet do
		if not PlayerDataJSON[i] then
			print("Filling in data: "..tostring(StarterDataSet[i]))
			PlayerDataJSON[i] = StarterDataSet[i]
		end
	end
	return PlayerDataJSON
end

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
	CurrentEgg.Value = "Cat"

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


--[[ 	table.insert(DataTable,0)
	table.insert(DataTable,ReplicatedStorage.Eggs:FindFirstChild("StarterEgg"):FindFirstChild("Difficulty").Value)
	table.insert(DataTable,1)
	table.insert(DataTable,{"Cat"})
	table.insert(DataTable,{{1,0,20}})
	table.insert(DataTable,"Cat")
	table.insert(DataTable,0)
	table.insert(DataTable,1)
	table.insert(DataTable,0)
	table.insert(DataTable,"") -- last reward time
	table.insert(DataTable,"StarterEgg") -- Current egg
	table.insert(DataTable,10) -- Gems
	table.insert(DataTable,{{"StarterIsland"}}) -- islands unlocked
	table.insert(DataTable,{{"StarterEgg"}}) -- eggs unlocked ]]

	local PlayerData = Instance.new("StringValue", Data)
	PlayerData.Name = "PlayerData"
	PlayerData.Value = Database.Convert(StarterDataSet)

	local success, PlayerDataStore = pcall(function()
		return PlayerDataStore:GetAsync(Player)
	end)

	if success and PlayerDataStore ~= nil then
		print("Loading player data for: "..Player.Name)
		print("Player datastore contains "..tostring(#Database.Pull(PlayerDataStore)).." values")
		if #Database.Pull(PlayerDataStore) == #StarterDataSet then
			--PlayerDataStore=Database.Convert(PlayerDataStore)
			PlayerData.Value = PlayerDataStore
			print(Database.Pull(PlayerDataStore))
		elseif #Database.Pull(PlayerDataStore) < #StarterDataSet then
			print(Player.Name.." needs Datastore update, fixing...")
			PlayerData.Value = Database.Convert(UpdateDataStore(Database.Pull(PlayerDataStore)))
		else
			print(Player.Name.." has the following data: "..tostring(PlayerData.Value))
			print(Player.Name.." has a Datastore corruption, wiping...")
			PlayerData.Value = Database.Convert(StarterDataSet)
		end
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

	local NumberOfCoinsEarned = math. floor(math.random()*10+5 + 0.5)
	local NumberOfGemsEarned = (1 or 0)

	PlayerTable[1]=0
	PlayerTable[2]=ReplicatedStorage.Eggs:FindFirstChild(PlayerTable[11]):FindFirstChild("Difficulty").Value --(GoalXP*Level)
	PlayerTable[3]=Level+1

	PlayerTable[9] = PlayerTable[9] + NumberOfCoinsEarned
	PlayerTable[12] = PlayerTable[12] + NumberOfGemsEarned
	
	RewardPrompt:FireClient(Player,"CoinDisplay",NumberOfCoinsEarned)
	RewardPrompt:FireClient(Player,"GemDisplay",NumberOfGemsEarned)

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
--[[ 	PlayerTable[3]=1
	PlayerTable[1]=0
	PlayerTable[2]=ReplicatedStorage.Eggs:FindFirstChild("StarterEgg"):FindFirstChild("Difficulty").Value
	PlayerTable[4]={"Cat"}
	PlayerTable[5]={{1,0,20}}
	PlayerTable[6]="Cat"
	PlayerTable[7]=0
	PlayerTable[8]=1
	PlayerTable[9]=0
	PlayerTable[10]=""
	PlayerTable[11]="StarterEgg"
	PlayerTable[12]=10
	PlayerTable[13]={{"StarterIsland"}}
	PlayerTable[14]={{"StarterEgg"}}PlayerTable ]]
	PlayerData.Value = Database.Convert(StarterDataSet)
	PlayerDataStore:SetAsync(Player,PlayerData.Value)
end)
