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
PetConfig = require(script.Parent.PetConfig)
--DeterminePet = PetConfig.DeterminePet
GetAmount = ReplicatedStorage.RemoteFunctions:WaitForChild("GetAmount")
local Database = require(ReplicatedStorage.Modules.Data)
Players.PlayerAdded:Connect(function(Player)
    CameraEvent:FireClient(Player,true)
end)

BackToPlayerCamera.OnServerEvent:Connect(function(Player)
    BackToPlayerCamera:FireClient(Player)
end)

--[[ RunService.Heartbeat:Connect(function()
    if PlayerView.Value == true then
        if 
    end
end *]]

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

RemovePetInGame.OnServerEvent:Connect(function(Player,PetName)
    local Pet = game.Workspace.PlayerPets:GetChildren()
    for _,v in pairs(Pet) do v:Destroy() end
    CameraEvent:FireClient(Player,true)
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
        print("Pet level: "..tostring(PlayerData[5][i][1]))
        if PlayerData[5][i][2] >= PlayerData[5][i][3] then
            PlayerData[5][i][1] = PlayerData[5][i][1]+1
            PlayerData[5][i][2] = 0
            PlayerData[5][i][3] = PlayerData[5][i][1]*20
            LevelUp = true
        end
    end
    PlayerData[8] = increment
    local Level = tonumber(PlayerData[3])
    --print(Database.Convert(PlayerData))
    return {increment,Database.Convert(PlayerData),LevelUp}
end

