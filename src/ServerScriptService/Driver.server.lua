--[[
    Driver script mostly listens for events called by the client
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
ReplicatedStorage = game.ReplicatedStorage
--Events
CameraEvent = ReplicatedStorage.RemoteEvents:WaitForChild("CameraMode")
BackToPlayerCamera = ReplicatedStorage.RemoteEvents:WaitForChild("BackToPlayerCamera")
TriggerPlayerPet = ReplicatedStorage.RemoteEvents:WaitForChild("TriggerPlayerPet")
RemovePetInGame = ReplicatedStorage.RemoteEvents:WaitForChild("RemovePetInGame")
local RewardPrompt = ReplicatedStorage.RemoteEvents:WaitForChild("RewardPrompt")
Data = ReplicatedStorage.RemoteEvents:WaitForChild("Data")
PetConfig = require(script.Parent.PetConfig)
--DeterminePet = PetConfig.DeterminePet
GetAmount = ReplicatedStorage.RemoteFunctions:WaitForChild("GetAmount")
CheckPurchase = ReplicatedStorage.RemoteFunctions:WaitForChild("CheckPurchase")
local Database = require(ReplicatedStorage.Modules.Data)
Players.PlayerAdded:Connect(function(Player)
    local Character = Player.CharacterAdded:Wait() or Player.Character
    --CameraEvent:FireClient(Player,true)
    local PhysicsService = game:GetService("PhysicsService")
    for i,v in pairs(Character:GetChildren()) do
        if v:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(v, "Players")
        end
    end
end)

BackToPlayerCamera.OnServerEvent:Connect(function(Player)
    BackToPlayerCamera:FireClient(Player)
end)

--[[ RunService.Heartbeat:Connect(function()
    if PlayerView.Value == true then
        if 
    end
end *]]

--[[ spawn(function()
    while wait() do
        print(PetConfig.DeterminePet())
    end
end) ]]

TriggerPlayerPet.OnServerEvent:Connect(function(Player,Pet) -- Move to petconfig
    CurrentPets=game.Workspace.PlayerPets:GetChildren()
    print(#CurrentPets)
    for _,v in ipairs(CurrentPets) do
        if string.find(v.Name, Player.Name) then -- string expected got instance
            v:Destroy()
        end
    end

    Pet = ReplicatedStorage.Pets:FindFirstChild(Pet):Clone()
    Pet.Name = Pet.Name.."_"..Player.Name
    Pet.Parent = game.Workspace.PlayerPets
    for i,v in ipairs(Pet:GetChildren()) do
        if v:IsA("UnionOperation") or v:IsA("Union") or v:IsA("Part") then
            v.CanCollide = false
        end
    end

    PetConfig.ThreadPet(Pet,Player)
end)

Data.OnServerEvent:Connect(function(Player,Data) -- Severe security bug, temp patch
    --print("Payload complete")
    Player:WaitForChild("Data").PlayerData.Value = Data
end)

RemovePetInGame.OnServerEvent:Connect(function(Player,PetName)
    local Pet = game.Workspace.PlayerPets:GetChildren()
    for _,v in pairs(Pet) do
        if string.find(v.Name, Player.Name) then
            v:Destroy()
        end
    end
    local JSON = Database.Pull(Player:FindFirstChild("Data"):FindFirstChild("PlayerData").Value)
    CameraEvent:FireClient(Player,true,game.Workspace:WaitForChild("DebugObjects"):WaitForChild(JSON[15].."_EGGPOS"))
end)

GetAmount.OnServerInvoke=function(Player,Level,Data)
    local PlayerData = Database.Pull(Data)
    local PlayerDataString = Player:FindFirstChild("Data").PlayerData
    local increment = 0
    local LevelUp = false
    if #PlayerData[4] > #PlayerData[5] then
        table.insert(PlayerData[5],{1,0,10})
    end
    for i,v in pairs(PlayerData[5]) do
        PlayerData[5][i][2] = PlayerData[5][i][2]+(1/(i/2))
        increment = increment + PlayerData[5][i][1]
        --print("Pet level: "..tostring(PlayerData[5][i][1]))
        if PlayerData[5][i][2] >= PlayerData[5][i][3] then

            RewardPrompt:FireClient(Player,"CoinDisplay",1)
            PlayerData[9] = PlayerData[9] + 1
            PlayerData[5][i][1] = PlayerData[5][i][1]+1
            PlayerData[5][i][2] = 0
            PlayerData[5][i][3] = PlayerData[5][i][1]*20
            LevelUp = true
        end
        if PlayerData[5][i][1] < ReplicatedStorage.Pets:WaitForChild(PlayerData[4][i]):FindFirstChild("StarterPower").Value then
            print("Upgraded pets")
            PlayerData[5][i][1] = ReplicatedStorage.Pets:WaitForChild(PlayerData[4][i]):FindFirstChild("StarterPower").Value
        end
    end
    PlayerData[8] = increment
    local Level = tonumber(PlayerData[3])
    --print(Database.Convert(PlayerData))
    return {increment,Database.Convert(PlayerData),LevelUp}
end

CheckPurchase.OnServerInvoke=function(Player,type,amount,deduction, type2, payload)
    local PlayerData = Database.Pull(Player:FindFirstChild("Data").PlayerData.Value)
    if tonumber(PlayerData[type]) and deduction then
        if PlayerData[type] > amount then
            PlayerData[type] = PlayerData[type] - amount
            if type2 and payload then
                if type2 == 13 then
                    PlayerData[type2][#PlayerData[type2]+1]=payload
                    PlayerData[15] = payload
                end
            end
            Player:FindFirstChild("Data").PlayerData.Value = Database.Convert(PlayerData)
            return true
        else
            return false
        end
    end
end