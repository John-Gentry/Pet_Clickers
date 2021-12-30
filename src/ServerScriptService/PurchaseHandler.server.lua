local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProductPurchase = ReplicatedStorage.RemoteEvents:WaitForChild("ProductPurchase")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")


local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local Database = require(ReplicatedStorage.Modules.Data)

--[[ ProductPurchase ]]

ProductList = {
	[1] = 1231214711,
	[2] = 1231214864,
	[3] = 1231214865,
	[4] = 1231215065,
	[5] = 1231215064,
	[6] = 1231215063
}

ProductPurchase.OnServerEvent:Connect(function(Player,ProductID)
	MarketplaceService:PromptProductPurchase(Player, ProductID)
end)


 
-- Data store for tracking purchases that were successfully processed

 

local productFunctions = {}

productFunctions[1231214711] = function(receipt, Player)
    local PlayerData = Database.Pull(Player:WaitForChild("Data"):WaitForChild("PlayerData").Value)
    PlayerData[9] = PlayerData[9] + 100
    Player:WaitForChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerData)
    return true
end

productFunctions[1231214864] = function(receipt, Player)
    local PlayerData = Database.Pull(Player:WaitForChild("Data"):WaitForChild("PlayerData").Value)
    PlayerData[9] = PlayerData[9] + 300
    Player:WaitForChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerData)
    return true
end

productFunctions[1231214865] = function(receipt, Player)
    local PlayerData = Database.Pull(Player:WaitForChild("Data"):WaitForChild("PlayerData").Value)
    PlayerData[9] = PlayerData[9] + 1000
    Player:WaitForChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerData)
    return true
end

productFunctions[1231215065] = function(receipt, Player)
    local PlayerData = Database.Pull(Player:WaitForChild("Data"):WaitForChild("PlayerData").Value)
    PlayerData[12] = PlayerData[12] + 100
    Player:WaitForChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerData)
    return true
end

productFunctions[1231215064] = function(receipt, Player)
    local PlayerData = Database.Pull(Player:WaitForChild("Data"):WaitForChild("PlayerData").Value)
    PlayerData[12] = PlayerData[12] + 300
    Player:WaitForChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerData)
    return true
end

productFunctions[1231215063] = function(receipt, Player)
    local PlayerData = Database.Pull(Player:WaitForChild("Data"):WaitForChild("PlayerData").Value)
    PlayerData[12] = PlayerData[12] + 500
    Player:WaitForChild("Data"):WaitForChild("PlayerData").Value = Database.Convert(PlayerData)
    return true
end

 
-- The core 'ProcessReceipt' callback function
local function processReceipt(receiptInfo)
 
	-- Determine if the product was already granted by checking the data store  
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end
 
	-- Find the player who made the purchase in the server
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Look up handler function from 'productFunctions' table above
	local handler = productFunctions[receiptInfo.ProductId]
 
	-- Call the handler function and catch any errors
	local success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
 
	-- Record transaction in data store so it isn't granted again
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end
 
	-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
 
-- Set the callback; this can only be done once by one script on the server! 
MarketplaceService.ProcessReceipt = processReceipt