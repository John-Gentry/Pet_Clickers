local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
ReplicatedStorage = game.ReplicatedStorage
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

TriggerPlayerPet.OnServerEvent:Connect(function(Player,Pet)
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
    local Pet = game.Workspace.PlayerPets:FindFirstChild(PetName)
    Pet:Destroy()
    CameraEvent:FireClient(Player,true)
end)

GetAmount.OnServerInvoke=function(Player,Level)
    local PlayerData = Database.Pull(Player:FindFirstChild("Data"):WaitForChild("PlayerData").Value)
    local Level = tonumber(PlayerData[3])
    
    local Amount = tonumber(Level)*1.2

    return Amount
end

